
WITH source_dates AS (
    SELECT view_start_ts::date AS date_value
    FROM {{ source('staging', 'viewing_events') }}

    UNION ALL

    SELECT start_date
    FROM {{ source('staging', 'plan_history') }}

    UNION ALL

    SELECT end_date
    FROM {{ source('staging', 'plan_history') }}

    UNION ALL

    SELECT start_date
    FROM {{ source('staging', 'subscriber_addons') }}

    UNION ALL

    SELECT end_date
    FROM {{ source('staging', 'subscriber_addons') }}
),

date_range AS (
    SELECT
        MIN(date_value) AS min_date,
        MAX(date_value) AS max_date
    FROM source_dates
)

SELECT
    d.full_date AS date_key,
    EXTRACT(YEAR FROM d.full_date)::int AS year,
    EXTRACT(MONTH FROM d.full_date)::int AS month,
    EXTRACT(QUARTER FROM d.full_date)::int AS quarter,
    EXTRACT(DAY FROM d.full_date)::int AS day
FROM date_range r
CROSS JOIN LATERAL generate_series(
    r.min_date,
    r.max_date,
    INTERVAL '1 day'
) AS d(full_date)
