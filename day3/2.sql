WITH trend_data AS (
 
    SELECT 
        product_name,
        month_start,
        monthly_active_users,
        monthly_active_users - LAG(monthly_active_users) OVER (PARTITION BY product_name ORDER BY month_start) as diff
    FROM product_engagement
),
flags AS (
 
    SELECT 
        *,
        CASE WHEN diff < 0 THEN 1 ELSE 0 END as is_decline,
        CASE WHEN diff > 0 THEN 1 ELSE 0 END as is_growth
    FROM trend_data
),
turnarounds AS (
 
    SELECT 
        product_name,
        month_start,
        monthly_active_users,
c
        SUM(is_decline) OVER (PARTITION BY product_name ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as decl_count,
 
        SUM(is_growth) OVER (PARTITION BY product_name ORDER BY month_start ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as grow_count
    FROM flags
),
identified_products AS (
 
    SELECT 
        product_name,
        MIN(CASE WHEN decl_count = 3 THEN month_start END) OVER (PARTITION BY product_name) as decline_start_month,
        MIN(CASE WHEN grow_count = 3 THEN month_start END) OVER (PARTITION BY product_name) as growth_resume_month,
        MIN(monthly_active_users) OVER (PARTITION BY product_name ORDER BY month_start ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as lowest_users,
        MAX(monthly_active_users) OVER (PARTITION BY product_name) as peak_users
    FROM turnarounds
    WHERE EXISTS (SELECT 1 FROM turnarounds t2 WHERE t2.product_name = turnarounds.product_name AND t2.decl_count = 3)
      AND EXISTS (SELECT 1 FROM turnarounds t2 WHERE t2.product_name = turnarounds.product_name AND t2.grow_count = 3)
)
SELECT DISTINCT 
    product_name, 
    decline_start_month, 
    growth_resume_month,
    (CAST(peak_users AS FLOAT) - lowest_users) / lowest_users as growth_ratio
FROM identified_products
WHERE growth_resume_month > decline_start_month;