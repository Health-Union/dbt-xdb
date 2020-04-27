import yaml

def gather_targets(specified_targets=list()):
    with open('./profiles.yml','r') as f:
        profile = yaml.safe_load(f.read())
    return specified_targets if specified_targets else profile['default']['outputs']
