/* Q1 */
CREATE DATABASE software_company;

/**************************************************************************/
/* Q2 */
CREATE TABLE employee(
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(30) NOT NULL,
    emp_age INT NOT NULL,
    emp_salary INT NOT NULL,
    job_role VARCHAR(100) NOT NULL CHECK(
        job_role IN (
            'Data Analyst',
            'ML Engineer',
            'Software Developer'
        )
    )
);

INSERT INTO employee (emp_name, emp_age, emp_salary, job_role)
VALUES ('Aditya', 75, 56000, 'Software Developer'),
    ('Satyam', 60, 400000, 'Software Developer'),
    ('Neel', 21, 130000, 'Data Analyst'),
    ('Mayank', 21, 50505, 'Software Developer'),
    ('Amish', 19, 55000, 'ML Engineer'),
    ('Harsh', 80, 59999, 'Data Analyst'),
    ('Shubham', 61, 50000, 'ML Engineer'),
    ('Anurag', 22, 400000, 'Software Developer'),
    ('Jerry', 56, 100000, 'ML Engineer'),
    ('Naren', 21, 4000000, 'Data Analyst');

SELECT *
FROM software_company;

/**************************************************************************/
/* Q3 */
/* a */
SELECT DISTINCT job_role
FROM employee
WHERE emp_salary BETWEEN 50000 AND 59999;

/* b*/
SELECT DISTINCT job_role
FROM employee
WHERE emp_salary > 50000;

/**************************************************************************/
/* Q4 */
SELECT *
FROM employee
WHERE job_role = 'Software Developer'
    AND emp_age < 60;

/**************************************************************************/
/* Q5 */
ALTER TABLE employee DROP CONSTRAINT employee_job_role_check;

SELECT *
FROM employee;

UPDATE employee
SET job_role = 'Data Scientist'
WHERE job_role = 'Data Analyst';

SELECT *
FROM employee;

ALTER TABLE employee
ADD CONSTRAINT employee_job_role_check CHECK(
        job_role IN (
            'Data Scientist',
            'ML Engineer',
            'Software Developer'
        )
    );

/**************************************************************************/
/* Q6 */
ALTER TABLE employee
ADD COLUMN emp_experience INT CHECK(emp_experience >= 0);

UPDATE employee
SET emp_experience = 4
WHERE emp_name = 'Aditya';

UPDATE employee
SET emp_experience = 6
WHERE emp_name = 'Satyam';

UPDATE employee
SET emp_experience = 1
WHERE emp_name = 'Amish';

UPDATE employee
SET emp_experience = 3
WHERE emp_name = 'Shubham';

UPDATE employee
SET emp_experience = 4
WHERE emp_name = 'Mayank';

UPDATE employee
SET emp_experience = 2
WHERE emp_name = 'Anurag';

UPDATE employee
SET emp_experience = 5
WHERE emp_name = 'Jerry';

UPDATE employee
SET emp_experience = 10
WHERE emp_name = 'Neel';

UPDATE employee
SET emp_experience = 8
WHERE emp_name = 'Harsh';

UPDATE employee
SET emp_experience = 21
WHERE emp_name = 'Naren';

SELECT *
FROM employee;

/**************************************************************************/
/* Q7 */
DELETE FROM employee
WHERE emp_age > 65;

SELECT *
FROM employee;