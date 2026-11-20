SELECT
    history_id,
    subscriber_id,
    plan_id,
    start_date AS start_date_key,
    end_date AS end_date_key,
    CASE
        WHEN end_date IS NOT NULL
        THEN end_date - start_date
        ELSE NULL
    END AS duration_days,
    1 AS plan_history_count
FROM {{ source('staging', 'plan_history') }}
