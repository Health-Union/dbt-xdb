{{ config({"tags":["exclude_bigquery", "exclude_bigquery_tests"]}) }}

with uuids as (
    select {{xdb.generate_uuid()}} as uuid_varchar
    union all
    select {{xdb.generate_uuid()}} as uuid_varchar
    union all
    select {{xdb.generate_uuid()}} as uuid_varchar
    union all
    select {{xdb.generate_uuid()}} as uuid_varchar
    union all
    select {{xdb.generate_uuid()}} as uuid_varchar
    union all
    select {{xdb.generate_uuid()}} as uuid_varchar
    union all
    select {{xdb.generate_uuid()}} as uuid_varchar
    union all
    select {{xdb.generate_uuid()}} as uuid_varchar
    union all
    select {{xdb.generate_uuid()}} as uuid_varchar
)

select
    uuid_varchar,
    length(replace(uuid_varchar, '-', '')) as uuid_length,
    regexp_replace(uuid_varchar, '[0-9A-Fa-f]{8}(-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12}', '00000000-0000-0000-0000-000000000000') as uuid_regex
from uuids