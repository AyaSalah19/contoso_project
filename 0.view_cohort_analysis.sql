WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.quantity::double precision * s.netprice * s.exchangerate) AS net_revenue,
            count(s.orderkey) AS order_count,
            c.countryfull,
            c.givenname,
            c.surname,
            c.age
           FROM sales s
             LEFT JOIN customer c ON s.customerkey = c.customerkey
          GROUP BY s.customerkey, s.orderdate, c.countryfull, c.age, c.givenname, c.surname
        )
 SELECT customerkey,
    orderdate,
    net_revenue,
    order_count AS order_num,
    countryfull,
    concat(TRIM(BOTH FROM givenname), ' ', TRIM(BOTH FROM surname)) AS full_name,
    age,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue cr;