import yaml
import subprocess
import re
import os
import json
from macrodocs import macrodocs
import sys

## run tests
with open('./profiles.yml','r') as f:
    profile = yaml.safe_load(f.read())
success = 0

targets = sys.argv[1:] if len(sys.argv[1:]) > 0 else profile['default']['outputs']

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
                                '--exclude', f'tag:exclude_{target}',
                                '--vars', '{"xdb_allow_unsupported_macros":true}'])
    ## test that excluded models throw a compilation error
    exceptions_text = subprocess.Popen(['dbt','run', 
                                        '--profiles-dir','.',
                                        '--target', target, 
                                        '--models', f'tag:exclude_{target}'], 
                                        stdout=subprocess.PIPE, 
                                        stderr=subprocess.PIPE)
    out, _ = exceptions_text.communicate()
    
    success += int(not bool(sum([val in out for val in (b'Compilation Error', b'WARNING: Nothing to do',)])))

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
