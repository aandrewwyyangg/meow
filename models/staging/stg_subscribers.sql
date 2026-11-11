SELECT
    subscriber_id,
    first_name,
    last_name,
    email,
    country,
    birth_year,
    signup_date,
    subscription_status,
    cancel_date,
    marketing_opt_in,
    current_plan_id
FROM {{ source('meow', 'subscribers') }}