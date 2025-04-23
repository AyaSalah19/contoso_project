WITH customer_last_purchase AS (
	SELECT 
		customerkey,
		full_name ,
		orderdate,
		ROW_NUMBER() OVER (PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,
		first_purchase_date 
	FROM 
		cohort_analysis
),churned_customers AS (
	SELECT
		customerkey,
		full_name,
		orderdate last_purchase_date,
		CASE 
			WHEN orderdate<(SELECT max(orderdate) FROM sales)- INTERVAL'6 month' THEN  'Churned'
			ELSE 'Active'
		END customer_status
		
	FROM customer_last_purchase 
	WHERE rn=1
		AND first_purchase_date<(SELECT max(orderdate) FROM sales)  - INTERVAL'6 month'
)

SELECT 
	customer_status,
	count(customerkey) AS num_customer,
	sum(count (customerkey)) over() AS total_customers,
	100*round(count(customerkey)/sum(count (customerkey)) over(),2) AS status_percentage
FROM churned_customers
GROUP BY 
	customer_status