USE sakila
-- 1a. Display the first and last names of all actors from the table actor.
Select first_name, last_name
from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
Select upper(concat(first_name,' ',last_name)) as 'Actor Name'
from actor;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name
from actor
where last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id, first_name, last_name
from actor
where last_name LIKE "%LI%"
ORDER BY last_name, first_name;
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ("Afghanistan","Bangladesh","china");
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD Description blob ;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
Drop Description ;
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(first_name) as 'Name Count'
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name,count(first_name) as 'Name Count'
from actor
group by last_name
having count(first_name) >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.alter
UPDATE actor
set first_name = replace(first_name,'GROUCHO','HARPO')
WHERE last_name='Williams';
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
set first_name = replace(first_name,'HARPO','GROUCHO')
WHERE last_name='Williams';
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name, last_name, address
from staff  join address on address.address_id = staff.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select staff.staff_id, first_name, last_name, sum(amount)
from staff join payment on staff.staff_id = payment.staff_id
where year(payment_date)=2005 and month(payment_date)=8
group by staff.staff_id, first_name, last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select title, count(actor_id) as 'Number of Actors'
from film_actor inner join film on film.film_id = film_actor.film_id
group by title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, count(inventory_id)
from film inner join inventory on inventory.film_id = film.film_id
where title= "Hunchback Impossible"
group by title;
-- 6 copies in stock for Hunchback Impossible.
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select first_name, last_name, sum(amount)as 'Total Paid'
from customer join payment on customer.customer_id = payment.customer_id
group by first_name, last_name
order by last_name;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title
from film
where (title like 'K%' OR title like 'Q%') and language_id = 
(select language_id from language where name ='English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name ,upper(concat(first_name,' ',last_name)) as 'Actor Name'
from actor
where actor_id  in
(select actor_id
from film_actor
where film_id = 
(select film_id
from film 
where title = "Alone Trip"));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select first_name, last_name, email, country
from customer join address on customer.address_id = address. address_id
join city on city.city_id = address.city_id
join country on country.country_id = city.country_id
where country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title
from film inner join film_category on film_category.film_id = film.film_id
inner join category on film_category.category_id = category.category_id
where name = "family";

-- 7e. Display the most frequently rented movies in descending order.
select inventory.film_id, title ,count(film.film_id) as 'Rental Frequency'
from film join inventory on inventory.film_id = film.film_id
join rental on rental.inventory_id = inventory.inventory_id
group by  inventory.film_id, title
order by count(film.film_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store_id, sum(amount)
from payment join rental on rental.rental_id  =  payment.rental_id
join inventory on inventory.inventory_id  = rental.inventory_id
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store.store_id, city, country
from store join address on address.address_id = store.address_id
 join city on city.city_id = address.city_id
 join country on country.country_id  = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name, sum(amount) as'Gross Revenue'
from category inner join film_category on category.category_id = film_category.category_id
inner join inventory on inventory.film_id = film_category.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on payment.rental_id = rental.rental_id
group by category.name
order by sum(amount) desc limit 5;

-- 8a.for update
create view Top_5_genres_by_gross_revenue as 
select category.name, sum(amount) as'Gross Revenue'
from category inner join film_category on category.category_id = film_category.category_id
inner join inventory on inventory.film_id = film_category.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on payment.rental_id = rental.rental_id
group by category.name
order by sum(amount) desc limit 5;

-- 8b.show view
show create view Top_5_genres_by_gross_revenue;
-- delect view
drop view Top_5_genres_by_gross_revenue;
