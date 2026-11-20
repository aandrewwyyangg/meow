SELECT
    device_id,
    device_type,
    platform_family
FROM {{ ref('devices') }}