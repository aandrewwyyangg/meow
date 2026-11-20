SELECT
    c.content_id,
    c.title,
    c.content_type,
    c.genre_id,
    g.genre_name,
    c.release_year,
    c.maturity_rating,
    c.runtime_minutes,
    c.package_id,
    c.added_to_catalog_date
FROM {{ source('staging', 'content_catalog') }} c
LEFT JOIN {{ source('staging', 'genres') }} g
    ON c.genre_id = g.genre_id
