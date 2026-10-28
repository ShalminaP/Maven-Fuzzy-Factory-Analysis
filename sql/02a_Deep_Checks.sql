USE maven_fuzzy_factory;

CREATE INDEX idx_orders_session   ON orders (website_session_id);
CREATE INDEX idx_orders_ym        ON orders (`year_month`);
CREATE INDEX idx_sessions_ym      ON website_sessions (`year_month`);
CREATE INDEX idx_sessions_channel ON website_sessions (channel);
CREATE INDEX idx_items_order      ON order_items (order_id);
CREATE INDEX idx_items_product    ON order_items (product_id);
CREATE INDEX idx_refunds_item     ON order_item_refunds (order_item_id);
CREATE INDEX idx_pageviews_session ON website_pageviews (website_session_id);

-- expect: sessions 472871 | pageviews 1188124 (or 0 if skipped) | orders 32313
--         order_items 40025 | refunds 1731 | products 4
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

-- CHECK 2: the main totals
-- expect: 472871 sessions | 32313 orders | 6.83 conversion | 1938509.75 revenue
SELECT
    (SELECT COUNT(*) FROM website_sessions)  AS total_sessions,
    (SELECT COUNT(*) FROM orders)            AS total_orders,
    ROUND(100.0 * (SELECT COUNT(*) FROM orders) / (SELECT COUNT(*) FROM website_sessions), 2) AS conversion_rate_pct,
    (SELECT ROUND(SUM(price_usd), 2) FROM orders) AS total_revenue;
    
-- CHECK 3: sessions, orders and revenue per year
-- expect: 2012 = 62470 / 2586 / 129274.14
--         2013 = 112781 / 7447 / 393247.87
--         2014 = 233422 / 16860 / 1075612.19
--         2015 = 64198 / 5420 / 340375.55
SELECT s.year, s.sessions, o.orders, o.revenue
FROM (SELECT year, COUNT(*) AS sessions FROM website_sessions GROUP BY year) AS s
JOIN (SELECT year, COUNT(*) AS orders, ROUND(SUM(price_usd), 2) AS revenue FROM orders GROUP BY year) AS o
  ON s.year = o.year
ORDER BY s.year;

-- CHECK 4: are the column types right?
-- Look at the "Type" column: gross_profit_usd should say decimal(10,2) and
-- year_month should say char(7).
DESCRIBE orders;
DESCRIBE website_sessions;

-- CHECK 5: the double-counting test.
-- Orders and order_items must give the SAME revenue. expect: 1938509.75 twice.
SELECT
    (SELECT ROUND(SUM(price_usd), 2) FROM orders)      AS revenue_from_orders,
    (SELECT ROUND(SUM(price_usd), 2) FROM order_items) AS revenue_from_order_items;
    
-- CHECK 6: orphans = rows with no matching parent row. expect: 0
-- LEFT JOIN keeps every order; if no session matches, the session columns are NULL.
SELECT COUNT(*) AS orders_without_a_session
FROM orders o
LEFT JOIN website_sessions s ON o.website_session_id = s.website_session_id
WHERE s.website_session_id IS NULL;