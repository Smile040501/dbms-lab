# Data Base Management Systems Laboratory

- [Data Base Management Systems Laboratory](#data-base-management-systems-laboratory)
- [What is PostgreSQL?](#what-is-postgresql)
- [PostgreSQL Installation and Setup](#postgresql-installation-and-setup)
- [PSQL](#psql)
  - [Setup](#setup)
  - [Terminal Commands](#terminal-commands)
  - [Interactive Terminal Commands](#interactive-terminal-commands)
- [PostgreSQL Data Types](#postgresql-data-types)
  - [BOOL](#bool)
  - [VARCHAR, CHAR, TEXT](#varchar-char-text)
  - [INT](#int)
  - [REAL](#real)
  - [NUMERIC](#numeric)
  - [SERIAL](#serial)
  - [MONEY](#money)
  - [DATE](#date)
  - [TIMESTAMP, TIMESTAMPTZ](#timestamp-timestamptz)
  - [TIME](#time)
  - [INTERVAL](#interval)
  - [UUID](#uuid)
  - [JSON](#json)
  - [ARRAY](#array)
  - [User-Defined Data Types](#user-defined-data-types)
- [Table Constraints](#table-constraints)
  - [NOT NULL](#not-null)
  - [UNIQUE](#unique)
  - [CHECK](#check)
  - [PRIMARY KEY](#primary-key)
  - [FOREIGN KEY](#foreign-key)
  - [GENERATED AS IDENTITY](#generated-as-identity)
- [Creating and Dropping DATABASE](#creating-and-dropping-database)
- [Creating, Copying and Dropping TABLE](#creating-copying-and-dropping-table)
- [Queries](#queries)
  - [INSERT](#insert)
  - [SELECT](#select)
    - [Operators in WHERE clause](#operators-in-where-clause)
  - [UPDATE](#update)
  - [DELETE and TRUNCATE](#delete-and-truncate)
- [Updating Table Structure](#updating-table-structure)
  - [Adding and Dropping a Column](#adding-and-dropping-a-column)
  - [Change Column Type](#change-column-type)
  - [Modify Default Value of a Column](#modify-default-value-of-a-column)
  - [Adding and Dropping a Column Constraint](#adding-and-dropping-a-column-constraint)
  - [Rename a Column or a Table](#rename-a-column-or-a-table)
- [Queries on Multiple Relations/Tables](#queries-on-multiple-relationstables)
- [String Operations](#string-operations)
- [ORDER BY clause](#order-by-clause)
- [LIMIT and FETCH clauses](#limit-and-fetch-clauses)
- [Set operations](#set-operations)
- [Aggregation Functions](#aggregation-functions)
- [GROUP BY and HAVING clauses](#group-by-and-having-clauses)
- [Nested Subqueries](#nested-subqueries)
  - [PostgreSQL Common Table Expressions(CTEs)](#postgresql-common-table-expressionsctes)
- [Joins](#joins)
  - [(INNER) JOIN](#inner-join)
  - [NATURAL JOIN](#natural-join)
  - [LEFT (OUTER) JOIN](#left-outer-join)
  - [RIGHT (OUTER) JOIN](#right-outer-join)
  - [FULL (OUTER) JOIN](#full-outer-join)
  - [CROSS JOIN](#cross-join)
  - [Self Join](#self-join)
- [VIEW](#view)
  - [Updatable Views](#updatable-views)
  - [Materialized Views](#materialized-views)
- [SEQUENCE](#sequence)
- [Conditional Expressions](#conditional-expressions)
- [Useful Functions](#useful-functions)
  - [CAST](#cast)
  - [COALESCE](#coalesce)
  - [NULLIF](#nullif)
  - [RANDOM](#random)
  - [GENERATE_SERIES](#generate_series)
  - [Get Database Object Sizes](#get-database-object-sizes)
- [Database Users and Privileges](#database-users-and-privileges)
  - [Users, Groups and Roles](#users-groups-and-roles)
    - [Client Authentication](#client-authentication)
  - [GRANT and REVOKE](#grant-and-revoke)
  - [Role Membership](#role-membership)
- [Transactions](#transactions)
- [Indexing](#indexing)
  - [Index Types](#index-types)
  - [Creating an Index](#creating-an-index)
  - [Dropping an Index](#dropping-an-index)
  - [List Indexes](#list-indexes)
  - [Index on Expression](#index-on-expression)
  - [Re-Index](#re-index)
  - [Example](#example)

# What is PostgreSQL?

PostgreSQL is a powerful, open source object-relational database system that uses and extends the SQL language combined with many features that safely store and scale the most complicated data workloads.

# PostgreSQL Installation and Setup

-   Install from official [docs](https://www.postgresql.org/download/linux/ubuntu/)
-   **PostgreSQL Clusters**

    ```bash
    # Show information about all PostgreSQL clusters
    pg_lsclusters

    # start/stop/restart/reload a PostgreSQL cluster
    # pg_ctlcluster
    sudo pg_ctlcluster <version> <cluster_name> restart  # Restart cluster
    ```

-   **PostgreSQL service**

    ```bash
    # Check commands available with PostgreSQL service
    service postgresql

    # Check status of PostgreSQL service
    service postgresql status

    # Restart PostgreSQL service
    service postgresql restart
    ```

-   Before using PostgreSQL, check the status of the PostgreSQL cluster by checking the status of the PostgreSQL service.\
    Restart the cluster if the service is down and again check the status of PostgreSQL service and make sure it is **online**

# PSQL

PostgreSQL Interactive Terminal

## Setup

-   Default user for PostgreSQL is **postgres**
-   First time, start `psql` as
    ```bash
    # Starting psql with default PostgreSQL user
    $ sudo -u postgres psql
    ```
-   Setting a password for default user **(once we have entered the interactive terminal)**:
    ```sql
    ALTER USER postgres PASSWORD 'newpassword';
    ```
-   To use `psql` without changing the user every time, we can create a new superuser with our system default username and password.\
    Using **postgres** user:

    -   Create a new super user
        ```sql
        CREATE USER uname WITH SUPERUSER ENCRYPTED PASSWORD 'pswd';
        ```
    -   Create a new database with the same name as the new super user created above
        ```sql
        CREATE DATABASE uname;
        ```

    Now, we can simply type `psql` in the terminal to connect to start using PostgreSQL with the new super user created above.

-   Retrieve current version of PostgreSQL
    ```sql
    SELECT VERSION();
    ```

## Terminal Commands

```bash
# Connect to a PostgreSQL database under a specific user
$ psql -d dbname -U uname -W

# # If we want to connect to a database that resides on another host
$ psql -h host -d dbname -U uname -W
```

```bash
# Export PostgreSQL database

# Export PostgreSQL database to a plain-text SQL script file (the default).
$ pg_dump -h host -d dbname -U uname > /path/to/file/dump_name.pgsql

# Export PostgreSQL database to tar-format archive
$ pg_dump -h host -d dbname -U uname -F t > /path/to/file/dump_name.tar
# -F format: Specify the output format.

# Backup all databases
$ pg_dumpall ...
```

```bash
# Import to PostgreSQL database

# If our backup is a plain-text SQL script file,
# we can restore our database by using the `psql` command itself
$ psql -h host -d dbname -U uname -f data-dump.pgsql  # Recommended
$ psql -h host -d dbname -U uname < data-dump.pgsql
# The database should already be created before importing the data

# If we choose custom, directory, or archive format when creating a backup file,
# then we will need to use `pg_restore` in order to restore our database
$ pg_restore -h host -d dbname -c -C -U uname -v /path/to/file/dump_name.tar
# -c : Clean the database objects before recreating them.
# -C : Create the database before restoring into it.
#      If -c is also specified, drop and recreate the target database.
# -v : Specifies the verbose mode.
```

## Interactive Terminal Commands

```bash
# List all the users and their roles
\du
\dg[S+]

# Quit psql
\q

# List all the available databases
\l

# Connect to a database under the current user
\c dbname

\c dbname username # Switch connection to a new database under a specified user

# List everything available in the current database
\d

# List all the tables in the current database
\dt

# Describe a table such as column, type,
# modifiers of columns, indexes, integrity constraints, etc.
\d table_name

# Execute an SQL File which has SQL queries written in it
\i /path/to/file.sql

# Get help on psql commands
\?

# Get help on specific PostgreSQL statement
\h ALTER TABLE

# List all the schemas of the currently connected database
\dn

# List all the available functions in the current database
\df

\sf[+] funcname   # Shows function's definition

# List all the available views in the current database
\dv
\dm[S+]    # List materialized views
\sv[+] viewname   # Shows views's definition

# Lists tables, views and sequences with their associated access privileges
\dp
\ddp    # default privileges

# List all access methods
\dA+

# List event triggers
\dy[+]

# List all the available domains in the current database
\dD

# List all user-defined types in the current database
\dT+

# List indexes
\di[S+]

# List procedural languages
\dL[S+]

# List all tablespaces
\db+

# List extensions
\dx[+]

# Arranges to save future query results to the file <filename>, or
# Pipe future results to the shell command <command>
# If no argument is specified, the query output is reset to the standard output.
\o <filename>
\o | <command>

# Turn ON/OFF query execution time
\timing

# Change the password of the specified user (default is current user)
\password ?uname

# Execute the previous command
\g

# Prints psql's command line history to filename
\s ?filename

# Switch b/w aligned and non-aligned column output
\a

# Formats the output to HTML format
\H

# Change the current working directory
\cd directory

# Prints the current working directory
\! pwd

# Clears the psql console
\! clear
```

# PostgreSQL Data Types

## BOOL

```sql
BOOLEAN or BOOL

TRUE, FALSE or NULL

-- Truthy values
true, 't', 'true', 'y', 'yes', '1', 'on'

-- Falsy values
false, 'f', 'false', 'n', 'no', '0', 'off'

-- DEMO
CREATE TABLE boolean_demo(
   ...
   is_ok BOOL DEFAULT TRUE
);
```

## VARCHAR, CHAR, TEXT

```sql
CHARACTER VARYING(n) or VARCHAR(n)  -- variable-length with length limit
CHARACTER(n) or CHAR(n)             -- fixed-length, blank padded
TEXT                                -- variable unlimited length

-- DEMO
CREATE TABLE character_tests (
    ...
	x CHAR(1),
	y VARCHAR(10),
	z TEXT
);
```

## INT

```sql
INTEGER or INT
SMALLINT
BIGINT

-- DEMO
CREATE TABLE cities (
    ...
    population INT NOT NULL CHECK(population >= 0)
);
```

## REAL

```sql
REAL     -- Double precision
FLOAT(n) -- at least precision n

-- DEMO
CREATE TABLE products (
    ...
    price REAL
);
```

## NUMERIC

```sql
NUMERIC(precision, scale=0) or DECIMAL(precision, scale=0)
-- precision: total number of digits
-- scale: number of digits after the decimal point

NUMERIC or DECIMAL  -- any precision and scale

-- slower than integers, floats and double precisions
-- can also hold a special value `NaN`

-- DEMO
CREATE TABLE products (
    ...
    price NUMERIC(5,2)
);
```

## SERIAL

```sql
SERIAL      -- auto-incrementing integer
SMALLSERIAL
BIGSERIAL

-- Always `NOT NULL` by default

-- DEMO
CREATE TABLE table_name(
    id SERIAL PRIMARY KEY,
    ...
);
```

## MONEY

```sql
MONEY

-- DEMO
CREATE TABLE money_example (
    cash MONEY
);

INSERT INTO money_example
VALUES ('$99.99');

INSERT INTO money_example
VALUES (99.98996998);
```

## DATE

```sql
DATE    -- `yyyy-mm-dd` format

-- CURRENT_DATE as the default

-- DEMO
CREATE TABLE documents (
	document_id SERIAL PRIMARY KEY,
	header_text VARCHAR(255) NOT NULL,
	posting_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Get current date of the database sever
SELECT NOW()::DATE;
SELECT CURRENT_DATE;

-- Output a PostgreSQL date value in a specific format
SELECT TO_CHAR(CURRENT_DATE, 'dd/mm/yyyy');
SELECT TO_CHAR(CURRENT_DATE, 'Mon dd, yyyy');    -- Mar 01, 2022

-- Get interval between two dates
SELECT CURRENT_DATE - birth_date AS diff
FROM students;

-- Calculate age in years, months and days
-- AGE(date) = (CURRENT_DATE - date)
-- AGE(date1, date2) = (date1 - date2)
SELECT AGE(birth_date) AS age
FROM students;

-- Extract year, quarter, month, week, day from a date value
SELECT EXTRACT(YEAR FROM birth_date) AS YEAR
       EXTRACT(MONTH FROM birth_date) AS MONTH
       EXTRACT(DAY FROM birth_date) AS DAY
FROM students;
```

## TIMESTAMP, TIMESTAMPTZ

```sql
TIMESTAMP   -- timestamp without time zone
TIMESTAMPTZ   -- timestamp with time zone

-- DEMO
CREATE TABLE timestamp_demo (
    ts TIMESTAMP,
    tstz TIMESTAMPTZ
);

-- Set time zone of the database server
SET TIMEZONE = 'American/Los_Angeles';

-- Show current time zone
SHOW TIMEZONE;

-- Getting current time
SELECT NOW();
SELECT CURRENT_TIMESTAMP;
SELECT CURRENT_TIME;
SELECT TIMEOFDAY();
SELECT LOCALTIME;

-- Convert between timezones
-- TIMEZONE(zone, timestamp)
-- Case the timestamp to TIMESTAMPTZ explicitly
SELECT TIMEZONE('America/New_York','2016-06-01 00:00'::TIMESTAMPTZ);
```

## TIME

```sql
TIME
TIME WITH TIME ZONE

-- Convert time to different time zone
[TIME with time zone] AT TIME ZONE 'time_zone'

-- Extract hours, minutes, seconds from a time value
EXTRACT(HOUR FROM LOCALTIME) AS hour
```

## INTERVAL

```sql
INTERVAL [fields][(precision)]

INTERVAL '6 months before'
INTERVAL '2 hours 30 minutes'

-- DEMO
SELECT NOW()::DATE - INTERVAL '1 year 6 months 100 days' AS interval;
```

## UUID

```sql
UUID  -- stands for Universal Unique Identifier

-- To install the `uuid-ossp` module, we use:
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- To generate the UUID values based on the combination of
-- computer’s MAC address, current timestamp, and a random value
SELECT UUID_GENERATE_v1();

-- if we want to generate a UUID value solely based on random numbers
SELECT UUID_GENERATE_v4();

-- Create a table with UUID column
CREATE TABLE contacts (
    contact_id UUID DEFAULT UUID_GENERATE_v4(),
    ...
    PRIMARY KEY(contact_id)
);
```

## JSON

```sql
JSON

-- DEMO
CREATE TABLE orders (
	id SERIAL NOT NULL PRIMARY KEY,
	info JSON NOT NULL
);

INSERT INTO orders (info)
VALUES(
        '{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24}}'
    ),
    (
        '{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'
    ),
    (
        '{ "customer": "Mary Clark", "items": {"product": "Toy Train","qty": 2}}'
    );

SELECT info FROM orders;

-- -> : Returns JSON object field by key
--      Output is in JSON format
SELECT info -> 'customer' AS customer
FROM orders;

-- ->> : Returns JSON object field by key
--       Output is in Text format
SELECT info -> 'items' ->> 'product' AS customer
FROM orders;

SELECT
   MIN(CAST(info -> 'items' ->> 'qty' AS INTEGER)),
   MAX(CAST(info -> 'items' ->> 'qty' AS INTEGER)),
   SUM(CAST(info -> 'items' ->> 'qty' AS INTEGER)),
   AVG(CAST(info -> 'items' ->> 'qty' AS INTEGER))
FROM orders;

-- `JSON_EACH()` allows us to expand the outermost JSON object into a set of key-value pairs
-- `JSON_EACH_TEXT()` gives the key-value pairs as text
SELECT JSON_EACH(info)
FROM orders;

-- `JSON_OBJECT_KEYS()`: to get a set of keys in the outermost JSON object
SELECT JSON_OBJECT_KEYS(info -> 'items')
FROM orders;

-- `JSON_TYPEOF()` function returns type of the outermost JSON value as a string.
-- It can be `number`, `boolean`, `null`, `object`, `array`, and `string`
SELECT JSON_TYPEOF(info -> 'items')
FROM orders;
```

## ARRAY

```sql
ARRAY
-- PostgreSQL allows us to define a column to be an array
-- of any valid data type including built-in type,
-- user-defined type or enumerated type.

CREATE TABLE contacts (
	id serial PRIMARY KEY,
	name VARCHAR (100),
	phones TEXT[]
);

-- Using the `ARRAY` constructor
INSERT INTO contacts (name, phones)
VALUES(
        'John Doe',
        ARRAY [ '(408)-589-5846','(408)-589-5555' ]
    );

-- Using the curly braces {}
INSERT INTO contacts (name, phones)
VALUES('Lily Bush', '{"(408)-589-5841"}'),
    (
        'William Gate',
        '{"(408)-589-5842","(408)-589-58423"}'
    );

-- ONE-BASED indexing
SELECT name,
    phones[1]
FROM contacts;

-- `UNNEST()` function to expand an array to a set of rows
SELECT name,
	UNNEST(phones)
FROM contacts;
```

## User-Defined Data Types

```sql
-- USER-DEFINED DATA TYPES
-- `CREATE DOMAIN` creates a user-defined data type with constraints such as `NOT NULL`, `CHECK`, etc.
-- `CREATE TYPE` creates a composite type used in stored procedures as the data types of returned values.

-- Example1
-- Do not accept NULL and spaces
CREATE DOMAIN CONTACT_NAME AS VARCHAR NOT NULL CHECK (value !~ '\s');

CREATE TABLE mailing_list (
    id SERIAL PRIMARY KEY,
    first_name CONTACT_NAME,
    last_name CONTACT_NAME,
    email VARCHAR NOT NULL
);

-- Get all the domains in a specific schema
SELECT typname
FROM pg_catalog.pg_type
    JOIN pg_catalog.pg_namespace ON pg_namespace.oid = pg_type.typnamespace
WHERE typtype = 'd'
    and nspname = '<schema_name>';  -- Ex: 'public'


-- Example2
CREATE TYPE FILM_SUMMARY AS (
    film_id INT,
    title VARCHAR,
    release_year SMALLINT
);

CREATE TYPE FRUITS_NAME AS ENUM ('Mango', 'Apple', 'Orange', 'Strawberry');
```

# Table Constraints

## NOT NULL

```sql
-- Make sure a column can't have `NULL` values

-- DEMO
CREATE TABLE table_name (
    ...
    column1 INT NOT NULL,
    column2 NUMERIC NOT NULL
);

-- DEMO: Adding/Dropping NOT NULL constraint
ALTER TABLE table_name
ALTER COLUMN column_name
[SET | DROP] NOT NULL;
```

## UNIQUE

```sql
-- Make sure a column can't have duplicate values

-- DEMO
CREATE TABLE table_name (
    ...
    column1 INT NOT NULL UNIQUE
);

-- DEMO: Generating a unique constraint on multiple columns
CREATE TABLE table_name (
    ...
    [CONSTRAINT constraint_name] UNIQUE(column_list)
);

-- DEMO: Adding it to existing columns
ALTER TABLE table_name
ADD [CONSTRAINT constraint_name] UNIQUE(column_list);
```

## CHECK

```sql
-- Make sure that all the values in the column satisfy the condition(s)
-- Can be defined by a separate name

-- DEMO
CREATE TABLE table_name(
    col1 datatype,
    col2 datatype,
    col3 datatype [CONSTRAINT constraint_name] CHECK(conditions),
    [CONSTRAINT constraint_name] CHECK(conditions);
);

-- DEMO: Add CHECK constraint to an existing column
ALTER TABLE table_name
ADD [CONSTRAINT constraint_name] CHECK(conditions);
```

## PRIMARY KEY

```sql
-- Individually identifies each row or the record in the database
-- A table can have one and only one primary key
-- Contains UNIQUE and NOT NULL values
-- Can also use SERIAL datatype

-- DEMO
CREATE TABLE table_name (
    column1 datatype [CONSTRAINT constraint_name] PRIMARY KEY,
    ...
);

-- DEMO: PRIMARY KEY on multiple columns
CREATE TABLE table_name (
    ...
    [CONSTRAINT constraint_name] PRIMARY KEY(column_list)
);

-- DEMO: Adding it to existing table
ALTER TABLE table_name
ADD [CONSTRAINT constraint_name] PRIMARY KEY(column_list);
```

## FOREIGN KEY

```sql
-- Ensures values in a column or a group of columns from a table exists in a column or group of columns in another table.
-- Unlike the primary key, a table can have many foreign keys.

-- Syntax
[CONSTRAINT constraint_name]
FOREIGN KEY [foreign_key_name] (column_name, ...)
REFERENCES parent_table_name (column_name, ...)
[ON DELETE referenceOption]
[ON UPDATE referenceOption]

-- Reference Options
SET DEFAULT  -- Parser itself identifies the default
SET NULL     -- When we remove/modify any row from PARENT
             -- Foreign key values in child table are set to NULL
CASCADE      -- When we remove/modify any row from PARENT
             -- Values of corresponding rows from CHILD will be removed/updated repeatedly.
RESTRICT     -- When we remove/modify any row from PARENT, which has a similar row in the CHILD
NO ACTION    -- Similar to RESTRICT
             -- Also verifies the `referential integrity` after we are trying to update the particular table.
```

## GENERATED AS IDENTITY

```sql
-- Allows to automatically assign a unique number to a column.

-- Syntax
-- type can be: SMALLINT, INT, BIGINT
column_name type GENERATED {ALWAYS | BY DEFAULT} AS IDENTITY[( sequence_option )]

-- `GENERATED ALWAYS` instructs PostgreSQL to always generate a value for the identity column.
-- If we attempt to insert (or update) values into the `GENERATED ALWAYS AS IDENTITY` column, PostgreSQL will issue an error.

-- The `GENERATED BY DEFAULT` also instructs PostgreSQL to generate a value for the identity column.
-- However, if we supply a value for insert or update, PostgreSQL will use that value to insert into the identity column instead of using the system-generated value.

-- DEMO1
CREATE TABLE color (
    color_id INT GENERATED ALWAYS AS IDENTITY,
    color_name VARCHAR NOT NULL
);

INSERT INTO color (color_name)
VALUES ('Red');

INSERT INTO color (color_id, color_name)
VALUES (2, 'Green');    -- ERROR

INSERT INTO color (color_id, color_name)
OVERRIDING SYSTEM VALUE
VALUES(2, 'Green');

-- DEMO2
CREATE TABLE color (
    color_id INT GENERATED BY DEFAULT AS IDENTITY,
    color_name VARCHAR NOT NULL
);

INSERT INTO color (color_name)
VALUES ('White');

INSERT INTO color (color_id, color_name)
VALUES (2, 'Yellow');

-- DEMO3: Sequence options example
CREATE TABLE color (
    color_id INT GENERATED BY DEFAULT AS IDENTITY (START WITH 10 INCREMENT BY 10),
    color_name VARCHAR NOT NULL
);

-- Adding it to existing table
ALTER TABLE table_name
ALTER COLUMN column_name
ADD GENERATED { ALWAYS | BY DEFAULT } AS IDENTITY { ( sequence_option ) }

-- Changing an identity column
ALTER TABLE table_name
ALTER COLUMN column_name
{ SET GENERATED { ALWAYS| BY DEFAULT } |
  SET sequence_option | RESTART [ [ WITH ] restart ] }

-- Removing an identity constraint
ALTER TABLE table_name
ALTER COLUMN column_name
DROP IDENTITY [ IF EXISTS ];
```

# Creating and Dropping DATABASE

```sql
CREATE DATABASE dbname;

-- Full syntax
CREATE DATABASE dbname
WITH
    OWNER =  role_name          -- default `postgres`
    TEMPLATE = template
    ENCODING = encoding         -- default `UTF8`
    LC_COLLATE = collate        -- define the sort order of strings that mark the result of the ORDER BY clause if we are using a SELECT statement.
    LC_CTYPE = ctype            -- display the character classification for the new database
    TABLESPACE = tablespace_name  -- define the tablespace name for the new database, and by default, it is the `template database's tablespace`.
    ALLOW_CONNECTIONS = true | false
    CONNECTION LIMIT = max_concurrent_connection    -- default `-1 (unlimited)`
    IS_TEMPLATE = true | false
```

```sql
DROP DATABASE dbname;

-- Warning is displayed in the place of an error if
-- the database does not exist
DROP DATABASE IF EXISTS dbname;
```

# Creating, Copying and Dropping TABLE

```sql
CREATE [TEMP] TABLE [IF NOT EXISTS] table_name (
    column1_name <datatype> <column_constraint(s)>,
    column2_name <datatype> <column_constraint(s)>,
    <table_constraints>
);

-- IF NOT EXISTS: If a table already occurs with a similar name, a warning will be displayed in place of an error.

-- TEMP: It is used to generate a temporary table, and it will delete after the existing operation or at the end of a session.


-- Add a default value for a column if no value is specified

-- DEFAULT Values
CREATE TABLE table_name (
    ...
    column1 <datatype> DEFAULT <default_val>,
);
```

```sql
-- Copying the table

-- Copy a table completely
CREATE TABLE new_table_name AS
TABLE existing_table;

-- Copy structure of the table
CREATE TABLE new_table_name AS
TABLE existing_table
WITH NO DATA;

-- Creates a new table and fills it with the data returned by a query
CREATE TABLE new_table_name AS
sql_query;
```

```sql
DROP TABLE [IF EXISTS] table_name;
```

# Queries

## INSERT

```sql
INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...),
    (value1, value2, ...),
    (value1, value2, ...);

-- Insert default values
INSERT INTO table_name (column1, column2, ...)
DEFAULT VALUES;

-- Insert multiple records using a sub-select
INSERT INTO table_name (column1, column2, ...)
SELECT expression1,
    expression2,
    ...
FROM source_table
[WHERE conditions];
```

## SELECT

```sql
SELECT column1,
    column2 AS column_alias,
    ...
FROM table_name
[WHERE conditions];

-- Retrieve all the columns
SELECT *
FROM table_name;

-- Retrieve distinct rows
SELECT DISTINCT table_alias.column1,
    table_alias.column2,
    ...
FROM table_name AS table_alias;

-- Limiting Results
SELECT column1, column2, ...
FROM table_name
LIMIT <num_rows_to_output> [OFFSET <num_rows_to_skip>];

-- Fully Qualified Table Name
SELECT table_name.column1
FROM table_name;
```

### Operators in WHERE clause

```sql
=   -- Equality
<>  -- Non-equality
!=  -- Non-equality
<, <=, >, >=  -- Comparison

[IN | NOT IN](value_list)  -- Check from multiple possible values

BETWEEN <lower_bound> AND <upper_bound>  -- Between two specified values

AND, OR, NOT  -- Logical operators

IS NULL, IS NOT NULL  -- Test for NULL Values

-- Compares a value to a set of values returned by a subquery.
-- Returns true if any value of the subquery meets the condition, otherwise, false.
-- `= ANY` ≣ `IN`
<expression> <operator> ANY(subquery)

-- Compares a value to a set of values returned by a subquery.
-- Returns true if all the values of the subquery meets the condition, otherwise, false.
<expression> <operator> ALL(subquery)

-- EXISTS (empty_relation) -> False
-- EXISTS (null) -> True (if all the tuples are null)
-- Returns True if subquery returns several records
EXISTS(subquery);
```

## UPDATE

```sql
UPDATE table_name
SET column1 = value1,
    column2 = value2,
    ...
WHERE condition;

-- If we don't provide WHERE clause, all the records will get updated
```

```sql
-- Example of UPDATE joins command
UPDATE department_tmp
SET location = department.location,
    description = department.description,
    last_update = department.last_update
FROM department
WHERE department_tmp.Dept_id = department.Dept_id;

-- Both the tables have similar structure
-- Update values in one table based on the values in another table
```

```sql
-- Example of UPDATE command with RETURNING clause
UPDATE department
SET description = 'Names of departments',
    location = 'NewYork'
WHERE dept_id = 1
RETURNING dept_id,
    description,
    location;

-- Default: Returns number of affected rows.
```

## DELETE and TRUNCATE

```sql
DELETE FROM table_name
WHERE condition;

-- If we don't provide WHERE clause, all the records in the table will get deleted
```

```sql
TRUNCATE TABLE table_name
[RESTART IDENTITY | CONTINUE IDENTITY] [CASCADE | RESTRICT] ;

-- Remove all the records in the table
-- Faster than DELETE
-- Does not accept WHERE clause

-- RESTART IDENTITY: It repeatedly restarts orders owned by columns of the truncated tables.
-- CONTINUE IDENTITY: (Default) Does not change the values of orders
-- CASCADE: Automatically truncates all tables, which contains the foreign-key references to other tables, or any tables added to the collection due to CASCADE.
-- RESTRICT: (Default) Decline to truncate if other tables contain the foreign-key references of tables, which are not mentioned in the command.
```

# Updating Table Structure

## Adding and Dropping a Column

```sql
ALTER TABLE table_name
ADD COLUMN new_column_name <datatype> <constraints>;
```

```sql
ALTER TABLE table_name
DROP COLUMN column_name;

-- Remove column and all its connected objects
ALTER TABLE table_name
DROP COLUMN column_name CASCADE;
```

## Change Column Type

```sql
ALTER TABLE table_name
ALTER COLUMN column_name TYPE <new_type>
[USING expression];

-- PostgreSQL offers us to change the old column values to the new one while modifying the column's data type by adding a USING condition.
-- The PostgreSQL will create old column values to the new one indirectly if we are not using the USING condition.
-- If the creation is failed, PostgreSQL will raise an issue and ask us to give the USING clause with an expression that is used for alteration.
```

## Modify Default Value of a Column

```sql
ALTER TABLE table_name
ALTER COLUMN column_name
[SET DEFAULT value | DROP DEFAULT];
```

## Adding and Dropping a Column Constraint

```sql
ALTER TABLE table_name
ADD CONSTRAINT constraint_name constraint_definition;
```

```sql
ALTER TABLE table_name
DROP CONSTRAINT constraint_name;
```

## Rename a Column or a Table

```sql
ALTER TABLE table_name
RENAME COLUMN column_name TO new_column_name;
```

```sql
ALTER TABLE table_name
RENAME TO new_table_name;
```

# Queries on Multiple Relations/Tables

```sql
SELECT name,
    title
FROM category,
    film_category,
    films
WHERE films.film_id = 9
    and films.film_id = film_category.film_id
    and film_category.category_id = category.category_id;
```

# String Operations

```sql
-- Returns true if the string matches the supplied pattern.
SELECT title
FROM films
WHERE description LIKE '%Robot%';

-- % -> Zero or More characters
-- _ -> Any single character
-- ILIKE -> for case-insensitivity
-- Operator ~~   is equivalent to LIKE
--          !~~  is equivalent to NOT LIKE
--          ~~*  is equivalent to ILIKE
--          !~~* is equivalent to NOT ILIKE
```

```sql
-- Starts with P followed by e or a and then any number of characters
SELECT first_name
FROM actor
WHERE first_name SIMILAR TO 'P(e|a)%';

--  5 underscores means start with P and then any 5 letters
SELECT first_name
FROM customer
WHERE first_name SIMILAR TO 'P_____';
```

```sql
--  Combine multiple row values as CSV in single cell by grouping
--  `STRING_AGG` function
--  DISTINCT for distinct values only
SELECT ...,
    STRING_AGG(
        DISTINCT column_name,
        ', '
        ORDER BY column_name ASC
    ) AS column_alias
FROM table_name
GROUP BY table_name.ID;
```

# ORDER BY clause

```sql
-- Default `ASC`
SELECT *
FROM actor
ORDER BY first_name ASC,
    last_name DESC;
```

# LIMIT and FETCH clauses

-   Both are same
-   `LIMIT` only works in PostgreSQL
-   `FETCH` is compatible with other database systems
    -   `FETCH` does not preserve the order of the rows, so should be used with `ORDER BY` clause

```sql
SELECT column1, column2, ...
FROM table_name
LIMIT <num_rows_to_output> [OFFSET <num_rows_to_skip>];
```

```sql
SELECT column1, column2, ...
FROM table_name
ORDER BY column_name
OFFSET <start=0> {ROW | ROWS}
FETCH {FIRST | NEXT} <num_rows_to_output> {ROW | ROWS} ONLY;

-- `ROW` and `ROWS` are synonyms
-- `FIRST` and `NEXT` are synonyms
```

# Set operations

-   `UNION (A ∪ B)`
    -   `UNION ALL` (with repetition of columns)
-   `INTERSECT (A ∩ B)`
-   `EXCEPT (A-B)`

```sql
SELECT *
FROM first_table
[UNION | UNION ALL | INTERSECT | EXCEPT]
SELECT *
FROM second_table;
```

# Aggregation Functions

```sql
--  Counts the number of rows in a table
SELECT COUNT(*)
FROM clg;

SELECT COUNT(DISTINCT marks)
FROM clg;
```

```sql
--  Returns the sum of all the values in the column
SELECT SUM(marks)
FROM clg;

SELECT SUM(DISTINCT marks)
FROM clg;
```

```sql
--  Returns the minimum value in the column
SELECT MIN(age)
FROM clg;

--  Returns the maximum value in the column
SELECT MAX(age) AS max_age
FROM clg;
```

```sql
-- Returns the average of the value in the column
SELECT AVG(age)
FROM clg;
```

# GROUP BY and HAVING clauses

-   `GROUP BY`: Used to split rows into groups where the GROUP BY condition collects the data across several records and sets the result by one or more columns.
-   `HAVING`: Used to specify a search condition for a group or an aggregate.

```bash
        Working of GROUP BY Clause

        +===================+
        |       FROM        |    |
        +===================+    V
        |       WHERE       |    |
        +===================+    V
        |     GROUP BY      |    |
        +===================+    V
        |      HAVING       |    |
        +===================+    V
        |      SELECT       |    |
        +===================+    V
        |     DISTINCT      |    |
        +===================+    V
        |     ORDER BY      |    |
        +===================+    V
```

```sql
SELECT column_list
FROM table_name
WHERE [conditions]
GROUP BY column1,
    column2,
    ...
HAVING [conditions]
ORDER BY column1,
    column2,
    ...
```

|                        HAVING Clause                        |                   WHERE Clause                    |
| :---------------------------------------------------------: | :-----------------------------------------------: |
| Allows to filter groups of rows<br>as per defined condition | Allows to filter rows as per<br>defined condition |
|                    Useful to group rows                     |               Applied to rows only                |

> `Q`: Find the subject-wise total marks secured by the students

```sql
-- First it will group all the similar rows together
-- Then it will find the sum of marks for each subject
SELECT subject,
    SUM(marks)
FROM clg
GROUP BY subject;
```

> `Q`: Find the number of students enrolled in each subject

```sql
SELECT subject,
    COUNT(*)
FROM clg
GROUP BY subject;
```

> `Q`: Find the subjects whose total marks > 200

```sql
SELECT subject,
    SUM(marks)
FROM clg
GROUP BY subject
HAVING SUM(marks) > 200;
```

# Nested Subqueries

> `Q`: Find the subject where number of students enrolled is greater than the number of students enrolled in the 'geology' subject

```sql
SELECT subject,
    COUNT(*)
FROM clg
GROUP BY subject
HAVING COUNT(*) > (
        SELECT COUNT(*)
        FROM clg
        GROUP BY subject
        HAVING subject = 'geology'
    );
```

> `Q`: Find the subject and average marks of students whose average marks is greater than the average marks of the students in 'maths' subject

```sql
SELECT subject,
    AVG(marks)
FROM clg
GROUP BY subject
HAVING AVG(marks) > (
        SELECT AVG(marks)
        FROM clg
        GROUP BY subject
        HAVING subject = 'maths'
    );
```

## PostgreSQL Common Table Expressions(CTEs)

-   Temporary result which we can reference within another SQL statement. They only exist during the execution of the query
-   Used to simplify complex joins and subqueries
-   Use them as table or view in other sql statements

```sql
WITH cte_name (column_list?) AS (
    CTE_sql_query_definition
)
another_sql_statement;

-- `CTE_sql_query_definition` will be treated as the nested subquery that returns a result set
-- column_list is optional and by default will take all the columns of nested subquery
```

# Joins

## (INNER) JOIN

`A INNER JOIN B` ≣ `A ∩ B`

```sql
SELECT column_list
FROM table1
INNER JOIN table2 ON [conditions]
INNER JOIN table3 ON [conditions];

-- If both the tables have same column name
-- Checks for equality condition only
SELECT column_list
FROM table1
INNER JOIN table2 USING(column_name);

-- Using WHERE Clause
SELECT column_list
FROM table1,
    table2
WHERE [conditions];

-- Equi Join
SELECT *
FROM table1
INNER JOIN table2 ON table1.column_name = table2.column_name;
```

## NATURAL JOIN

```sql
-- Default: INNER
FROM table1
NATURAL [INNER | LEFT | RIGHT] JOIN table2;
```

## LEFT (OUTER) JOIN

`A LEFT JOIN B` ≣ `A`

```sql
SELECT column_list
FROM table1
LEFT [OUTER] JOIN table2 ON [conditions];

-- We can use USING Clause also
```

## RIGHT (OUTER) JOIN

`A RIGHT JOIN B` ≣ `B`

```sql
SELECT column_list
FROM table1
RIGHT [OUTER] JOIN table2 ON [conditions];

-- We can use USING Clause also
```

## FULL (OUTER) JOIN

`A FULL JOIN B` ≣ `A ∪ B`

```sql
SELECT column_list
FROM table1
FULL [OUTER] JOIN table2 ON [conditions];

-- We can use USING Clause also
```

## CROSS JOIN

```sql
-- CARTESIAN JOIN
-- Cartesian Product

SELECT column_list
FROM table1
CROSS JOIN table2;

-- Method2
SELECT column_list
FROM table1,
    table2;

-- Method3
SELECT column_list
FROM table1
INNER JOIN table2 ON TRUE;
```

## Self Join

```sql
-- Same table with different alias names
SELECT column_list
FROM table_name AS t1,
    table_name AS t2;

SELECT column_list
FROM table_name AS t1
INNER JOIN table_name AS t2 ON join_predicate;
```

# VIEW

-   A VIEW is a pseudo table in PostgreSQL
-   Named query that provides another way to present data in the database tables
-   When we create a view, we basically create a query and assign a name to the query

```sql
-- REPLACE parameter will replace the view if it already exists.
CREATE [OR REPLACE] VIEW view_name AS
SELECT column(s)
FROM table(s)
[WHERE condition(s)];
```

```sql
-- Drops the view
DROP VIEW [IF EXISTS] view_name
[CASCADE | RESTRICT];
```

## Updatable Views

A PostgreSQL view is updatable when it meets the following conditions:

-   The defining query of the view **must have exactly one entry** in the `FROM` clause, which can be a table or another updatable view.
-   The defining query **must not contain** one of the following clauses at the top level: `GROUP BY`, `HAVING`, `LIMIT`, `OFFSET`, `DISTINCT`, `WITH`, `UNION`, `INTERSECT`, and `EXCEPT`.
-   The selection list **must not contain** any `window function`, any `set-returning function`, or any `aggregate function`

## Materialized Views

-   Materialized views cache the result of a complex and expensive query and allow us to refresh this result periodically.

```sql
CREATE MATERIALIZED VIEW view_name
AS
query
WITH [NO] DATA;

-- if we want to load data into the materialized view at the creation time,
-- use the `WITH DATA` option; otherwise, we use `WITH NO DATA`.
-- In case we use `WITH NO DATA`, the view is flagged as unreadable.
-- It means that we cannot query data from the view until we load data into it.
```

```sql
REFRESH MATERIALIZED VIEW view_name;

-- When we refresh data for a materialized view, PostgreSQL locks the entire table
-- therefore we cannot query data against it.
-- To avoid this, we can use the `CONCURRENTLY` option.
-- For using this, we need to create a `UNIQUE` index for the view first
CREATE UNIQUE INDEX index_name ON view_name (column);
REFRESH MATERIALIZED VIEW CONCURRENTLY view_name;
```

```sql
DROP MATERIALIZED VIEW view_name;
```

# SEQUENCE

-   Ordered list of integers
-   A sequence in PostgreSQL is a user-defined schema-bound object that generates a sequence of integers based on a specified specification.
-   If sequence is owned by some table column, dropping the table will also drop the sequence automatically.

```sql
-- Creating a sequence
CREATE SEQUENCE [ IF NOT EXISTS ] sequence_name
    [ AS { SMALLINT | INT | BIGINT } ]
    [ INCREMENT [ BY ] increment ]
    [ MINVALUE minvalue | NO MINVALUE ]
    [ MAXVALUE maxvalue | NO MAXVALUE ]
    [ START [ WITH ] start ]
    [ CACHE cache ]
    [ [ NO ] CYCLE ]
    [ OWNED BY { table_name.column_name | NONE } ]

-- Demo
CREATE SEQUENCE order_item_id
START 10
INCREMENT 10
MINVALUE 10
OWNED BY order_details.item_id;
```

```sql
-- Getting next value of the sequence
SELECT NEXTVAL('mysequence');
```

```sql
-- List all sequences in the database
SELECT relname AS sequence_name
FROM  pg_class
WHERE  relkind = 'S';
```

```sql
-- Deleting sequences
DROP SEQUENCE [ IF EXISTS ] sequence_name [, ...]
[ CASCADE | RESTRICT ];
```

# Conditional Expressions

```sql
-- Method1: (Similar to `if-else`)
CASE
    WHEN condition_1 THEN result_1
    WHEN condition_2 THEN result_2
    [WHEN ...]
    [ELSE else_result]
END

-- Method2: (Similar to `switch`)
CASE expression
   WHEN value_1 THEN result_1
   WHEN value_2 THEN result_2
   [WHEN ...]
ELSE
   else_result
END

-- DEMO
SELECT title,
       length,
       CASE
            WHEN length > 0
                AND length <= 50 THEN 'Short'
            WHEN length > 50
                AND length <= 120 THEN 'Medium'
            WHEN length> 120 THEN 'Long'
       END duration
FROM film
ORDER BY title;

-- DEMO
SELECT SUM (
        CASE
            WHEN rental_rate = 0.99 THEN 1
            ELSE 0
        END
    ) AS "Economy"
FROM film;

-- DEMO
SELECT title,
       rating,
       CASE rating
            WHEN 'G'     THEN 'General Audiences'
            WHEN 'PG'    THEN 'Parental Guidance Suggested'
            WHEN 'PG-13' THEN 'Parents Strongly Cautioned'
            WHEN 'R'     THEN 'Restricted'
            WHEN 'NC-17' THEN 'Adults Only'
            ELSE 'UNKOWN'
       END rating_description
FROM film
ORDER BY title;
```

# Useful Functions

## CAST

```sql
-- Convert a value of one data type into another
CAST(expression AS target_type);

-- Cast operator `::`
expression::target_type
```

## COALESCE

```sql
-- It returns the first argument that is not NULL.
-- Accepts an unlimited number of arguments.
-- If all arguments are NULL, the COALESCE function will return NULL.

-- DEMO
SELECT product,
    (price - COALESCE(discount, 0)) AS net_price
FROM items;
```

## NULLIF

```sql
-- Returns a null value if argument_1 equals to argument_2,
-- otherwise it returns argument_1
NULLIF(argument_1, argument_2);

-- DEMO
SELECT id,
    title,
    COALESCE(NULLIF(excerpt, ''), LEFT(body, 40))
FROM posts;
```

## RANDOM

-   Returns a random number between 0 and 1.

```sql
SELECT RANDOM();

-- Generate random number as an integer
SELECT FLOOR(RANDOM() * (high - low + 1) + low)::INT;
```

## GENERATE_SERIES

-   Generates a series of integers between two integers

```sql
SELECT GENERATE_SERIES(1, 5);
```

## Get Database Object Sizes

```sql
-- Values
SELECT PG_COLUMN_SIZE(5::INT);

-- Tables
SELECT PG_SIZE_PRETTY(PG_RELATION_SIZE('table_name'));  -- Human Readable
SELECT PG_TOTAL_RELATION_SIZE('table_name'));

-- Database
SELECT PG_DATABASE_SIZE('dbname'));

-- Indexes
SELECT PG_INDEXES_SIZE('index_name'));

-- Tablespace
SELECT PG_TABLESPACE_SIZE('tablespace_name'));
```

# Database Users and Privileges

## Users, Groups and Roles

-   **Users**, **Roles** and **Groups** are all represented as `Roles` in PostgreSQL
    -   We have different commands available for each, but still they all will be created as `Roles`

```sql
-- Create a user
-- User by default has `login` privileges
CREATE USER uname
[WITH]
    SYSID uid
    | CREATEDB | NOCREATEDB
    | CREATEUSER | NOCREATEUSER
    | IN GROUP groupname [, ...]   -- list of groups in which user should be added to
    | [ ENCRYPTED | UNENCRYPTED ] PASSWORD 'password'
    | VALID UNTIL 'abstime';

-- List set of existing users
SELECT username FROM pg_user;   -- \du

-- Drop user
DROP USER uname;
```

```sql
-- Create Group
CREATE GROUP gname
[WITH]
    SYSID gid
   | USER  username [, ...]  -- list of users to include in the group

-- Add or remove user
ALTER GROUP gname ADD USER uname [, ...];
ALTER GROUP gname DROP USER uname [, ...];

-- List set of existing groups
SELECT groname FROM pg_group;   -- \dg
```

```sql
-- Create Role
CREATE ROLE role_name
[WITH]
    SUPERUSER | NOSUPERUSER
    | CREATEDB | NOCREATEDB
    | CREATEROLE | NOCREATEROLE
    | CREATEUSER | NOCREATEUSER
    | INHERIT | NOINHERIT
    | LOGIN | NOLOGIN
    | CONNECTION LIMIT connlimit    -- No. of concurrent connections a role can make
    | [ ENCRYPTED | UNENCRYPTED ] PASSWORD 'password'
    | VALID UNTIL 'timestamp'
    | IN ROLE rolename [, ...]
    | IN GROUP rolename [, ...]
    | ROLE rolename [, ...]     -- Creates the newrole a group
    | ADMIN rolename [, ...]
    | USER rolename [, ...]
    | SYSID uid

-- The ADMIN clause is like ROLE, but the named roles are added to the new role
-- WITH ADMIN OPTION, giving them the right to grant membership in this role to others

-- List set of existing roles
SELECT rolname FROM pg_roles;  -- `\du`
```

### Client Authentication

```bash
# `peer` tries to connect with the database with system credentials

# To be able to login with different users
# we need to change the authentication mechanism from `peer` to `md5`
sudo nano /etc/postgresql/<version>/main/pg_hba.conf
# Change below line
local   all             all              peer
# To
local   all             all              md5

# We need to restart the `postgresql` service after changing above file

# We can have separate authentication mechanism for `postgres` and linux user as well
local   all             postgres         trust  # Won't ask for password
local   all             mayank           peer
local   all             all              md5
```

```bash
$ psql -U uname     # ERROR
# Since we haven't mentioned any database, postgres will
# try to find a database with a same name as this user

# Either create a database with the same name as the user

# Or mention the database name in the command
$ psql -U uname -d dbname

$ psql -d dbname    # Will login with the default system user
```

## GRANT and REVOKE

-   To allow the user role to interact with database objects, we need to grant privileges on the database objects to the user role by using the `GRANT` statement.
-   The `REVOKE` statement revokes previously granted privileges on database objects from a role.
-   `ALTER` and `DROP` permissions are only given to the superuser and owner of the table.

```sql
GRANT privilege_list | ALL
ON [TABLE] table_name | ALL TABLES IN SCHEMA schema_name
TO  role_name;

GRANT privilege_list | ALL
ON DATABASE dbname
TO role_name;

-- privilege_list can be `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, etc.
```

```sql
REVOKE privilege | ALL
ON TABLE table_name | ALL TABLES IN SCHEMA schema_name
FROM role_name;
```

```sql
-- See privileges on a table
SELECT grantee,
    table_name,
    STRING_AGG(
        DISTINCT privilege_type,
        ', '
        ORDER BY privilege_type ASC
    ) AS privileges
FROM information_schema.role_table_grants
WHERE table_name = 'table_name'
GROUP BY grantee,
    table_name;


-- psql \z command: To obtain info about existing privileges
-- \z table_name
=> \z mytable

                        Access privileges for database "lusitania"
 Schema |  Name   | Type  |                     Access privileges
--------+---------+-------+-----------------------------------------------------------
 public | mytable | table | {miriam=arwdRxt/miriam,=r/miriam,"group todos=arw/miriam"}
(1 row)

-- Interpretation
              =xxxx -- privileges granted to PUBLIC
         uname=xxxx -- privileges granted to a user
   group gname=xxxx -- privileges granted to a group

                  r -- SELECT ("read")
                  w -- UPDATE ("write")
                  a -- INSERT ("append")
                  d -- DELETE
                  R -- RULE
                  x -- REFERENCES
                  t -- TRIGGER
                  X -- EXECUTE
                  U -- USAGE
                  C -- CREATE
                  T -- TEMPORARY
            arwdRxt -- ALL PRIVILEGES (for tables)
                  * -- grant option for preceding privilege

              /yyyy -- user who granted this privilege
```

## Role Membership

-   It is easier to manage roles as a group so that we can grant or revoke privileges from a group as a whole instead of doing it on an individual role.
-   We create a role that represents a group and then grants membership in the group role to individual roles.
-   By convention, a group role does not have the `LOGIN` privilege, it means that we will not be able to use the group role to log in to PostgreSQL.

```sql
CREATE ROLE group_role_name;

CREATE ROLE user_role;

GRANT group_role to user_role;
```

A role can use privileges of the group role in the following ways:

-   First, a role with the `INHERIT` attribute will automatically have privileges of the group roles of which it is the member, including any privileges inherited by that role.
    -   The `INHERIT` attribute governs inheritance of grantable privileges (that is, access privileges for database objects and role memberships).
    -   It does not apply to the special role attributes set by `CREATE ROLE` and `ALTER ROLE`. For example, being a member of a role with `CREATEDB` privilege does not immediately grant the ability to create databases, even if `INHERIT` is set; it would be necessary to become that role via `SET ROLE` before creating a database.
    -   Be careful with the `CREATEROLE` privilege. There is no concept of inheritance for the privileges of a `CREATEROLE`-role.
-   Second, a role can use the `SET ROLE role_name;` statement to temporarily become the group role. The role will have privileges of the group role rather than its original login role. Also, the objects are created by the role are owned by the group role, not the login role.

```sql
-- DEMO
CREATE ROLE sales_manager;

CREATE DATABASE sales;

GRANT ALL ON DATABASE sales TO sales_manager;

CREATE ROLE ben
WITH LOGIN PASSWORD 'ben';

GRANT sales_manager TO ben;

REVOKE CONNECT ON DATABASE sales FROM PUBLIC;
-- Any other user will not be able to connect to this database
-- Only superusers and those explicitly given privilege access
-- (in this case sales_manager group, and hence to ben as well) will be able
-- to connect to that database
```

# Transactions

-   **Definition**: A transaction is a logical unit of work that contains one or more than one SQL statements where either all statements will succeed or all will fail.\
    The intermediate states between the steps are not visible to other concurrent transactions, and if some failure occurs that prevents the transaction from completing, then none of the steps affect the database at all.
-   **Properties**:
    -   `Atomicity`: This property ensures that all the operations of the transactions are complete. It follows all or none property i.e. the transaction should not be partially completed.
    -   `Consistency`: This property ensures that after all the transactions database is in consistent state i.e. after committing the transaction those changes are properly updated in the database or not.
    -   `Isolation`: When two transactions are running then both the transactions will have their own privacy i.e. one transaction won't disturb another transaction
    -   `Durability`: This property ensures that even at the time of system failures the committed data in the database is secure i.e. permanently.
-   **Commands**:
    -   `BEGIN`: Used to start a transaction block
    -   `COMMIT`: Used to save changes to the database
    -   `ROLLBACK`: Undoes the changes that were issued in the transaction block before it, either fully or till the last **savepoint**
    -   `SAVEPOINT`: Helps in defining the boundary withing a transaction that allows for a partial rollback. It also gives the user the ability to roll the transaction back to a certain point without rolling back the entire transaction.

```sql
-- Begin a transaction (any way)
BEGIN [TRANSACTION | WORK] [transaction_mode, ...];

-- where transaction_mode is one of:
ISOLATION LEVEL {SERIALIZABLE | READ COMMITTED}
READ WRITE | READ ONLY

-- Isolation level of a transaction determines what data the transaction
-- can see when other transactions are running concurrently
READ COMMITTED -- (default) A statement can only see rows committed before it began
SERIALIZABLE   -- All statements of the current transaction can only see rows
               -- committed before the first query or data-modification statement
               -- was executed in this transaction.

-- Access modes
READ WRITE  -- (default)
READ ONLY   -- Prevents all writes to the disk
```

```sql
-- Commit a transaction (any way)
COMMIT [TRANSACTION | WORK];
-- If any SQL statement throws an error, then the COMMIT will not be executed
-- and the transaction will be rolled back automatically.

-- Rolling back a transaction (any way)
ROLLBACK [TRANSACTION | WORK];

-- Creating a savepoint
SAVEPOINT savepoint_name;

-- Rolling back a transaction to a certain savepoint
ROLLBACK TO [SAVEPOINT] savepoint_name;

-- Destroying a previously defined savepoint
-- Makes it unavailable as a rollback point.
RELEASE [SAVEPOINT] savepoint_name;
```

```sql
-- DEMO

-- BEGIN-SAVEPOINT-ROLLBACK-COMMIT
BEGIN;
...<sql_statements>...
SAVEPOINT first_savepoint;
...<sql_statements>...
ROLLBACK TO first_savepoint;
COMMIT;

-- BEGIN-ROLLBACK
BEGIN;
...<sql_statements>...
ROLLBACK;

-- BEGIN-COMMIT
BEGIN;
...<sql_statements>...
COMMIT;

-- Inside Procedures
CREATE [OR REPLACE] PROCEDURE proc_name(parameter_list)
LANGUAGE PLPGSQL
AS $$
DECLARE
    -- local variable declarations
BEGIN
    ...<sql_statements>...
    COMMIT;
    ...<sql_statements>...
    COMMIT;
    ...
END;
$$;
```

# Indexing

Indexing is the technique used for accessing the contents of a database quickly.

## Index Types

-   **B-Tree**: A B-Tree index breaks down the database into a tree like structure, with the starting node being the root node and finally terminating with the leaf node.
    -   Use B-tree index whenever index columns are involved in a comparison that uses one of the following operators:
        ```sql
        <
        <=
        =
        >=
        BETWEEN
        IN
        IS NULL
        IS NOT NULL
        ```
        ```sql
        LIKE
        ILIKE
        ~ '^...'
        ~*
        ```
-   **Hash**: A Hash index is a data structure which accelerates query searches. It uses a key and a hash function for this purpose.
    -   Hash indexes can handle only simple equality comparison `(=)`
-   **GIN (Generalized Inverted Index)**: GIN indexes are most useful when you have multiple values stored in a single column. Ex: array

## Creating an Index

```sql
CREATE [UNIQUE] INDEX index_name
ON table_name [USING method]
(
    column_name [ASC | DESC] [NULLS {FIRST | LAST}],
    ...
)
[WHERE condition];

-- UNIQUE enforces the uniqueness of values in one or multiple columns

-- Index method could be:
BTREE -- Default
HASH, GIN, GIST, SPGIST, BRIN

-- ASC and DESC specify the sort order
ASC -- Default


-- `NULLS FIRST` and `NULL LAST` specifies nulls sort before or after non-nulls
NULLS FIRST -- Default when DESC is specified
NULLS LAST  -- Default when DESC is not specified

-- `WHERE` condition will make this index a partial index
```

```sql
ANALYZE -- Returns the time to execute the query
EXPLAIN -- Tells the execution plan of the query

EXPLAIN ANALYZE
<query>;

-- Example
EXPLAIN ANALYZE
SELECT *
FROM <table>;
```

```sql
-- After creating the index, the query time can be enhanced or slowed down
EXPLAIN ANALYZE
<query>;
```

## Dropping an Index

```sql
-- Dropping an index
DROP INDEX  [ CONCURRENTLY]
[ IF EXISTS ]  index_name
[ CASCADE | RESTRICT ];
```

## List Indexes

```sql
-- List all the indexes of the `public` schema
SELECT
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'public'
ORDER BY
    tablename,
    indexname;
```

```sql
-- List all the indexes of a particular table
SELECT
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    tablename = 'table_name';
```

```sql
-- psql
\d table_name
```

## Index on Expression

```sql
CREATE INDEX index_name
ON table_name (expression);
```

-   Once you define an index expression, PostgreSQL will consider using that index when the expression that defines the index appears in the `WHERE` clause or in the `ORDER BY` clause of the SQL statement.
-   Indexes on expressions are quite expensive to maintain

## Re-Index

-   In practice, an index can become corrupted and no longer contains valid data due to hardware failures or software bugs. To recover the index, we can use the `REINDEX` statement:

```sql
REINDEX [ ( VERBOSE ) ] { INDEX | TABLE | SCHEMA | DATABASE | SYSTEM } name;
```

## Example

```sql
-- Creating a Table
CREATE TABLE sample (
	title TEXT,
	treatment TEXT
);

-- Add random 10000 tuples to the table
INSERT INTO sample2(title2, treatment2)
SELECT MD5(RANDOM()::TEXT), MD5(RANDOM()::TEXT)
FROM (
	SELECT *
	FROM generate_series(1, 10000) AS id
) AS x;

-- Analyzing this query
EXPLAIN ANALYZE
SELECT *
FROM sample2
WHERE title2 ILIKE '%eca%';

-- Extension for the operators used
CREATE EXTENSION pg_trgm;

-- Indexing the table
CREATE INDEX sample2_index2
ON sample2
USING GIN(title2 GIN_TRGM_OPS, treatment2 GIN_TRGM_OPS);
```

-   When defining a **multi-column index**, you should place the columns which are often used in the `WHERE` clause at the beginning of the column list and the columns that are less frequently used in the condition after.
