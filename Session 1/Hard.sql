WITH purchases AS (
    SELECT
        transaction_id,
        transaction_date,
        amount
    FROM product_sales
    WHERE product_id = 'PROD-2891'
      AND country = 'US'
      AND status = 'completed'
      AND type = 'purchase'
      AND transaction_date BETWEEN DATE '2025-04-15'
                               AND DATE '2025-04-28'
),

revenue_events AS (
    SELECT
        transaction_date,
        amount AS revenue
    FROM purchases

    UNION ALL

    SELECT
        r.transaction_date,
        -r.amount AS revenue
    FROM product_sales r
    JOIN purchases p
      ON r.original_transaction_id = p.transaction_id
    WHERE r.type = 'refund'
      AND r.status = 'completed'
),

calendar AS (
    SELECT generate_series(
        DATE '2025-04-15',
        DATE '2025-04-28',
        INTERVAL '1 day'
    )::date AS transaction_date
)

SELECT
    c.transaction_date,
    COALESCE(SUM(re.revenue), 0) AS daily_net_revenue
FROM calendar c
LEFT JOIN revenue_events re
    ON c.transaction_date = re.transaction_date
GROUP BY c.transaction_date
ORDER BY c.transaction_date;
