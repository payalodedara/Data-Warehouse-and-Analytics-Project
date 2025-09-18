-- --------- CUMULATIVE ANALYSIS -----------------
-- ==================================================


select order_date, total_sales,
sum(total_sales) over(partition by order_date order by order_date) as running_total_sales,
round(avg(avg_price) over(partition by order_date order by order_date),0) as moving_avg_price
from (
select DATE_FORMAT(order_date, '%Y-%m') AS order_date, sum(sales_amount) as total_sales, avg(price) as avg_price
from fact_sales
where order_date is not null
group by DATE_FORMAT(order_date, '%Y-%m')
order by DATE_FORMAT(order_date, '%Y-%m'))t;

