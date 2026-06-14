create schema Zepto;
use zepto;

DROP TABLE zepto;

CREATE TABLE zepto (
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp DECIMAL(8,2),
    discount_percent DECIMAL(5,2),
    available_quantity INT,
    discounted_selling_price DECIMAL(8,2),
    weight_in_gms INT,
    out_of_stock BOOLEAN,
    quantity INT
);

-- data exploration 
ALTER TABLE zepto_v2
RENAME COLUMN discountPercent TO discount_percent;

ALTER TABLE zepto_v2
RENAME COLUMN availableQuantity TO available_quantity;

ALTER TABLE zepto_v2
RENAME COLUMN discountedSellingPrice TO discounted_selling_price;

ALTER TABLE zepto_v2
RENAME COLUMN weightInGms TO weight_in_gms;

ALTER TABLE zepto_v2
RENAME COLUMN outOfStock TO out_of_stock;

-- count of rows 
select count(*) from zepto_v2;

-- sample data
select * from zepto_v2
limit 10;

-- checking null values 

SELECT *
FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discount_Percent IS NULL
   OR discounted_Selling_Price IS NULL
   OR weight_In_Gms IS NULL
   OR available_Quantity IS NULL
   OR out_Of_Stock IS NULL
   OR quantity IS NULL;
   
-- different product categories 
select distinct category
from zepto_v2
order by category;

-- Product in stock vs Out of stock

select out_of_Stock, count(Category)
from zepto_v2
group by out_of_Stock;

-- Product names present multiple times 
select name,count(Category) as 'number_of_Categories'
from zepto_v2
group by name
having count(Category)>1
order by count(Category) Desc;

-- Data Cleaning 

-- Checking product with price = 0

select * from zepto_v2
where mrp = 0 or discounted_selling_price = 0;

-- found mrp as 0
delete from zepto_v2
where mrp=0;

-- converting paise to rupees

update zepto_v2
set mrp = mrp/100.0,
discounted_selling_price = discounted_selling_price / 100.0;

select mrp, discounted_selling_price from zepto_v2;

-- KPI 

-- Q1. Find the Top 10 Best-Value Products Based on Discount Percentage
select distinct name, mrp, discount_percent
from zepto_v2
order by discount_percent desc
limit 10;

-- Q2. Identify Products with High MRP but Currently Out of Stock
SELECT DISTINCT name, mrp
FROM zepto_v2
WHERE mrp > 300 and out_of_stock ='TRUE';

-- Q3. Calculate Estimated Revenue for Each Category
SELECT Category,
SUM(discounted_selling_price * available_quantity) AS total_revenue
FROM zepto_v2
GROUP BY Category
ORDER BY total_revenue DESC;

-- Q4. Find All Products Where MRP is Greater Than ₹500 and Discount is Less Than 10%
SELECT DISTINCT name,mrp,discount_percent
FROM zepto_v2
WHERE mrp > 500
  AND discount_percent < 10
ORDER BY mrp DESC, discount_percent DESC;

-- Q5. Identify the Top 5 Categories Offering the Highest Average Discount Percentage
SELECT Category,
ROUND(AVG(discount_percent), 2) AS avg_discount
FROM zepto_v2
GROUP BY Category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Find the Price per Gram for Products Weighing More Than 100g and Rank Them by Best Value
SELECT DISTINCT name,weight_in_gms,discounted_selling_price,
ROUND(discounted_selling_price / weight_in_gms, 2) AS price_per_gram
FROM zepto_v2
WHERE weight_in_gms > 100
ORDER BY price_per_gram;

-- Q7. Categorize Products into Inventory Segments (Low, Medium, Bulk)
SELECT DISTINCT name,weight_in_gms,
CASE
	WHEN weight_in_gms < 1000 THEN 'Low'
	WHEN weight_in_gms < 5000 THEN 'Medium'
	ELSE 'Bulk'
END AS weight_category
FROM zepto_v2;

-- Q8. Calculate Total Inventory Weight for Each Category
SELECT Category,
SUM(weight_in_gms * available_quantity) AS total_weight
FROM zepto_v2
GROUP BY Category
ORDER BY total_weight DESC;

-- Q9. Identify Categories with the Highest Stock-Out Risk
SELECT Category,
COUNT(*) AS out_of_stock_products
FROM zepto_v2
WHERE out_of_stock = 'TRUE'
GROUP BY Category
ORDER BY out_of_stock_products DESC;

-- Q10. Estimate Potential Revenue Loss Due to Out-of-Stock Products
SELECT Category,
SUM(discounted_selling_price * quantity) AS potential_revenue_loss
FROM zepto_v2
WHERE out_of_stock = 'TRUE'
GROUP BY Category
ORDER BY potential_revenue_loss DESC;

-- Q11. Identify Dead Inventory (High Stock, Low Discount Products)
SELECT name,Category,available_quantity,discount_percent
FROM zepto_v2
WHERE available_quantity > 
(
SELECT AVG(available_quantity)
        FROM zepto_v2
)
AND discount_percent < 
(
SELECT AVG(discount_percent)
FROM zepto_v2
)
ORDER BY available_quantity DESC;

-- Q12. Calculate Discount Leakage by Category
SELECT Category,
SUM((mrp - discounted_selling_price) * available_quantity) AS discount_leakage
FROM zepto_v2
GROUP BY Category
ORDER BY discount_leakage DESC;

-- Q13. Determine Category Dominance by Inventory Value Contribution
SELECT Category,
SUM(discounted_selling_price * available_quantity) AS inventory_value
FROM zepto_v2
GROUP BY Category
ORDER BY inventory_value DESC;

-- Q14. Identify Products Suitable for Portfolio Optimization or Discontinuation
SELECT name,Category,available_quantity,discount_percent,discounted_selling_price
FROM zepto_v2
WHERE available_quantity < 
(
SELECT AVG(available_quantity)
FROM zepto_v2
)
AND discounted_selling_price < 
(
SELECT AVG(discounted_selling_price)
FROM zepto_v2
)
ORDER BY discounted_selling_price;

-- Q15 Top 3 Products by Inventory Value in Each Category
WITH ranked_products AS (
SELECT Category,name,
discounted_selling_price * available_quantity AS inventory_value,
ROW_NUMBER() OVER (
PARTITION BY Category
ORDER BY discounted_selling_price * available_quantity DESC
) AS rn
FROM zepto_v2
)
SELECT *
FROM ranked_products
WHERE rn <= 3
order by rn;



select * from zepto_v2;
