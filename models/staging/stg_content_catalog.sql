SELECT
    content_id,
    content_type,
    genre_id,
    release_year,
    maturity_rating,
    runtime_minutes,
    package_id,
    added_to_catalog_date
FROM {{ source('meow', 'content_catalog') }}