--Count the total number of products in the database.
SELECT COUNT(*) AS 'product count'
FROM production.products;

-- Find the average, minimum, and maximum price of all products.
SELECT AVG(list_price) AS average , MIN(list_price) AS minimum , MAX(list_price) AS maximum
FROM production.products;

--Count how many products are in each category.
SELECT category_id , COUNT(*) AS count
FROM production.products
GROUP BY category_id;

-- Find the total number of orders for each store.
SELECT COUNT(*) AS 'order count'
FROM sales.orders;

--Show customer first names in UPPERCASE and last names in lowercase for the first 10 customers.
SELECT TOP(10) UPPER(first_name) AS fname , LOWER(last_name) AS lname
FROM sales.customers

--Get the length of each product name. Show product name and its length for the first 10 products.
SELECT TOP(10) product_name , LEN(product_name) AS 'Name Length'
FROM production.products

--Format customer phone numbers to show only the area code (first 3 digits) for customers 1-15.
SELECT TOP(15) RIGHT(phone,3) AS 'Area Code'
FROM sales.customers

-- Show the current date and extract the year and month from order dates for orders 1-10.
SELECT TOP(10) order_date , YEAR(order_date) AS year , MONTH(order_date) AS month
FROM sales.orders;

--Join products with their categories. Show product name and category name for first 10 products.
SELECT TOP(10) product_name , category_name
FROM production.products p
JOIN production.categories c
	ON p.category_id = c.category_id

--Join customers with their orders. Show customer name and order date for first 10 orders.
SELECT first_name + ' ' + last_name AS 'full name' , order_date
FROM sales.customers c 
JOIN sales.orders o
	ON o.customer_id = c.customer_id

--Show all products with their brand names, even if some products don't have brands. Include product name, brand name (show 'No Brand' if null).
SELECT product_name , COALESCE(brand_name, 'No Brand') AS brand_name
FROM production.products p
JOIN production.brands b
	ON p.brand_id = b.brand_id

--Find products that cost more than the average product price. Show product name and price.
SELECT product_name , list_price
FROM production.products
WHERE list_price > (
SELECT AVG(list_price)
FROM production.products
)

-- Find customers who have placed at least one order. Use a subquery with IN. Show customer_id and customer_name.
SELECT customer_id , first_name + ' ' + last_name AS 'full name'
FROM sales.customers
WHERE customer_id IN (
SELECT customer_id
FROM sales.orders
)

--For each customer, show their name and total number of orders using a subquery in the SELECT clause.
SELECT first_name + ' ' + last_name AS 'full name' ,
(
	SELECT COUNT(*) 
	FROM sales.orders o 
	WHERE o.customer_id = c.customer_id
) AS 'orders count'
FROM sales.customers c;

--Create a simple view called easy_product_list that shows product name, category name, and price. Then write a query to select all products from this view where price > 100.
CREATE VIEW  easy_product_list AS
SELECT 
    p.product_name,
    c.category_name,
    p.list_price AS price
FROM production.products AS p
JOIN production.categories AS c
    ON p.category_id = c.category_id;

SELECT * 
FROM easy_product_list
WHERE price > 100;

--Create a view called customer_info that shows customer ID, full name (first + last), email, and city and state combined. Then use this view to find all customers from California (CA).
CREATE VIEW customer_info AS
SELECT 
customer_id ,
first_name + ' ' + last_name AS 'full name',
email,
state
FROM sales.customers

SELECT * 
FROM customer_info
WHERE state = 'CA'

--Find all products that cost between $50 and $200. Show product name and price, ordered by price from lowest to highest.
SELECT product_name , list_price
FROM production.products
WHERE list_price BETWEEN 50 AND 200
ORDER BY list_price

--Count how many customers live in each state. Show state and customer count, ordered by count from highest to lowest.
SELECT state , COUNT(*) AS 'customer count'
FROM sales.customers
GROUP BY state
ORDER BY COUNT(*) DESC

--Find the most expensive product in each category. Show category name, product name, and price.
-- CAN'T SOLVE IT 

--Show all stores and their cities, including the total number of orders from each store. Show store name, city, and order count.
SELECT store_name , city , COUNT(*) AS orders_count
FROM sales.stores s
JOIN sales.orders o
	ON s.store_id = o.store_id
GROUP BY store_name,city