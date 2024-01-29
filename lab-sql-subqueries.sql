-- Welcome to the SQL Subqueries lab!

-- In this lab, you will be working with the Sakila database on movie rentals. Specifically, you will be practicing how to perform subqueries, which are queries embedded within 
-- other queries. Subqueries allow you to retrieve data from one or more tables and use that data in a separate query to retrieve more specific information.

-- Challenge
-- Write SQL queries to perform the following tasks using the Sakila database:

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
USE sakila;
SELECT COUNT(film_id)
FROM inventory i
WHERE film_id = (
	SELECT film_id
	FROM (
		SELECT title, film_id
		FROM film f
		WHERE title = "Hunchback Impossible"
	) id_hunchback_impossible
)	
;
-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT title
FROM sakila.film
WHERE length > (SELECT AVG(length) FROM sakila.film);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id = (
		SELECT film_id
		FROM film f
		WHERE title = "Alone Trip"
		 )
	);
            
-- Bonus:
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id
	FROM film_category
	WHERE category_id = (
		SELECT category_id
		FROM category
		WHERE name = 'Family'
					)
			);

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify
-- the relevant tables and their primary and foreign keys.
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
	SELECT address_id
	FROM country
	JOIN city
	USING (country_id)
	JOIN address
	USING (city_id)
	WHERE country = 'Canada'
    );

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number
-- of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id
	FROM film_actor
	WHERE actor_id = (
		SELECT actor_id
		FROM (
			SELECT COUNT(film_id) film_count, actor_id
			FROM film_actor
			GROUP BY actor_id
			ORDER BY film_count DESC
			LIMIT 1) most_prolific_actor_id
		)
	);
    
-- 7. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT title
FROM film
JOIN inventory
USING (film_id)
JOIN rental
USING (inventory_id)
WHERE rental_id IN (
	SELECT rental_id
	FROM rental
	WHERE customer_id =(
		SELECT customer_id
		FROM (
			SELECT customer_id, SUM(amount) AS total_amount
			FROM payment
			GROUP BY customer_id
			ORDER BY total_amount DESC
			LIMIT 1) most_profitable_customer
			)
		);

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
CREATE TEMPORARY TABLE avg_of_total_amount_spent_by_each_client AS (
	SELECT AVG(total_amount) AS avg_total_amount
    FROM (
		SELECT customer_id, SUM(amount) AS total_amount
		FROM payment
		GROUP BY customer_id) total_amount_by_customer
	);

SELECT *
FROM avg_of_total_amount_spent_by_each_client;

SELECT customer_id, SUM(amount) AS total_amount
FROM payment
JOIN customer
USING (customer_id)
GROUP BY customer_id
HAVING SUM(amount) > (SELECT AVG(total_amount) AS avg_total_amount
					FROM (
							SELECT customer_id, SUM(amount) AS total_amount
							FROM payment
							GROUP BY customer_id) total_amount_by_customer
						);
