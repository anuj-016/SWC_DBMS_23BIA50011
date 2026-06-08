WITH downloads_by_type AS (
    SELECT
        d.date,
        SUM(
            CASE
                WHEN a.paying_customer = 'no'
                THEN d.downloads
                ELSE 0
            END
        ) AS non_paying_downloads,
        SUM(
            CASE
                WHEN a.paying_customer = 'yes'
                THEN d.downloads
                ELSE 0
            END
        ) AS paying_downloads
    FROM ms_download_facts d
    JOIN ms_user_dimension u
      ON d.user_id = u.user_id
    JOIN ms_acc_dimension a
      ON u.acc_id = a.acc_id
    GROUP BY d.date
)

SELECT
    date,
    non_paying_downloads,
    paying_downloads
FROM downloads_by_type
WHERE non_paying_downloads > paying_downloads
ORDER BY date;
