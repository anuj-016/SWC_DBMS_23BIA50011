SELECT
    DATE(s.date) AS request_date,
    ROUND(
        COUNT(a.action)::numeric / COUNT(*)::numeric,
        2
    ) AS acceptance_rate
FROM fb_friend_requests s
LEFT JOIN fb_friend_requests a
    ON s.user_id_sender = a.user_id_sender
   AND s.user_id_receiver = a.user_id_receiver
   AND a.action = 'accepted'
WHERE s.action = 'sent'
GROUP BY DATE(s.date)
HAVING COUNT(a.action) > 0;
