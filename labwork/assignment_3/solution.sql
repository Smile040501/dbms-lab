/* Creating the database for this assignment */
CREATE DATABASE lab3;
/* *************************************************************************/
/* Creating the reference table and inserting the given data into it */
CREATE TABLE assignment_3_data (
    emp_id SERIAL PRIMARY KEY,
    dept_id INT NOT NULL,
    salary INT NOT NULL
);
INSERT INTO assignment_3_data (emp_id, dept_id, salary)
VALUES (111, 504, 70000),
    (112, 509, 90000),
    (113, 509, 85000),
    (114, 501, 60000),
    (115, 504, 55000),
    (116, 504, 80000),
    (117, 506, 40000),
    (118, 506, 65000),
    (119, 509, 95000),
    (120, 509, 75000);
/**************************************************************************/
/* Q1: Display the number of unique department ids present in the table. */
SELECT COUNT(DISTINCT dept_id)
FROM assignment_3_data;
/**************************************************************************/
/* Q2: Display the department-wise maximum, minimum, sum and average salary. */
SELECT dept_id,
    MAX(salary),
    MIN(salary),
    SUM(salary),
    AVG(salary)
FROM assignment_3_data
GROUP BY dept_id;
/**************************************************************************/
/* Q3: Find the department id whose average salary is greater than 70,000. */
SELECT dept_id,
    AVG(salary)
FROM assignment_3_data
GROUP BY dept_id
HAVING AVG(salary) > 70000;
/**************************************************************************/
/* Q4: Display the employee ids from the relation whose salary < average salary of department id 506. */
SELECT emp_id
FROM assignment_3_data
WHERE salary < (
        SELECT AVG(salary)
        FROM assignment_3_data
        GROUP BY dept_id
        HAVING dept_id = 506
    );
/**************************************************************************/
/* Q5: Find the department id and average salary from the relation whose average salary is greater than the average salary of department id 504. */
SELECT dept_id,
    AVG(salary)
FROM assignment_3_data
GROUP BY dept_id
HAVING AVG(salary) > (
        SELECT AVG(salary)
        FROM assignment_3_data
        GROUP BY dept_id
        HAVING dept_id = 504
    );
/**************************************************************************/
/* Q6: Display the employee ids whose salary is greater than the average salary of department id 506. */
SELECT emp_id
FROM assignment_3_data
WHERE salary > (
        SELECT AVG(salary)
        FROM assignment_3_data
        GROUP BY dept_id
        HAVING dept_id = 506
    );