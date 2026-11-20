SELECT
    subscriber_package_id,
    subscriber_id,
    package_id,
    start_date,
    end_date
FROM {{ ref('subscriber_addons') }}