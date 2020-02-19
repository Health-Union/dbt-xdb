import yaml
import subprocess

with open('./profiles.yml','r') as f:
    profile = yaml.safe_load(f.read())
    
for target in profile['default']['outputs']:
    subprocess.call(['dbt','run', '--profiles-dir','.','--target', target])
    subprocess.call(['dbt','test', '--profiles-dir','.','--target', target])
    
