import yaml
import subprocess


## run tests
with open('./profiles.yml','r') as f:
    profile = yaml.safe_load(f.read())
    
for target in profile['default']['outputs']:
    print(f"\n\n~~~~~~~~~~~~~~~~~~ {target} ~~~~~~~~~~~~~~~~~~\n\n")
    subprocess.call(['dbt','deps'])
    subprocess.call(['dbt','run', '--profiles-dir','.','--target', target])
    subprocess.call(['dbt','test', '--profiles-dir','.','--target', target])
    
