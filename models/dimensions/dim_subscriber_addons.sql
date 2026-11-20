SELECT
    subscriber_package_id,
    subscriber_id,
    package_id,
    start_date AS start_date_key,
    end_date AS end_date_key,
    CASE
        WHEN end_date IS NOT NULL
        THEN end_date - start_date
        ELSE NULL
    END AS duration_days,
    1 AS enrollment_count
FROM {{ source('staging', 'subscriber_addons') }}
