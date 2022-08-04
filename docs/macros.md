
# XDB Available Macros

These macros carry functionality across **Snowflake** and **Postgresql**, and most also support **BigQuery**. Individual support listed below.


### [env_generate_schema_name](../macros/env_generate_schema_name.sql)
**xdb.env_generate_schema_name** (**custom_schema_name** _string_, **branch_name** _string_, **default_schema** _string_)

/* Used in conjunction with generate_schema_name, this macro returns a schema name
        based on the cusrrent working environment

- custom_schema_name The configured value of schema in the specified node, or none if a value is not supplied
- branch_name The current branch name
- default_schema The default schema name e.g. target.schema

**Returns**:         A schema name.

##### Supports: _Postgres, Snowflake_
----
### [hash](../macros/hash.sql)
**xdb.hash** (**fields** _list_)

/* takes a list of values to hash, coerces them to strings and hashes them.
        *Note* the fields will be sorted by name and concatenated as strings with a default '-' separator.

- fields one of field names to hash together

**Returns**:          A string representing hash of `fields`

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [_concat_cast_fields](../macros/concat.sql)
**xdb._concat_cast_fields** (**fields** _None_, **convert_null** _None_)

/*


**Returns**: 
##### Supports: _Postgres, Snowflake, BigQuery_
----
### [_concat_separator_text](../macros/concat.sql)
**xdb._concat_separator_text** (**separator** _None_)

/*


**Returns**: 
##### Supports: _All_
----
### [_fold](../macros/fold.sql)
**xdb._fold** (**val** _string_)

-/* folds a value per the target adapter default.

- val : the value to be folded.

**Returns**:      `val` either upper or lowercase (or unfolded), per the target adapter spec.

##### Supports: _Postgres, Snowflake, BigQuery, _
----
### [_normalize_schema](../macros/env_generate_schema_name.sql)
**xdb._normalize_schema** (**branch_name** _None_)




**Returns**: 
##### Supports: __
----
### [_not_supported_exception](../macros/not_supported_exception.sql)
**xdb._not_supported_exception** (**_name** _None_)

Throws an exception unless the global `xdb_allow_unsupported_macros` isTrue.

- macro_name : the name of the macro throwing the exception.

**Returns**:          None

##### Supports: _All_
----
### [_regex_string_escape](../macros/regexp.sql)
**xdb._regex_string_escape** (**pattern** _string_)

/* applies the weird escape sequences required for bigquery and snowflake

- pattern the regex pattern to be escaped

**Returns**:         A properly escaped regex string

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [aggregate_strings](../macros/aggregate_strings.sql)
**xdb.aggregate_strings** (**val** _None_, **delim** _None_)

/*


**Returns**: 
##### Supports: _Postgres, Snowflake, BigQuery_
----
### [any_value](../macros/any_value.sql)
**xdb.any_value** (**val** _None_)

/*


**Returns**: 
##### Supports: _Postgres, Snowflake, BigQuery, Redshift_
----
### [array_contains](../macros/array_contains.sql)
**xdb.array_contains** (**array_values** _array_, **contained_value** _string_)

This macro is used to determine if an array contains a certain value

- array_values the array to check for the value
- contained_value the value to check the array for

**Returns**:          The appropriate sql syntax needed to check if the array contains the value

##### Supports: _Postgres, Snowflake_
----
### [array_index](../macros/array_index.sql)
**xdb.array_index** (**index** _None_)

/* This macro takes a number and adjusts the index based on programming language. We use 0
        index because we're rational human beings

- Index the 0 based index to convert

**Returns**:          The right position for the right database

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [cast_json](../macros/cast_json.sql)
**xdb.cast_json** (**val** _string_)

converts `val` to the basic json type in the target database

- val : the value to be cast/parsed

**Returns**:         The value typed as json

##### Supports: _Postgres, Snowflake_
----
### [cast_timestamp](../macros/cast_timestamp.sql)
**xdb.cast_timestamp** (**val** _identifier/date/timestamp_, **cast_as** _string_)

/* converts `val` to either a timestamp with timezone or a timestamp without timezone (per `cast_as`).

- val the value to be cast.
- cast_as the destination data type, supported are `timestamp_tz` and `timestamp(_ntz)`

**Returns**:         The value typed as either timestamp or timestamp_ntz **with UTC time zone**

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [concat](../macros/concat.sql)
**xdb.concat** (**fields** _list_, **separator** _string_, **convert_null** _None_)

/* takes a list of column names to concatenate and an optional separator

- fields one of field names to hash together
- separator a string value to separate field values with. defaults to an empty space
- null_representation defines how NULL values are passed to the target. Default is the string 'NULL'.

**Returns**:      A string representing hash of given comments

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [date_part_day_of_week](../macros/date_part_day_of_week.sql)
**xdb.date_part_day_of_week** (**val** _identifier/date/timestamp_)

/* ports DATE_PART's day of week functionality for `val`.

- val the value from where to extract the number indicating the day of the week.

**Returns**:         The integer indicating the day of week (0 for Sunday).

##### Supports: _Postgres, Snowflake_
----
### [dateadd](../macros/dateadd.sql)
**xdb.dateadd** (**part** _string_, **amount_to_add** _int_, **value** _string_)

/* adds `amount_to_add` `part`s to `value`. so adding one day to Jan 1 2020 would be dateadd('day',1,'2020-01-01').
       NOTE: dateadd only manipulates date values. for time additions see [timeadd](#timeadd)

- part one of 'day','week','month','year'.
- amount_to_add number of `part` units to add to `value`. Negative subtracts.
- value the date string or column to add to.

**Returns**:         a date value with the amount added.

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [datediff](../macros/datediff.sql)
**xdb.datediff** (**part** _string_, **left_val** _date/timestamp_, **right_val** _date/timestamp_, **date_format** _pattern_)

/* determines the delta (in `part` units) between first_val and second_val.
       *Note* the order of left_val, right_val is reversed from Snowflake.

- part one of 'second', 'minute', 'hour', 'day', 'week', 'month', 'year', 'quarter'
- left_val the value before the minus in the equation "left - right"
- right_val the value after the minus in the equation "left - right"
- date_format a string pattern for the provided arguments (primarily for BigQuery)

**Returns**:         An integer representing the delta in `part` units

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [fold](../macros/fold.sql)
**xdb.fold** (**val** _None_)

-/*


**Returns**: 
##### Supports: _Postgres, Snowflake, BigQuery, _
----
### [generate_daily_time_series_from](../macros/generate_daily_time_series_from.sql)
**xdb.generate_daily_time_series_from** (**start_date** _date_, **stop_date** _date_)

/* Used in conjunction with generate_time_series_values, this macro returns a time series
        of values based on the start_date and stop_date in 1 day increments

- start_date the start date of the series
- stop_date the ending date of the series
  - 

**Returns**:         A new column containing the generated series.

##### Supports: _Postgres, Snowflake_
----
### [generate_daily_time_series_values](../macros/generate_daily_time_series_values.sql)
**xdb.generate_daily_time_series_values** (**start_date** _date_, **stop_date** _date_)

/* Used in conjunction with generate_daily_time_series_from, this macro returns a time series
        of values based on the start_date and stop_date using 1 day increments

- start_date the start date of the series
- stop_date the ending date of the series

**Returns**:         A new column containing the generated series.

##### Supports: _Postgres, Snowflake_
----
### [generate_uuid](../macros/generate_uuid.sql)
**xdb.generate_uuid** (**type** _None_)

/*
    Generates a uuid value of the given type. Only currently supports v4.

    Prerequisite:
      - Postgres requires the "uuid-ossp" extension to be added to the target database

- `type` the type of uuid to generate (defaults to `"v4"`)

**Returns**:         (varchar) The generated uuid value as a varchar

##### Supports: _Postgres, Snowflake_
----
### [get_email_domain_extension](../macros/get_email_domain_extension.sql)
**xdb.get_email_domain_extension** (**string** _string_)

/* Returns the domain extension of an email address (e.g. 'com', 'net', 'co.uk').

- string email address to be processed.

**Returns**:         The requested part of an email address.

##### Supports: _Postgres, Snowflake_
----
### [get_time_slice](../macros/get_time_slice.sql)
**xdb.get_time_slice** (**date_or_time_expr** _date or time_, **slice_length** _int_, **date_or_time_part** _string_, **start_or_end** _string_)

/* Calculates the beginning or end of a “slice” of time, 
      where the length of the slice is a multiple of a standard unit of time (minute, hour, day, etc.).
      This function can be used to calculate the start and end times of fixed-width “buckets” into which data can be categorized..

- date_or_time_expr : This macro returns the start or end of the slice that contains this date or time.
- slice_length : the width of the slice, i.e. how many units of time are contained in the slice. For example, if the unit is DAY and the slice_length is 2, then each slice is 2 days wide. The slice_length must be an integer greater than or equal to 1.
- date_or_time_part : Time unit for the slice length. The value must be a string containing one of the values listed below:
  - MINUTE, HOUR, DAY, YEAR
  - NOTE: This macro has not been tested for second, week, month, or quarter intervals.
- start_or_end : This is an optional constant parameter that determines whether the start or end of the slice should be returned.
  - Supported values are ‘START’ or ‘END’. The values are case insensitive.
  - The default value is ‘START’.

**Returns**:         a timestamp

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [interval_to_timestamp](../macros/interval_to_timestamp.sql)
**xdb.interval_to_timestamp** (**part** _string_, **val** _integer representing a unit of time_)

/* converts and interval `val` to a timestamp
       *Note* the order of left_val, right_val is reversed from Snowflake.

- part one of 'second', 'minute'
- val the value

**Returns**:         A string representing the time in HH24:MM:SS format

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [json_extract_path_text](../macros/json_extract_path_text.sql)
**xdb.json_extract_path_text** (**column** _None_, **path_vals** _None_)

/*
    Extracts the value at `path_vals` from the json typed `column` (or expression)

    Note that in some DBs, the context is used for extraction:
      - Postgres: `'0'` will indicate the key `"0"` or `[0]` (first array item) based on the object it is requested of.

- `column` the column name (or expression) to extract the values from
- `path_vals` the path to the desired value.
  - The list can be a combination of strings and integers. In general, integers will be treated as json array indexing unless they are typed as strings (e.g. `'0'` instead of `0`)
  - 

**Returns**:         (varchar) The value as a string at the given path in the json or `NULL` if the path does not exist

##### Supports: _Postgres, Snowflake_
----
### [last_value](../macros/last_value.sql)
**xdb.last_value** (**col** _string_, **data_type** _string_, **partition_by** _string_, **order_by** _string_)

/* Window function that returns the last value within an ordered group of values.

- col : the column to get the value from
- data_type : the data type to cast col to
- partition_by : the expression to be partitioned by, e.g. "id, type"
- order_by : the expression to order the partitioned data by, e.g. "date DESC"

**Returns**:        The last value within an ordered group of values.

##### Supports: _Postgres, Snowflake_
----
### [linear_interpolate](../macros/linear_interpolate.sql)
**xdb.linear_interpolate** (**x_i** _numeric_, **x_0** _numeric_, **y_0** _numeric_, **x_1** _numeric_, **y_1** _numeric_)

-/* Calculates linearly interpolated value given two data points

- x_i : the x value to calculate the interpolated value for
- x_0 : x value of first data point
- y_0 : y value of first data point
- x_1 : x value of second data point
- y_1 : y value of second data point

**Returns**:        linearly interpolated value (numeric)

##### Supports: _All (purely arithmetic), _
----
### [not_supported_exception](../macros/not_supported_exception.sql)
**xdb.not_supported_exception** (**_name** _None_)

Wraps `_not_supported_exception` macro

- macro_name : the name of the macro throwing the exception.

**Returns**:          None

##### Supports: _All_
----
### [percent_change](../macros/percent_change.sql)
**xdb.percent_change** (**x_0** _numeric_, **x_N** _numeric_)

- /* Computes the percent change between `x_0` and `x_N` (numeric)

- x_0 is the initial value
- x_N is the final value

**Returns**:         the percent change between `x_0` and `x_N` (numeric)

##### Supports: _All (purely arithmetic), _
----
### [quote_insensitive](../macros/quote_insensitive.sql)
**xdb.quote_insensitive** (**identifier** _string_)

/* Correctly quotes identifers to match the native folding for the target data warehouse.
       Per the SQL spec this _should_ be to uppercase, but this is not always the standard.

- identifier the column / database / relation name to be folded and quoted.

**Returns**:         The `identifier` value correctly folded **and wrapped in double quotes**.

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [recursive_cte](../macros/recursive_cte.sql)
**xdb.recursive_cte** (**** _None_)

/* Supplies the correct wrapper for recursive CTEs in postgres & snowflake
       NOTE: Bigquery does not currently support recursive CTEs per their docs


**Returns**:         The correct wrapper for the CTE

##### Supports: _Postgres, Snowflake_
----
### [regexp](../macros/regexp.sql)
**xdb.regexp** (**val** _None_, **pattern** _None_, **flag** _None_)

/*


**Returns**: 
##### Supports: _Postgres, Snowflake, BigQuery_
----
### [regexp_count](../macros/regexp.sql)
**xdb.regexp_count** (**value** _string_, **pattern** _string_)

/* counts how many instances of `pattern` in `value`

- value the subject to be searched
- pattern the regex pattern to search for

**Returns**:         An integer count of patterns in value

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [regexp_replace](../macros/regexp.sql)
**xdb.regexp_replace** (**val** _string/column_, **pattern** _string_, **replace** _string_)

/* replaces any matches of `pattern` in `val` with `replace`.
    NOTE: this will use native (database) regex matching, which may differ from db to db.

- val the value to search for `pattern`.
- pattern the native regex pattern to search for.
- replace the string to insert in place of `pattern`.

**Returns**:      the updated string. 

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [relative_change](../macros/relative_change.sql)
**xdb.relative_change** (**x_0** _numeric_, **x_N** _numeric_)

-/* Computes the relative change between `x_0` and `x_N` values

- x_0 is the initial value
- x_N is the final value

**Returns**:         the relative change between `x_0` and `x_N` (numeric)

##### Supports: _All (purely arithmetic), _
----
### [split](../macros/split.sql)
**xdb.split** (**_column** _None_, **delimeter** _string_)

-/* Splits the supplied string into an array based on the delimiter

- split_column the column / database / relation name to be split.
- delimeter the delimeter to use when splitting the split_column

**Returns**:         An array of the split string

##### Supports: _Postgres, Snowflake, BigQuery, _
----
### [split_part](../macros/split_part.sql)
**xdb.split_part** (**string** _string_, **delimiter** _string_, **position** _int_)

/* ports SPLIT_PART function, that splits a string on a specified delimiter and returns the nth substring.

- string text to be split into parts.
- delimiter text representing the delimiter to split by.
- position requested part of the split (1-based). If the value is negative, the parts are counted backward from the end of the string.

**Returns**:         The requested part of a string.

##### Supports: _Postgres, Snowflake_
----
### [split_to_table](../macros/split_to_table.sql)
**xdb.split_to_table** (**split_column** _string_, **delimeter** _string_)

/* Splits the supplied string type column into rows based on the delimeter

- split_column the column / database / relation name to be split.
- delimeter the delimeter to use when splitting the split_column

**Returns**:         A new column containing the split data.

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [split_to_table_values](../macros/split_to_table_values.sql)
**xdb.split_to_table_values** (**table_array** _string_)

/* Used in conjunction with split_to_table, this macro returns the split_to_table
        values associated with the split_to_table macro
    NOTE: This is a wrapper macro for unnest_values.

- table_array the table array form of the split_column.

**Returns**:         A new column containing the split data.

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [strip_to_single_line](../macros/strip_to_single_line.sql)
**xdb.strip_to_single_line** (**str** _None_)

this removes all side-effect formatting from nested macros, producing a single line sql statement


**Returns**: 
##### Supports: _All_
----
### [test_does_not_contain](../macros/test_does_not_contain.sql)
**xdb.test_does_not_contain** (**model** _None_, **substring** _None_, **column_name** _None_)

tests that `substring` is not contained in `column_name`


**Returns**: 
##### Supports: _Most (requires basic CTE support)_
----
### [timeadd](../macros/timeadd.sql)
**xdb.timeadd** (**part** _string_, **amount_to_add** _int_, **value** _string_, **timestamp_cast_flag** _boolean_)

/* adds `amount_to_add` `part`s to `value`. so adding one hour to Jan 1 2020 01:00:00 would be timeadd('hour',1,'2020-01-01 01:00:00').
       NOTE: timeadd can handle either string or date/time types passed in `value`.

- part one of 'second','minute','hour'.
- amount_to_add number of `part` units to add to `value`. Negative subtracts.
- value the date time string or column to add to.
- timestamp_cast_flag indicates if `value` should be internally casted to timestamp type

**Returns**:         a date time value with the amount added.

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [timestamp_to_date_part](../macros/timestamp_to_date_part.sql)
**xdb.timestamp_to_date_part** (**timestamp_t** _timestamp_, **date_part** _string_)

/* Ensures that result of EXTRACT in Snowflake is a double to match the default behavior of EXTRACT in postgres

- timestamp_t : timestamp to extract the date_part from
- date_part : tested for 'epoch', 'year', 'month', 'day', 'hour', 'minute', 'second'

**Returns**:        double 

##### Supports: _Postgres, Snowflake_
----
### [unnest](../macros/unnest.sql)
**xdb.unnest** (**array_to_** _None_)

/* Takes an array and splits it into rows of values

- array_to_unnest the array to unnest.

**Returns**:         A new column containing the split data.

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [unnest_values](../macros/unnest_values.sql)
**xdb.unnest_values** (**table_array** _string_)

/* Used in conjunction with unnest, this macro returns the unnested
        values associated with the unnest macro

- table_array the table array form of the split_column.

**Returns**:         A new column containing the split data.

##### Supports: _Postgres, Snowflake, BigQuery_
----
### [using](../macros/using.sql)
**xdb.using** (**rel_1** _None_, **rel_2** _None_, **col** _None_)

/*


**Returns**: 
##### Supports: _Postgres, Snowflake, BigQuery, Redshift_
----