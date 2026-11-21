# Team Meow: Streaming Subscription Data Pipeline

Final project presented by Team Meow! The pipeline loads a streaming service's raw CSV files into PostgreSQL, models them as a star schema with dbt, and builds reporting views for Superset.

## Industry problem

A subscription streaming service wants to know how customers use its plans and add-on packages, what they watch, and how viewing relates to plan changes and cancellations. The results are meant for the subscriber growth, content strategy, packaging and pricing, and retention teams.

## Objectives

1. **Subscription levels:** count subscribers on each plan and each add-on package, and track upgrades and downgrades over time.
2. **Viewing:** measure hours and sessions by genre, content type, device, plan, and month.
3. **Package value:** check whether add-on holders watch the content in their packages and find under-used packages.
4. **Opportunity and risk:** find subscribers on lower plans with heavy viewing (upgrade candidates) and describe cancelled subscribers.

## Team

| Name | GitHub |
|---|---|
| Caitlyn Pratt | caitlyn-p |
| Inchara Kashyap | inchara-kashyap |
| Eddie Lin | eddiehlin |
| Andrew Yang | aandrewwyyangg |

## Data sources

The course instructor provided nine CSV files found in `seeds/`. Each file has a header row. Viewing events cover 2026-07-01 to 2026-10-31. Subscriptions and plan history go back to 2019. The project's as-of date is 2026-10-31.

| File | Rows | One row per |
|---|---|---|
| subscribers.csv | 2,506 | subscriber record (2,500 distinct subscriber IDs) |
| subscription_plans.csv | 4 | plan |
| plan_history.csv | 3,594 | period a subscriber spent on a plan |
| addon_packages.csv | 6 | add-on package |
| subscriber_addons.csv | 1,995 | add-on enrollment |
| content_catalog.csv | 400 | title |
| genres.csv | 12 | genre |
| devices.csv | 8 | device type |
| viewing_events.csv | 32,395 | source viewing record (32,355 distinct view IDs) |

## Pipeline

```
seeds/*.csv
  -> starter_files/02_load_starter.psql (psql \copy)
  -> raw tables in schema cmp4754
  -> models/dimensions (dbt views: 8 dimensions and fact_viewing_events)
  -> models/products (dbt views for the business questions)
  -> Superset charts
```

The conceptual and physical ER diagrams of the star schema are in `diagrams/`.

## Repository layout

```
meow/
  README.md
  docs/data_dictionary.md        tables, models, columns, and data quality notes
  seeds/                         the 9 source CSV files
  starter_files/
    01_create_staging_starter.sql    creates schema cmp4754 and the 9 raw tables
    02_load_starter.psql             loads the CSVs with \copy
    03_verify_starter.sql            row counts, sample rows, null, duplicate, and orphan checks
  verification_results.txt       saved output of 03_verify_starter.sql
  models/
    staging/                     stg_ views over the raw tables
    dimensions/                  sources.yml, 8 dimensions, and the fact table
    products/                    data products for the business questions
  diagrams/                      conceptual and physical ER diagrams
  dbt_project.yml
  analyses/ macros/ snapshots/ tests/
```

## How to reproduce

These steps build a fresh copy of the project in your own schema. In every command, replace `YOUR_DB_USER` with the database username you normally connect with and `YOUR_SCHEMA` with your own schema name.

### 1. Clone the repository

```bash
git clone https://github.com/aandrewwyyangg/meow.git
cd meow
```

Run every command below from this `meow` folder.

### 2. Point the scripts and dbt sources at your schema

The scripts and `models/dimensions/sources.yml` use schema `cmp4754`, where our team loaded the data. Replace it with your schema in your local copy:

```bash
sed -i 's/cmp4754/YOUR_SCHEMA/g' starter_files/01_create_staging_starter.sql starter_files/02_load_starter.psql starter_files/03_verify_starter.sql models/dimensions/sources.yml
```

The raw tables, `sources.yml`, and your dbt profile (step 4) must all use this same schema. The dimensional models read the raw tables through `source()`, which uses the schema in `sources.yml`. The `stg_` views read them through `ref()` to the seed names, which resolve to tables with those names in the dbt target schema. The nine tables loaded in step 3 have exactly those names.

### 3. Create, load, and verify a fresh copy of the raw tables

```bash
psql -h info-smith-i320.inf.utexas.edu -p 5432 -U YOUR_DB_USER -d postgres -f starter_files/01_create_staging_starter.sql
psql -h info-smith-i320.inf.utexas.edu -p 5432 -U YOUR_DB_USER -d postgres -f starter_files/02_load_starter.psql
psql -h info-smith-i320.inf.utexas.edu -p 5432 -U YOUR_DB_USER -d postgres -f starter_files/03_verify_starter.sql
```

`01_create_staging_starter.sql` creates the schema and the nine raw tables. 

`02_load_starter.psql` truncates all nine raw tables and reloads them from the CSVs in one transaction.

In `03_verify_starter.sql`, the first four queries are the instructor's starter examples against `staging.subscribers`. The project's checks start at the section `ROW COUNTS FOR ALL NINE TABLES`. In the output, that section begins with the nine-row table of row counts and the same table that starts at line 35 of `verification_results.txt`. Compare the rest of the output from that point.

### 4. Configure dbt

`dbt_project.yml` uses a profile named `meow`. Add it to `~/.dbt/profiles.yml`. That file stays outside the repository and must never be committed. Set `schema` to the schema that holds the nine raw tables.

```yaml
meow:
  target: dev
  outputs:
    dev:
      type: postgres
      host: info-smith-i320.inf.utexas.edu
      port: 5432
      user: YOUR_DB_USER
      password: YOUR_PASSWORD
      dbname: postgres
      schema: YOUR_SCHEMA
      threads: 1
```

Check the connection:

```bash
dbt debug
```

### 5. Build and test the models

```bash
dbt run
dbt test
```

`dbt run` builds every model in `models/` as a view in your schema: the `stg_` views, the dimensional models, and the data products. `dbt test` runs the project's data tests. Do not run `dbt seed` or `dbt build` for this recipe. `dbt build` includes `dbt seed`, and seeding would write the CSVs into tables with the same names as the raw tables you loaded in step 3.

### 6. Check the results

- **Raw tables:** the row counts should match the nine-row table at line 35 of `verification_results.txt`, the team's saved output from the course database.
- **Models:** expected row counts for the dimensional models and data products are in the [data dictionary](docs/data_dictionary.md). They were cross-checked against the supplied CSV files. For example, `fact_viewing_events` should have 32,355 rows (one per distinct `view_id`) and `dim_subscriber` should have 2,500 (one per distinct `subscriber_id`).

## Dashboard

Chart explanations are in the team's final report.

## Credentials

No passwords or connection strings with credentials are stored in this repository. Keep your password in `~/.dbt/profiles.yml` or enter it when psql asks.
