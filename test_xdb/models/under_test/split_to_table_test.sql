with test_cte as (
    select 'Lorem ipsum dolor sit amet,' as text_field
    
    union all
    
    select 'ad augue eget.' as text_field
    
    union all

    select 'Dictumst blandit semper arcu,' as text_field
)

SELECT {{ xdb.split_to_table_values("temp") }} as value_field
from test_cte
, {{ xdb.split_to_table("test_cte.text_field", ' ' ) }} temp


