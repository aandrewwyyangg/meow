SELECT
    history_id,
    subscriber_id,
    plan_id,
    start_date,
    end_date
FROM {{ ref('plan_history') }}