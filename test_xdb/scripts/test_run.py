import subprocess
import sys
from macrodocs import macrodocs
from gather_targets import gather_targets

targets = gather_targets(sys.argv[1:])
success = 0

for target in targets:
    print(f"\n\n~~~~~~~~~~~~~~~~~~ {target} ~~~~~~~~~~~~~~~~~~\n\n")
    success += subprocess.call(['dbt','clean', '--profiles-dir','.'])
    success += subprocess.call(['dbt','deps',  '--profiles-dir','.'])
    ## this gnarly mess handles dbt's compile behavior, which is to compile everything including the excluded models. 
    success += subprocess.call(['dbt','run' ,  
                                '--profiles-dir','.',
                                '--target', target, 
                                '--exclude', f'tag:exclude_{target}', 
                                '--vars', '{"xdb_allow_unsupported_macros":true}'])
    success += subprocess.call(['dbt','test', 
                                '--profiles-dir','.',
                                '--target', target, 
                                '--exclude', f'tag:exclude_{target}', f'tag:exclude_{target}_tests',
                                '--vars', '{"xdb_allow_unsupported_macros":true}'])
    print("\n\nTest unsupported macros throw compilation error...")
    ## test that excluded models throw a compilation error
    exceptions_text = subprocess.Popen(['dbt','run', 
                                        '--profiles-dir','.',
                                        '--target', target, 
                                        '--models', f'tag:exclude_{target}'], 
                                        stdout=subprocess.PIPE, 
                                        stderr=subprocess.PIPE)
    out, _ = exceptions_text.communicate()
    
    passed = bool(sum([val in out for val in (b'Compilation Error', b'WARNING: Nothing to do',)]))
    
    print("\033[0;32mError(s) correctly thrown\033[0m" if passed else "\033[0;31mExpected error not thrown!\033[0m") 
    success += int(not passed)

## build the docs once everything passes
if success < 1:
    header = """
# XDB Available Macros

These macros carry functionality across **Snowflake**, **Postgresql**, **Redshift** and **BigQuery** unless otherwise noted. 

"""
    macrodocs('/dbt-xdb/macros',
              '/dbt-xdb/docs/macros.md',
              header,
              'xdb')
