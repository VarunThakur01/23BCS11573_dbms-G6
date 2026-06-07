SELECT 
    sent.date,
    ROUND(COUNT(accepted.user_id_sender) * 1.0 / COUNT(sent.user_id_sender), 2) AS acceptance_rate
FROM fb_friend_requests AS sent
LEFT JOIN fb_friend_requests AS accepted 
    ON sent.user_id_sender = accepted.user_id_sender 
    AND sent.user_id_receiver = accepted.user_id_receiver
    AND accepted.action = 'accepted'
WHERE sent.action = 'sent'
GROUP BY sent.date
HAVING COUNT(accepted.user_id_sender) > 0;