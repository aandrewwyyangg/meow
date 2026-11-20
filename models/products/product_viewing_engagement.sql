SELECT
    DATE_TRUNC('month', f.view_start_ts)::date AS viewing_month,
    c.genre_name,
    c.content_type,
    d.device_type,
    p.plan_name,

    COUNT(*) AS viewing_events,
    COUNT(DISTINCT f.subscriber_id) AS unique_subscribers,
    SUM(f.minutes_watched) AS total_minutes_watched,
    SUM(f.hours_watched) AS total_hours_watched,
    AVG(f.completion_ratio) AS avg_completion_ratio

FROM {{ ref('fact_viewing_events') }} f

LEFT JOIN {{ ref('dim_content') }} c
    ON f.content_id = c.content_id

LEFT JOIN {{ ref('dim_device') }} d
    ON f.device_id = d.device_id

LEFT JOIN {{ ref('dim_plan') }} p
    ON f.plan_id = p.plan_id

GROUP BY
    DATE_TRUNC('month', f.view_start_ts)::date,
    c.genre_name,
    c.content_type,
    d.device_type,
    p.plan_name
