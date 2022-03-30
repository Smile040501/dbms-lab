/**************************************************************************/
/* Q1 */

CREATE TABLE student (
    roll_no SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    grade CHAR(1) NOT NULL
);

INSERT INTO student
VALUES (1, 'X', 'A'),
    (2, 'Y', 'B'),
    (3, 'Z', 'C');


CREATE OR REPLACE FUNCTION isValidGrade()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    IF (NEW.grade IN (SELECT grade FROM student)) THEN
        -- If new grade is already present then allowing the insertion
        RETURN NEW;
    ELSE
        -- Returning null won't allow the insertion
        RAISE EXCEPTION 'Unkown Grade Value Provided!!!';
        RETURN NULL;
    END IF;
END;
$$;

CREATE OR REPLACE TRIGGER validate_grade
BEFORE INSERT
ON student
FOR EACH ROW
EXECUTE FUNCTION isValidGrade();

/**************************************************************************/
/* Q2 */

CREATE TABLE connection (
    name1 VARCHAR(50) NOT NULL,
    name2 VARCHAR(50) NOT NULL,
    PRIMARY KEY (name1, name2)
);

CREATE OR REPLACE FUNCTION insert_connection()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN

    IF (NOT EXISTS (
                    SELECT *
                    FROM connection
                    WHERE name1 = NEW.name2
                        AND name2 = NEW.name1
                    )
    ) THEN
        INSERT INTO connection(name1, name2)
        VALUES (NEW.name2, NEW.name1);
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER connection_insert
AFTER INSERT
ON connection
FOR EACH ROW
EXECUTE FUNCTION insert_connection();


CREATE OR REPLACE FUNCTION delete_connection()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    IF (EXISTS (
                SELECT *
                FROM connection
                WHERE name1 = OLD.name2
                    AND name2 = OLD.name1
                )
    ) THEN
        DELETE FROM connection
        WHERE name1 = OLD.name2
            AND name2 = OLD.name1;
    END IF;

    RETURN OLD;
END;
$$;

CREATE OR REPLACE TRIGGER connection_delete
AFTER DELETE
ON connection
FOR EACH ROW
EXECUTE FUNCTION delete_connection();

/**************************************************************************/
/* Q3 */
CREATE TABLE grades (
    roll_no SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    grade CHAR(1) NOT NULL
);

CREATE TABLE student_log (
    roll_no INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    time TIME NOT NULL
);

CREATE OR REPLACE FUNCTION student_logs()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    INSERT INTO student_log
    VALUES (NEW.roll_no, NEW.name, CURRENT_TIME);
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER log_trigger
AFTER INSERT
ON grades
FOR EACH ROW
EXECUTE FUNCTION student_logs();

INSERT INTO grades
VALUES (1, 'X', 'A'),
    (2, 'Y', 'B'),
    (3, 'Z', 'C');

CREATE OR REPLACE FUNCTION student_logs_update()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS $$
BEGIN
    UPDATE student_log
    SET time = CURRENT_TIME
    WHERE roll_no = NEW.roll_no;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER log_trigger_update
AFTER UPDATE
ON grades
FOR EACH ROW
EXECUTE FUNCTION student_logs_update();
