# For calculating the mean, median and variance
from statistics import mean, median, variance

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
DATABASE_NAME = "univ_db"
HOST = "localhost"

# Note - Database should be created before executing below operation
# Initializing SqlAlchemy Postgresql Db Instance
db = PostgresqlDB(
    user_name=USER_NAME, password=PASSWORD, host=HOST, port=PORT, db_name=DATABASE_NAME
)

# ========================================================
# Q1. Retrieve the top-3 students based on tot cred.

print("Q1")
# Retrieval Query
q1 = text(
    """
    SELECT *
    FROM students
    ORDER BY tot_cred DESC
    LIMIT 3;
    """
)
top3_students = db.execute_dql_commands(q1)

# Traversing Result
for row in top3_students:
    print(
        f"Student Id: {row.stud_id}, Student Name: {row.stud_name}, Department ID: {row.dept_id} Total Credits: {row.tot_cred}"
    )
print("-----------------------------------------------------")

"""
OUTPUT:
Student Id: 7, Student Name: Naren, Department ID: 3 Total Credits: 5
Student Id: 3, Student Name: Neel, Department ID: 3 Total Credits: 5
Student Id: 13, Student Name: Abraham, Department ID: 3 Total Credits: 5
"""


# ========================================================
# Q2. Retrieve the budget in ascending order and display the name of the department with max and min budget. Show the statistics (mean, median, variance) on the department budget with help of python code.

print("Q2")
# Retrieval Query
q2 = text(
    """
    SELECT dept_name, budget
    FROM departments
    ORDER BY budget ASC;
"""
)
res2 = db.execute_dql_commands(q2)

# Traversing Result
res_list2 = []
for row in res2:
    res_list2.append((row.dept_name, row.budget))

budgetList = [row[1] for row in res_list2]

print(f"Department with Max budget: {res_list2[-1][0]}")
print(f"Department with Min budget: {res_list2[0][0]}")
print(f"Mean of budgets: {mean(budgetList)}")
print(f"Median of budgets: {median(budgetList)}")
print(f"Variance of budgets: {variance(budgetList)}")

print("-----------------------------------------------------")

"""
OUTPUT:
Department with Max budget: Mtech DS
Department with Min budget: Mtech SOCD
Mean of budgets: 98750
Median of budgets: 102500.0
Variance of budgets: 6239583333.333333
"""


# ========================================================
# Q3. Show the details of the departments which have budgets more than the average budget across all departments. First show it without defining any SQL function, then show it by defining a SQL function avg_budget that returns the average budget across all departments.
print("Q3: Method 1")
# Method 1:
q31 = text(
    """
    SELECT *
    FROM departments
    WHERE budget > (
            SELECT AVG(budget)
            FROM departments
        );
    """
)
res31 = db.execute_dql_commands(q31)

# Traversing Result
for row in res31:
    print(
        f"Department Id: {row.dept_id}, Department Name: {row.dept_name}, Building: {row.building} Total Budget: {row.budget}"
    )
print("-----------------------------------------------------")

"""
OUTPUT:
Department Id: 4, Department Name: Mtech Geo, Building: Packard Total Budget: 120000
Department Id: 1, Department Name: Mtech DS, Building: Watson Total Budget: 190000
"""


print("Q3: Method 2")
# Method 2:

# Creating the function
createFun2 = text(
    """
    CREATE OR REPLACE FUNCTION avg_budget()
    RETURNS NUMERIC
    LANGUAGE PLPGSQL
    AS $$
    DECLARE -- local variable declarations
        result NUMERIC;
    BEGIN
        SELECT AVG(budget)
        INTO result
        FROM departments;
        RETURN result;
    END;
    $$;
    """
)
db.execute_ddl_and_dml_commands(createFun2)

# Quering
q32 = text(
    """
    SELECT *
    FROM departments
    WHERE budget > avg_budget();
    """
)
res32 = db.execute_dql_commands(q32)

# Traversing Result
for row in res32:
    print(
        f"Department Id: {row.dept_id}, Department Name: {row.dept_name}, Building: {row.building} Total Budget: {row.budget}"
    )
print("-----------------------------------------------------")

"""
OUTPUT:
Department Id: 4, Department Name: Mtech Geo, Building: Packard Total Budget: 120000
Department Id: 1, Department Name: Mtech DS, Building: Watson Total Budget: 190000
"""


# ========================================================
# Q4: Consider the department of M.tech DS and M.tech SOCD is merged and consequently the budget of M.tech SOCD moved to M.tech DS.Write a procedure to handle the update such a way that ACID property holds.
print("Q4")

# Creating the procedure
createProc4 = text(
    """
    CREATE OR REPLACE PROCEDURE merge_depts()
    LANGUAGE PLPGSQL
    AS $$
    DECLARE
        socd_budget INT;
    BEGIN
        SELECT budget
        INTO socd_budget
        FROM departments
        WHERE dept_name = 'Mtech SOCD';


        UPDATE departments
        SET budget = 0
        WHERE dept_name = 'Mtech SOCD';

        UPDATE departments
        SET budget = budget + socd_budget
        WHERE dept_name = 'Mtech DS';

        UPDATE students
        SET dept_id = (
                SELECT dept_id
                FROM departments
                WHERE dept_name = 'Mtech DS'
            )
        WHERE dept_id = (
                SELECT dept_id
                FROM departments
                WHERE dept_name = 'Mtech SOCD'
            );

        DELETE FROM departments
        WHERE dept_name = 'Mtech SOCD';
    END;
    $$;
    """
)
db.execute_ddl_and_dml_commands(createProc4)

# Quering
q41 = text(
    """
    CALL merge_depts();
    """
)
db.execute_ddl_and_dml_commands(q41)

q42 = text(
    """
    SELECT *
    FROM departments;
    """
)

res4 = db.execute_dql_commands(q42)

# Traversing Result
for row in res4:
    print(
        f"Department Id: {row.dept_id}, Department Name: {row.dept_name}, Building: {row.building} Total Budget: {row.budget}"
    )

"""
OUTPUT:
Command executed successfully.
Command executed successfully.
Department Id: 3, Department Name: Mtech COM, Building: Painter Total Budget: 85000
Department Id: 4, Department Name: Mtech Geo, Building: Packard Total Budget: 120000
Department Id: 1, Department Name: Mtech DS, Building: Watson Total Budget: 190000
"""
