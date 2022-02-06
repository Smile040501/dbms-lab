# Data Base Management Systems Laboratory

# PostgreSQL

## Installation and Setup

-   Install from official [docs](https://www.postgresql.org/download/linux/ubuntu/)
-   **Postgresql service**
    -   Check commands available with postgresql `service postgresql`
    -   Check status of postgresql service `service postgresql status`
    -   Restart postgresql service `service postgresql restart`
-   **Postgresql Clusters**
    -   List: `pg_lsclusters`
    -   Restart Cluster: `sudo pg_ctlcluster <version> <cluster_name> restart`
    -   Restart postgresql service again and make sure it is **online**

## PSQL

### Setup

-   Default user for postgresql is `postgres`
-   Start **psql** as `sudo -u postgres psql`
-   **Setting a password for default user**
    -   `ALTER USER postgres PASSWORD 'newpassword';`
-   To use psql without changing the user every time, we can create a new superuser with our system default username and password.
    -   Using `postgres` user, create a new super user `CREATE USER uname WITH SUPERUSER ENCRYPTED PASSWORD 'pswd';`
    -   Using `postgres` user, create a new database with the same name as the new super user created above `CREATE DATABASE uname;`

### Commands

-   `\du`: List all the users
-   `\q`: Quit psql
-   `\l`: List all databases
-   `\c db_name`: Connect to a database
-   `\dt`: View all the created tables
-   `\d table_name`: View the structure of a specific table
-   `\i /path/to/file.sql`: Execute an SQL File which has SQL queries written in it
