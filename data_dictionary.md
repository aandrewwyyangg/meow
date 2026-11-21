# Data Dictionary

This file describes the raw tables, staging views, dimensional models, and data products in the Team Meow pipeline. The raw tables are created and loaded by the scripts in `starter_files/` into schema `cmp4754`. dbt builds every model as a view in the same schema. Row counts were cross-checked against the supplied CSV files in `seeds/`.

Types are PostgreSQL types. Raw table types match `starter_files/01_create_staging_starter.sql`, and dimensional model types match `diagrams/physical erd.png`.

## Key conventions

- Source IDs are retained and no surrogate keys are generated.
- `dim_date.date_key` is generated from the calendar date. Date key columns in the other models are calendar dates that join to it.
- PK and FK labels below are logical keys. They are not declared as database constraints. The star schema relationships are drawn in `diagrams/physical erd.png`.

## 1. Raw tables (schema `cmp4754`)

### subscribers
One row per subscriber record. 2,506 rows.

| Column | Type | Key | Description |
|---|---|---|---|
| subscriber_id | VARCHAR(20) | Source ID (duplicates present) | Subscriber identifier. 2,506 records share 2,500 IDs; the 6 extra rows are exact copies |
| first_name | VARCHAR(100) | | First name (synthetic) |
| last_name | VARCHAR(100) | | Last name (synthetic) |
| email | VARCHAR(100) | | Email address at example.com. 75 blank |
| country | VARCHAR(100) | | Two-letter country code: US, CA, GB, MX. 51 rows use lowercase |
| birth_year | INTEGER | | Year of birth, 1945 to 2008 |
| signup_date | DATE | | Signup date, 2019-03-01 to 2026-10-15 |
| subscription_status | VARCHAR(100) | | Active, Cancelled, or Paused, with inconsistent case (for example ACTIVE, active) |
| cancel_date | DATE | | Cancellation date. Blank unless the subscriber is cancelled (2,181 blank) |
| marketing_opt_in | VARCHAR(100) | | Y or N |
| current_plan_id | VARCHAR(20) | FK to subscription_plans | Plan the subscriber is on now |

### subscription_plans
One row per plan. 4 rows.

| Column | Type | Key | Description |
|---|---|---|---|
| plan_id | VARCHAR(20) | PK | Plan identifier |
| plan_name | VARCHAR(100) | | Basic with Ads, Standard, Premium, Premium Annual |
| monthly_price | NUMERIC(10,2) | | Monthly price, 7.99 to 22.99 |
| max_concurrent_streams | INTEGER | | Streams allowed at once: 1, 2, or 4 |
| max_resolution | VARCHAR(20) | | 720p, 1080p, or 4K |
| has_ads | VARCHAR(10) | | Y or N |
| billing_cycle | VARCHAR(50) | | Monthly or Annual |

### plan_history
One row per period a subscriber spent on one plan. 3,594 rows.

| Column | Type | Key | Description |
|---|---|---|---|
| history_id | VARCHAR(20) | PK | Plan period identifier |
| subscriber_id | VARCHAR(20) | FK to subscribers | Subscriber |
| plan_id | VARCHAR(20) | FK to subscription_plans | Plan for this period |
| start_date | DATE | | Plan-period start date, 2019-03-01 to 2026-10-31 |
| end_date | DATE | | Plan-period end date. When a subscriber changes plans, it equals the start_date of the next period. Blank when the period is still open (2,175 blank) |

### addon_packages
One row per add-on package. 6 rows.

| Column | Type | Key | Description |
|---|---|---|---|
| package_id | VARCHAR(20) | PK | Package identifier |
| package_name | VARCHAR(100) | | Sports Pass, Kids Zone, Documentary Plus, Anime Hub, Premium Movies, Global Cinema |
| monthly_price | NUMERIC(10,2) | | Monthly price, 4.99 to 9.99 |
| description | TEXT | | Short description of the package |

### subscriber_addons
One row per enrollment of a subscriber in an add-on package. 1,995 rows.

| Column | Type | Key | Description |
|---|---|---|---|
| subscriber_package_id | VARCHAR(20) | PK | Enrollment identifier |
| subscriber_id | VARCHAR(20) | FK to subscribers | Subscriber |
| package_id | VARCHAR(20) | FK to addon_packages | Package |
| start_date | DATE | | Enrollment start date |
| end_date | DATE | | Enrollment end date. Blank when still enrolled (1,430 blank) |

### content_catalog
One row per title. 400 rows.

| Column | Type | Key | Description |
|---|---|---|---|
| content_id | VARCHAR(20) | PK | Title identifier |
| title | VARCHAR(200) | | Title name |
| content_type | VARCHAR(100) | | Movie, Series, Documentary Special, or Stand-up Special |
| genre_id | VARCHAR(20) | FK to genres | Genre |
| release_year | INTEGER | | Release year, 2008 to 2026 |
| maturity_rating | VARCHAR(20) | | G, PG, PG-13, R, TV-Y, TV-14, or TV-MA. 10 blank |
| runtime_minutes | INTEGER | | Runtime, 22 to 150 minutes |
| package_id | VARCHAR(20) | FK to addon_packages | Add-on package that contains the title. Blank when the title is not in any package (259 blank) |
| added_to_catalog_date | DATE | | Date added to the catalog, 2022-01-10 to 2026-09-30 |

### genres
One row per genre. 12 rows.

| Column | Type | Key | Description |
|---|---|---|---|
| genre_id | VARCHAR(20) | PK | Genre identifier |
| genre_name | VARCHAR(100) | | Drama, Comedy, Action, Sci-Fi, Horror, Romance, Documentary, Kids & Family, Anime, Sports, International, Reality |

### devices
One row per device type. 8 rows.

| Column | Type | Key | Description |
|---|---|---|---|
| device_id | VARCHAR(20) | PK | Device identifier |
| device_type | VARCHAR(100) | | Smart TV, Mobile Phone, Tablet, Web Browser, Streaming Stick, Game Console, Set-Top Box, Laptop App |
| platform_family | VARCHAR(100) | | TV, Mobile, or Desktop |

### viewing_events
One row per source viewing record. 32,395 rows.

| Column | Type | Key | Description |
|---|---|---|---|
| view_id | VARCHAR(20) | Source ID (duplicates present) | Viewing record identifier. 32,395 records share 32,355 IDs; the 40 extra rows are exact copies |
| subscriber_id | VARCHAR(20) | FK to subscribers | Who watched |
| content_id | VARCHAR(20) | FK to content_catalog | What was watched |
| device_id | VARCHAR(20) | FK to devices | Device used |
| view_start_ts | TIMESTAMP | | Session start, no time zone, 2026-07-01 to 2026-10-31 |
| minutes_watched | INTEGER | | Minutes watched, 0 to 150. 224 sessions are 0 |
| completion_ratio | NUMERIC(5,4) | | Completion of the title, 0 to 1 |

## 2. Staging views (`models/staging`)

Nine `stg_` views, one per raw table. They read the loaded tables through `ref()` to the seed names, so they need the raw tables in the same schema as the dbt target. They keep the raw columns, types, and row counts, except that `stg_addon_packages` renames `monthly_price` to `package_price` and `stg_content_catalog` leaves out `title`. The dimensional models do not use them; they read the raw tables directly through `source()`.

## 3. Dimensional models (`models/dimensions`)

The models read the raw tables through `source('staging', ...)`, which `sources.yml` maps to schema `cmp4754`. A description of "As raw" means the column keeps the definition from section 1.

### fact_viewing_events
Grain: one row per viewing event. 32,355 rows (32,395 raw rows minus 40 duplicate view_id rows).

| Column | Type | Key | Description |
|---|---|---|---|
| view_id | VARCHAR(20) | PK | As raw, deduplicated so each view_id appears once |
| subscriber_id | VARCHAR(20) | FK to dim_subscriber | As raw |
| content_id | VARCHAR(20) | FK to dim_content | As raw |
| device_id | VARCHAR(20) | FK to dim_device | As raw |
| date_key | DATE | FK to dim_date | Calendar date of view_start_ts |
| view_start_ts | TIMESTAMP | | As raw |
| plan_id | VARCHAR(20) | FK to dim_plan | Plan active when the view began. The plan period includes its start date and excludes its end date. On a change date, the new plan applies if its period covers the view. Six views occurred on a period's end date with no covering period, so their plan_id is NULL |
| minutes_watched | INTEGER | | Measure, as raw |
| hours_watched | NUMERIC | | Measure: minutes_watched / 60.0 |
| completion_ratio | NUMERIC(5,4) | | Measure, as raw |
| view_count | INTEGER | | Measure: always 1, summed to count views |

### dim_subscriber
One row per subscriber. 2,500 rows (2,506 raw rows minus 6 duplicates). Source: subscribers.

| Column | Type | Key | Description |
|---|---|---|---|
| subscriber_id | VARCHAR(20) | PK | One row kept per subscriber_id |
| first_name | VARCHAR(100) | | As raw |
| last_name | VARCHAR(100) | | As raw |
| email | VARCHAR(100) | | As raw |
| country | VARCHAR(100) | | As raw. Case is not standardized |
| birth_year | INTEGER | | As raw |
| signup_date | DATE | | As raw |
| subscription_status | TEXT | | Trimmed and standardized to Active, Cancelled, or Paused |
| cancel_date | DATE | | As raw |
| marketing_opt_in | VARCHAR(100) | | As raw |
| current_plan_id | VARCHAR(20) | FK to dim_plan | As raw |

### dim_plan
One row per plan. 4 rows. Source: subscription_plans, with the same columns and types. PK: plan_id.

### dim_package
One row per add-on package. 6 rows. Source: addon_packages, with the same columns and types. PK: package_id.

### dim_device
One row per device type. 8 rows. Source: devices, with the same columns and types. PK: device_id.

### dim_content
One row per title. 400 rows. Source: content_catalog joined to genres on genre_id.

| Column | Type | Key | Description |
|---|---|---|---|
| content_id | VARCHAR(20) | PK | As raw |
| title | VARCHAR(200) | | As raw |
| content_type | VARCHAR(100) | | As raw |
| genre_id | VARCHAR(20) | | As raw. Kept as an attribute; genre_name is already on this table |
| genre_name | VARCHAR(100) | | Genre name from genres |
| release_year | INTEGER | | As raw |
| maturity_rating | VARCHAR(20) | | As raw |
| runtime_minutes | INTEGER | | As raw |
| package_id | VARCHAR(20) | FK to dim_package | As raw. Null for titles outside add-on packages |
| added_to_catalog_date | DATE | | As raw |

### dim_date
One row per calendar day from 2019-03-01 to 2026-10-31. 2,802 rows. The range runs from the earliest to the latest date in viewing_events, plan_history, and subscriber_addons.

| Column | Type | Key | Description |
|---|---|---|---|
| date_key | TIMESTAMPTZ | PK | The calendar day at midnight. Stored as a timestamp with time zone because generate_series returns timestamps |
| year | INTEGER | | Year |
| month | INTEGER | | Month, 1 to 12 |
| quarter | INTEGER | | Quarter, 1 to 4 |
| day | INTEGER | | Day of the month |

### dim_plan_history
One row per plan period. 3,594 rows. Source: plan_history.

| Column | Type | Key | Description |
|---|---|---|---|
| history_id | VARCHAR(20) | PK | As raw |
| subscriber_id | VARCHAR(20) | FK to dim_subscriber | As raw |
| plan_id | VARCHAR(20) | FK to dim_plan | As raw |
| start_date_key | DATE | FK to dim_date | Raw start_date |
| end_date_key | DATE | FK to dim_date | Raw end_date. Null while the period is open |
| duration_days | INTEGER | | end_date minus start_date. Null while open |
| plan_history_count | INTEGER | | Always 1, summed to count periods |

### dim_subscriber_addons
One row per add-on enrollment. 1,995 rows. Source: subscriber_addons.

| Column | Type | Key | Description |
|---|---|---|---|
| subscriber_package_id | VARCHAR(20) | PK | As raw |
| subscriber_id | VARCHAR(20) | FK to dim_subscriber | As raw |
| package_id | VARCHAR(20) | FK to dim_package | As raw |
| start_date_key | DATE | FK to dim_date | Raw start_date |
| end_date_key | DATE | FK to dim_date | Raw end_date. Null while enrolled |
| duration_days | INTEGER | | end_date minus start_date. Null while enrolled |
| enrollment_count | INTEGER | | Always 1, summed to count enrollments |

## 4. Data products (`models/products`)

### product_plan_levels
Question 1 (plans). One row per plan. 4 rows.

| Column | Type | Description |
|---|---|---|
| plan_id | VARCHAR(20) | From dim_plan |
| plan_name | VARCHAR(100) | From dim_plan |
| monthly_price | NUMERIC(10,2) | From dim_plan |
| max_concurrent_streams | INTEGER | From dim_plan |
| max_resolution | VARCHAR(20) | From dim_plan |
| has_ads | VARCHAR(10) | From dim_plan |
| active_subscriber_count | BIGINT | Subscribers with status Active whose current plan is this plan |
| active_monthly_revenue | NUMERIC | active_subscriber_count multiplied by monthly_price |

### product_addon_levels
Question 1 (add-on packages). One row per package. 6 rows.

| Column | Type | Description |
|---|---|---|
| package_id | VARCHAR(20) | From dim_package |
| package_name | VARCHAR(100) | From dim_package |
| monthly_price | NUMERIC(10,2) | From dim_package |
| active_subscriber_count | BIGINT | Distinct Active subscribers with an open enrollment (no end date) in the package |
| active_monthly_revenue | NUMERIC | active_subscriber_count multiplied by monthly_price |

### product_viewing_engagement
Question 2. One row per viewing month, genre, content type, device type, and plan. 3,928 rows.

| Column | Type | Description |
|---|---|---|
| viewing_month | DATE | First day of the month the view started |
| genre_name | VARCHAR(100) | Genre of the title |
| content_type | VARCHAR(100) | Content type of the title |
| device_type | VARCHAR(100) | Device used |
| plan_name | VARCHAR(100) | Plan at the time of the view. Null for the 6 views with no plan |
| viewing_events | BIGINT | Number of views |
| unique_subscribers | BIGINT | Distinct subscribers |
| total_minutes_watched | BIGINT | Sum of minutes_watched |
| total_hours_watched | NUMERIC | Sum of hours_watched |
| avg_completion_ratio | NUMERIC | Average completion_ratio |

### product_package_utilization
Question 3. One row per add-on package. 6 rows. A view counts toward a package when the subscriber watched a title in that package on or after the enrollment start date and on or before the end date (or any time after the start if the enrollment is open).

| Column | Type | Description |
|---|---|---|
| package_id | VARCHAR(20) | From dim_package |
| package_name | VARCHAR(100) | From dim_package |
| monthly_price | NUMERIC(10,2) | From dim_package |
| catalog_titles_count | BIGINT | Titles in the package |
| total_enrollments | BIGINT | Enrollment rows for the package |
| distinct_holders | BIGINT | Distinct subscribers ever enrolled |
| active_holders | BIGINT | Distinct subscribers with an open enrollment |
| active_viewing_holders | BIGINT | Distinct holders who watched package content while enrolled |
| holder_utilization_pct | NUMERIC | active_viewing_holders / distinct_holders x 100 |
| package_sessions | BIGINT | Distinct views of package content while enrolled |
| package_hours_watched | NUMERIC | Hours of package content watched while enrolled |
| avg_hours_per_holder | NUMERIC | package_hours_watched / distinct_holders |

### product_upgrade_churn
Question 3. One row per add-on package. 6 rows. Uses the same enrollment-window rule as product_package_utilization.

| Column | Type | Description |
|---|---|---|
| package_id | VARCHAR(20) | From dim_package |
| package_name | VARCHAR(100) | From dim_package |
| total_package_holders | BIGINT | Distinct subscribers ever enrolled |
| active_viewers | BIGINT | Distinct holders who watched package content while enrolled |
| total_views | BIGINT | Distinct views of package content while enrolled |
| total_hours_watched | NUMERIC | Hours of package content watched while enrolled |
| utilization_rate_pct | NUMERIC | active_viewers / total_package_holders x 100 |

## 5. Data quality notes

- **Duplicate rows:** 6 subscriber_id values and 40 view_id values appear twice as exact copies of the full row. dim_subscriber and fact_viewing_events keep one row per ID with ROW_NUMBER.
- **Inconsistent case:** subscription_status mixes cases and is standardized in dim_subscriber. 51 country codes are lowercase and are not standardized in the models.
- **Blanks with a business meaning:** cancel_date (not cancelled), plan_history.end_date and subscriber_addons.end_date (still open), content_catalog.package_id (title not in an add-on package).
- **Blanks without a business meaning:** email (75) and maturity_rating (10).
- **Zero-minute views:** 224 views have 0 minutes watched. They are kept.
- **Views with no plan:** 6 views occurred on a plan period's end date with no covering period, so fact_viewing_events.plan_id is NULL for them.
