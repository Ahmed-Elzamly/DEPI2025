--1-
CREATE NONCLUSTERED INDEX idx_customers_email ON sales.customers(email);
--2-
CREATE NONCLUSTERED INDEX idx_products_category_brand ON production.products(category_id, brand_id);
--3-
CREATE NONCLUSTERED INDEX idx_orders_order_date ON sales.orders(order_date)
INCLUDE (customer_id, store_id, order_status);
--4-
CREATE TRIGGER trg_after_customer_insert
ON sales.customers
AFTER INSERT
AS
BEGIN
    INSERT INTO sales.customer_log(customer_id, log_message)
    SELECT customer_id, email
    FROM inserted;
END;
--5-
CREATE TRIGGER trg_price_update
ON production.products
AFTER UPDATE
AS
INSERT INTO production.price_history(product_ID , old_price , new_price)
SELECT i.product_id , (SELECT d.list_price  FROM deleted d) , i.list_price
FROM inserted i ;
--6-
CREATE TRIGGER tr_catDeletion 
ON production.categories 
INSTEAD OF DELETE 
AS 
BEGIN
	IF EXISTS (
		SELECT 1  FROM deleted d
		JOIN production.products  P
		ON  d.category_id = P.category_id 
	)
	BEGIN
		SELECT 'you can not delete this '
	END
	ELSE 
		BEGIN
			DELETE FROM production.categories  
			WHERE category_id IN (SELECT category_id FROM deleted)
		END 	
 END;
--7-
CREATE TRIGGER tr_quanReduce
ON sales.order_items 
AFTER INSERT
AS 
BEGIN
	 UPDATE ST 
	 SET st.quantity = st.quantity - i.quantity FROM inserted i
	 JOIN production.stocks St 
	 ON i.product_id = st.product_id   
END;
--8-
CREATE TRIGGER tr_newOrd 
ON sales.orders 
AFTER INSERT 
AS
BEGIN
INSERT INTO sales.order_audit(order_id, customer_id, order_date ,[audit_timestamp])
SELECT order_id , customer_id , order_date , GETDATE()  FROM inserted 
END


