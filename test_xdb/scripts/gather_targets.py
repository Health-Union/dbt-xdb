import yaml
from test_setup import prepare_postgres_db

def gather_targets(specified_targets=list()):
    with open('./profiles.yml','r') as f:
        profile = yaml.safe_load(f.read())

    if 'postgres' in specified_targets or len(specified_targets) == 0:
        prepare_postgres_db(profile['default']['outputs']['postgres'])
    return specified_targets if specified_targets else profile['default']['outputs']
