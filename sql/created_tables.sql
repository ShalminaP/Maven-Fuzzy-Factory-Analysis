CREATE DATABASE IF NOT EXISTS maven_fuzzy_factory;
USE maven_fuzzy_factory;

CREATE TABLE products (
    product_id    INT PRIMARY KEY,
    created_at    DATETIME,
    product_name  VARCHAR(100)
);

CREATE TABLE website_sessions (
    website_session_id  INT PRIMARY KEY,
    created_at          DATETIME,
    user_id             INT,
    is_repeat_session   TINYINT,
    utm_source          VARCHAR(30),
    utm_campaign        VARCHAR(30),
    utm_content         VARCHAR(30),
    device_type         VARCHAR(20),
    http_referer        VARCHAR(100),
    channel             VARCHAR(30),
    campaign            VARCHAR(30),
    `date`              DATE,
    `year`              SMALLINT,
    `month`             TINYINT,
    `year_month`        CHAR(7)
);

CREATE TABLE website_pageviews (
    website_pageview_id  INT PRIMARY KEY,
    created_at           DATETIME,
    website_session_id   INT,
    pageview_url         VARCHAR(100)
);

CREATE TABLE orders (
    order_id            INT PRIMARY KEY,
    created_at          DATETIME,
    website_session_id  INT,
    user_id             INT,
    primary_product_id  INT,
    items_purchased     TINYINT,
    price_usd           DECIMAL(10,2),
    cogs_usd            DECIMAL(10,2),
    `date`              DATE,
    `year`              SMALLINT,
    `month`             TINYINT,
    `year_month`        CHAR(7),
    gross_profit_usd    DECIMAL(10,2)
);

CREATE TABLE order_items (
    order_item_id     INT PRIMARY KEY,
    created_at        DATETIME,
    order_id          INT,
    product_id        INT,
    is_primary_item   TINYINT,
    price_usd         DECIMAL(10,2),
    cogs_usd          DECIMAL(10,2),
    `date`            DATE,
    `year`            SMALLINT,
    `month`           TINYINT,
    `year_month`      CHAR(7),
    gross_profit_usd  DECIMAL(10,2)
);

CREATE TABLE order_item_refunds (
    order_item_refund_id  INT PRIMARY KEY,
    created_at            DATETIME,
    order_item_id         INT,
    order_id              INT,
    refund_amount_usd     DECIMAL(10,2),
    `date`                DATE,
    `year`                SMALLINT,
    `month`               TINYINT,
    `year_month`          CHAR(7)
);

SELECT COUNT(*) AS row_count,
       MIN(website_session_id) AS first_id,
       MAX(website_session_id) AS last_id,
       SUM(website_session_id) AS id_total
FROM maven_fuzzy_factory.website_sessions;

SET GLOBAL local_infile = 1;
USE maven_fuzzy_factory;

LOAD DATA LOCAL INFILE 'data/cleaned/clean_website_pageviews.csv'
INTO TABLE website_pageviews
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(website_pageview_id, created_at, website_session_id, @last_col)
SET pageview_url = TRIM(TRAILING '\r' FROM @last_col);

SELECT COUNT(*) AS row_count,
       MIN(website_pageview_id) AS first_id,
       MAX(website_pageview_id) AS last_id,
       SUM(website_pageview_id) AS id_total,
       COUNT(DISTINCT pageview_url) AS different_pages,
       COUNT(DISTINCT website_session_id) AS different_sessions
FROM website_pageviews;

SELECT COUNT(*) FROM website_pageviews WHERE pageview_url = '/thank-you-for-your-order';

