SELECT 
    date,
    SUM(CASE WHEN paying_customer = 'no' THEN downloads ELSE 0 END) AS non_paying_downloads,
    SUM(CASE WHEN paying_customer = 'yes' THEN downloads ELSE 0 END) AS paying_downloads
FROM ms_download_facts f
JOIN ms_user_dimension u ON f.user_id = u.user_id
JOIN ms_acc_dimension a ON u.acc_id = a.acc_id
GROUP BY date
HAVING SUM(CASE WHEN paying_customer = 'no' THEN downloads ELSE 0 END) > 
       SUM(CASE WHEN paying_customer = 'yes' THEN downloads ELSE 0 END)
ORDER BY date;