# I320 Data Engineering - Final Project Dataset
## Entertainment (Streaming) | Team: Meow

### The assignment brief
> This will be focused on the streaming service packages customers have, what they are viewing, and what level of subscriptions.

**Stakeholders you are building for:** Subscriber growth, content strategy, packaging/pricing, and retention teams.

**Data window:** Viewing events from 2026-07-01 to 2026-10-31; subscriptions and plan history from 2019.

**"Today" for this project:** treat **2026-10-31** as the current date for any as-of logic.

### Analytical requirements (restate these in your own words in Section 2 of your report)
1. Subscription levels: How many subscribers are on each plan level and add-on package, and how have plan changes (upgrades/downgrades) moved over time?
2. Viewing: What are subscribers watching - hours and sessions by genre, content type, device, plan level, and month?
3. Package value: Do add-on package holders actually watch package content, and which packages are under-used?
4. Opportunity and risk: Which subscribers on a lower plan show heavy engagement (upgrade candidates), and what do cancelled subscribers look like?

### What is in this package
```
entertainment_meow/
  README.md                         <- this file
  data/                             <- 9 CSV files (UTF-8, comma-delimited, header row)
  starter/
    01_create_staging_starter.sql   <- example staging DDL (ONE table)
    02_load_starter.psql            <- example psql \copy load (ONE table)
    03_verify_starter.sql           <- verification / profiling queries
    04_dbt_sources_starter.yml      <- example dbt source declaration
```

| File | What it contains |
|---|---|
| `data/addon_packages.csv` | Optional add-on packages with price. |
| `data/content_catalog.csv` | Titles with type, genre, rating, runtime, and the add-on package (if any) that contains them. |
| `data/devices.csv` | Viewing device types. |
| `data/genres.csv` | Genres used to classify titles. |
| `data/plan_history.csv` | Every plan a subscriber has been on, with start and end dates. |
| `data/subscriber_addons.csv` | Add-on packages a subscriber has held, with start/end dates. |
| `data/subscribers.csv` | Streaming customers with signup, status, country, and current plan. |
| `data/subscription_plans.csv` | Plan levels with price, streams, resolution, and ads flag. |
| `data/viewing_events.csv` | Each viewing session with start time, minutes watched, and completion. |

### Read this before you start
* **All data is synthetic.** Names, e-mails, phone numbers and identifiers are invented. E-mails use the reserved `example.com` domain.
* **Nothing is labelled for you.** The files are not marked as "fact" or "dimension". Deciding what the **grain** is, which file(s) are fact tables, which are dimensions, which are bridges or lookups, and how the files relate is **your job** - and a core part of your grade. Start by reading headers, sampling rows, and testing which columns the files have in common.
* **The files share identifiers.** Columns with the same name/format across files are how the files connect. Verify every join: check cardinality (1:1, 1:many, many:many) before you trust a count.
* **The data is realistic, not pristine.** Expect nulls, inconsistent text values, and repeated rows. Detect them with queries, decide how to handle them, and document your decisions in your report (Sections 3 and 7). Do not silently delete rows - show your evidence.
* Some NULLs are *meaningful* (they describe a real business situation) and some are *defects*. Part of the work is telling them apart.

### Quick start
```bash
# 1. create your GitHub repo, then copy this folder's /data and /starter into it
# 2. from the project root:
psql -h <HOST> -U <YOUR_ROLE> -d dataeng -f starter/01_create_staging_starter.sql
psql -h <HOST> -U <YOUR_ROLE> -d dataeng -f starter/02_load_starter.psql
psql -h <HOST> -U <YOUR_ROLE> -d dataeng -f starter/03_verify_starter.sql
```
Then extend the snippets to cover **all** files, build your own dbt models (staging -> star schema -> data products), and visualize in Superset.

### Repository hygiene (from the project guide)
* Do **not** commit passwords, tokens, or `profiles.yml`. Add them to `.gitignore`.
* Commit the data only if your instructor allows it; otherwise document how to place it locally.

### Report checklist reminder
Introduction + restated requirements -> source documentation (conceptual & physical ER) -> staging DDL & `\copy` script with verification -> grain/facts/dimensions + lineage diagram -> star schema evidence -> your own dbt models -> data products -> Superset dashboard + interpretation -> reflection -> repo link.
