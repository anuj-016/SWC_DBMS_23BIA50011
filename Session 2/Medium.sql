WITH purchases AS (
    SELECT
        user_id,
        created_at,
        LEAD(created_at) OVER (
            PARTITION BY user_id
            ORDER BY created_at, id
        ) AS next_purchase_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY created_at, id
        ) AS rn
    FROM amazon_transactions
)

SELECT user_id
FROM purchases
WHERE rn = 1
  AND next_purchase_date > created_at
  AND next_purchase_date <= created_at + INTERVAL '7 days';
