
# XDB Available Macros

These macros carry functionality across **Snowflake**, **Postgresql**, **Redshift** and **BigQuery** unless otherwise noted. 


### [cast_timestamp](../macros/cast_timestamp.sql)
**xdb.cast_timestamp** (**val** _identifier/date/timestamp_, **cast_as** _string_)

converts `val` to either a timestamp with timezone or a timestamp without timezone (per `cast_as`).

- val the value to be cast.
- cast_as the destination data type, supported are `timestamp_tz` and `timestamp(_ntz)`

**Returns**:         The value typed as either timestamp or timestamp_ntz **with UTC time zone**
    

### [using](../macros/using.sql)
**xdb.using** (**rel_1** _None_, **rel_2** _None_, **col** _None_)




**Returns**: 
### [regex_string_escape](../macros/regexp.sql)
**xdb.regex_string_escape** (**string** _None_)




**Returns**: 
### [regexp](../macros/regexp.sql)
**xdb.regexp** (**val** _None_, **pattern** _None_, **flag** _None_)




**Returns**: 
### [datediff](../macros/datediff.sql)
**xdb.datediff** (**part** _string_, **left_val** _date/timestamp_, **right_val** _date/timestamp_, **date_format** _pattern_)

determines the delta (in `part` units) between first_val and second_val.
       *Note* the order of left_val, right_val is reversed from Snowflake.

- part one of 'day', 'week', 'month', 'year', 'quarter'
- left_val the value before the minus in the equation "left - right"
- right_val the value after the minus in the equation "left - right"
- date_format a string pattern for the provided arguments (primarily for BigQuery)

**Returns**:         An integer representing the delta in `part` units
    

### [any_value](../macros/any_value.sql)
**xdb.any_value** (**val** _None_)




**Returns**: 
### [aggregate_strings](../macros/aggregate_strings.sql)
**xdb.aggregate_strings** (**val** _None_, **delim** _None_)




**Returns**: 