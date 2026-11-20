SELECT
    plan_id,
    plan_name,
    monthly_price,
    max_concurrent_streams,
    max_resolution,
    has_ads,
    billing_cycle
FROM {{ source('staging', 'subscription_plans') }}
