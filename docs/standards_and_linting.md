## Standards and Linting

Having standards makes for better code (it's a fact). XDB has a rich set of guidelines for contribution to help make things easier for developers.

***Remember***: convention makes things easy if you go with it, hard if you fight it. Go with it. 

### Terminology
- _Public Macros_ are macros that are intended for use as part of the XDB api. All the macros we create and document in XDB for use elsewhere are public macros.
- _Private Macros_ are macros that behave as internal functions within a module (macro file) or a public macro. These are not intended for use outside of XDB. 

### Naming Macros
- use only lowercase names. 
- public macros should use the SQL spec naming whenever possible.
- private macros start with an underscore. 
- private macros that are intended to be internal to a public macro are namespaced to that public macro. For example:
```
{%- macro aggregate_all_the_things() -%}
    {%- for thing in all_the things -%}
        {{ _aggregate_one_thing() }}
    {%- endfor -%}
{%- endmacro -%}

{%- macro _aggregate_one_thing() -%}
    ...
{%- endmacro -%}
```

### Heredocs
Macros intended for public use need documentation. XDB uses traditional python docstrings using a combination of comment wrappers like this:

```
{%- macro sweep_the_leg(leg, speed='fast') -%}
    /*{# Initiates a leg sweep.
        ARGS:
            - leg (string): one of "left" or "right"
            - speed (string): one of "fast" or "slow". Default "fast".
        RETURNS: the result of the leg sweeping.
    #}*/
```
***Note***: docs are **required** for all public macros. 

### Data Warehouse Support
It is important you call out explicitly each data warehouse you support via an `if` loop through the supported targets. At the end of the supported targets must be an else condition that calls the `not_supported_exception()` macro. This ensures that every database we _claim_ to support we can test and be sure we _actually_ support - and the docs can reflect that. Example: 
```
...
{%- if target.type in ('bigquery','snowflake',) -%}
    -- do things 
{%- elif target.type == 'postgres' -%}
    -- other things
{%- else -%}
    {{not_supported_exception('macro_name')}}
{%- endif -%}
```