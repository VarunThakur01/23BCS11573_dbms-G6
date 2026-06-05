WITH june_actions AS (
     
    SELECT DISTINCT user_id
    FROM user_actions
    WHERE event_date >= '2022-06-01' AND event_date < '2022-07-01'
),
july_actions AS (
     
    SELECT DISTINCT user_id
    FROM user_actions
    WHERE event_date >= '2022-07-01' AND event_date < '2022-08-01'
)
 
SELECT 
    7 AS month, 
    COUNT(july_actions.user_id) AS monthly_active_users
FROM july_actions
INNER JOIN june_actions 
    ON july_actions.user_id = june_actions.user_id;