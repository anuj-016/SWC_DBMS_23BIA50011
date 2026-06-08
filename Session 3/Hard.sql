WITH monthly_trends AS (
    SELECT
        product_id,
        product_name,
        month_start,
        monthly_active_users,
        LAG(monthly_active_users, 1) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS prev_1,
        LAG(monthly_active_users, 2) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS prev_2,
        LAG(monthly_active_users, 3) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS prev_3,
        LEAD(monthly_active_users, 1) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS next_1,
        LEAD(monthly_active_users, 2) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS next_2,
        LEAD(monthly_active_users, 3) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS next_3
    FROM product_engagement
),

turnarounds AS (
    SELECT
        product_id,
        product_name,
        month_start AS lowest_month,
        monthly_active_users AS lowest_users
    FROM monthly_trends
    WHERE
        prev_3 > prev_2
        AND prev_2 > prev_1
        AND prev_1 > monthly_active_users
        AND next_1 > monthly_active_users
        AND next_2 > next_1
        AND next_3 > next_2
),

peaks AS (
    SELECT
        t.product_id,
        t.product_name,
        t.lowest_month,
        t.lowest_users,
        MAX(p.monthly_active_users) AS peak_users
    FROM turnarounds t
    JOIN product_engagement p
      ON p.product_id = t.product_id
     AND p.month_start >= t.lowest_month
    GROUP BY
        t.product_id,
        t.product_name,
        t.lowest_month,
        t.lowest_users
)

SELECT
    t.product_name,
    t.lowest_month - INTERVAL '3 months' AS decline_started_month,
    t.lowest_month + INTERVAL '1 month' AS growth_resumed_month,
    ROUND(
        (p.peak_users - t.lowest_users)::numeric
        / t.lowest_users,
        4
    ) AS growth_ratio
FROM turnarounds t
JOIN peaks p
  ON p.product_id = t.product_id
 AND p.lowest_month = t.lowest_month
ORDER BY t.product_name;
