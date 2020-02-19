# dbt-xdb
_Cross-database support for dbt_

This package is designed to make your sql purely portable in the DRYest possible way. 

### Installing xdb

in your `packages.yml` add this line:

```

  - git: "https://github.com/norton120/dbt-xdb.git"
    revision: 0.0.1

```
(_no worries, this will be published to dbt hub very very soon_.)


### Using xdb

`xdb` macros are written as close to ansii spec as possible. 
For something like `regexp` searching to see if the case-insensitive username starts with "soup":

```
    ...
    CASE
        WHEN {{xdb.regexp('username','soup.*','i')}} THEN 'Is Soup User'
        ELSE 'Not Soup User'
    END AS soup_user 

```

### Why use xdb? 

Vendor-specific SQL is a relationship. 
Using xdb is like a prenuptual agreement for your code; because no matter how much you love your data warehouse vendor today, it is better to be safe than sorry. 

