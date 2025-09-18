-- --------- CHANGE OVER TIME -----------------
===============================================

-- YEAR 

select year(order_date) as order_year, sum(sales_amount) as total_sales, count(distinct customer_key) as total_customers, sum(quantity) as total_quantity
from fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date);

-- MONTH YEAR 

select DATE_FORMAT(order_date, '%Y-%m') AS order_date, sum(sales_amount) as total_sales, count(distinct customer_key) as total_customers, sum(quantity) as total_quantity
from fact_sales
where order_date is not null
group by DATE_FORMAT(order_date, '%Y-%m')
order by DATE_FORMAT(order_date, '%Y-%m');
