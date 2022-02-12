-- CREATE DATABASE dvdrental;
/*
 pg_restore -c -U <user> -d <already_created_db_with_that_user> -v "<filename>.tar"
 */
/**************************************************************************/
/* Q1: Write a query to find the country where city “ Abu Dhabi ” is located. */
SELECT country
FROM city,
    country
WHERE city.city = 'Abu Dhabi'
    and city.country_id = country.country_id;
/**************************************************************************/
/* Q2: Write a query to find the address, district, city and country of the customer with first name “ Mary ” and last name “ Smith ” */
SELECT address,
    district,
    city,
    country
FROM customer,
    address,
    city,
    country
WHERE customer.first_name = 'Mary'
    and customer.last_name = 'Smith'
    and customer.address_id = address.address_id
    and address.city_id = city.city_id
    and city.country_id = country.country_id;
/**************************************************************************/
/* Q3: Write a query to find the films in which actor “ Penelope Guiness ” worked and sort the films in descending order. */
SELECT DISTINCT title
FROM film,
    actor,
    film_actor
WHERE actor.first_name = 'Penelope'
    and actor.last_name = 'Guiness'
    and actor.actor_id = film_actor.actor_id
    and film_actor.film_id = film.film_id
ORDER BY film.title DESC;
/**************************************************************************/
/* Q4: Write a query to find the cities with only 3 characters only. */
SELECT city
FROM city
WHERE city.city SIMILAR TO '___';
/**************************************************************************/
/* Q5: Write a query to find the films starting with A,E,I,O,U and ending with a,e,i,o,u with description containing “Shark” in it. */
SELECT DISTINCT title,
    description
FROM film
WHERE film.title SIMILAR TO '[AEIOU]%[aeiou]'
    and film.description LIKE '%Shark%';
/**************************************************************************/
/* Q6: Write a query to find the title of films offered for rent in store 1 and store 2 */
SELECT DISTINCT title
FROM film,
    inventory
WHERE inventory.store_id = 1
    and inventory.film_id = film.film_id
INTERSECT
SELECT DISTINCT title
FROM film,
    inventory
WHERE inventory.store_id = 2
    and inventory.film_id = film.film_id