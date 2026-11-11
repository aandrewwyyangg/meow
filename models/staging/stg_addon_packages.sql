SELECT
    package_id,
    package_name,
    monthly_price AS package_price,
    description
FROM {{ source('meow', 'addon_packages') }}