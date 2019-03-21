-- Tell this script to use sakila
USE sakila;

-- Start selecting things because that's what the homework says to do.
# 1A: Display the first and last names of all actors from the table actor.
SELECT first_name, last_name 
FROM actor;

# 1B: Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name,' ', last_name)) AS 'Actor Name'
FROM actor; 

# 2A: You need to find the ID number, first name, and last name of an actor, 
# of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
-- Assuming this isn't a theoretical exercise, maybe something like:
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";
-- But more importantly, why doesn't it bring up Joe Mangianello?

# 2B: Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%gen%';

# 2C: Find all actors whose last names contain the letters LI. 
# This time, order the rows by last name and first name, in that order.
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name;

# 2D: Using IN, display the country_id and country columns of the following countries: 
# Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

# 3A: You want to keep a description of each actor. 
# You don't think you will be performing queries on a description, 
# so create a column in the table actor named description and use the data type BLOB 
# (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
-- BLOB? Serioursly? Are the people creating these variables drunk and high most of the time?
ALTER TABLE actor
ADD COLUMN description BLOB(1000);

# 3B: Very quickly you realize that entering descriptions for each actor is too much effort. 
# Delete the description column.
-- UGH! After all that hard word?
ALTER TABLE actor
DROP COLUMN description;

# 4A: List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name;

# 4B: List last names of actors and the number of actors who have that last name, 
# but only for names that are shared by at least two actors.
SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name
HAVING count(last_name) > 1;

# 4C: The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
# Write a query to fix the record.
-- I suspect this was NOT an accident. Whatever.
-- Also, I think I F*cked something up as I don't think this actually did anything...
SELECT REPLACE(first_name, 'GROUCHO', 'HARPO')
FROM actor;

# 4D: Perhaps we were too hasty in changing GROUCHO to HARPO. 
# It turns out that GROUCHO was the correct name after all! 
# In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
-- something feels amiss. I don't have a Harpo OR a Groucho in my table. meh.
SELECT REPLACE(first_name, 'HARPO', 'GROUCHO')
FROM actor;

# 5: You cannot locate the schema of the address table. Which query would you use to re-create it?
-- I have no idea what this is asking... Sorry for this mess.
CREATE TABLE address(
address_id INT AUTO_INCREMENT PRIMARY KEY,
address VARCHAR(50),
address2 VARCHAR(50),
district VARCHAR(20),
city_id SMALLINT(5),
postal_code VARCHAR(10),
phone VARCHAR(20),
location GEOMETRY,
last_update TIMESTAMP
);

# 6A: Use JOIN to display the first and last names, as well as the address, of each staff member. 
# Use the tables staff and address.
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address 
ON staff.address_id = address.address_id;

# 6B: Use JOIN to display the total amount rung up by each staff member in August of 2005. 
# Use tables staff and payment.
SELECT staff_id, first_name, last_name , SUM(amount)
FROM 
(SELECT staff.staff_id, staff.first_name, staff.last_name, payment.amount
FROM staff
INNER JOIN payment
ON staff.staff_id = payment.staff_id) combo
GROUP BY staff_id;

# 6C: List each film and the number of actors who are listed for that film. 
# Use tables film_actor and film. Use inner join.
SELECT AC.film_id film_id, title, AC.Actor_Count Actor_Count
FROM film
INNER JOIN(
	SELECT film_id, COUNT(film_id) Actor_Count
	FROM film_actor
	GROUP BY film_id) AS AC
ON film.film_id = AC.film_id;

# 6D: How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(film_id)
FROM inventory
WHERE film_id IN(
SELECT film_id
FROM film
WHERE title = "Hunchback Impossible");

# 6E: Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
# List the customers alphabetically by last name.
-- This feels like an invasion of privacy. 
SELECT first_name, last_name, SUM(amount)
FROM (SELECT first_name, last_name, amount, c.customer_id
from customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id ) AS cust_invasion
GROUP BY cust_invasion.customer_id 
ORDER BY last_name;

# 7A: The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
# As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
# Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- I sense this was just made up! Fake. Science.
SELECT title
FROM(
	SELECT title
	FROM film
	WHERE language_id IN (
		SELECT language_id
		FROM language
		WHERE name = "english")) AS eng_film
WHERE eng_film.title LIKE 'K%'
OR eng_film.title LIKE 'Q%';

# 7B: Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN(
	SELECT actor_id 
	FROM film_actor 
	WHERE film_id IN
		(SELECT film_id
		FROM film
		WHERE title = "Alone Trip"));
        
# 7C: You want to run an email marketing campaign in Canada, 
# for which you will need the names and email addresses of all Canadian customers. 
# Use joins to retrieve this information.
-- UGH! Such targeted marketing! Is there no privacy anymore?
SELECT first_name, last_name
FROM customer
WHERE address_id IN
	(SELECT address_id
	FROM address
	WHERE city_id IN
		(SELECT city_id
		FROM city
		WHERE country_id IN
			(SELECT country_id
			FROM country
			WHERE country = 'canada')));
            
# 7D: Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
# Identify all movies categorized as family films.
-- Please note that "Bedazzled Married" is the name of one of the films. Just imagine that plot for a second.
SELECT title
FROM film
WHERE film_id IN
    (SELECT film_id
	FROM film_category
	WHERE category_id IN
		(SELECT category_id
		FROM category
		WHERE name = 'family'));

# 7E: Display the most frequently rented movies in descending order.
-- This one was terrible. An easier way probably exists to do this. But... who knows.
-- Please note that we also have a movie called Dinosaur Secretary. And please imagine a T-rex trying to answer a phone.
SELECT title, c.rentals rentals
FROM film f
INNER JOIN 
	(SELECT count(film_id) rentals, film_id
		FROM inventory
		WHERE inventory_id IN
			(SELECT inventory_id
			FROM rental)
	GROUP BY film_id
	ORDER BY rentals DESC) c
ON f.film_id = c.film_id;

# 7F: Write a query to display how much business, in dollars, each store brought in.
-- Well, I apparently only have 2 stores and 2 staff members. I may have something wrong with my database?
SELECT store_id Store, c.staff_id StaffID, c.sales Sales 
FROM staff 
INNER JOIN
	(SELECT SUM(amount) sales, staff_id
	FROM payment
	GROUP BY staff_id) c
ON staff.staff_id = c.staff_id;

# 7G: Write a query to display for each store its store ID, city, and country.
SELECT r.store_id StoreID, r.city City, country
FROM country
INNER JOIN
	(SELECT z.store_id store_id, city, country_id
	FROM city c
	INNER JOIN 
		(SELECT store_id, a.address_id address_id, city_id
		FROM address a
		INNER JOIN store s
		ON a.address_id = s.address_id) AS z
	ON c.city_id = z.city_id) AS r
ON country.country_id = r.country_id;

# 7H: List the top five genres in gross revenue in descending order. 
# (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- "hint". lies. 
SELECT name, SUM(amount) Gross
FROM
    (SELECT name, cc.category_id category_id, cc.amount amount, cc.rental_id rental_id
	FROM category
	INNER JOIN
		(SELECT f.film_id, category_id, bb.amount amount, bb.rental_id rental_id, bb.inventory_id inventory_id
		FROM film_category f
		INNER JOIN
			(SELECT film_id, aa.amount amount, aa.rental_id rental_id, aa.inventory_id inventory_id 
			FROM inventory
			INNER JOIN
				(SELECT amount, r.rental_id rental_id, inventory_id
				FROM payment p
				INNER JOIN rental r
				ON p.rental_id = r.rental_id) AS aa
			ON inventory.inventory_id = aa.inventory_id) AS bb
		ON f.film_id = bb.film_id) AS cc
	ON category.category_id = cc.category_id) AS final
GROUP BY name
ORDER BY Gross DESC
LIMIT 5;

# 8A: In your new role as an executive, you would like to have an easy way of viewing 
# the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
# If you haven't solved 7H, you can substitute another query to create a view.
-- "...your new role as an executive..." AS IF an executive is running queries. Maybe for a tiny startup.
CREATE VIEW Top_Genres AS 
SELECT name, SUM(amount) Gross
FROM
    (SELECT name, cc.category_id category_id, cc.amount amount, cc.rental_id rental_id
	FROM category
	INNER JOIN
		(SELECT f.film_id, category_id, bb.amount amount, bb.rental_id rental_id, bb.inventory_id inventory_id
		FROM film_category f
		INNER JOIN
			(SELECT film_id, aa.amount amount, aa.rental_id rental_id, aa.inventory_id inventory_id 
			FROM inventory
			INNER JOIN
				(SELECT amount, r.rental_id rental_id, inventory_id
				FROM payment p
				INNER JOIN rental r
				ON p.rental_id = r.rental_id) AS aa
			ON inventory.inventory_id = aa.inventory_id) AS bb
		ON f.film_id = bb.film_id) AS cc
	ON category.category_id = cc.category_id) AS final
GROUP BY name
ORDER BY Gross DESC
LIMIT 5;

# 8B: How would you display the view that you created in 8A?
SELECT * FROM sakila.top_genres;

# 8C: You find that you no longer need the view top_five_genres. Write a query to delete it.
-- This HW seems to like to make things and delete them. Basically what I do all the time. So efficient. 
DROP VIEW sakila.top_genres;











