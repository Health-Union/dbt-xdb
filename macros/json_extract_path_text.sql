{%- macro json_extract_path_text(column, path_vals) -%}
  {#/*
    Extracts the value at `path_vals` from the json typed `column` (or expression)

    Note that in some DBs, the context is used for extraction:
      - Postgres: `'0'` will indicate the key `"0"` or `[0]` (first array item) based on the object it is requested of.
       ARGS:
         - `column` (string) the column name (or expression) to extract the values from
         - `path_vals` (list[string/int]) the path to the desired value. 
           The list can be a combination of strings and integers. In general, integers will be treated as json array indexing unless they are typed as strings (e.g. `'0'` instead of `0`)

       RETURNS: (varchar) The value as a string at the given path in the json or `NULL` if the path does not exist
       SUPPORTS:
            - Postgres
            - Snowflake
  */#}
  {%- if target.type == 'postgres' -%}
    {%- set expr = namespace(value="json_extract_path_text(" ~ column ~ ", ") -%}
    {%- for val in path_vals -%}
      {%- set expr.value = expr.value ~ "'" ~ val ~ "'" -%}
      {%- if not loop.last -%}
        {%- set expr.value = expr.value ~ ", " -%}
      {%- endif -%}
    {%- endfor -%}
    {%- set expr.value = expr.value ~ ")" -%}
  {%- elif target.type == 'snowflake' -%}
    {%- set expr = namespace(value="json_extract_path_text(" ~ column ~ ", '") -%}
    {%- for val in path_vals -%}
      {%- if val is integer -%}
        {%- set append_val = val -%}
        {%- set expr.value = expr.value ~ '[' ~ append_val ~ ']' -%}
      {%- else -%}
        {%- if not loop.first -%}
          {# no . for first item #}
          {%- set expr.value = expr.value ~ '."' ~ val ~ '"' -%}
        {%- else -%}
          {%- set expr.value = expr.value ~ '"' ~ val ~ '"' -%}
        {%- endif -%}
      {%- endif -%}
    {%- endfor -%}
    {%- set expr.value = expr.value ~ "')" -%}
  {%- else -%}
    {%- set expr = namespace(value='') -%}
    {{ xdb.not_supported_exception('json_extract_path_text') }}
  {%- endif -%}
  {{ return(expr.value) }}
{%- endmacro -%}