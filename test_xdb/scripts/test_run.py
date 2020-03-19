import yaml
import subprocess
import re
import os
from macrodocs import macrodocs


## run tests
with open('./profiles.yml','r') as f:
    profile = yaml.safe_load(f.read())
success = 0
for target in profile['default']['outputs']:
    print(f"\n\n~~~~~~~~~~~~~~~~~~ {target} ~~~~~~~~~~~~~~~~~~\n\n")
    success += subprocess.call(['dbt','deps'])
    success += subprocess.call(['dbt','run', '--profiles-dir','.','--target', target])
    success += subprocess.call(['dbt','test', '--profiles-dir','.','--target', target])


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
