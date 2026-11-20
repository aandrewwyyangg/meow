{{ config(materialized='view') }}

WITH active_addon_holders AS (
    SELECT
        sa.package_id,
        sa.subscriber_id
    FROM {{ ref('dim_subscriber_addons') }} sa
    INNER JOIN {{ ref('dim_subscriber') }} s
        ON sa.subscriber_id = s.subscriber_id
    WHERE sa.end_date_key IS NULL
      AND s.subscription_status = 'Active'
)

SELECT
    pkg.package_id,
    pkg.package_name,
    pkg.monthly_price,
    COUNT(DISTINCT a.subscriber_id) AS active_subscriber_count,
    ROUND(COUNT(DISTINCT a.subscriber_id) * pkg.monthly_price, 2) AS active_monthly_revenue
FROM {{ ref('dim_package') }} pkg
LEFT JOIN active_addon_holders a
    ON pkg.package_id = a.package_id
GROUP BY
    pkg.package_id,
    pkg.package_name,
    pkg.monthly_price