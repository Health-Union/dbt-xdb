SELECT
{%- if target.type == "postgres" -%}
    {{ xdb.fold("'PostGres'") }} AS folded_value
{%- elif target.type == "bigquery" -%}
    {{ xdb.fold("'BiGQuery'") }} AS folded_value
{%- elif target.type == "snowflake" %}
    {{ xdb.fold("'SnowFlake'") }} AS folded_value
{% endif -%}
