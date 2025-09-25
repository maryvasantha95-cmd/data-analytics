--  View all orders
SELECT * FROM Ecommerce_Delivery_Analytics_New;

--  Count orders for each platform, descending
SELECT
    "Platform",
    COUNT(*) AS order_count
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Platform"
ORDER BY order_count DESC;

--  Average delivery time and average service rating per platform
SELECT
    "Platform",
    ROUND(AVG("Delivery Time (Minutes)"),2) AS avg_delivery_time,
    ROUND(AVG("Service Rating"),2) AS avg_service_rating
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Platform"
ORDER BY avg_delivery_time;

--  Percentage of deliveries delayed by product category
SELECT
    "Product Category",
    ROUND(100.0 * SUM(CASE WHEN "Delivery Delay" = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS percent_delayed
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Product Category"
ORDER BY percent_delayed DESC;

--  Refund requests per platform
SELECT
    "Platform",
    COUNT(*) FILTER (WHERE "Refund Requested" = 'Yes') AS refund_requests,
    COUNT(*) AS total_orders
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Platform";

--  Minimum delivery time per customer
SELECT
    "Customer ID",
    MIN("Delivery Time (Minutes)") AS min_delivery_time
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Customer ID"
ORDER BY min_delivery_time ASC;

--  Orders with service rating below 3
SELECT *
FROM Ecommerce_Delivery_Analytics_New
WHERE "Service Rating" < 3;

--  Total order value by platform
SELECT
    "Platform",
    SUM("Order Value (INR)") AS total_order_value
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Platform"
ORDER BY total_order_value DESC;

--  Average delivery time for delayed vs non-delayed deliveries
SELECT
    "Delivery Delay",
    ROUND(AVG("Delivery Time (Minutes)"),2) AS avg_delivery_time
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Delivery Delay";

--  Distribution of orders by service rating
SELECT
    "Service Rating",
    COUNT(*) AS count_orders
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Service Rating"
ORDER BY "Service Rating";

--  Top 10 orders by order value
SELECT *
FROM Ecommerce_Delivery_Analytics_New
ORDER BY "Order Value (INR)" DESC
LIMIT 10;

--  Total revenue by platform
SELECT
    "Platform",
    SUM("Order Value (INR)") AS total_revenue
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Platform"
ORDER BY total_revenue DESC;

--  Delay percentage by platform
SELECT
    "Platform",
    ROUND(100.0 * SUM(CASE WHEN "Delivery Delay"='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS delay_percentage
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Platform"
ORDER BY delay_percentage DESC;

--  Average service rating by platform
SELECT
    "Platform",
    ROUND(AVG("Service Rating"),2) AS avg_rating
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Platform"
ORDER BY avg_rating DESC;

--  Refund rate by product category
SELECT
    "Product Category",
    ROUND(100.0 * SUM(CASE WHEN "Refund Requested"='Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS refund_rate
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Product Category"
ORDER BY refund_rate DESC;

--  Top 10 highest spending customers
SELECT
    "Customer ID",
    SUM("Order Value (INR)") AS total_spent,
    COUNT(*) AS total_orders
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Customer ID"
ORDER BY total_spent DESC
LIMIT 10;

--  Average service rating by delivery delay
SELECT
    "Delivery Delay",
    ROUND(AVG("Service Rating"),2) AS avg_rating
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Delivery Delay";

--  Top 5 product categories by revenue
SELECT
    "Product Category",
    SUM("Order Value (INR)") AS total_revenue
FROM Ecommerce_Delivery_Analytics_New
GROUP BY "Product Category"
ORDER BY total_revenue DESC
LIMIT 5;
