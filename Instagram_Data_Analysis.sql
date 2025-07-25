
Instagram_Metrics_SQL_Project

--Q1:How many unique post types are found in the fact_content table?
SELECT COUNT(DISTINCT post_type) AS unique_post_types
FROM fact_content;
---------------------------------------------------------------------------------------------------------------------------------------------------------

--Q2:What are the highest and lowest recorded impressions for each post type?
SELECT 
   post_type,
   MAX(impressions) AS highest_impressions,
   MIN(impressions) AS lowest_impressions
FROM fact_content
GROUP BY post_type;
----------------------------------------------------------------------------------------------------------------------------------------------------------

--Q3:Filter all the posts that were published on a weekend in the month of March and April and export them to a separate csv file.
SELECT fc.*
FROM fact_content fc
JOIN dim_dates dd ON fc.date = dd.date
WHERE dd.month_name IN ('March', 'April')
  AND dd.weekend_or_weekday = 'Weekend';
--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q4:Create a report to get the statistics for the account (month name, total profile visits, total new followers).
SELECT
    dd.month_name,
    SUM(fa.profile_visits) AS total_profile_visits,
    SUM(fa.new_followers) AS total_new_followers
FROM fact_account fa
JOIN dim_dates dd ON fa.date = dd.date
GROUP BY dd.month_name
ORDER BY dd.month_name;
------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q5:Calculate the total number of likes for each post category during July and arrange them in descending order.
WITH category_likes AS (
    SELECT
        fc.post_category,
        SUM(fc.likes) AS total_likes
    FROM fact_content fc
    JOIN dim_dates dd ON fc.date = dd.date
    WHERE dd.month_name = 'July'
    GROUP BY fc.post_category
)
SELECT
    post_category,
    total_likes
FROM category_likes
ORDER BY total_likes DESC;
-----------------------------------------------------------------------------------------------------------------------------------------------------------

--Q6:Create a report showing the unique post category names and their counts for each month.

SELECT
    dd.month_name,
    GROUP_CONCAT(DISTINCT fc.post_category 
    ORDER BY fc.post_category SEPARATOR ',') AS post_category_names,
    COUNT(DISTINCT fc.post_category) AS post_category_count
FROM fact_content fc
JOIN dim_dates dd ON fc.date = dd.date
GROUP BY dd.month_name
ORDER BY dd.month_name;
----------------------------------------------------------------------------------------------------------------------------------------------------------

--Q7:What is the percentage breakdown of total reach by post type?

SELECT 
post_type, 
SUM(reach) AS total_reach,
ROUND(SUM(reach) * 100.0 / 
(SELECT SUM(reach) FROM fact_content), 2) AS reach_percentage
FROM fact_content
GROUP BY post_type
ORDER BY reach_percentage DESC;
-----------------------------------------------------------------------------------------------------------------------------------------------------------

--Q8:Create a report that includes the quarter, total comments, and total saves recorded for each post category.

The final output columns should consist of:
•	post_category
•	quarter
•	total_comments
•	total_saves

SELECT fc.post_category,
    CASE 
        WHEN dd.month_name IN ('January', 'February', 'March') THEN 'Q1'
        WHEN dd.month_name IN ('April', 'May', 'June') THEN 'Q2'
        WHEN dd.month_name IN ('July', 'August', 'September') THEN 'Q3'
      ELSE 'Q4'
    END AS quarter,
SUM(fc.comments) AS total_comments, SUM(fc.saves) AS total_saves
FROM fact_content fc JOIN dim_dates dd ON fc.date = dd.date
GROUP BY fc.post_category, quarter
ORDER BY fc.post_category, quarter;
------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q9:List the top three dates in each month with the highest number of new followers.

SELECT 
    dd.month_name AS month, fa.date, fa.new_followers
FROM fact_account fa
JOIN dim_dates dd ON fa.date = dd.date
WHERE (
    SELECT COUNT(*) FROM fact_account fa2
    JOIN dim_dates dd2 ON fa2.date = dd2.date
    WHERE dd2.month_name = dd.month_name
      AND fa2.new_followers > fa.new_followers
) < 3
ORDER BY month, new_followers DESC;
---------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q10:Create a stored procedure that takes the week number as input (e.g., 'W1', 'W2') and shows total shares for each post type.

DELIMITER $$
CREATE PROCEDURE GetTotalSharesByPostType(IN input_week_no VARCHAR(10))
BEGIN
    SELECT 
        fc.post_type,
        SUM(fc.shares) AS total_shares
    FROM fact_content fc
    JOIN dim_dates dd ON fc.date = dd.date
    WHERE dd.week_no = input_week_no
    GROUP BY fc.post_type
    ORDER BY total_shares DESC;
END$$
DELIMITER ;

CALL GetTotalSharesByPostType('W1');
---------------------------------------------------------------------------------------------------------------------------------------------------------------


















