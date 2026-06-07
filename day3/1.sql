SELECT 
    cust_id, 
    SUM(total_order_cost) AS revenue
FROM orders
WHERE order_date >= '2019-03-01' AND order_date <= '2019-03-31'
GROUP BY cust_id
ORDER BY revenue DESC;