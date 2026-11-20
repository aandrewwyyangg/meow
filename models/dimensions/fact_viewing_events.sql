WITH ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY view_id
            ORDER BY view_start_ts DESC NULLS LAST,
                     subscriber_id,
                     content_id,
                     device_id,
                     minutes_watched DESC NULLS LAST,
                     completion_ratio DESC NULLS LAST
        ) AS rn
    FROM {{ source('staging', 'viewing_events') }}
),

deduplicated AS (
    SELECT *
    FROM ranked
    WHERE rn = 1
)

SELECT
    v.view_id,
    v.subscriber_id,
    v.content_id,
    v.device_id,
    v.view_start_ts::date AS date_key,
    v.view_start_ts,
    p.plan_id,
    v.minutes_watched,
    v.minutes_watched / 60.0 AS hours_watched,
    v.completion_ratio,
    1 AS view_count
FROM deduplicated v
LEFT JOIN LATERAL (
    SELECT h.plan_id
    FROM {{ source('staging', 'plan_history') }} h
    WHERE h.subscriber_id = v.subscriber_id
      AND v.view_start_ts >= h.start_date
      AND (
          h.end_date IS NULL
          OR v.view_start_ts < h.end_date
      )
    ORDER BY h.start_date DESC, h.history_id DESC
    LIMIT 1
) p ON TRUE
