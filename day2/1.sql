SELECT DISTINCT
    t1.user_id
FROM amazon_transactions t1
JOIN (
 
    SELECT 
        user_id, 
        MIN(created_at) AS first_purchase_date
    FROM amazon_transactions
    GROUP BY user_id
) t2 ON t1.user_id = t2.user_id
WHERE t1.created_at > t2.first_purchase_date
  AND t1.created_at <= t2.first_purchase_date + INTERVAL '7 days'
ORDER BY t1.user_id;