create database data_analyst_pr;
use data_analyst_pr;
show tables;

Select *from customer_data;
-- Business Insights Questions
-- 1 Category generating Highest revenu
DESCRIBE customer_data;
DROP TABLE customer_data;
DESCRIBE customer_data;
SELECT category, 
       ROUND(SUM(purchase_amount_usd),2) AS revenue
FROM customer_data
GROUP BY category;

-- Company does not know which category contributes most to revenue

-- 2 Are discounts actually purchase value?
select *from customer_data;

SELECT discount_applied, 
       ROUND(SUM(purchase_amount_usd),2) AS total_revenue,
       ROUND(AVG(purchase_amount_usd),2) AS avg_purchase
FROM customer_data
GROUP BY discount_applied;


-- 3 What is the total revenue by male and female customer?
select *from customer_data;
SELECT gender, 
       ROUND(SUM(purchase_amount_usd),2) AS revenue
FROM customer_data
GROUP BY gender
order by revenue desc;
-- Lack of understanding of revenue contribution by gender segments


-- 4 which customer used discount but still spent more then average purchase amount?
select *from customer_data;
SELECT customer_id,
       purchase_amount_usd,
       discount_applied
FROM customer_data
WHERE discount_applied = 'Yes'
  AND purchase_amount_usd > (
        SELECT AVG(purchase_amount_usd) 
        FROM customer_data
      )
LIMIT 10;

-- 5 which are the top/bottom 5 prodcuts with the highest average review rating
select *from customer_data;

 select item_purchased, 
      round( AVG(review_rating),2) AS avg_ratings
FROM customer_data
GROUP BY item_purchased
order by avg_ratings desc limit 5;

 select item_purchased, 
      round( AVG(review_rating),2) AS avg_ratings
FROM customer_data
GROUP BY item_purchased
order by avg_ratings asc limit 5;

-- 6 Average purchase : Standard vs Express Shipping
select *from customer_data;

Select shipping_type , 
Count(Distinct customer_id) as order_placed,
Round(avg(purchase_amount_usd),2)as avg_purchase
from customer_data
Where shipping_type In ('Standard' ,'Express')
group by shipping_type;

-- 7 Do subscribed customer spend more? Compare average speed and total revenue between subscribers and non - subscribers

select *from customer_data;

select subscription_status,
count(customer_id) as users,
Round(avg(purchase_amount_usd) , 2) as avg_revenue,
Round(Sum(purchase_amount_usd) , 2) as total_revnue
from customer_data
group by subscription_status;


--  8 top 5 products with highest discount usage %

select *from customer_data;
SELECT 
    item_purchased,
    COUNT(*) AS total_sold,
    
    SUM(CASE 
            WHEN discount_applied = 'yes' THEN 1 
            ELSE 0 
        END) AS discount_used,

    (SUM(CASE 
            WHEN discount_applied = 'yes' THEN 1 
            ELSE 0 
        END) * 100.0 / COUNT(*)) AS discount_usage_percentage

FROM customer_data
GROUP BY item_purchased
ORDER BY discount_usage_percentage DESC
LIMIT 5;

-- 9 Segment customer into new , returning and loyal based on their total number of previous purchase ,
-- and show the count of each segment.

select *from customer_data;
SELECT 
    CASE 
        WHEN previous_purchases = 0 THEN 'New Customer'
        WHEN previous_purchases BETWEEN 1 AND 15 THEN 'Returning Customer'
        ELSE 'Loyal Customer'
    END AS customer_segment,
    
    COUNT(*) AS customer_count

FROM customer_data

GROUP BY customer_segment;

-- Lack of customer segmentation leads to generic strategies

-- 10 What are the top 3 most purchased products within each category
WITH cte AS (
    SELECT 
        category,
        item_purchased,
        COUNT(*) AS most_purchased,
        RANK() OVER (
            PARTITION BY category 
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM customer_data
    GROUP BY category, item_purchased
)

SELECT *
FROM cte
WHERE rnk <= 3
ORDER BY category, rnk;


--  11 Are customers who are repeat buyers(more then 5 previous purchased ) also likely to subscribe?
SELECT 
    CASE 
        WHEN previous_purchases > 5 THEN 'Repeat Buyers'
        ELSE 'Normal Buyers'
    END AS customer_type,

    subscription_status,

    COUNT(*) AS customer_count,

    (COUNT(*) * 100.0 / 
        SUM(COUNT(*)) OVER (
            PARTITION BY 
                CASE 
                    WHEN previous_purchases > 5 THEN 'Repeat Buyers'
                    ELSE 'Normal Buyers'
                END
        )
    ) AS percentage

FROM customer_data

GROUP BY 
    customer_type,
    subscription_status;
    
    -- 12 what is the reveue contribution of each age group ?
    
    SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 35 AND 50 THEN '35-50'
        ELSE '51+'
    END AS age_group,

   round( SUM(purchase_amount_usd),2) AS total_revenue

FROM customer_data

GROUP BY 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 35 AND 50 THEN '35-50'
        ELSE '51+'
    END

 