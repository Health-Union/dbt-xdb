
# XDB Available Macros

These macros carry functionality across **Snowflake**, **Postgresql**, **Redshift** and **BigQuery** unless otherwise noted. 


### [_concat_cast_fields](../macros/concat.sql)
**xdb._concat_cast_fields** (**fields** _None_)




**Returns**: 
### [_concat_separator_text](../macros/concat.sql)
**xdb._concat_separator_text** (**separator** _None_)




**Returns**: 
### [hash](../macros/hash.sql)
**xdb.hash** (**fields** _list_)



- fields one of field names to hash together

**Returns**:          A string representing hash of `fields`
    */

### [regexp_replace](../macros/regexp.sql)
**xdb.regexp_replace** (**val** _string/column_, **pattern** _string_, **replace** _string_)



- val the value to search for `pattern`.
- pattern the native regex pattern to search for.
- replace the string to insert in place of `pattern`.

**Returns**:      the updated string. 
  */

### [_not_supported_exception](../macros/not_supported_exception.sql)
**xdb._not_supported_exception** (**_name** _None_)



- macro_name : the name of the macro throwing the exception.

**Returns**:          None
    */

### [_regex_string_escape](../macros/regexp.sql)
**xdb._regex_string_escape** (**pattern** _string_)

applies the weird escape sequences required for bigquery and snowflake

- pattern the regex pattern to be escaped

**Returns**:         A properly escaped regex string
    

### [aggregate_strings](../macros/aggregate_strings.sql)
**xdb.aggregate_strings** (**val** _None_, **delim** _None_)




**Returns**: 
### [any_value](../macros/any_value.sql)
**xdb.any_value** (**val** _None_)




**Returns**: 
### [cast_timestamp](../macros/cast_timestamp.sql)
**xdb.cast_timestamp** (**val** _identifier/date/timestamp_, **cast_as** _string_)

converts `val` to either a timestamp with timezone or a timestamp without timezone (per `cast_as`).

- val the value to be cast.
- cast_as the destination data type, supported are `timestamp_tz` and `timestamp(_ntz)`

**Returns**:         The value typed as either timestamp or timestamp_ntz **with UTC time zone**
    

### [dateadd](../macros/dateadd.sql)
**xdb.dateadd** (**part** _string_, **amount_to_add** _int_, **value** _string_)

adds `amount_to_add` `part`s to `value`. so adding one day to Jan 1 2020 would be dateadd('day',1,'2020-01-01'). 
       NOTE: dateadd only manipulates date values. for time additions see [timeadd](#timeadd)

- part one of 'day','week','month','year'.
- amount_to_add number of `part` units to add to `value`. Negative subtracts.
- value the date string or column to add to.

**Returns**:         a date value with the amount added.
    

### [datediff](../macros/datediff.sql)
**xdb.datediff** (**part** _string_, **left_val** _date/timestamp_, **right_val** _date/timestamp_, **date_format** _pattern_)

determines the delta (in `part` units) between first_val and second_val.
       *Note* the order of left_val, right_val is reversed from Snowflake.

- part one of 'second', 'minute', 'hour', 'day', 'week', 'month', 'year', 'quarter'
- left_val the value before the minus in the equation "left - right"
- right_val the value after the minus in the equation "left - right"
- date_format a string pattern for the provided arguments (primarily for BigQuery)

**Returns**:         An integer representing the delta in `part` units
    

### [interval_to_timestamp](../macros/interval_to_timestamp.sql)
**xdb.interval_to_timestamp** (**part** _string_, **val** _integer representing a unit of time_)

converts and interval `val` to a timestamp
       *Note* the order of left_val, right_val is reversed from Snowflake.

- part one of 'second', 'minute'
- val the value

**Returns**:         A string representing the time in HH24:MM:SS format
    

### [not_supported_exception](../macros/not_supported_exception.sql)
**xdb.not_supported_exception** (**_name** _None_)




**Returns**: 
### [quote_insensitive](../macros/quote_insensitive.sql)
**xdb.quote_insensitive** (**identifier** _string_)

Correctly quotes identifers to match the native folding for the target data warehouse.
       Per the SQL spec this _should_ be to uppercase, but this is not always the standard.

- identifier the column / database / relation name to be folded and quoted.

**Returns**:         The `identifier` value correctly folded **and wrapped in double quotes**.
    

### [regexp](../macros/regexp.sql)
**xdb.regexp** (**val** _None_, **pattern** _None_, **flag** _None_)




**Returns**: 
### [regexp_count](../macros/regexp.sql)
**xdb.regexp_count** (**value** _string_, **pattern** _string_)

counts how many instances of `pattern` in `value`

- value the subject to be searched
- pattern the regex pattern to search for

**Returns**:         An integer count of patterns in value
    

### [strip_to_single_line](../macros/strip_to_single_line.sql)
**xdb.strip_to_single_line** (**str** _None_)




**Returns**: 
### [test_does_not_contain](../macros/test_does_not_contain.sql)
**xdb.test_does_not_contain** (**model** _None_, **substring** _None_, **column_name** _None_)




**Returns**: 
### [using](../macros/using.sql)
**xdb.using** (**rel_1** _None_, **rel_2** _None_, **col** _None_)




**Returns**: 