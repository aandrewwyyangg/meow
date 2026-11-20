{{ config(materialized='view') }}

SELECT
    p.plan_id,
    p.plan_name,
    p.monthly_price,
    p.max_concurrent_streams,
    p.max_resolution,
    p.has_ads,
    COUNT(s.subscriber_id) AS active_subscriber_count,
    ROUND(COUNT(s.subscriber_id) * p.monthly_price, 2) AS active_monthly_revenue
FROM {{ ref('dim_plan') }} p
LEFT JOIN {{ ref('dim_subscriber') }} s
    ON p.plan_id = s.current_plan_id
    AND s.subscription_status = 'Active'
GROUP BY
    p.plan_id,
    p.plan_name,
    p.monthly_price,
    p.max_concurrent_streams,
    p.max_resolution,
    p.has_ads