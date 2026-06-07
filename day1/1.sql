WITH date_series AS (
    SELECT generate_series('2025-04-15'::date, '2025-04-28'::date, '1 day'::interval)::date AS transaction_date
),
target_purchases AS (
    SELECT 
        transaction_id, 
        transaction_date, 
        amount
    FROM product_sales
    WHERE product_id = 'PROD-2891'
      AND country = 'US'
      AND type = 'PURCHASE'
      AND status = 'completed'
      AND transaction_date BETWEEN '2025-04-15'::date AND '2025-04-28'::date
),
refunds AS (
    SELECT 
        ps.original_transaction_id, 
        ps.amount
    FROM product_sales ps
    JOIN target_purchases tp ON ps.original_transaction_id = tp.transaction_id
    WHERE ps.type = 'REFUND'
      AND ps.status = 'completed'
),
daily_revenue AS (
    SELECT 
        tp.transaction_date,
        SUM(tp.amount - COALESCE(r.amount, 0)) AS net_revenue
    FROM target_purchases tp
    LEFT JOIN refunds r ON tp.transaction_id = r.original_transaction_id
    GROUP BY tp.transaction_date
)
SELECT 
    ds.transaction_date,
    COALESCE(dr.net_revenue, 0) AS daily_net_revenue
FROM date_series ds
LEFT JOIN daily_revenue dr ON ds.transaction_date = dr.transaction_date
ORDER BY ds.transaction_date;