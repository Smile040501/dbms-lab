-- =====================================================
/* Schema Creation */
/**************************************************************************/
/* Q1 */
CREATE DATABASE univ_db;
/**************************************************************************/
/* Q2 */
CREATE TABLE departments(
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) UNIQUE NOT NULL CHECK(
        dept_name IN (
            'Mtech DS',
            'Mtech SOCD',
            'Mtech COM',
            'Mtech Geo'
        )
    ),
    building VARCHAR(50) NOT NULL,
    budget INT NOT NULL CHECK(budget > 0)
);

CREATE TABLE students (
    stud_id SERIAL PRIMARY KEY,
    stud_name VARCHAR(30) NOT NULL,
    dept_id INT NOT NULL,
    tot_cred INT NOT NULL CHECK(tot_cred >= 0),
    FOREIGN KEY(dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments(dept_name, building, budget)
VALUES ('Mtech DS', 'Watson', 90000),
    ('Mtech SOCD', 'Taylor', 100000),
    ('Mtech COM', 'Painter', 85000),
    ('Mtech Geo', 'Packard', 120000);

INSERT INTO students(stud_name, dept_id, tot_cred)
VALUES ('Satyam', 1, 3),
    ('Amish', 2, 4),
    ('Neel', 3, 5),
    ('Aditya', 4, 2),
    ('Harsh', 1, 3),
    ('Mayank', 2, 4),
    ('Naren', 3, 5),
    ('Anurag', 4, 2),
    ('Jerry', 1, 3),
    ('Hrishi', 2, 4);
-- =====================================================
/* Transactions */
/**************************************************************************/
/* Q1 */
BEGIN TRANSACTION;
INSERT INTO students(stud_name, dept_id, tot_cred)
VALUES ('Jasir', 1, 3),
    ('Yagnesh', 2, 4),
    ('Abraham', 3, 5);
COMMIT;

BEGIN TRANSACTION;
INSERT INTO students(stud_name, dept_id, tot_cred)
VALUES ('Jasir', 2, 4),
    ('Yagnesh', 3, 5),
    ('Abraham', 1, 3);
ROLLBACK;

BEGIN TRANSACTION;
INSERT INTO students(stud_name, dept_id, tot_cred)
VALUES ('Saurabh', 1, 3),
    ('Shubham', 2, 4),
    ('Rupesh', 3, 5),
    ('Kundan', 4, 2),
    ('Sahil', 3, 5);
SAVEPOINT first_savepoint;
INSERT INTO students(stud_name, dept_id, tot_cred)
VALUES ('Mayank', 1, 3),
    ('Aditya', 2, 4),
    ('Kundan', 3, 5);
ROLLBACK TO first_savepoint;
INSERT INTO students(stud_name, dept_id, tot_cred)
VALUES ('Joel', 4, 2),
    ('Ishwar', 4, 2);
COMMIT;
