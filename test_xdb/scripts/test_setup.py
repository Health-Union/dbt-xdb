import yaml
import subprocess

with open('./profiles.yml','r') as f:
    profile = yaml.safe_load(f.read())
    
for target in profile['default']['outputs']:
    subprocess.call(['dbt','seed', '--profiles-dir','.','--target', target])
