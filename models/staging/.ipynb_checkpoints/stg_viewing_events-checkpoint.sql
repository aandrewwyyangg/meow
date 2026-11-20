SELECT
    view_id,
    subscriber_id,
    content_id,
    device_id,
    view_start_ts,
    minutes_watched,
    completion_ratio
FROM {{ ref('viewing_events') }}