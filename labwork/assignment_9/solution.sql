/* **************************************************************************/
/* Q1 - a) */
EXPLAIN ANALYZE
SELECT *
FROM payment
WHERE amount > 3;

CREATE INDEX pay_amt
ON payment(amount)
WHERE amount > 3;

DROP INDEX pay_amt;

/* Q1 - b) */
BEGIN;
DROP INDEX idx_fk_customer_id;
EXPLAIN ANALYZE
SELECT *
FROM payment
WHERE customer_id = '380';
ROLLBACK;

CREATE INDEX pay_cust_id
ON payment(customer_id)
WHERE customer_id = '380';

DROP INDEX pay_cust_id;

/* **************************************************************************/
/* Q2 - a) */
BEGIN;
DROP INDEX idx_fk_customer_id;
DROP INDEX idx_fk_staff_id;
EXPLAIN ANALYZE
SELECT transaction_id,
	payment_date
FROM payment
WHERE customer_id = '341'
	AND staff_id = '1';
ROLLBACK;

SELECT COUNT(DISTINCT customer_id),
	COUNT(DISTINCT staff_id)
FROM payment;

CREATE INDEX pay_cust_staff_id
ON payment(customer_id, staff_id);

DROP INDEX pay_cust_staff_id;

/* Q2 - b) */

CREATE INDEX pay_cust_staff_id2
ON payment(staff_id, customer_id);

DROP INDEX pay_cust_staff_id2;

/* **************************************************************************/
/* Q3 - a) */
EXPLAIN ANALYZE
SELECT title,
	release_year
FROM film
WHERE rental_rate > '3'
	AND length > '100';

CREATE INDEX rental_rate_length
ON film(rental_rate)
INCLUDE(length);

DROP INDEX rental_rate_length;

/* Q3 - b) */
SELECT COUNT(DISTINCT length),
	COUNT(DISTINCT rental_rate)
FROM film;

CREATE INDEX rental_rate_length2
ON film(length, rental_rate);

DROP INDEX rental_rate_length2;
