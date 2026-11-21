{{ config(materialized='view') }}

WITH package_catalog AS (
    SELECT
        package_id,
        COUNT(DISTINCT content_id) AS catalog_titles_count
    FROM {{ ref('dim_content') }}
    WHERE package_id IS NOT NULL
    GROUP BY package_id
),

package_holders AS (
    SELECT
        package_id,
        COUNT(DISTINCT subscriber_package_id) AS total_enrollments,
        COUNT(DISTINCT subscriber_id) AS distinct_holders,
        COUNT(DISTINCT CASE WHEN end_date_key IS NULL THEN subscriber_id END) AS active_holders
    FROM {{ ref('dim_subscriber_addons') }}
    GROUP BY package_id
),

holder_viewing AS (
    SELECT
        sa.package_id,
        COUNT(DISTINCT f.subscriber_id) AS active_viewing_holders,
        COUNT(DISTINCT f.view_id) AS package_sessions,
        ROUND(SUM(f.hours_watched), 2) AS package_hours_watched
    FROM {{ ref('dim_subscriber_addons') }} sa
    INNER JOIN {{ ref('fact_viewing_events') }} f
        ON sa.subscriber_id = f.subscriber_id
        AND f.date_key >= sa.start_date_key
        AND (sa.end_date_key IS NULL OR f.date_key <= sa.end_date_key)
    INNER JOIN {{ ref('dim_content') }} c
        ON f.content_id = c.content_id
        AND c.package_id = sa.package_id
    GROUP BY sa.package_id
)

SELECT
    pkg.package_id,
    pkg.package_name,
    pkg.monthly_price,
    COALESCE(cat.catalog_titles_count, 0) AS catalog_titles_count,
    COALESCE(h.total_enrollments, 0) AS total_enrollments,
    COALESCE(h.distinct_holders, 0) AS distinct_holders,
    COALESCE(h.active_holders, 0) AS active_holders,
    COALESCE(v.active_viewing_holders, 0) AS active_viewing_holders,
    ROUND(
        100.0 * COALESCE(v.active_viewing_holders, 0) / NULLIF(h.distinct_holders, 0),
        2
    ) AS holder_utilization_pct,
    COALESCE(v.package_sessions, 0) AS package_sessions,
    COALESCE(v.package_hours_watched, 0) AS package_hours_watched,
    ROUND(
        COALESCE(v.package_hours_watched, 0) / NULLIF(h.distinct_holders, 0),
        2
    ) AS avg_hours_per_holder
FROM {{ ref('dim_package') }} pkg
LEFT JOIN package_catalog cat
    ON pkg.package_id = cat.package_id
LEFT JOIN package_holders h
    ON pkg.package_id = h.package_id
LEFT JOIN holder_viewing v
    ON pkg.package_id = v.package_id