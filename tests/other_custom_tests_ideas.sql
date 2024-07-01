
--  1.Check for invalid values

-- Check CUSTOMER_ZIP_CODE_PREFIX (e.g., not a 5-digit number)
   -- SELECT COUNT(*) AS invalid_zip_codes
   -- FROM Customers
   -- WHERE LENGTH(CAST(CUSTOMER_ZIP_CODE_PREFIX AS STRING)) != 5;

-- 2. Check for logical consistency

-- Check that timestamps are in correct order in Orders table:
   -- SELECT COUNT(*) AS inconsistent_order_dates
   -- FROM Orders
   -- WHERE order_delivered_customer_date < order_purchase_timestamp;

   -- SELECT COUNT(*) AS inconsistent_order_dates
   -- FROM Orders
   -- WHERE order_delivered_carrier_date < order_purchase_timestamp;

   -- SELECT COUNT(*) AS inconsistent_order_dates
   -- FROM Orders
   -- WHERE order_approved_at < order_purchase_timestamp;


-- Check that shipping_limit_date in Order_Items is after order_purchase_timestamp in Orders
   -- SELECT COUNT(*) AS inconsistent_shipping_dates
   -- FROM Order_Items AS oi
   -- JOIN Orders AS o ON oi.ORDER_ID = o.order_id
   -- WHERE oi.shipping_limit_date < o.order_purchase_timestamp;
