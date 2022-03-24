/**************************************************************************/
/* Q1 */
ALTER TABLE film
ADD COLUMN genre VARCHAR(100);

UPDATE film
SET genre = 'Genre';

ALTER TABLE film
ADD CONSTRAINT genre_not_null CHECK (genre IS NOT NULL);

/**************************************************************************/
/* Q2 */
UPDATE film
SET genre = category.name
FROM film_category,
    category
WHERE film.film_id = film_category.film_id
    AND film_category.category_id = category.category_id;

/**************************************************************************/
/* Q3 */
SELECT film.title,
    film.genre AS category,
    (
        SELECT STRING_AGG(
                lname,
                ', '
                ORDER BY lname ASC
            )
        FROM (
                SELECT actor.last_name AS lname
                FROM film_actor,
                    actor
                WHERE film.film_id = film_actor.film_id
                    AND film_actor.actor_id = actor.actor_id
                LIMIT 3
            ) AS top_3_actors
    ) AS cast
FROM film
WHERE film.title SIMILAR TO '[aAeEiIoOuU]%';

/**************************************************************************/
/* Q4 */
SELECT first_name,
    last_name,
    SUM(amount) AS total_payment
FROM customer,
    payment
WHERE customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY total_payment DESC
LIMIT 5;

/**************************************************************************/
/* Q5 */
CREATE GROUP customer;

CREATE GROUP cashier;

CREATE VIEW customer_view AS
SELECT film.title,
    film.genre AS category,
    STRING_AGG(
        actor.first_name || ' ' || actor.last_name,
        ', '
    ) AS cast_names
FROM film,
    film_actor,
    actor
WHERE film.film_id = film_actor.film_id
    AND film_actor.actor_id = actor.actor_id
GROUP BY film.film_id;

CREATE VIEW cashier_view AS
SELECT customer.first_name || ' ' || customer.last_name AS customer_name,
    payment.amount,
    payment.payment_date,
    payment.transaction_id,
    payment.payment_info
FROM customer,
    payment
WHERE customer.customer_id = payment.customer_id;

GRANT SELECT ON customer_view TO customer;

GRANT SELECT ON cashier_view TO cashier;

CREATE USER aditya IN GROUP customer ENCRYPTED PASSWORD 'aditya';

CREATE USER satyam IN GROUP customer ENCRYPTED PASSWORD 'satyam';

CREATE USER neel IN GROUP customer ENCRYPTED PASSWORD 'neel';

CREATE USER amish IN GROUP cashier ENCRYPTED PASSWORD 'amish';

CREATE USER harsh IN GROUP cashier ENCRYPTED PASSWORD 'harsh';

CREATE USER jerry IN GROUP cashier ENCRYPTED PASSWORD 'jerry';

/**************************************************************************/
/* Q6 */
CREATE OR REPLACE FUNCTION cashback_offer(cid INT)
RETURNS TABLE(
    customer_name TEXT,
    cashback_amount NUMERIC
)
LANGUAGE PLPGSQL
AS $$
DECLARE
    top_10_cid SMALLINT;
BEGIN

    -- Check if customer id is in top 10% of customers based on total payment (SELECT-INTO)
    SELECT customer_id
    INTO top_10_cid
    FROM (
            SELECT customer_id
            FROM payment
            GROUP BY payment.customer_id
            ORDER BY SUM(amount) DESC
            LIMIT 0.1 * (
                    SELECT COUNT(DISTINCT payment.customer_id)
                    FROM payment
                )
        ) AS top_10_precent_cusomters
    WHERE customer_id = cid;

    -- If customer id is not in top 10% list, then returning 1% cashback
    IF NOT FOUND THEN
        RETURN QUERY
            SELECT customer.first_name || ' ' || customer.last_name AS customer_name,
                0.01 * SUM(amount) AS cashback_amount
            FROM payment,
                customer
            WHERE payment.customer_id = customer.customer_id
            GROUP BY payment.customer_id,
                customer.first_name,
                customer.last_name
            HAVING payment.customer_id = cid;
    ELSE
        -- If customer id is in top 10% list, then returning 2% cashback
        RETURN QUERY
            SELECT customer.first_name || ' ' || customer.last_name AS customer_name,
                0.02 * SUM(amount) AS cashback_amount
            FROM payment,
                customer
            WHERE payment.customer_id = customer.customer_id
            GROUP BY payment.customer_id,
                customer.first_name,
                customer.last_name
            HAVING payment.customer_id = cid;
    END IF;
END;
$$;
