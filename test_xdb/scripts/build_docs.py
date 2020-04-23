from macrodocs import macrodocs

## build the docs 
header = """
# XDB Available Macros

These macros carry functionality across **Snowflake**, **Postgresql**, **Redshift** and **BigQuery** unless otherwise noted. 

"""
macrodocs('/dbt-xdb/macros',
          '/dbt-xdb/docs/macros.md',
          header,
          'xdb')
