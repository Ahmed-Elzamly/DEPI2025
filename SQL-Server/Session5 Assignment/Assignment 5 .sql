--1-
SELECT * ,
CASE 
	WHEN list_price < 300 THEN 'Economy'
	WHEN list_price <= 999 THEN 'Standard'
	WHEN list_price <= 2499 THEN 'Premium'
	ELSE 'Luxury'
END AS price_cat
FROM production.products;

--2-
SELECT *,
CASE
	WHEN order_status = 1 THEN 'Order Received'
	WHEN order_status = 2 THEN 'In Preparation'
	WHEN order_status = 3 THEN 'Order Cancelled'
	WHEN order_status = 4 THEN 'Order Delivered'
END AS status ,
CASE 
    WHEN order_status = 1 AND DATEDIFF(DAY, order_date, GETDATE()) > 5 THEN 'URGENT'
    WHEN order_status = 2 AND DATEDIFF(DAY, order_date, GETDATE()) > 3 THEN 'HIGH'
	ELSE 'NORMAL'
END AS priority_level
FROM sales.orders
--3-
SELECT 
s.staff_id,
s.first_name,
s.last_name,
COUNT(o.order_id) AS order_count,
CASE 
	WHEN COUNT(o.order_id) = 0 THEN 'New Staff'
    WHEN COUNT(o.order_id) BETWEEN 1 AND 10 THEN 'Junior Staff'	
	WHEN COUNT(o.order_id) BETWEEN 11 AND 25 THEN 'Senior Staff'
    ELSE 'Expert Staff'
END AS staff_category
FROM sales.staffs s
LEFT JOIN sales.orders o ON s.staff_id = o.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name
ORDER BY s.staff_id;
--4-
SELECT 
    customer_id,
    first_name,
    last_name,
    ISNULL(phone, 'Phone Not Available') AS phone,
    email,
    street,
    city,
    state,
    zip_code,
    COALESCE(phone, email, 'No Contact Method') AS preferred_contact
FROM sales.customers;
--5-
SELECT 
s.store_id,
s.product_id,
p.product_name,
s.quantity,
ISNULL(p.list_price / NULLIF(s.quantity, 0), 0) AS price_per_unit,
CASE 
    WHEN s.quantity IS NULL OR s.quantity = 0 THEN 'Out of Stock'
    ELSE 'In Stock'
END AS stock_status
FROM production.stocks s
JOIN production.products p ON s.product_id = p.product_id
WHERE s.store_id = 1;
--6-
SELECT 
customer_id,
first_name,
last_name,
COALESCE(street, '') AS street,
COALESCE(city, '') AS city,
COALESCE(state, '') AS state,
COALESCE(zip_code, '') AS zip_code,
COALESCE(
        NULLIF(
        COALESCE(street, '') + ', ' + COALESCE(city, '') +  ', ' + COALESCE(state, '')+ ', ' + COALESCE(zip_code, '') , ', , , '
        ), 'Address Not Available'
    ) AS formatted_address
FROM sales.customers;
--7-
WITH customer_spending AS (
    SELECT 
    o.customer_id,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT 
c.customer_id,
c.first_name,
c.last_name,
cs.total_spent
FROM customer_spending cs
JOIN sales.customers c ON c.customer_id = cs.customer_id
WHERE cs.total_spent > 1500
ORDER BY cs.total_spent DESC;
--8-
WITH total_revenue AS (
    SELECT 
    p.category_id,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
    FROM sales.order_items oi
    JOIN production.products p ON oi.product_id = p.product_id
    GROUP BY p.category_id
),
average_order_value AS (
    SELECT 
    p.category_id,
    AVG(oi.quantity * oi.list_price * (1 - oi.discount)) AS avg_order_value
    FROM sales.order_items oi
    JOIN production.products p ON oi.product_id = p.product_id
    GROUP BY p.category_id
)
SELECT 
c.category_id,
c.category_name,
tr.revenue,
aov.avg_order_value,
CASE 
    WHEN tr.revenue > 50000 THEN 'Excellent'
    WHEN tr.revenue > 20000 THEN 'Good'
    ELSE 'Needs Improvement'
END AS performance_rating
FROM total_revenue tr
JOIN average_order_value aov ON tr.category_id = aov.category_id
JOIN production.categories c ON c.category_id = tr.category_id;
--9-
WITH monthly_sales AS (
    SELECT 
    MONTH(o.order_date) AS month,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY MONTH(o.order_date)
),
sales_with_lag AS (
    SELECT 
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales
    FROM monthly_sales
)
SELECT 
month,
total_sales,
prev_month_sales,
CASE 
    WHEN prev_month_sales IS NULL THEN NULL
    WHEN prev_month_sales = 0 THEN NULL
    ELSE ROUND(((total_sales - prev_month_sales) / prev_month_sales) * 100, 2)
END AS growth_percentage
FROM sales_with_lag;
--10-
WITH ranked_products AS (
    SELECT 
    p.category_id,
    c.category_name,
    p.product_id,
    p.product_name,
    p.list_price,
    ROW_NUMBER() OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS row_num,
    RANK() OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS rank,
    DENSE_RANK() OVER (PARTITION BY p.category_id ORDER BY p.list_price DESC) AS dense_rank
    FROM production.products p
    JOIN production.categories c ON p.category_id = c.category_id
)
SELECT *
FROM ranked_products
WHERE row_num <= 3;
--11-
WITH customer_totals AS (
    SELECT 
    o.customer_id,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT 
c.customer_id,
c.first_name,
c.last_name,
ct.total_spent,
RANK() OVER (ORDER BY ct.total_spent DESC) AS spending_rank,
NTILE(5) OVER (ORDER BY ct.total_spent DESC) AS spending_group,
CASE 
    WHEN NTILE(5) OVER (ORDER BY ct.total_spent DESC) = 1 THEN 'VIP'
    WHEN NTILE(5) OVER (ORDER BY ct.total_spent DESC) = 2 THEN 'Gold'
    WHEN NTILE(5) OVER (ORDER BY ct.total_spent DESC) = 3 THEN 'Silver'
    WHEN NTILE(5) OVER (ORDER BY ct.total_spent DESC) = 4 THEN 'Bronze'
    ELSE 'Standard'
END AS tier
FROM customer_totals ct
JOIN sales.customers c ON c.customer_id = ct.customer_id;
--12-
WITH store_revenue AS (
    SELECT 
    o.store_id,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY o.store_id
)
SELECT 
s.store_id,
s.store_name,
sr.total_revenue,
sr.total_orders,
RANK() OVER (ORDER BY sr.total_revenue DESC) AS revenue_rank,
RANK() OVER (ORDER BY sr.total_orders DESC) AS order_count_rank,
PERCENT_RANK() OVER (ORDER BY sr.total_revenue) AS revenue_percentile
FROM store_revenue sr
JOIN sales.stores s ON s.store_id = sr.store_id;
--13-
SELECT 
c.category_name,
COUNT(CASE WHEN b.brand_name = 'Electra' THEN p.product_id END) AS Electra,
COUNT(CASE WHEN b.brand_name = 'Haro' THEN p.product_id END) AS Haro,
COUNT(CASE WHEN b.brand_name = 'Trek' THEN p.product_id END) AS Trek,
COUNT(CASE WHEN b.brand_name = 'Surly' THEN p.product_id END) AS Surly
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id
JOIN production.brands b ON p.brand_id = b.brand_id
GROUP BY c.category_name;
--14-
SELECT 
s.store_name,
SUM(CASE WHEN MONTH(o.order_date) = 1 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS Jan,
SUM(CASE WHEN MONTH(o.order_date) = 2 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS Feb,
SUM(CASE WHEN MONTH(o.order_date) = 3 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS Mar,
SUM(CASE WHEN MONTH(o.order_date) = 4 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS Apr,
SUM(CASE WHEN MONTH(o.order_date) = 5 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS May,
SUM(CASE WHEN MONTH(o.order_date) = 6 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS Jun,
SUM(CASE WHEN MONTH(o.order_date) = 7 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS Jul,
SUM(CASE WHEN MONTH(o.order_date) = 8 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS Aug,
SUM(CASE WHEN MONTH(o.order_date) = 9 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS Sep,
SUM(CASE WHEN MONTH(o.order_date) = 10 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS Oct,
SUM(CASE WHEN MONTH(o.order_date) = 11 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS Nov,
SUM(CASE WHEN MONTH(o.order_date) = 12 THEN oi.quantity * oi.list_price * (1 - oi.discount) ELSE 0 END) AS Dec,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS Total
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
JOIN sales.stores s ON o.store_id = s.store_id
GROUP BY s.store_name;
--15-
SELECT 
s.store_name,
COUNT(CASE WHEN o.order_status = 1 THEN o.order_id END) AS Pending,
COUNT(CASE WHEN o.order_status = 2 THEN o.order_id END) AS Processing,
COUNT(CASE WHEN o.order_status = 3 THEN o.order_id END) AS Rejected,
COUNT(CASE WHEN o.order_status = 4 THEN o.order_id END) AS Completed
FROM sales.orders o
JOIN sales.stores s ON o.store_id = s.store_id
GROUP BY s.store_name;
--16-
WITH yearly_sales AS (
    SELECT 
    b.brand_name,
    YEAR(o.order_date) AS order_year,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    JOIN production.products p ON oi.product_id = p.product_id
    JOIN production.brands b ON p.brand_id = b.brand_id
    WHERE YEAR(o.order_date) IN (2022, 2023, 2024)
    GROUP BY b.brand_name, YEAR(o.order_date)
),
pivoted AS (
    SELECT 
    brand_name,
    SUM(CASE WHEN order_year = 2022 THEN revenue ELSE 0 END) AS y2022,
    SUM(CASE WHEN order_year = 2023 THEN revenue ELSE 0 END) AS y2023,
    SUM(CASE WHEN order_year = 2024 THEN revenue ELSE 0 END) AS y2024
    FROM yearly_sales
    GROUP BY brand_name
)
SELECT 
brand_name,
y2022,
y2023,
y2024,
CASE 
    WHEN y2022 = 0 THEN NULL
    ELSE ROUND(((y2023 - y2022) / y2022) * 100, 2)
END AS growth_22_23,
CASE 
    WHEN y2023 = 0 THEN NULL
    ELSE ROUND(((y2024 - y2023) / y2023) * 100, 2)
END AS growth_23_24
FROM pivoted;
--17-
SELECT 
p.product_id,
p.product_name,
'In Stock' AS status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity > 0
UNION
SELECT 
p.product_id,
p.product_name,
'Out of Stock' AS status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity = 0 OR s.quantity IS NULL
UNION
SELECT 
p.product_id,
p.product_name,
'Discontinued' AS status
FROM production.products p
WHERE NOT EXISTS (
    SELECT 1 FROM production.stocks s WHERE s.product_id = p.product_id
);
--18-
SELECT DISTINCT customer_id
FROM sales.orders
WHERE YEAR(order_date) = 2023
INTERSECT
SELECT DISTINCT customer_id
FROM sales.orders
WHERE YEAR(order_date) = 2024;

--19-
SELECT product_id FROM production.stocks WHERE store_id = 1
INTERSECT
SELECT product_id FROM production.stocks WHERE store_id = 2
INTERSECT
SELECT product_id FROM production.stocks WHERE store_id = 3
EXCEPT
SELECT product_id FROM production.stocks WHERE store_id = 2
UNION
SELECT product_id FROM production.stocks WHERE store_id = 1

--20-
SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2022
EXCEPT
SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2023
UNION ALL
SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2023
EXCEPT
SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2022
UNION ALL
SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2022
INTERSECT
SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2023;



