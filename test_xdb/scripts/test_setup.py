import yaml
import subprocess
from sqlalchemy import create_engine

with open('./profiles.yml','r') as f:
    profile = yaml.safe_load(f.read())
    
for target in profile['default']['outputs']:
    subprocess.call(['dbt','seed', '--profiles-dir','.','--target', target])


def prepare_postgres_db(profile: dict):
    """ Prepares the target postgres db for testing

        Args:
            - profile (dict): The loaded postgres yaml block from profiles.yml
    """
    user = profile['user']
    password = profile['pass']
    host = profile['host']
    port = profile['port']
    db = profile['dbname']
    engine = create_engine(f"postgresql://{user}:{password}@{host}:{port}/{db}")
    with engine.connect() as conn:
        # install uuid-ossp for generating uuid fields
        conn.execute('create extension if not exists "uuid-ossp"')
    engine.dispose()
