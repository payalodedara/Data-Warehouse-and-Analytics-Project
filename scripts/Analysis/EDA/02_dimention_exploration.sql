-- ---------------- Dimention Exploration ------------------------

-- Retrieve a list of unique countries from which customers originate
SELECT DISTINCT country 
FROM gold.dim_customer
ORDER BY country;

-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT category, subcategory, product_name 
FROM gold.dim_product
ORDER BY category, subcategory, product_name;
