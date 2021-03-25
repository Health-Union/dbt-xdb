import yaml
import subprocess
from sqlalchemy import create_engine

with open('./profiles.yml','r') as f:
    profile = yaml.safe_load(f.read())
    
for target in profile['default']['outputs']:
    subprocess.call(['dbt','seed', '--profiles-dir','.','--target', target])


def prepare_postgres_db(profile: dict):
    user = profile['user']
    password = profile['pass']
    host = profile['host']
    port = profile['port']
    db = profile['dbname']
    engine = create_engine(f"postgresql://{user}:{password}@{host}:{port}/{db}")
    with engine.connect() as conn:
        conn.execute('create extension if not exists "uuid-ossp"')
    engine.dispose()
