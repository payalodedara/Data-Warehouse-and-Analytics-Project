-- --------- PART TO WHOLE ANALYSIS ------------------
-- ==================================================

-- which category contributes to the overasll sales

with category_sales as(
select p.category, sum(f.sales_amount) as total_sales
from gold.fact_sales f
left join gold.dim_product p on f.product_key = p.product_key
group by p.category
)

select category, total_sales, sum(total_sales) over() overall_sales,
(total_sales/sum(total_sales) over()) * 100 as per_of_total
from category_sales;
