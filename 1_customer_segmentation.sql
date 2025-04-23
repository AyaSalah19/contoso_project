WITH customer_ltv AS (
	SELECT 
		customerkey,
		full_name,
		sum(net_revenue) AS total_ltv
	FROM cohort_analysis 
	GROUP BY 
		customerkey,
		full_name
), customer_segments AS (
SELECT 
	PERCENTILE_CONT(.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile_ltv,
	PERCENTILE_CONT(.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile_ltv
FROM 
	customer_ltv
), segment_values AS (
SELECT 
c.*,
CASE 
	WHEN c.total_ltv< cs.ltv_25th_percentile_ltv  THEN '1-low_value'
	WHEN c.total_ltv<= cs.ltv_75th_percentile_ltv  THEN '2-Mid_value'
	ELSE '3-High_value'
END AS customer_segment


FROM customer_ltv c,
customer_segments cs
)

SELECT 
	customer_segment ,
	sum(total_ltv) AS total_ltv 
FROM segment_values
GROUP BY customer_segment