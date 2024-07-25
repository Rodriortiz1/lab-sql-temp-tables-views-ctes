-- Active: 1721292127253@@127.0.0.1@3306@sakila
USE sakila;

--Creating a Customer Summary Report

--In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

--Step 1: Create a View
--First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

DROP VIEW IF EXISTS CSR;
CREATE VIEW CSR AS
SELECT cu.customer_id, CONCAT(cu.first_name, ' ', cu.last_name) AS name, cu.email, COUNT(r.rental_id) AS Rental_count
FROM customer AS cu
JOIN rental AS r ON cu.customer_id = r.customer_id
GROUP BY cu.customer_id;

--Step 2: Create a Temporary Table
--Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_payment_summary AS (
SELECT cs.customer_id, SUM(pa.amount) AS total_paid
FROM CSR AS cs
JOIN payment AS pa ON cs.customer_id = pa.customer_id
GROUP BY cs.customer_id);

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH customer_summary AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.email,
        csr.rental_count,
        tp.total_paid
    FROM 
        customer c
    JOIN 
        CSR csr ON c.customer_id = csr.customer_id
    JOIN 
        customer_payment_summary tp ON c.customer_id = tp.customer_id
)
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    (total_paid / rental_count) AS average_payment_per_rental
FROM 
    customer_summary
ORDER BY 
    customer_name;
