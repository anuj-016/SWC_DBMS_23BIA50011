WITH user_purchases AS (
    SELECT
        user_id,
        MIN(created_at) AS first_purchase_date
    FROM purchases
    GROUP BY user_id
)

SELECT DISTINCT p.user_id
FROM purchases p
JOIN user_purchases u
ON p.user_id = u.user_id
WHERE p.created_at > u.first_purchase_date
  AND p.created_at <= u.first_purchase_date + INTERVAL '7 days';
