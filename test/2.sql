 WITH payment_diffs AS (
  SELECT 
    merchant_id,
     
    EXTRACT(EPOCH FROM (transaction_timestamp - LAG(transaction_timestamp) OVER (
      PARTITION BY merchant_id, credit_card_id, amount 
      ORDER BY transaction_timestamp
    ))) / 60 AS minute_difference
  FROM transactions
)

SELECT COUNT(*) AS payment_count
FROM payment_diffs
WHERE minute_difference <= 10;