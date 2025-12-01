-- Create Database
DROP DATABASE IF EXISTS customer_data_analysis;
CREATE DATABASE customer_data_analysis;


-- Use "customer_data_analysis" 
USE customer_data_analysis;


-- Create a Clean Copy of the Raw Data
DROP TABLE IF EXISTS customer_data_copy;

CREATE TABLE customer_data_copy AS
SELECT * FROM customer_data;


/* Identify duplicate rows in the table
And return the duplicates */
SELECT *
FROM (
    SELECT
	ROW_NUMBER() OVER (
				PARTITION BY customer_id, gender, age, category, quantity,
                price, payment_method, invoice_date, shopping_mall
				ORDER BY invoice_no
			) AS rn,
	customer_data_copy.*
	FROM customer_data_copy) AS Duplicate_rows
WHERE rn > 1;


-- Trim Spaces, Fix Casing, Standardize Text Fields
UPDATE customer_data_copy
SET 
    gender = TRIM(gender),
    gender = CASE 
                WHEN LOWER(gender) LIKE 'male%' THEN 'Male'
                WHEN LOWER(gender) LIKE 'female%' THEN 'Female'
                WHEN LOWER(gender) LIKE 'other%' THEN 'Other'
                ELSE gender
             END,

    payment_method = TRIM(payment_method),
    payment_method = CASE
                        WHEN LOWER(payment_method) LIKE '%cash%' THEN 'Cash'
                        WHEN LOWER(payment_method) LIKE '%credit%' THEN 'Credit Card'
                        WHEN LOWER(payment_method) LIKE '%debit%' THEN 'Debit Card'
                        ELSE payment_method
                     END,

    shopping_mall = TRIM(shopping_mall),
    category = TRIM(category);


-- Fix Invalid or Inconsistent Date Format (DD-MM-YYYY → YYYY-MM-DD)
UPDATE customer_data_copy
SET invoice_date = STR_TO_DATE(invoice_date, '%d-%m-%Y')
WHERE invoice_date IS NOT NULL;


-- Replace NULL or Blank Values With Standard Values
UPDATE customer_data_copy
SET 
    gender = NULLIF(gender, ''),
    category = NULLIF(category, ''),
    payment_method = NULLIF(payment_method, ''),
    shopping_mall = NULLIF(shopping_mall, '');


-- Fix Invalid Numeric Values (Age, Price, Quantity)
-- Replace negative or zero quantity with NULL
UPDATE customer_data_copy
SET quantity = NULL
WHERE quantity <= 0;

-- Replace invalid ages (below 10 or above 100)
UPDATE customer_data_copy
SET age = NULL
WHERE age < 10 OR age > 100;

-- Replace negative or zero price with NULL
UPDATE customer_data_copy
SET price = NULL
WHERE price <= 0;


-- Fill Missing Values
-- Missing gender → "Unknown"
UPDATE customer_data_copy
SET gender = 'Unknown'
WHERE gender IS NULL;

-- Missing payment method → "Not Provided"
UPDATE customer_data_copy
SET payment_method = 'Not Provided'
WHERE payment_method IS NULL;

-- Missing shopping mall → "Unknown"
UPDATE customer_data_copy
SET shopping_mall = 'Unknown'
WHERE shopping_mall IS NULL;
