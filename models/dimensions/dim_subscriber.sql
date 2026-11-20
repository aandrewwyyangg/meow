WITH ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY subscriber_id
            ORDER BY signup_date DESC NULLS LAST,
                     email NULLS LAST,
                     first_name,
                     last_name
        ) AS rn
    FROM {{ source('staging', 'subscribers') }}
)

SELECT
    subscriber_id,
    first_name,
    last_name,
    email,
    country,
    birth_year,
    signup_date,
    INITCAP(LOWER(TRIM(subscription_status))) AS subscription_status,
    cancel_date,
    marketing_opt_in,
    current_plan_id
FROM ranked
WHERE rn = 1
