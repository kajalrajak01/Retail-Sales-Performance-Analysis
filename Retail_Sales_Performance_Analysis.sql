-- =====================================================
-- Retail Sales Performance Analysis
-- SQL Analysis Queries
-- Author: Kajal Rajak
-- Database: PostgreSQL
-- =====================================================

--Q1. How does sales performance change by month and season?
SELECT
	year,
	month,
	SUM(total_amount) AS total_revenue,
	COUNT(order_id) AS total_orders,
	SUM(quantity) AS total_items_sold
FROM retail_sales
GROUP BY year, month
ORDER BY year ASC, month ASC;

--Q2. Which cities or regions are strongest and weakest in performance?
SELECT city,
	SUM(total_amount) AS total_revenue,
	COUNT(order_id) AS total_orders
FROM retail_sales
GROUP BY city
ORDER BY total_revenue DESC;

--Q3. What is the percentage of sales of each product category?
WITH cat_sales AS (
	SELECT 
		product_category,
		SUM(total_amount) AS category_sales
	FROM retail_sales
	GROUP BY product_category
)
SELECT 
	product_category,
	category_sales,
	ROUND(( 100.0 * category_sales / SUM(category_sales) OVER())::numeric, 2) AS sales_percentage
FROM cat_sales
ORDER BY category_sales DESC;

--Q4. Which product categories drive the most revenue, and what is their average transaction value?
SELECT 
    product_category,
    SUM(total_amount) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(total_amount)::numeric / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS average_order_value
FROM retail_sales
GROUP BY product_category
ORDER BY total_revenue DESC;

--Q5. Which customer segment and age group contribute the most revenue?
WITH demographic_sales AS (
	SELECT 
		gender,
		age_group,
		SUM(total_amount) AS total_revenue,
		COUNT(DISTINCT order_id) AS total_orders
FROM retail_sales
GROUP BY gender, age_group
ORDER BY total_revenue DESC
),
ranked_sales AS (
	SELECT *,
		ROW_NUMBER() OVER (PARTITION BY gender ORDER BY total_revenue DESC) AS rn
	FROM demographic_sales
)
SELECT gender, age_group, total_orders, total_revenue
FROM ranked_sales
WHERE rn = 1
ORDER BY total_revenue DESC;

--Q6. Who are the top customers, and how concentrated is revenue among them?
SELECT customer_id,
	COUNT(order_id) AS total_purchases,
	SUM(total_amount) AS total_spend
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spend DESC
LIMIT 10;

--Q7. Which customer groups or product groups should the business target for retention or promotion?
SELECT 
    city,
    age_group,
    gender,
    SUM(total_amount) AS total_revenue,
    COUNT(order_id) AS total_orders,
    ROUND(CAST(AVG(total_amount) AS NUMERIC), 2) AS avg_order_value
FROM retail_sales
GROUP BY city, age_group, gender
ORDER BY total_revenue ASC
LIMIT 20;