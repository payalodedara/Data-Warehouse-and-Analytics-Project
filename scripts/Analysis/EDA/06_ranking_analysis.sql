
-- -------------------Ranking Analysis ------------------------

-- Which 5 products Generating the Highest Revenue? (for less data run for : order_date >= '2012-01-01' )

with product_rank as(
select 
product_name, sum(sales_amount) as revenue_generated, rank() over(order by sum(sales_amount)  desc) rnk
from gold.dim_product p
left join gold.fact_sales f on f.product_key = p.product_key
where f.order_date >= '2012-01-01' 
group by product_name
)

SELECT product_name, revenue_generated
FROM product_rank
WHERE rnk <= 5;

-- The 3 customers with the fewest orders placed

SELECT c.customer_key, c.first_name, c.last_name, COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customer c ON c.customer_key = f.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders DESC
LIMIT 3;
