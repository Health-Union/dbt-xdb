import subprocess
import sys
from gather_targets import gather_targets

targets = gather_targets(sys.argv[1:])
success = 0
failed_targets = list()
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
    
    passed = bool(sum([val in out for val in (b'Compilation Error', b'[WARNING]: Nothing to do',)]))
    
    print("\033[0;32mAnticipated error(s) correctly thrown, exceptions pass.\033[0m" if passed else "\033[0;31mExpected error not thrown!\033[0m") 
    success += int(not passed)

    ## test that clone_schema() macro throws a compilation errors
    exceptions_clone_schema = subprocess.Popen(['dbt','run-operation','clone_schema',
                                                '--args "{schema_one: XDB_TEST.STAGE, schema_two: XDB_TEST.STAGE}"',
                                                '--profiles-dir','.',
                                                '--target', target], 
                                                stdout=subprocess.PIPE, 
                                                stderr=subprocess.PIPE)
    out, _ = exceptions_text.communicate()
    if target == 'postgres':
        passed = bool(sum([val in out for val in (b'Compilation Error', b'The `schema_one` and `schema_two` must not include a database name for the Postgres DB adapter.',)]))
    if target == 'snowflake':
        passed = bool(sum([val in out for val in (b'Compilation Error', b'The `schema_one` and `schema_two` must be a different schemas!',)]))

    print("\033[0;32mAnticipated error by clone_schema() macro correctly thrown, exceptions pass.\033[0m" if passed else "\033[0;31mExpected error clone_schema() macro is not thrown!\033[0m") 
    success += int(not passed)

    if success != 0:
        failed_targets.append(target)

print(f"\n\033[0;32m All builds and tests successful! Tested against {','.join(targets)}.\033[0m\n" if success == 0 else 
      f"\n\033[0;31m Builds and/or tests failed :(. Tested against {','.join(failed_targets)}\033[0m\n")
sys.exit(success)
