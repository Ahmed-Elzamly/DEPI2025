-- 1-
DECLARE @customer_id INT = 1;
DECLARE @total_spent DECIMAL(10, 2);
SELECT @total_spent = SUM(oi.quantity * oi.list_price * (1 - oi.discount))
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = @customer_id;
IF @total_spent > 5000
    PRINT 'Customer ID ' + CAST(@customer_id AS VARCHAR) + ' is a VIP. Total Spent: $' + CAST(@total_spent AS VARCHAR);
ELSE
    PRINT 'Customer ID ' + CAST(@customer_id AS VARCHAR) + ' is a Regular Customer. Total Spent: $' + CAST(@total_spent AS VARCHAR);

-- 2-
DECLARE @threshold DECIMAL(10, 2) = 1500;
DECLARE @count INT;
SELECT @count = COUNT(*) FROM production.products WHERE list_price > @threshold;
PRINT 'Products above $' + CAST(@threshold AS VARCHAR) + ': ' + CAST(@count AS VARCHAR);

-- 3-
DECLARE @staff_id INT = 2;
DECLARE @year INT = 2023;
DECLARE @total_sales DECIMAL(10, 2);
SELECT @total_sales = SUM(oi.quantity * oi.list_price * (1 - oi.discount))
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.staff_id = @staff_id AND YEAR(o.order_date) = @year;
PRINT 'Staff ID: ' + CAST(@staff_id AS VARCHAR) + ', Year: ' + CAST(@year AS VARCHAR) + ', Total Sales: $' + CAST(@total_sales AS VARCHAR);

-- 4-
SELECT @@SERVERNAME AS server_name, @@VERSION AS sql_version, @@ROWCOUNT AS last_rows_affected;

-- 5-
DECLARE @quantity INT;
SELECT @quantity = quantity FROM production.stocks WHERE product_id = 1 AND store_id = 1;
IF @quantity > 20
    PRINT 'Well stocked';
ELSE IF @quantity BETWEEN 10 AND 20
    PRINT 'Moderate stock';
ELSE
    PRINT 'Low stock - reorder needed';

-- 6-
WHILE EXISTS (SELECT TOP 1 * FROM production.stocks WHERE quantity < 5)
BEGIN
    UPDATE TOP (3) production.stocks
    SET quantity = quantity + 10
    WHERE quantity < 5;
    PRINT 'Updated 3 low-stock items';
END

-- 7-
SELECT 
product_id,
product_name,
list_price,
CASE 
    WHEN list_price < 300 THEN 'Budget'
    WHEN list_price BETWEEN 300 AND 800 THEN 'Mid-Range'
    WHEN list_price BETWEEN 801 AND 2000 THEN 'Premium'
    ELSE 'Luxury'
END AS price_category
FROM production.products;

-- 8.-
IF EXISTS (SELECT 1 FROM sales.customers WHERE customer_id = 5)
    SELECT COUNT(*) AS order_count FROM sales.orders WHERE customer_id = 5;
ELSE
    PRINT 'Customer ID 5 not found.';

-- 9-
CREATE FUNCTION dbo.CalculateShipping(@order_total DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN (
        CASE 
            WHEN @order_total > 100 THEN 0
            WHEN @order_total BETWEEN 50 AND 100 THEN 5.99
            ELSE 12.99
        END
    );
END;

-- 10-
CREATE FUNCTION dbo.GetProductsByPriceRange(@min_price DECIMAL(10,2), @max_price DECIMAL(10,2))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.product_id,
        p.product_name,
        p.list_price,
        b.brand_name,
        c.category_name
    FROM production.products p
    JOIN production.brands b ON p.brand_id = b.brand_id
    JOIN production.categories c ON p.category_id = c.category_id
    WHERE p.list_price BETWEEN @min_price AND @max_price
);

-- 11-
CREATE FUNCTION dbo.GetCustomerYearlySummary(@customer_id INT)
RETURNS @summary TABLE (
    year INT,
    total_orders INT,
    total_spent DECIMAL(10,2),
    avg_order_value DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @summary
    SELECT 
        YEAR(o.order_date),
        COUNT(DISTINCT o.order_id),
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)),
        AVG(oi.quantity * oi.list_price * (1 - oi.discount))
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @customer_id
    GROUP BY YEAR(o.order_date);
    RETURN;
END;

-- 12-
CREATE FUNCTION dbo.CalculateBulkDiscount(@quantity INT)
RETURNS DECIMAL(4,2)
AS
BEGIN
    RETURN (
        CASE 
            WHEN @quantity BETWEEN 3 AND 5 THEN 0.05
            WHEN @quantity BETWEEN 6 AND 9 THEN 0.10
            WHEN @quantity >= 10 THEN 0.15
            ELSE 0
        END
    );
END;

-- 13-
CREATE PROCEDURE sp_GetCustomerOrderHistory
    @customer_id INT,
    @start_date DATE = NULL,
    @end_date DATE = NULL
AS
BEGIN
    SELECT 
        o.order_id,
        o.order_date,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS order_total
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = @customer_id
    AND (@start_date IS NULL OR o.order_date >= @start_date)
    AND (@end_date IS NULL OR o.order_date <= @end_date)
    GROUP BY o.order_id, o.order_date;
END;

-- 14-
CREATE PROCEDURE sp_RestockProduct
    @store_id INT,
    @product_id INT,
    @restock_qty INT,
    @old_qty INT OUTPUT,
    @new_qty INT OUTPUT,
    @success BIT OUTPUT
AS
BEGIN
    SELECT @old_qty = quantity FROM production.stocks WHERE store_id = @store_id AND product_id = @product_id;
    UPDATE production.stocks
    SET quantity = quantity + @restock_qty
    WHERE store_id = @store_id AND product_id = @product_id;
    SELECT @new_qty = quantity FROM production.stocks WHERE store_id = @store_id AND product_id = @product_id;
    SET @success = 1;
END;

-- 15-
CREATE PROCEDURE sp_ProcessNewOrder
    @customer_id INT,
    @product_id INT,
    @quantity INT,
    @store_id INT
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @order_id INT, @price DECIMAL(10,2);
    SELECT @price = list_price FROM production.products WHERE product_id = @product_id;
    INSERT INTO sales.orders (customer_id, order_status, order_date, required_date, store_id, staff_id)
    VALUES (@customer_id, 1, GETDATE(), GETDATE(), @store_id, 1);
    SET @order_id = SCOPE_IDENTITY();
    INSERT INTO sales.order_items (order_id, item_id, product_id, quantity, list_price, discount)
    VALUES (@order_id, 1, @product_id, @quantity, @price, 0);
    COMMIT;
END;

-- 16-
CREATE PROCEDURE sp_SearchProducts
    @search_term VARCHAR(255) = NULL,
    @category_id INT = NULL,
    @min_price DECIMAL(10,2) = NULL,
    @max_price DECIMAL(10,2) = NULL,
    @sort_column VARCHAR(50) = NULL
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX) = 'SELECT * FROM production.products WHERE 1=1';
    IF @search_term IS NOT NULL SET @sql += ' AND product_name LIKE ''%' + @search_term + '%''';
    IF @category_id IS NOT NULL SET @sql += ' AND category_id = ' + CAST(@category_id AS VARCHAR);
    IF @min_price IS NOT NULL SET @sql += ' AND list_price >= ' + CAST(@min_price AS VARCHAR);
    IF @max_price IS NOT NULL SET @sql += ' AND list_price <= ' + CAST(@max_price AS VARCHAR);
    IF @sort_column IS NOT NULL SET @sql += ' ORDER BY ' + QUOTENAME(@sort_column);
    EXEC sp_executesql @sql;
END;

-- 17-
DECLARE @start_date DATE = '2023-01-01';
DECLARE @end_date DATE = '2023-03-31';
DECLARE @base_bonus DECIMAL(5,2) = 0.05;
SELECT 
s.staff_id,
s.first_name,
s.last_name,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales,
CASE 
    WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 10000 THEN 0.10
    WHEN SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 5000 THEN 0.07
    ELSE @base_bonus
END AS bonus_rate
FROM sales.staffs s
JOIN sales.orders o ON s.staff_id = o.staff_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.order_date BETWEEN @start_date AND @end_date
GROUP BY s.staff_id, s.first_name, s.last_name;

-- 18-
SELECT 
s.store_id,
s.product_id,
p.category_id,
s.quantity,
CASE 
    WHEN s.quantity < 10 THEN
        CASE 
            WHEN p.category_id = 1 THEN 'Reorder 20'
            WHEN p.category_id = 2 THEN 'Reorder 15'
            WHEN p.category_id = 3 THEN 'Reorder 10'
            ELSE 'Reorder 5'
        END
    WHEN s.quantity BETWEEN 10 AND 20 THEN
        CASE 
            WHEN p.category_id = 1 THEN 'Monitor Stock'
            ELSE 'Stock Sufficient'
        END
    ELSE 'Stock OK'
END AS restock_action
FROM production.stocks s
JOIN production.products p ON s.product_id = p.product_id;


-- 19-
WITH spending AS (
    SELECT 
        customer_id,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY customer_id
)
SELECT 
c.customer_id,
c.first_name,
c.last_name,
ISNULL(s.total_spent, 0) AS total_spent,
CASE 
    WHEN s.total_spent >= 10000 THEN 'Platinum'
    WHEN s.total_spent >= 5000 THEN 'Gold'
    WHEN s.total_spent >= 1000 THEN 'Silver'
    WHEN s.total_spent > 0 THEN 'Bronze'
    ELSE 'None'
END AS loyalty_tier
FROM sales.customers c
LEFT JOIN spending s ON c.customer_id = s.customer_id;

-- 20-
CREATE PROCEDURE sp_DiscontinueProduct
    @product_id INT,
    @replacement_product_id INT = NULL
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM sales.order_items oi
        JOIN sales.orders o ON oi.order_id = o.order_id
        WHERE oi.product_id = @product_id AND o.order_status IN (1, 2)
    )
    BEGIN
        IF @replacement_product_id IS NOT NULL
        BEGIN
            UPDATE sales.order_items
            SET product_id = @replacement_product_id
            WHERE product_id = @product_id;
            PRINT 'Product replaced in pending orders.';
        END
        ELSE
        BEGIN
            PRINT 'Cannot discontinue: product has pending orders.';
            RETURN;
        END
    END
    DELETE FROM production.stocks WHERE product_id = @product_id;
    PRINT 'Product discontinued and inventory cleared.';
END;