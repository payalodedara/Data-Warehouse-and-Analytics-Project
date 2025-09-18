-- --------- DATA SEGMENTATION -----------------
-- =============================================

/*Segment products into cost ranges and 
count how many products fall into each segment*/

with product_segement as (
select product_key, product_name, product_cost,
CASE WHEN product_cost < 100 THEN 'Below 100'
     WHEN product_cost BETWEEN 100 AND 500 THEN '100-500'
     WHEN product_cost BETWEEN 500 AND 1000 THEN '500-1000'
      ELSE 'Above 1000'
END AS cost_range
from gold.dim_product
)

select cost_range,count(product_key) as count_product
from product_segement
group by cost_range;


/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/

with customer_spending as(
SELECT c.customer_key, fs.total_sales, fs.life_span
FROM gold.dim_customer c
LEFT JOIN (
SELECT customer_key, SUM(sales_amount) AS total_sales, MIN(order_date) AS min_od, MAX(order_date) AS max_od, TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) as life_span
FROM gold.fact_sales
GROUP BY customer_key
) fs
ON c.customer_key = fs.customer_key
)

select customer_key, total_sales, life_span,
case when total_sales> 5000 and life_span>=12 then 'VIP'
     when total_sales<= 5000 and life_span>=12 then 'Regular'
     else 'New'
end as segment
from customer_spending;


-- total segment count

with customer_spending as(
SELECT c.customer_key, fs.total_sales, fs.life_span
FROM gold.dim_customer c
LEFT JOIN (
SELECT customer_key, SUM(sales_amount) AS total_sales, MIN(order_date) AS min_od, MAX(order_date) AS max_od, TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) as life_span
FROM gold.fact_sales
GROUP BY customer_key
) fs
ON c.customer_key = fs.customer_key
)

select segment, count(customer_key) as segment_count
from(
select customer_key,
case when total_sales> 5000 and life_span>=12 then 'VIP'
     when total_sales<= 5000 and life_span>=12 then 'Regular'
     else 'New'
end as segment
from customer_spending
) seg
group by segment;
