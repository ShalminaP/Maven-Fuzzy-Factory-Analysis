-- =====================================================================
-- MAVEN FUZZY FACTORY | SIMPLE DATA CHECKS AFTER LOADING (no indexes needed)
-- Purpose: prove the data in SQL is complete and correct BEFORE doing analysis.
-- Select ONE query at a time and press Ctrl+Enter.
-- =====================================================================
USE maven_fuzzy_factory;

-- CHECK 1: ROW COUNTS - did every row load?
-- Why: if a count is lower than the CSV, the import stopped early.
-- expect: sessions 472871 | pageviews 1188124 | orders 32313 | order_items 40025 | refunds 1731 | products 4
SELECT 'website_sessions' AS table_name, COUNT(*) AS row_count FROM website_sessions
UNION ALL
SELECT 'website_pageviews', COUNT(*) FROM website_pageviews
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_item_refunds', COUNT(*) FROM order_item_refunds
UNION ALL
SELECT 'products', COUNT(*) FROM products;

-- CHECK 2: DATE RANGE - is the whole 3 years there?
-- Why: a load that stopped early would end before the real last date.
-- expect: 2012-03-19 08:04:16  to  2015-03-19 07:59:08
SELECT MIN(created_at) AS first_visit, MAX(created_at) AS last_visit FROM website_sessions;

-- CHECK 3: DUPLICATE IDs - is every ID unique?
-- Why: a table loaded twice would repeat IDs.
-- expect: 0 rows returned for each query (an empty result is good)
SELECT website_session_id, COUNT(*) AS times_found
FROM website_sessions
GROUP BY website_session_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*) AS times_found
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- CHECK 4: MISSING VALUES - are there any blanks in key columns?
-- Why: blanks can break joins and ratios.
-- expect: 0 for every column
SELECT
    SUM(CASE WHEN created_at IS NULL THEN 1 ELSE 0 END)         AS missing_dates,
    SUM(CASE WHEN channel IS NULL THEN 1 ELSE 0 END)            AS missing_channel,
    SUM(CASE WHEN device_type IS NULL THEN 1 ELSE 0 END)        AS missing_device
FROM website_sessions;

-- CHECK 5: ORPHANS - does every order belong to a session?
-- Why: it proves the tables really connect. LEFT JOIN keeps every order; if no
--      session matches, the session columns are NULL and we count those.
-- expect: 0
SELECT COUNT(*) AS orders_without_a_session
FROM orders o
LEFT JOIN website_sessions s ON o.website_session_id = s.website_session_id
WHERE s.website_session_id IS NULL;

-- CHECK 6: MAIN TOTALS - do they match the Python benchmark?
-- expect: 472871 sessions | 32313 orders | 6.83 conversion | 1938509.75 revenue
SELECT
    (SELECT COUNT(*) FROM website_sessions) AS total_sessions,
    (SELECT COUNT(*) FROM orders)           AS total_orders,
    ROUND(100.0 * (SELECT COUNT(*) FROM orders) / (SELECT COUNT(*) FROM website_sessions), 2) AS conversion_rate_pct,
    (SELECT ROUND(SUM(price_usd), 2) FROM orders) AS total_revenue;

-- CHECK 7: DOUBLE-COUNTING TEST - do two tables agree on revenue?
-- Why: orders and order_items hold the same money in two different shapes.
--      If they disagree, a table is incomplete.
-- expect: 1938509.75 in both columns
SELECT
    (SELECT ROUND(SUM(price_usd), 2) FROM orders)      AS revenue_from_orders,
    (SELECT ROUND(SUM(price_usd), 2) FROM order_items) AS revenue_from_order_items;

-- CHECK 8: THE ROUNDING FIX - does gross profit have at most 2 decimals?
-- expect: 0
SELECT COUNT(*) AS values_with_extra_decimals
FROM orders
WHERE gross_profit_usd <> ROUND(gross_profit_usd, 2);
