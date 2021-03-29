{%- macro _not_supported_exception(macro_name) -%} {# no_coverage #}
    {# Throws an exception unless the global `xdb_allow_unsupported_macros` isTrue.
        ARGS:
         - macro_name (string): the name of the macro throwing the exception.
        RETURNS: None
        SUPPORTS:
            - All
    #}
    {%- if not var("xdb_allow_unsupported_macros", False) -%}
	    {{exceptions.raise_compiler_error("macro " ~ macro_name ~ " is not supported for target " ~ target.type ~ ".")}}
    {%- else -%}
        -- unsupported macro {{macro_name}} ignored.
    {%- endif -%}
{%- endmacro -%}  

{%- macro not_supported_exception(macro_name) -%} {# no_coverage #}
    {# Wraps `_not_supported_exception` macro
        ARGS:
         - macro_name (string): the name of the macro throwing the exception.
        RETURNS: None
        SUPPORTS:
            - All
    #}
    {{xdb.strip_to_single_line(xdb._not_supported_exception(macro_name))}}
{%- endmacro -%}
