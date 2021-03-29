from macrodocs import macrodocs

## build the docs 
header = """
# XDB Available Macros

These macros carry functionality across **Snowflake** and **Postgresql**, and most also support **BigQuery**. Individual support listed below.

"""
macrodocs('/dbt-xdb/macros',
          '/dbt-xdb/docs/macros.md',
          header,
          'xdb')
