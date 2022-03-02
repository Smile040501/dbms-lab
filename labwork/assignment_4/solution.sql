/**************************************************************************/
/* Q1: List the name language and category name of all the movies that have a rental rate below 3. */
SELECT title as film_name,
    language.name as language_name,
    category.name as category_name
FROM film
    JOIN language ON film.language_id = language.language_id
    JOIN film_category ON film.film_id = film_category.film_id
    JOIN category ON film_category.category_id = category.category_id
WHERE film.rental_rate < 3;
/***************************************************************************/
/* Q2: List the name of all movies acted by the actors with the first name ‘ Burt ’. Also, display the last name of the actor in each row.. */
SELECt title,
    last_name
FROM film
    JOIN film_actor ON film.film_id = film_actor.film_id
    JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE first_name = 'Burt';
/***************************************************************************/
/* Q3: List all the addresses from the table address. If there is staff living in the address list their names as well in the same row. */
SELECT address,
    first_name
FROM address
    LEFT JOIN staff ON address.address_id = staff.address_id;
/***************************************************************************/
/* Q4: Create a view with the First name, last name, email, phone number, and address of all active customers with store id 1. */
CREATE VIEW lab_4_customer_view AS
SELECT first_name,
    last_name,
    email,
    phone,
    address
FROM customer
    JOIN address on customer.address_id = address.address_id
WHERE customer.active = 1
    AND customer.store_id = 1;
SELECT *
FROM lab_4_customer_view;
/***************************************************************************/
/* Q5: Create a view with film name, category name, and language. List all rows from this view. */
CREATE VIEW lab_4_film_view AS
SELECT title as film_name,
    language.name as language_name,
    category.name as category_name
FROM film
    JOIN language ON film.language_id = language.language_id
    JOIN film_category ON film.film_id = film_category.film_id
    JOIN category ON film_category.category_id = category.category_id;
SELECT *
FROM lab_4_film_view;
/***************************************************************************/
/* Q6: Create a view with the list of all distinct languages an actor has acted. The view should include: Actor ’ s first name,last name, and the languages he worked in. (it would be better if the actor has an only one - row entry with the language column stores all distinct language acted by him / her in the same cell) */
CREATE VIEW lab_4_actor_language_view AS
SELECT first_name,
    last_name,
    STRING_AGG(
        DISTINCT language.name,
        ', '
        ORDER BY language.name ASC
    ) AS language_name
FROM actor
    JOIN film_actor ON actor.actor_id = film_actor.actor_id
    JOIN film ON film_actor.film_id = film.film_id
    JOIN language ON film.language_id = language.language_id
GROUP BY actor.actor_id;
SELECT *
FROM lab_4_actor_language_view;
