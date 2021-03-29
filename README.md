# dbt-xdb
_Cross-database support for dbt_

![tests-coverage-linting](https://github.com/Health-Union/dbt-xdb/workflows/tests-coverage-linting/badge.svg)

This package is designed to make your sql purely portable in the DRYest possible way. 

#### Check out all the available macros [here](docs/macros.md) 


### Installing xdb

in your `packages.yml` add this line:

```

  - git: "git@github.com:Health-Union/dbt-xdb.git"
    revision: master

```
(_no worries, this will be tagging very soon_. Right now we are committing new macros rapidly and don't want version hangups.)

#### Database Prerequisites:

To ensure compatibility, some database engines require extra setup to support certain `xdb` macros.

- **Postgres**:
  - `xdb.generate_uuid()` requires the `uuid-ossp` extension to be installed

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

### Developing XDB
To get started clone this repo with 

```

git clone git@github.com:Health-Union/dbt-xdb.git

```

Then set up your `profiles.yml` file and freeze it with 

```

git update-index --assume-unchanged profiles.yml

```
You can add your `keyfile.json` directly to the `test_xdb` package root, it is already in .gitignore, and then reference directly in your `profiles.yml`. 


**Note:** each target you set up in `profiles.yml` will get tested. So if you have access to a BigQuery, Redshift _and_ Snowflake instance, you can test them all! Since both AWS and GCP have a lot of free development credits for new accounts, this is not as heavy a lift as it sounds. 

On to the dev! 
This dev env uses Docker. Start your env with:

```

docker-compose up -d

```

From here you can run the tests with

```

docker-compose exec testxdb test

```

Which does a dbt run and dbt test and returns results. You can flag only certain targets (say, when you are squashing a targeted bug) with 

```

docker-compose exec testxdb test bigquery snowflake ## list only the targets you want

```

To test your macros:

- write your `xdb` macro in `xdb/macros/`. 
- build a model in `test_xdb/models/under_test/` that uses the macro with the simplest possible case using the sample data.
  (_Note_: try using `SELECT .. UNION ALL` syntax for your test source directly in the model, it makes the tests much cleaner.
- add tests to confirm the macro works in `test_xdb/models/under_test/schema.yml`.

You can exclude specific models from tests for specific targets (i.e. when the same test cannot support all the targets) using [config flags](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/tags/).

```
{{ config(tags=["exclude_bigquery","exclude_bigquery_tests"]) }}

-- this model will be not be built or tested against bigquery

```

### Test Coverage & Linting
XDB is grounded in Test Driven Development. Before macro code can be merged it must pass our code coverage and linting standards. You can check your coverage / linting status with:

```
docker-compose exec testxdb coverage

```
This will report back if the codebase passes or, if it fails it will report why. 

you can exclude difficult-to-test macros with 

```
/* xdb: nocoverage */
```
as the very first line of the macro file. 

**NOTE:** this same coverage check is required to pass for code to merge. 

### Docs
Generate fresh docs at any time with 

```
docker-compose exec testxdb docs 
```

**Note:** Docs will be built automatically during deployment, so you don't _need_ to do this during development - but it is helpful to see how your docs will render. 

Autodocs read from the macros into the `/docs` folder. This uses docstring syntax (and will be split into a stand-alone module soon).


