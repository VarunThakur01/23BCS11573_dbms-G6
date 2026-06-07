WITH user_segments AS (
  
    SELECT 
        user_id,
        CASE 
            WHEN registration_date >= (SELECT MAX(event_timestamp::date) - INTERVAL '30 days' FROM search_events) 
            THEN 'new' 
            ELSE 'existing' 
        END AS user_segment
    FROM accounts
),
search_click_data AS (
 
    SELECT 
        s.user_id,
        s.event_timestamp AS search_time,
        MIN(c.event_timestamp) AS first_click_time
    FROM search_events s
    LEFT JOIN search_events c 
        ON s.session_id = c.session_id 
        AND c.event_type = 'click'
        AND c.event_timestamp > s.event_timestamp
        AND c.event_timestamp <= s.event_timestamp + INTERVAL '30 seconds'
    WHERE s.event_type = 'search'
    GROUP BY s.user_id, s.event_timestamp, s.session_id, s.query
)
 
SELECT 
    us.user_segment,
    COUNT(*) AS total_searches,
    COUNT(sc.first_click_time) AS successful_searches,
    ROUND(COUNT(sc.first_click_time)::numeric / COUNT(*), 2) AS success_rate
FROM search_click_data sc
JOIN user_segments us ON sc.user_id = us.user_id
GROUP BY us.user_segment;