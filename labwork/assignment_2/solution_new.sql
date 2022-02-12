CREATE DATABASE dvdrental;
--- pg_restore -c -U <user> -d <already_created_db_with_that_user> -v "<filename>.tar"
/**************************************************************************/
/* Q1: Write a query to find the store_id where “ Mike ” work. */
SELECT store_id
FROM staff
WHERE first_name = 'Mike';
/**************************************************************************/
/* Q2: Write a query to find the address, district, city and country of the customer with first name “ Linda ” and last name “ Williams ” */
SELECT address,
    district,
    city,
    country
FROM customer,
    address,
    city,
    country
WHERE customer.first_name = 'Linda'
    and customer.last_name = 'Williams'
    and customer.address_id = address.address_id
    and address.city_id = city.city_id
    and city.country_id = country.country_id;
/**************************************************************************/
/* Q3: Write a query to find the title of films offered for rent in store_id = 1 and film category is “ Comedy ” and sort the films in descending order */
SELECT DISTINCT title
FROM film,
    inventory,
    film_category,
    category
WHERE inventory.store_id = 1
    and inventory.film_id = film.film_id
    and film.film_id = film_category.film_id
    and category.category_id = film_category.category_id
    and category.name = 'Comedy'
ORDER BY film.title DESC;
/**************************************************************************/
/* Q4: Write a query to find the actors whose name have ‘ a ’ at 3rd position from the last. */
SELECT first_name,
    last_name
FROM actor
WHERE actor.first_name SIMILAR TO '%a__';
/**************************************************************************/
/* Q5: Write a query to find the films containing three vowels together with description containing “ Action ” in it. */
SELECT DISTINCT title,
    description
FROM film
WHERE film.title SIMILAR TO '%[aeiou]{3}%'
    and film.description LIKE '%Action%';
/**************************************************************************/
/* Q6: Write a query to find the title of films in which “ Penelope Guiness ” and “ Jennifer Davis ” worked together (Use Set Operation). */
SELECT DISTINCT title
FROM actor,
    film,
    film_actor
WHERE actor.first_name = 'Penelope'
    and actor.last_name = 'Guiness'
    and actor.actor_id = film_actor.actor_id
    and film_actor.film_id = film.film_id
INTERSECT
SELECT DISTINCT title
FROM actor,
    film,
    film_actor
WHERE actor.first_name = 'Jennifer'
    and actor.last_name = 'Davis'
    and actor.actor_id = film_actor.actor_id
    and film_actor.film_id = film.film_id;