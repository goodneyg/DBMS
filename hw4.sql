--1 What is the average length of films in each category? List the results in alphabetic order of categories.
SELECT category.name as category, AVG(film.length) as averageLength         --show category and average length
FROM category
JOIN film_category ON category.category_id = film_category.category_id      --join category and film_category to get the category ID
JOIN film ON film_category.film_id = film.film_id                           --join film to get the film ID
GROUP BY category.category_id
ORDER BY category.name                                                --order by alphabetical order of categories


--2 Which categories have the longest and shortest average film lengths?
WITH avgPerCat AS (
    SELECT category.name AS category, AVG(film.length) AS averageLength     -- same as first question
    FROM category                                                           -- x     
    JOIN film_category ON category.category_id = film_category.category_id  -- x
    JOIN film ON film_category.film_id = film.film_id                       -- x
    GROUP BY category.category_id                                           -- x
    ORDER BY category.name                                                  -- end of first question
)
--part 1 - find max
SELECT category, averageLength                              --show category and average length
FROM avgPerCat
WHERE averageLength = (SELECT max(averageLength) 
FROM avgPerCat)                                              --find the max

--part 2 - find min
SELECT category, averageLength                              --show category and average length
FROM avgPerCat
WHERE averageLength = (SELECT min(averageLength) 
FROM avgPerCat)                                          --find the min


--3 Which customers have rented action but not comedy or classic movies?
WITH rentalSearch AS (
    SELECT rental.customer_id, category.name
    FROM rental
    JOIN inventory ON rental.inventory_id = inventory.inventory_id      --join rental and inventory to get the inventory ID
    JOIN film ON inventory.film_id = film.film_id                       --join film to get the film ID
    JOIN film_category ON film.film_id = film_category.film_id          --join film_category to get the category ID
    JOIN category ON film_category.category_id = category.category_id   --join category to get the category name
)
SELECT customer.first_name, customer.last_name
FROM customer
WHERE EXISTS (
    SELECT 1
    FROM rentalSearch                                           --rentalSearch has the customer ID and the category name
    WHERE rentalSearch.customer_id = customer.customer_id      
    AND rentalSearch.name = 'Action'                              --find customers who rented action movies 
)
AND NOT EXISTS (
    SELECT 1
    FROM rentalSearch
    WHERE rentalSearch.customer_id = customer.customer_id
    AND rentalSearch.name IN ('Comedy', 'Classic')              -- find customers who did not rent comedy or classic movies
)



--4 Which actor has appeared in the most English-language movies?
SELECT COUNT(*) AS movieCount, actor.first_name, actor.last_name
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id     --join actor and film_actor to get the actor ID
JOIN film ON film_actor.film_id = film.film_id              --join film to get the film ID
JOIN language ON film.language_id = language.language_id    --join language to get the language ID
WHERE language.name = 'English'
GROUP BY actor.first_name, actor.last_name                 --group by actor name
ORDER BY movieCount DESC                        --needs descending order
LIMIT 1;                        -- only the top movie


--5 How many distinct movies were rented for exactly 10 days from the store where Mike works?
SELECT COUNT(DISTINCT inventory.film_id) AS distinctMoviesCount --distinct movies
FROM inventory
JOIN rental ON inventory.inventory_id = rental.inventory_id     
JOIN staff ON rental.staff_id = staff.staff_id                  --join staff to identify mike
WHERE staff.first_name='Mike'
AND DATEDIFF(rental.return_date, rental.rental_date)=10;


--6 Alphabetically list actors who appeared in the movie with the largest cast of actors.
WITH findTopID AS (     --find the largest movie and return the ID
    SELECT film_id
    FROM film_actor
    GROUP BY film_id
    ORDER BY COUNT(actor_id) DESC       --descending order because its the largest cast
    LIMIT 1                             --only want the top 1
)
SELECT actor.first_name, actor.last_name
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id     --join actor and film_actor to get the actor ID 
WHERE film_actor.film_id = (SELECT film_id FROM findTopID) -- find the actors from this film
ORDER BY actor.first_name;                 --make sure it is in alphabetical order