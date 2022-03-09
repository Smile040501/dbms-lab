# Package Installation
# Driver For connecting to postgres db
# `pip install psycopg2``
# Library For executing sql query via python
# `pip install SQLAlchemy``

# Database Utility Class
from sqlalchemy.engine import create_engine

# Provides executable SQL expression construct
from sqlalchemy.sql import text


class PostgresqlDB:
    """
    PostgresqlDB class provides methods to interact with Postgresql database.
    """

    def __init__(self, user_name, password, host, port, db_name):
        """
        The constructor
        """
        self.user_name = user_name
        self.password = password
        self.host = host
        self.port = port
        self.db_name = db_name
        self.engine = self.create_db_engine()

    def create_db_engine(self):
        """
        Creates a database engine to interact with PostgreSQL database
        """
        try:
            db_uri = f"postgresql+psycopg2://{self.user_name}:{self.password}@{self.host}:{self.port}/{self.db_name}"
            return create_engine(db_uri)
        except Exception as err:
            raise RuntimeError(f"Failed to establish connection -- {err}") from err

    def execute_dql_commands(self, stmnt, values=None):
        """DQL - Data Query Language
        SQLAlchemy execute query by default as
        BEGIN
        ....
        ROLLBACK
        BEGIN will be added implicitly everytime but if we don't mention commit or rollback eplicitly
        then rollback will be appended at the end.
        We can execute only retrieval query with above transaction block.If we try to insert or update data
        it will be rolled back.That's why it is necessary to use commit when we are executing
        Data Manipulation Langiage(DML) or Data Definition Language(DDL) Query.
        """
        try:
            with self.engine.connect() as conn:
                if values is not None:
                    result = conn.execute(stmnt, values)
                else:
                    result = conn.execute(stmnt)
            return result
        except Exception as err:
            print(f"Failed to execute dql commands -- {err}")

    def execute_ddl_and_dml_commands(self, stmnt, values=None):
        """
        DDL - Data Definition Language
        DML - Data Manipulation Language
        """
        connection = self.engine.connect()
        trans = connection.begin()
        try:
            if values is not None:
                result = connection.execute(stmnt, values)
            else:
                result = connection.execute(stmnt)
            trans.commit()
            connection.close()
            print("Command executed successfully.")
        except Exception as err:
            trans.rollback()
            print(f"Failed to execute ddl and dml commands -- {err}")


# Defining Db Credentials
USER_NAME = "postgres"
PASSWORD = "postgres"
PORT = 5432
DATABASE_NAME = "postgres"
HOST = "localhost"

# Note - Database should be created before executing below operation
# Initializing SqlAlchemy Postgresql Db Instance
db = PostgresqlDB(
    user_name=USER_NAME, password=PASSWORD, host=HOST, port=PORT, db_name=DATABASE_NAME
)

# Doing CRUD Operation Via SqlAlchemy

# =============================================================================
# Creating Table
# creation of the table flights with all the attributes
create_table_stmnt = text(
    """
    CREATE TABLE IF NOT EXISTS flights(
        id SERIAL PRIMARY KEY,
        origin VARCHAR(100) NOT NULL,
        destination VARCHAR(100) NOT NULL,
        duration INTEGER NOT NULL
    );
    """
)
db.execute_ddl_and_dml_commands(create_table_stmnt)


# =============================================================================
# Insertion Of Values

# Single Insertion
# insertion of values into the table flights
Values = {"origin": "New York", "destination": "London", "duration": 415}
single_insert_stmnt = text(
    """
    INSERT INTO flights(origin, destination, duration)
    VALUES (:origin, :destination, :duration);
    """
)
db.execute_ddl_and_dml_commands(single_insert_stmnt, Values)


# Bulk Insertion
Values = [
    {"origin": "Shanghai", "destination": "Paris", "duration": 760},
    {"origin": "Istanbul", "destination": "Tokyo", "duration": 700},
    {"origin": "New York", "destination": "Paris", "duration": 435},
]
bulk_insert_stmnt = text(
    """
    INSERT INTO flights(origin, destination, duration)
    VALUES (:origin, :destination, :duration),
    VALUES (:origin, :destination, :duration),
    VALUES (:origin, :destination, :duration);
    """
)
db.execute_ddl_and_dml_commands(bulk_insert_stmnt, Values)


# =============================================================================
# Retrieval Query
select_query_stmnt = text(
    """
    SELECT *
    FROM flights;
    """
)
result_1 = db.execute_dql_commands(select_query_stmnt)

# Traversing Result
for row in result_1:
    print(f"Origin:{row.origin} Destination:{row.destination} Duration:{row.duration}")

print("------------------------------------------------------------")

# Retrieval Query With Condition
select_query_stmnt_with_condition = text(
    """
    SELECT *
    FROM flights
    WHERE origin LIKE :origin;
    """
)
value = {"origin": "%" + "New York" + "%"}
result_2 = db.execute_dql_commands(select_query_stmnt_with_condition, value)

# Traversing Result
for row in result_2:
    print(f"Origin:{row.origin} Destination:{row.destination} Duration:{row.duration}")


# =============================================================================
# Update Query
update_query_stmnt = text(
    """
    UPDATE flights
    SET duration = :new_duration
    WHERE duration = :duration;
    """
)
value = [{"duration": 700, "new_duration": 500}, {"duration": 435, "new_duration": 600}]
db.execute_ddl_and_dml_commands(update_query_stmnt, value)


# =============================================================================
# Delete Query
delete_query_stmnt = text(
    """
    DELETE FROM flights
    WHERE duration = :duration
    """
)
value = {"duration": 500}
db.execute_ddl_and_dml_commands(delete_query_stmnt, value)


# =============================================================================
"""
### References
* https://docs.sqlalchemy.org/en/14/tutorial/index.html
* https://www.geeksforgeeks.org/sql-ddl-dql-dml-dcl-tcl-commands/
* Using SQLAlchemy as a ORM Set-Up
    * https://www.compose.com/articles/using-postgresql-through-sqlalchemy/
    * https://docs.sqlalchemy.org/en/13/orm/session_basics.html#when-do-i-make-a-sessionmaker
* Difference between SqlAlchemy Engine,Connection And Session
    * https://stackoverflow.com/questions/34322471/sqlalchemy-engine-connection-and-session-difference
* Accessing Postgresql via Java
    * https://www.javaguides.net/2020/02/java-crud-operations-with-postgresql.html
    * https://zetcode.com/java/postgresql/
"""
