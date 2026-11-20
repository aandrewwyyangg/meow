SELECT
    package_id,
    package_name,
    monthly_price,
    description
FROM {{ source('staging', 'addon_packages') }}
