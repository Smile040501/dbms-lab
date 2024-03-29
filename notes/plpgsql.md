# PostgreSQL PL/pgSQL

PL/pgSQL procedural language adds many procedural elements, e.g., control structures, loops, and complex computations, to extend standard SQL. It allows us to develop complex functions and stored procedures in PostgreSQL that may not be possible using plain SQL.

- [PostgreSQL PL/pgSQL](#postgresql-plpgsql)
- [Getting Started](#getting-started)
  - [Dollar-Quoted String Constants](#dollar-quoted-string-constants)
  - [Block Structure](#block-structure)
    - [DO Block](#do-block)
- [Variables and Constants](#variables-and-constants)
  - [Variables](#variables)
  - [Row Type Variables](#row-type-variables)
  - [Record Type Variables](#record-type-variables)
- [Executing SQL Commands](#executing-sql-commands)
  - [INTO clause](#into-clause)
  - [Doing Nothing at all](#doing-nothing-at-all)
  - [Executing Dynamic Commands](#executing-dynamic-commands)
- [Reporting Messages and Errors](#reporting-messages-and-errors)
  - [Raising Errors and Reporting Messages](#raising-errors-and-reporting-messages)
  - [Assert](#assert)
- [Control Structures](#control-structures)
  - [IF Statement](#if-statement)
  - [CASE Statement](#case-statement)
  - [LOOP Statement](#loop-statement)
    - [While Loops](#while-loops)
    - [For Loops](#for-loops)
    - [EXIT Statement](#exit-statement)
    - [CONTINUE Statement](#continue-statement)
- [User-defined Functions](#user-defined-functions)
  - [Creating Functions](#creating-functions)
    - [Calling a user-defined function](#calling-a-user-defined-function)
  - [Function Parameter Modes](#function-parameter-modes)
  - [Function that returns a Table](#function-that-returns-a-table)
  - [Security Invoker/Definer](#security-invokerdefiner)
  - [Drop Function](#drop-function)
- [Stored Procedures](#stored-procedures)
- [Triggers](#triggers)
  - [Create a Trigger](#create-a-trigger)
    - [Return Value](#return-value)
    - [Special Variables](#special-variables)
  - [Drop a Trigger](#drop-a-trigger)
  - [Alter a Trigger](#alter-a-trigger)
  - [Disable and Enable a Trigger](#disable-and-enable-a-trigger)
- [Exception Handling](#exception-handling)

# Getting Started

## Dollar-Quoted String Constants

```sql
SELECT 'String constant';
SELECT 'I''m also a string constant';

-- Problem comes when we need to use single quotes and backslashes in the string
-- We need to use escape characters
```

```sql
$tag$<string_constant>$tag$

-- Tag is optional
SELECT $$I'm a string constant that contains a backslash \$$;
```

-   Always provide a **tag** when using it with `EXECUTE` command to write an SQL query string.

## Block Structure

```sql
[ <<label>> ]
[ DECLARE
    declarations ]
BEGIN
    statements;
	...
END [ label ];
```

### DO Block

-   Execute an anonymous code block

```sql
DO $$
[ <<label>> ]
[ DECLARE
    declarations ]
BEGIN
    statements;
	...
END [ label ];
$$;
```

# Variables and Constants

## Variables

-   A variable holds a value that can be changed through the block.
-   Before using a variable, we must declare it in the declaration section of the PL/pgSQL block.
-   If we don't assign any initial value to a variable at declaration, it will be `NULL`

```sql
variable_name data_type [:= expression];
constant_variable_name CONSTANT data_type := expression;

-- Copy data type of a column or other variable
variable_name table_name.column_name%TYPE;
variable_name variable%TYPE;
```
## Row Type Variables

-   To store the whole row of a result set returned by the select into statement, we use the row-type variable or row variable.

```sql
row_variable table_name%ROWTYPE;
row_variable view_name%ROWTYPE;

-- To access the individual field of the row
row_variable.field_name
```

## Record Type Variables

-   Similar to row-type variables
-   It can hold only one row of a result set
-   Unlike a row-type variable, a `RECORD` variable does not have a predefined structure. The structure of a `RECORD` variable is determined when the `SELECT` or `FOR` statement assigns an actual row to it.

```sql
record_variable RECORD;

-- To access the individual field of the row
record_variable.field_name
```

# Executing SQL Commands

-   Any SQL command that does not return rows can be executed within a PL/pgSQL function just by writing the command
-   If the command does return rows (for example `SELECT`, or `INSERT/UPDATE/DELETE` with `RETURNING`):
    -   When command returns at most one row or we only care about the first row of output, add an `INTO` clause to capture the output
    -   If we want all the rows, use the command as the data source for a `FOR` loop
-   Sometimes it is useful to evaluate an expression or SELECT query but discard the result, for example when calling a function that has side-effects but no useful result value.
    ```sql
    -- Replace SELECT keyword with PERFORM
    PERFORM query;

    -- Example
    PERFORM validate_input(...);
    ```
-   Commands involving dynamic data values:
    -   For optimizable SQL commands, which are `SELECT`, `INSERT`, `UPDATE`, `DELETE`, variable name appearing in the command text is replaced by a query parameter and its value is placed dynamically
    -   Non-optimizable SQL commands (also called utility commands) are not capable of accepting query parameters. **We need to build the utility command as a string and then `EXECUTE` it**.

## INTO clause

-   Allows us to select data from the database and assign the data to a variable.
-   It can also add data to another table.

```sql
SELECT select_expressions INTO [STRICT] target FROM ...;
INSERT ... RETURNING expressions INTO [STRICT] target;
UPDATE ... RETURNING expressions INTO [STRICT] target;
DELETE ... RETURNING expressions INTO [STRICT] target;
```

-   If `STRICT` is not specified in the `INTO` clause, then target will be set to the first row returned by the command, or to nulls if the command returned no rows
-   We can check the special **`FOUND`** variable to determine whether a row was returned:
    -   A `SELECT INTO` statement sets `FOUND` true if a row is assigned, false if no row is returned.
    -   A `PERFORM` statement sets `FOUND` true if it produces (and discards) one or more rows, false if no row is produced.
    -   `UPDATE`, `INSERT`, and `DELETE` statements set `FOUND` true if at least one row is affected, false if no row is affected.
    ```sql
    SELECT select_expressions INTO target FROM ...;

    IF NOT FOUND THEN
        RAISE EXCEPTION '...';
    END IF;
    ```
-   If the `STRICT` option is specified, the command must return exactly one row or a run-time error will be reported, either `NO_DATA_FOUND` (no rows) or `TOO_MANY_ROWS` (more than one row).
    ```sql
    BEGIN
        SELECT select_expressions INTO STRICT target FROM ...;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE EXCEPTION 'not found';
            WHEN TOO_MANY_ROWS THEN
                RAISE EXCEPTION 'not unique';
    END;
    ```
-   For `INSERT/UPDATE/DELETE` with `RETURNING`, PL/pgSQL reports an error for more than one returned row, even when `STRICT` is not specified

## Doing Nothing at all

```sql
IF expression THEN
    NULL;   -- Placeholder statement that does nothing
END IF;
```

## Executing Dynamic Commands

```sql
EXECUTE command-string
    [ INTO [STRICT] target ]
    [ USING expression [, ... ] ];

-- command-string (type TEXT): command to be executed
-- target: location to store the result of the command
-- `USING`: supply values to be inserted into the command
```

-   The command string can use parameter values, which are referenced in the command as `$1`, `$2`, etc. These symbols refer to values supplied in the `USING` clause
    -   This method is often preferable to inserting data values into the command string as text: it avoids run-time overhead of converting the values to text and back, and it is much less prone to SQL-injection attacks since there is no need for quoting or escaping.
    ```sql
    EXECUTE 'SELECT count(*) FROM mytable WHERE inserted_by = $1 AND inserted <= $2'
    INTO c
    USING checked_user, checked_date;
    ```
-   Note that parameter symbols can only be used for data values only on optimizatble SQL commands.\
    We can use **FORMAT()'s `%I`** specification to insert table or column names with automatic quoting
    ```sql
    EXECUTE format('SELECT count(*) FROM %I '
    'WHERE inserted_by = $1 AND inserted <= $2', tabname)
    INTO c
    USING checked_user, checked_date;

    -- This example relies on the SQL rule that string literals separated by a newline are implicitly concatenated.
    ```
-   `QUOTE_IDENT`: Returns the given string suitable quoted to be used as an identifier in an SQL statement. Embedded quotes are properly doubled.\
    **Identifiers** are names of tables, columns, schemas, sequences...
    ```sql
    QUOTE_IDENT('tablename')    -> tablename
    QUOTE_IDENT('special name') -> "special name"
    ```
-   `QUOTE_LITERAL`: Returns the given string suitably quoted to be used as a string literal in an SQL statement string. Embedded single-quotes and backslashes are properly doubled.\
    **Literals** are some text values.
    ```sql
    QUOTE_LITERAL('some \\ text with \' char') -> 'some \\\\ text with '' char'
    ```
-   `FORMAT`: Formats arguments according to a format string.
    ```sql
    FORMAT(formatstr TEXT, formatarg "ANY")

    -- Format specifiers
    %[position][flag][width]type

    position : n$   -> n is index of the argument
    width    : Minimum number of characters
    flags    : '-' : For left justified

    type :
    -   `s`: Formats as simple string. Null is empty string
    -   `I`: Treat the argument value as SQL identifier
    -   `L`: Treat the argument value as SQL literal

    `%%` : To output % character
    ```
-   Example:
    ```sql
    CREATE OR REPLACE FUNCTION create_user(
        uname VARCHAR,
        pwd VARCHAR
    )
    RETURNS VOID
    AS $$
    BEGIN

    EXECUTE FORMAT($f$CREATE USER %I IN GROUP users PASSWORD '%s'$f$, uname, pwd);

    END;
    $$ LANGUAGE PLPGSQL;
    ```


# Reporting Messages and Errors

## Raising Errors and Reporting Messages

```sql
-- To raise a message, we can use `RAISE` statement

RAISE <level_option> <format_message>
-- EXCEPTION (default)
-- DEBUG
-- LOG
-- NOTICE
-- INFO
-- WARNING

-- `format_message` uses percentage `%` placeholders
-- that will be substituted by the arguments.

-- DEMO
DO $$
BEGIN
    RAISE NOTICE 'Notice Message %', NOW();
END;
$$;
```

```sql
-- Options with exceptions
RAISE EXCEPTION <format_string>
USING <option_name> = <expression_string>

-- option_name can be
MESSAGE  -- set error message
HINT     -- Provide the hint message so that the root cause
         -- of the error is easier to be discovered.
DETAIL   -- Give detailed info about the error
ERRCODE  -- Identify the error code
         -- Can either be a condition name
         -- or a 5-character `SQLSTATE` code

-- DEMO
DO $$
BEGIN
    RAISE EXCEPTION 'duplicate email: %', email
        USING HINT = 'check the email again';

    RAISE SQLSTATE '2210b';

    RAISE INVALID_REGULAR_EXPRESSION;
END;
$$;
```

## Assert

```sql
ASSERT condition [, message];

-- DEMO
DO $$
BEGIN
    ASSERT film_count > 0, 'Film not found, check the film table';
END;
$$;
```

# Control Structures

## IF Statement

```sql
IF condition1 THEN
   statements1;
ELSIF condition2 THEN
    statements2;
...
ELSE
    alternate-statements;
END IF;
```

## CASE Statement

```sql
-- Method1: (Similar to `switch`)
CASE expression
    WHEN expression_1 [, expression_2, ...] THEN
        statements_1;
    [...]
    ELSE
        else_statements;
END CASE;

-- Method2: (Similar to `if-else`)
CASE
    WHEN condition_1 THEN
        statements_1;
    [WHEN condition_2 THEN
        statements_2;
    ...]
    [ELSE
        else_statements;]
END CASE;
```

## LOOP Statement

-   The `LOOP` defines an unconditional loop that executes a block of code repeatedly until terminated by an `EXIT` or `RETURN` statement.

```sql
<<label>>
LOOP
    statements;
END LOOP;

-- Nested
<<outer>>
LOOP
    statements;
    <<inner>>
    LOOP
        /* ... */
        exit <<inner>>
    END LOOP;
END LOOP;
```

### While Loops

```sql
-- Syntax
[ <<label>> ]
WHILE condition LOOP
    statements;
END LOOP;

-- DEMO
DO $$
DECLARE
    counter INT := 0;
BEGIN
    WHILE counter < 5 LOOP
        RAISE NOTICE 'Counter %', counter;
        counter := counter + 1;
    END LOOP;
END;
$$;
```

### For Loops

```sql
-- Syntax
[ <<label>> ]
FOR loop_counter IN [ REVERSE ] FROM..TO [ BY step ] LOOP
    statements
END LOOP [label];

-- DEMO
DO $$
BEGIN
    FOR counter IN 1..5 LOOP
        RAISE NOTICE 'Counter: %', counter;
    END LOOP;
END;
$$;
```

```sql
-- Syntax to iterate over a query set
[ <<label>> ]
FOR variable IN (query) LOOP
    statements;
END LOOP [ label ];

-- DEMO
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN (SELECT film_id,
                    title
                FROM film
                ORDER BY film_id ASC
                )
    LOOP
        RAISE NOTICE 'film_id: %, title: %', rec.film_id, rec.title;
    END LOOP;
END;
$$;
```

```sql
-- Dynamic Query Example
DO $$
DECLARE
    -- sort by 1: title, 2: release year
    sort_type SMALLINT := 1;
	-- return the number of films
	rec_count INT := 10;
	-- use to iterate over the film
	rec RECORD;
	-- dynamic query
    query TEXT;
BEGIN
	query := 'SELECT title, release_year FROM film ';

	IF sort_type = 1 THEN
		query := query || 'ORDER BY title';
	ELSIF sort_type = 2 THEN
	    query := query || 'ORDER BY release_year';
	ELSE
	    RAISE 'invalid sort type %s', sort_type;
	END IF;

	query := query || ' LIMIT $1';

	FOR rec IN EXECUTE query USING rec_count LOOP
	    RAISE NOTICE '% - %', rec.release_year, rec.title;
	END LOOP;
END;
$$;
```

### EXIT Statement

-   The `EXIT` statement allows us to terminate a loop including an unconditional loop, a while loop, and a for loop.
-   It can be used to terminal a block as well.

```sql
-- Syntax
EXIT [block/loop_label] [WHEN condition];
```

### CONTINUE Statement

-   The `CONTINUE` statement prematurely skips the current iteration of the loop and jumps to the next one.
-   It can be used in all kinds of loops including unconditional loops, while loops, and for loops.

```sql
CONTINUE [block/loop_label] [WHEN condition];
```

# User-defined Functions

-   PostgreSQL also supports function overloading

## Creating Functions

```sql
-- Syntax
CREATE [OR REPLACE] FUNCTION function_name(param_list)
RETURNS return_type
AS $$
DECLARE
    -- local variable declarations
BEGIN
    -- logic
    -- `RETURN` to return a value from the function
END;
$$ LANGUAGE PLPGSQL;

-- DEMO
CREATE OR REPLACE FUNCTION square(x INT DEFAULT 0)
RETURNS INT
AS $$
DECLARE
    result INT;
BEGIN
    result = x * x;
    RETURN result;
END;
$$ LANGUAGE PLPGSQL;
```

### Calling a user-defined function

```sql
-- Positional Notation
SELECT square(23);

-- Named Notation
SELECT square(x => 23);

-- We can also use mixed notation
```

## Function Parameter Modes

|             IN             |                  OUT                   |                         INOUT                          |
| :------------------------: | :------------------------------------: | :----------------------------------------------------: |
|          Default           |          Explicitly specified          |                  Explicitly specified                  |
|  Pass a value to function  | Return multiple values from a function | Pass a value to a function and return an updated value |
|    Acts like constants     |   Acts like uninitialized variables    |            Acts like initialized variables             |
| Cannot be assigned a value |          Must assign a value           |               Should be assigned a value               |

```sql
-- DEMO
CREATE OR REPLACE FUNCTION get_film_stat(
    OUT min_len INT,
    OUT max_len INT,
    OUT avg_len NUMERIC
)
AS $$
BEGIN
    SELECT MIN(length),
        MAX(length),
        AVG(length)::NUMERIC(5, 1)
    INTO min_len,
        max_len,
        avg_len
    FROM film;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM get_film_stat();
```

```sql
-- Swap two variables
CREATE OR REPLACE FUNCTION swap(
    INOUT x INT,
    INOUT y INT
)
AS $$
BEGIN
    SELECT x,
        y
    INTO y,
        x;
END;
$$ LANGUAGE PLPGSQL;

SELECT swap(19, 13);
```

## Function that returns a Table

-   Need to define the return type of the table with the return type of columns
-   Use `RETURN QUERY` to return a query result

```sql
-- DEMO
CREATE OR REPLACE FUNCTION get_films(p_pattern VARCHAR)
RETURNS TABLE(
        film_title VARCHAR,
        film_release_year INT
)
AS $$
BEGIN
    RETURN QUERY
        SELECT title,
            release_year::INT
        FROM film
        WHERE title ILIKE p_pattern;
END;
$$ LANGUAGE PLPGSQL;

SELECT * FROM get_films('%Star Wars%');
```

## Security Invoker/Definer

```sql
-- Syntax
CREATE OR REPLACE FUNCTION function_name(param_list)
RETURNS return_type
AS $$
DECLARE
    -- local variable declarations
BEGIN
    -- logic
    -- `RETURN` to return a value from the function
END;
$$ LANGUAGE PLPGSQL
   SECURITY [INVOKER | DEFINER]
   -- Set a secure `search_path`: trusted schema(s), then `pg_temp`
   SET search_path = admin, pg_temp;
```

-   `SECURITY INVOKER` indicates that the function is to be executed with the privileges of the user that calls it. That is the **default**.
-   `SECURITY DEFINER` specifies that the function is to be executed with the privileges of the user that owns it.
-   `search_path`: This variable specifies the order in which schemas are searched when an object is referenced by a simple name with no schema specified.
    -   Default value: `"$user", public`
    -   `SHOW search_path;`
-   By default, execute privilege is granted to `PUBLIC` for newly created functions. Frequently we will wish to restrict use of a security definer function to only some users.
    ```sql
    BEGIN;
    CREATE FUNCTION check_password(uname TEXT, pass TEXT) ... SECURITY DEFINER;
    REVOKE ALL ON FUNCTION check_password(uname TEXT, pass TEXT) FROM PUBLIC;
    GRANT EXECUTE ON FUNCTION check_password(uname TEXT, pass TEXT) TO admins;
    COMMIT;
    ```

## Drop Function

```sql
DROP FUNCTION [IF EXISTS] function_name(argument_list)
[CASCADE | RESTRICT];
```

# Stored Procedures

-   A drawback of user-defined functions is that they cannot execute **transactions**. In other words, inside a user-defined function, we cannot start a transaction, and commit or rollback it.
-   Procedures don't return anything.\
    **However, we can use the `RETURN` statement without the expression to stop the stored procedure immediately**
-   Parameters in stored procedures can have the `IN` and `INOUT` modes. They cannot have the `OUT` mode.

```sql
CREATE [OR REPLACE] PROCEDURE proc_name(parameter_list)
AS $$
DECLARE
    -- local variable declarations
BEGIN
    -- stored procedure body
END;
$$ LANGUAGE PLPGSQL;

-- Calling a stored procedure
CALL stored_procedure_name(argument_list);
```

```sql
-- Drop stored procedure
DROP PROCEDURE [IF EXISTS] proc_name(argument_list)
[CASCADE | RESTRICT];
```

```sql
-- Display stored procedures code
SELECT prosrc
FROM pg_proc
WHERE proc_name='name';
```

# Triggers

-   A PostgreSQL **trigger** is a function invoked automatically whenever an event such as insert, update, or delete occurs.
-   A trigger is a special **user-defined function** associated with a table. To create a new trigger, we define a trigger function first, and then bind this trigger function to a table.
-   The difference between a trigger and a user-defined function is that a trigger is automatically invoked when a triggering event occurs.
-   PostgreSQL provides two main types of triggers: **row-level triggers** and **statement-level triggers**. The differences between the two kinds are how many times the trigger is invoked and at what time.
    -   For example, if we issue an `UPDATE` command, which affects 10 rows, the **row-level trigger** will be invoked **10 times**, on the other hand, the **statement-level trigger** will be invoked **1 time**.
-   We can specify whether the trigger is invoked **before** or **after** an event. If the trigger is invoked before an event, it can skip the operation for the current row or even change the row being updated or inserted. In case the trigger is invoked after the event, all changes are available to the trigger.
-   PostgreSQL requires us to define a user-defined function as the action of the trigger, while the SQL standard allows us to use any SQL commands.

## Create a Trigger

To create a new trigger in PostgreSQL, we follow these steps:

-   First, create a trigger function using `CREATE FUNCTION` statement.

    -   **A trigger function does not take any arguments and has a return value with the type `TRIGGER`**
    -   A trigger function receives data about its calling environment through a special structure called TriggerData which contains a set of local variables.
    -   `OLD` and `NEW` represent the states of the row in the table before or after the triggering event.
        -   **INSERT** → we can use only NEW\
            **UPDATE** → we can use both\
            **DELETE** → we can use only OLD

    ```sql
    -- User-defined trigger function
    CREATE FUNCTION trigger_function()
    RETURNS TRIGGER
    AS $$
    BEGIN
        -- trigger logic
    END;
    $$ LANGUAGE PLPGSQL;
    ```

-   Second, bind the trigger function to a table by using `CREATE TRIGGER` statement.

    ```sql
    CREATE [ OR REPLACE ] TRIGGER trigger_name
    { BEFORE | AFTER | INSTEAD OF } { event }
    ON table_name
    [ FOR [EACH] { ROW | STATEMENT } ]
    [ WHEN ( condition ) ]
    EXECUTE { FUNCTION | PROCEDURE } trigger_function (arguments);

    # where event can be one of:
        INSERT
        UPDATE [ OF column_name [, ...] ]
        DELETE
        TRUNCATE
    ```

    -   The `WHEN` condition can refer to columns of the old and/or new row values using `OLD` and `NEW` keywords.
    -   Procedures and functions are equivalent when we talk about triggers as functions are not taking any arguments.

**Example**

```sql
CREATE OR REPLACE FUNCTION log_insert()
RETURNS TRIGGER
AS $$
BEGIN
    RAISE NOTICE 'INSERT: %', NEW;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER log_insert_trigger
AFTER UPDATE
ON accounts
FOR EACH ROW
WHEN (OLD.* IS DISTINCT FROM NEW.*)
EXECUTE FUNCTION log_insert();
```

### Return Value

-   A trigger function must return either `NULL` or a record/row value having exactly the structure of the table the trigger was fired for.
-   Returning `NULL` from **row-level triggers** fired `BEFORE` signals the trigger manager to skip the rest of the operation for this row (**i.e. subsequent triggers are not fired, and the `INSERT/UPDATE/DELETE` does not occur for this row**)
-   If a **non-NULL** value is returned then the operation proceeds with that row value.
-   To alter the row to be stored, it is possible to replace single values directly in `NEW` and return the modified `NEW`, or to build a complete new record/row to return
-   In the case of a **before-trigger** on `DELETE`, the returned value has no direct effect, but it has to be **non-NULL** to allow the trigger action to proceed. Usually it is `OLD`.
-   The return value of a **row-level trigger fired `AFTER`** or a **statement-level trigger** fired BEFORE or AFTER is always ignored, it might as well be NULL. However, any of these types of triggers might still abort the entire operation by **raising an error**.
### Special Variables

```
NEW:
    Data type RECORD
    Hold new DB row for INSERT/UPDATE operations in row-level triggers
    NULL in statement-level-triggers and for DELETE operations

OLD:
    Data type RECORD
    Hold new DB row for UPDATE/DELETE operations in row-level triggers
    NULL in statement-level-triggers and for INSERT operations

TG_WHEN:
    Data type TEXT
    'BEFORE', 'AFTER', 'INSTEAD OF'

TG_LEVEL:
    Data type TEXT
    'ROW', 'STATEMENT'

TG_OP:
    Data type TEXT
    'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE'

TG_TABLE_NAME:
    Data type NAME
    Name of the table that caused the trigger invocation

TG_NARGS:
    Data type INTEGER
    Number of arguments given to the trigger procedure

TG_ARGV[]:
    Data type TEXT[]
    The arguments. Index count from 0. Invalid indexes results in NULL value.
```

## Drop a Trigger

```sql
DROP TRIGGER [IF EXISTS] trigger_name
ON table_name [ CASCADE | RESTRICT ];
```

## Alter a Trigger

```sql
ALTER TRIGGER trigger_name
ON table_name
RENAME TO new_trigger_name;
```

## Disable and Enable a Trigger

```sql
ALTER TABLE table_name
DISABLE TRIGGER trigger_name | ALL;
```

```sql
ALTER TABLE table_name
ENABLE TRIGGER trigger_name |  ALL;
```

# Exception Handling

-   When an error occurs in a block, PostgreSQL will abort the execution of the block and also the surrounding transaction.
-   To recover from the error, we can use the exception clause in the `BEGIN...END` block.

```sql
-- When an error occurs between the `BEGIN` and `EXCEPTION`,
-- PL/pgSQL stops the execution and passes the control to the exception list.
<<label>>
DECLARE
BEGIN
    statements;
EXCEPTION
    WHEN condition [OR condition...] THEN
        handle_exception;
    [WHEN condition [OR condition...] THEN
        handle_exception;]
    [WHEN others THEN
        handle_other_exceptions;
    ]
END;

-- Demo
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION 'no data found';
```
