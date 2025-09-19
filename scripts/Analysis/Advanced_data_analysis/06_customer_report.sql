/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================


-- --------------- Customer Report -----------------------

DROP VIEW IF EXISTS gold.report_customers;

CREATE VIEW gold.report_customers AS

/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
with base_query as(
select f.order_number, f.product_key, f.order_date, f.sales_amount, f.quantity, c.customer_key, c.customer_number, 
concat(c.first_name, ' ', c.last_name) as customer_name, 
TIMESTAMPDIFF(year, c.birthdate, CURRENT_DATE()) as age
from gold.fact_sales f
left join gold.dim_customer c on c.customer_key = f.customer_key
where f.order_date is not null
),


/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
customer_aggregation AS (
select customer_key, customer_number, customer_name, age,
count(distinct order_number)as total_orders,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
count(distinct product_key) as total_products,
max(order_date) as last_order_date,
TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) as life_span
from base_query
group by customer_key, customer_number, customer_name, age
)

select customer_key, customer_number, customer_name, age, 
CASE 
	 WHEN age < 20 THEN 'Under 20'
	 WHEN age between 20 and 29 THEN '20-29'
	 WHEN age between 30 and 39 THEN '30-39'
	 WHEN age between 40 and 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
case when total_sales> 5000 and life_span>=12 then 'VIP'
     when total_sales<= 5000 and life_span>=12 then 'Regular'
     else 'New'
end as segment,
last_order_date, total_orders, total_sales, total_quantity, total_products, life_span,
TIMESTAMPDIFF(month, last_order_date, CURRENT_DATE()) AS recency,
-- Compuate average order value (AVO)
CASE WHEN total_sales = 0 THEN 0 ELSE total_sales / total_orders
END AS avg_order_value,
-- Compuate average monthly spend
CASE WHEN life_span = 0 THEN total_sales ELSE total_sales / life_span
END AS avg_monthly_spend
from customer_aggregation;

select * from gold.report_customers 



