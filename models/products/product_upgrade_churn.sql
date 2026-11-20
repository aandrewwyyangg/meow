WITH enrollments AS (
    SELECT DISTINCT
        subscriber_package_id,
        subscriber_id,
        package_id,
        start_date,
        end_date
    FROM {{ ref('dim_subscriber_addons') }}
),

package_holders AS (
    SELECT
        package_id,
        COUNT(DISTINCT subscriber_id) AS total_package_holders
    FROM enrollments
    GROUP BY package_id
),

package_viewing AS (
    SELECT
        e.package_id,
        e.subscriber_id,
        f.view_id,
        f.minutes_watched
    FROM enrollments e
    INNER JOIN {{ ref('dim_content') }} c
        ON e.package_id = c.package_id
    INNER JOIN {{ ref('fact_viewing_events') }} f
        ON e.subscriber_id = f.subscriber_id
        AND c.content_id = f.content_id
        AND f.view_start_ts::date >= e.start_date
        AND (
            e.end_date IS NULL
            OR f.view_start_ts::date <= e.end_date
        )
),

unique_package_views AS (
    SELECT DISTINCT
        package_id,
        subscriber_id,
        view_id,
        minutes_watched
    FROM package_viewing
),

viewing_summary AS (
    SELECT
        package_id,
        COUNT(DISTINCT subscriber_id) AS active_viewers,
        COUNT(DISTINCT view_id) AS total_views,
        SUM(minutes_watched) / 60.0 AS total_hours_watched
    FROM unique_package_views
    GROUP BY package_id
)

SELECT
    p.package_id,
    p.package_name,
    COALESCE(h.total_package_holders, 0) AS total_package_holders,
    COALESCE(v.active_viewers, 0) AS active_viewers,
    COALESCE(v.total_views, 0) AS total_views,
    COALESCE(v.total_hours_watched, 0) AS total_hours_watched,

    ROUND(
        100.0 * COALESCE(v.active_viewers, 0)
        / NULLIF(h.total_package_holders, 0),
        2
    ) AS utilization_rate_pct

FROM {{ ref('dim_package') }} p
LEFT JOIN package_holders h
    ON p.package_id = h.package_id
LEFT JOIN viewing_summary v
    ON p.package_id = v.package_id
ORDER BY utilization_rate_pct ASC NULLS LAST

