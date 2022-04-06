/* **************************************************************************/

/* Q1 - i) */
BEGIN;
DROP INDEX idx_title;
EXPLAIN ANALYZE
SELECT *
FROM film
WHERE title = 'Amadeus Holy';
ROLLBACK;


CREATE INDEX film_title ON film USING HASH(title);

CREATE INDEX film_title ON film USING BTREE(title);

EXPLAIN ANALYZE
SELECT *
FROM film
WHERE title = 'Amadeus Holy';

DROP INDEX film_title;


/* Q1 - ii) */
EXPLAIN ANALYZE
SELECT *
FROM film
WHERE rental_rate > 2;

CREATE INDEX film_rental_rate ON film USING BTREE(rental_rate);

DROP INDEX film_rental_rate;


/* **************************************************************************/
/* Q2 */
EXPLAIN ANALYZE
SELECT *
FROM film
WHERE 'Drama' = ANY(special_features);

EXPLAIN ANALYZE
SELECT *
FROM film
WHERE 'Commentaries' = ANY(special_features);

CREATE INDEX gin_special_features
ON film
USING GIN(special_features);

EXPLAIN ANALYZE
SELECT *
FROM film
WHERE special_features @> ARRAY['Drama'];

EXPLAIN ANALYZE
SELECT *
FROM film
WHERE special_features @> ARRAY['Commentaries'];

DROP INDEX gin_special_features;


/* **************************************************************************/
/* Q3 */
DROP TABLE IF EXISTS dummy2;

CREATE TABLE dummy2 (
	sub1 TEXT NOT NULL,
	sub2 INT NOT NULL CHECK(sub2 >= 0 AND sub2 <= 100)
);

INSERT INTO dummy2(sub1, sub2)
SELECT MD5(RANDOM()::TEXT), RANDOM() * 100
FROM (
	SELECT *
	FROM generate_series(1, 100000) AS id
) AS x;

-- Extension for the operators used
CREATE EXTENSION pg_trgm;


EXPLAIN ANALYZE
SELECT *
FROM dummy2
WHERE sub1 ILIKE '%ecr%'
	AND  sub2 > 5;

CREATE INDEX sub1_idx
ON dummy2
USING GIN(sub1 GIN_TRGM_OPS);

CREATE INDEX sub2_idx
ON dummy2
USING BTREE(sub2);
