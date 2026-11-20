-- ============================================================================
-- STARTER SNIPPET 1 of 4 : staging DDL  (Entertainment (Streaming) - Meow)
-- Run from the project folder:
--   psql -h <HOST> -U <YOUR_ROLE> -d dataeng -f starter/01_create_staging_starter.sql
-- This creates ONE example table so you can see the pattern. YOU must write the
-- DDL for every other CSV in /data, choosing sensible data types.
-- If your instructor gave you your own schema (e.g. student_jdoe), replace
-- 'staging' below with that schema name.
-- Never put passwords in this file.
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS cmp4754;

DROP TABLE IF EXISTS cmp4754.subscribers;
CREATE TABLE cmp4754.subscribers (
    subscriber_id       VARCHAR(20),
    first_name          VARCHAR(100),
    last_name           VARCHAR(100),
    email               VARCHAR(100),
    country             VARCHAR(100),
    birth_year          INTEGER,
    signup_date         DATE,
    subscription_status VARCHAR(100),
    cancel_date         DATE,
    marketing_opt_in    VARCHAR(100),
    current_plan_id     VARCHAR(20)
);

-- Staging tables mirror the CSV exactly. We deliberately do NOT add PRIMARY KEY
-- or NOT NULL here: a staging table must accept whatever the source sends so you
-- can measure its quality afterwards (see 03_verify_starter.sql).

-- TODO: one CREATE TABLE per remaining CSV file (look at each header + data first!)

-- ============================================================
-- MEOW STREAMING PROJECT - STAGING TABLES
-- Schema: cmp4754
-- ============================================================

-- 2. SUBSCRIPTION PLANS
CREATE TABLE IF NOT EXISTS cmp4754.subscription_plans (
    plan_id                VARCHAR(20),
    plan_name              VARCHAR(100),
    monthly_price          NUMERIC(10,2),
    max_concurrent_streams INTEGER,
    max_resolution         VARCHAR(20),
    has_ads                VARCHAR(10),
    billing_cycle          VARCHAR(50)
);

-- 3. PLAN HISTORY
CREATE TABLE IF NOT EXISTS cmp4754.plan_history (
    history_id    VARCHAR(20),
    subscriber_id VARCHAR(20),
    plan_id       VARCHAR(20),
    start_date    DATE,
    end_date      DATE
);

-- 4. ADDON PACKAGES
CREATE TABLE IF NOT EXISTS cmp4754.addon_packages (
    package_id   VARCHAR(20),
    package_name VARCHAR(100),
    monthly_price NUMERIC(10,2),
    description  TEXT
);

-- 5. SUBSCRIBER ADDONS
CREATE TABLE IF NOT EXISTS cmp4754.subscriber_addons (
    subscriber_package_id VARCHAR(20),
    subscriber_id         VARCHAR(20),
    package_id            VARCHAR(20),
    start_date            DATE,
    end_date              DATE
);

-- 6. CONTENT CATALOG
CREATE TABLE IF NOT EXISTS cmp4754.content_catalog (
    content_id            VARCHAR(20),
    title                 VARCHAR(200),
    content_type          VARCHAR(100),
    genre_id              VARCHAR(20),
    release_year          INTEGER,
    maturity_rating       VARCHAR(20),
    runtime_minutes       INTEGER,
    package_id            VARCHAR(20),
    added_to_catalog_date DATE
);

-- 7. GENRES
CREATE TABLE IF NOT EXISTS cmp4754.genres (
    genre_id   VARCHAR(20),
    genre_name VARCHAR(100)
);

-- 8. DEVICES
CREATE TABLE IF NOT EXISTS cmp4754.devices (
    device_id       VARCHAR(20),
    device_type     VARCHAR(100),
    platform_family VARCHAR(100)
);

-- 9. VIEWING EVENTS
CREATE TABLE IF NOT EXISTS cmp4754.viewing_events (
    view_id          VARCHAR(20),
    subscriber_id    VARCHAR(20),
    content_id       VARCHAR(20),
    device_id        VARCHAR(20),
    view_start_ts    TIMESTAMP,
    minutes_watched  INTEGER,
    completion_ratio NUMERIC(5,4)
);

-- Staging tables intentionally have no PRIMARY KEY,
-- FOREIGN KEY, or NOT NULL constraints.
-- Data quality checks are performed after loading.

