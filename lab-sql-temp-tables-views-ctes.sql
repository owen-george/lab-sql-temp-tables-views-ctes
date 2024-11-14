-- Creating a Customer Summary Report
-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database,
-- including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer.
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
USE sakila;

DROP VIEW IF EXISTS rental_info;

CREATE VIEW rental_info AS
WITH cte_rentals AS (
SELECT r.customer_id, count(r.rental_id) AS rental_count
FROM sakila.rental AS r
GROUP BY r.customer_id
)
SELECT r.customer_id, c.first_name, c.last_name, c.email, r.rental_count FROM cte_rentals AS r
JOIN sakila.customer as c
ON c.customer_id = r.customer_id
;

SELECT * FROM rental_info;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
DROP TABLE IF EXISTS total_paid;

CREATE TEMPORARY TABLE total_paid
SELECT p.customer_id, sum(p.amount) as total_paid FROM rental_info AS r
JOIN sakila.payment AS p
ON r.customer_id = p.customer_id
GROUP BY customer_id
;

SELECT * FROM total_paid;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2.
-- The CTE should include the customer's name, email address, rental count, and total amount paid.
DROP TABLE IF EXISTS customer_summary;

CREATE TEMPORARY TABLE customer_summary
SELECT r.customer_id, r.first_name, r.last_name, r.email, r.rental_count, p.total_paid FROM total_paid AS p
JOIN rental_info AS r
ON r.customer_id = p.customer_id;

SELECT * FROM customer_summary;

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: 
-- customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
DROP TABLE IF EXISTS final_customer_summary;

CREATE TEMPORARY TABLE final_customer_summary
SELECT *, total_paid/rental_count AS average_payment_per_rental FROM customer_summary AS c
;

SELECT * FROM final_customer_summary;

