-- ============================================================================
-- STARTER SNIPPET 3 of 4 : verification queries   (Entertainment (Streaming))
-- Run after loading. Capture the output for your report (section 3.3).
-- ============================================================================

-- 1) Row count (compare to: wc -l data/subscribers.csv  minus 1 header line)
SELECT 'staging.subscribers' AS table_name, COUNT(*) AS row_count FROM staging.subscribers;

-- 2) Eyeball a few rows
SELECT * FROM staging.subscribers LIMIT 10;

-- 3) Null profile for every column (edit the column list for your table)
SELECT
    COUNT(*) FILTER (WHERE subscriber_id IS NULL) AS subscriber_id_nulls,
    COUNT(*) FILTER (WHERE first_name IS NULL) AS first_name_nulls,
    COUNT(*) FILTER (WHERE last_name IS NULL) AS last_name_nulls,
    COUNT(*) FILTER (WHERE email IS NULL) AS email_nulls,
    COUNT(*) FILTER (WHERE country IS NULL) AS country_nulls,
    COUNT(*) FILTER (WHERE birth_year IS NULL) AS birth_year_nulls,
    COUNT(*) FILTER (WHERE signup_date IS NULL) AS signup_date_nulls,
    COUNT(*) FILTER (WHERE subscription_status IS NULL) AS subscription_status_nulls,
    COUNT(*) FILTER (WHERE cancel_date IS NULL) AS cancel_date_nulls,
    COUNT(*) FILTER (WHERE marketing_opt_in IS NULL) AS marketing_opt_in_nulls,
    COUNT(*) FILTER (WHERE current_plan_id IS NULL) AS current_plan_id_nulls
FROM staging.subscribers;

-- 4) Is 'subscriber_id' really unique? (A key that is not unique changes your whole model.)
SELECT subscriber_id, COUNT(*) AS copies
FROM staging.subscribers
GROUP BY subscriber_id
HAVING COUNT(*) > 1
ORDER BY copies DESC
LIMIT 20;

-- 5) Profile the text columns: do category values look consistent?
--    (copy / paste this pattern for any column you want to inspect)
-- SELECT some_text_column, COUNT(*) FROM staging.subscribers GROUP BY 1 ORDER BY 2 DESC;

-- 6) Do the other files share this table's id? (example join check - adapt per file)
-- SELECT COUNT(*) FROM staging.<other_table> o
-- LEFT JOIN staging.subscribers t USING (subscriber_id)
-- WHERE t.subscriber_id IS NULL;

-- 1. ROW COUNTS FOR ALL NINE TABLES

SELECT 'subscribers' AS table_name, COUNT(*) AS row_count
FROM cmp4754.subscribers
UNION ALL
SELECT 'subscription_plans', COUNT(*)
FROM cmp4754.subscription_plans
UNION ALL
SELECT 'plan_history', COUNT(*)
FROM cmp4754.plan_history
UNION ALL
SELECT 'addon_packages', COUNT(*)
FROM cmp4754.addon_packages
UNION ALL
SELECT 'subscriber_addons', COUNT(*)
FROM cmp4754.subscriber_addons
UNION ALL
SELECT 'content_catalog', COUNT(*)
FROM cmp4754.content_catalog
UNION ALL
SELECT 'genres', COUNT(*)
FROM cmp4754.genres
UNION ALL
SELECT 'devices', COUNT(*)
FROM cmp4754.devices
UNION ALL
SELECT 'viewing_events', COUNT(*)
FROM cmp4754.viewing_events;


-- 2. SAMPLE ROWS

SELECT * FROM cmp4754.subscribers LIMIT 10;
SELECT * FROM cmp4754.subscription_plans LIMIT 10;
SELECT * FROM cmp4754.plan_history LIMIT 10;
SELECT * FROM cmp4754.addon_packages LIMIT 10;
SELECT * FROM cmp4754.subscriber_addons LIMIT 10;
SELECT * FROM cmp4754.content_catalog LIMIT 10;
SELECT * FROM cmp4754.genres LIMIT 10;
SELECT * FROM cmp4754.devices LIMIT 10;
SELECT * FROM cmp4754.viewing_events LIMIT 10;


-- 3. NULL PROFILE: SUBSCRIBERS

SELECT
    COUNT(*) FILTER (WHERE subscriber_id IS NULL) AS subscriber_id_nulls,
    COUNT(*) FILTER (WHERE first_name IS NULL) AS first_name_nulls,
    COUNT(*) FILTER (WHERE last_name IS NULL) AS last_name_nulls,
    COUNT(*) FILTER (WHERE email IS NULL) AS email_nulls,
    COUNT(*) FILTER (WHERE country IS NULL) AS country_nulls,
    COUNT(*) FILTER (WHERE birth_year IS NULL) AS birth_year_nulls,
    COUNT(*) FILTER (WHERE signup_date IS NULL) AS signup_date_nulls,
    COUNT(*) FILTER (WHERE subscription_status IS NULL) AS subscription_status_nulls,
    COUNT(*) FILTER (WHERE cancel_date IS NULL) AS cancel_date_nulls,
    COUNT(*) FILTER (WHERE marketing_opt_in IS NULL) AS marketing_opt_in_nulls,
    COUNT(*) FILTER (WHERE current_plan_id IS NULL) AS current_plan_id_nulls
FROM cmp4754.subscribers;


-- 4. DUPLICATE ID CHECKS

SELECT subscriber_id, COUNT(*) AS copies
FROM cmp4754.subscribers
GROUP BY subscriber_id
HAVING COUNT(*) > 1;

SELECT plan_id, COUNT(*) AS copies
FROM cmp4754.subscription_plans
GROUP BY plan_id
HAVING COUNT(*) > 1;

SELECT history_id, COUNT(*) AS copies
FROM cmp4754.plan_history
GROUP BY history_id
HAVING COUNT(*) > 1;

SELECT package_id, COUNT(*) AS copies
FROM cmp4754.addon_packages
GROUP BY package_id
HAVING COUNT(*) > 1;

SELECT subscriber_package_id, COUNT(*) AS copies
FROM cmp4754.subscriber_addons
GROUP BY subscriber_package_id
HAVING COUNT(*) > 1;

SELECT content_id, COUNT(*) AS copies
FROM cmp4754.content_catalog
GROUP BY content_id
HAVING COUNT(*) > 1;

SELECT genre_id, COUNT(*) AS copies
FROM cmp4754.genres
GROUP BY genre_id
HAVING COUNT(*) > 1;

SELECT device_id, COUNT(*) AS copies
FROM cmp4754.devices
GROUP BY device_id
HAVING COUNT(*) > 1;

SELECT view_id, COUNT(*) AS copies
FROM cmp4754.viewing_events
GROUP BY view_id
HAVING COUNT(*) > 1;


-- 5. CATEGORY PROFILING

SELECT subscription_status, COUNT(*)
FROM cmp4754.subscribers
GROUP BY subscription_status
ORDER BY COUNT(*) DESC;

SELECT marketing_opt_in, COUNT(*)
FROM cmp4754.subscribers
GROUP BY marketing_opt_in
ORDER BY COUNT(*) DESC;

SELECT content_type, COUNT(*)
FROM cmp4754.content_catalog
GROUP BY content_type
ORDER BY COUNT(*) DESC;

SELECT device_type, COUNT(*)
FROM cmp4754.devices
GROUP BY device_type
ORDER BY COUNT(*) DESC;


-- 6. REFERENTIAL INTEGRITY CHECKS

-- Viewing events referencing missing subscribers
SELECT COUNT(*) AS missing_subscribers
FROM cmp4754.viewing_events v
LEFT JOIN cmp4754.subscribers s
    ON v.subscriber_id = s.subscriber_id
WHERE s.subscriber_id IS NULL;

-- Viewing events referencing missing content
SELECT COUNT(*) AS missing_content
FROM cmp4754.viewing_events v
LEFT JOIN cmp4754.content_catalog c
    ON v.content_id = c.content_id
WHERE c.content_id IS NULL;

-- Viewing events referencing missing devices
SELECT COUNT(*) AS missing_devices
FROM cmp4754.viewing_events v
LEFT JOIN cmp4754.devices d
    ON v.device_id = d.device_id
WHERE d.device_id IS NULL;

-- Subscribers referencing missing subscription plans
SELECT COUNT(*) AS missing_plans
FROM cmp4754.subscribers s
LEFT JOIN cmp4754.subscription_plans p
    ON s.current_plan_id = p.plan_id
WHERE s.current_plan_id IS NOT NULL
  AND p.plan_id IS NULL;

-- Plan history referencing missing subscribers
SELECT COUNT(*) AS missing_history_subscribers
FROM cmp4754.plan_history h
LEFT JOIN cmp4754.subscribers s
    ON h.subscriber_id = s.subscriber_id
WHERE s.subscriber_id IS NULL;

-- Subscriber addons referencing missing packages
SELECT COUNT(*) AS missing_addon_packages
FROM cmp4754.subscriber_addons sa
LEFT JOIN cmp4754.addon_packages a
    ON sa.package_id = a.package_id
WHERE a.package_id IS NULL;

