-- SHORT NAMES (aliases) used below
--   s = website_sessions     o = orders     oi = order_items
--   p = products             r = order_item_refunds

-- QUESTIONS ANSWERED
--   Q1 trend in sessions and orders ........ vw_yearly_summary, vw_monthly_trend
--   Q2 conversion rate and its trend ....... vw_yearly_summary, vw_monthly_trend
--   Q3 most successful channels ............ vw_channel_performance, vw_channel_campaign
--   Q4 revenue per order / per session ..... vw_yearly_summary, vw_monthly_trend
--   Extras: device, products and refunds, basket size

-- Conversion rate = orders / sessions x 100
-- Revenue per order = revenue / orders         
-- Revenue per session = revenue / sessions

CREATE OR REPLACE VIEW vw_yearly_summary AS
WITH sessions_per_year AS (               -- CTE 1: count sessions in each year
    SELECT year, COUNT(*) AS sessions
    FROM website_sessions
    GROUP BY year
),
orders_per_year AS (                      -- CTE 2: count orders and add up money in each year
    SELECT year,
           COUNT(*)              AS orders,
           SUM(price_usd)        AS revenue,
           SUM(gross_profit_usd) AS gross_profit
    FROM orders
    GROUP BY year
)
SELECT
    s.year,
    s.sessions,
    o.orders,
    ROUND(o.orders * 100.0 / s.sessions, 2)  AS conversion_rate_pct,
    ROUND(o.revenue, 2)                      AS revenue,
    ROUND(o.revenue / o.orders, 2)           AS revenue_per_order,
    ROUND(o.revenue / s.sessions, 4)         AS revenue_per_session,
    ROUND(o.gross_profit, 2)                 AS gross_profit
FROM sessions_per_year s
JOIN orders_per_year o ON s.year = o.year;

CREATE OR REPLACE VIEW vw_monthly_trend AS
WITH sessions_per_month AS (              -- CTE 1: sessions in each month
    SELECT `year_month`, COUNT(*) AS sessions
    FROM website_sessions
    GROUP BY `year_month`
),
orders_per_month AS (                     -- CTE 2: orders and money in each month
    SELECT `year_month`,
           COUNT(*)       AS orders,
           SUM(price_usd) AS revenue
    FROM orders
    GROUP BY `year_month`
),
monthly AS (                              -- CTE 3: put the two together and add the ratios
    SELECT
        s.`year_month`,
        s.sessions,
        o.orders,
        ROUND(o.orders * 100.0 / s.sessions, 2)  AS conversion_rate_pct,
        ROUND(o.revenue, 2)                      AS revenue,
        ROUND(o.revenue / o.orders, 2)           AS revenue_per_order,
        ROUND(o.revenue / s.sessions, 4)         AS revenue_per_session
    FROM sessions_per_month s
    JOIN orders_per_month o ON s.`year_month` = o.`year_month`
)
SELECT
    STR_TO_DATE(CONCAT(`year_month`, '-01'), '%Y-%m-%d') AS month_start,  -- a real date, handy in Power BI
    `year_month`,
    sessions,
    orders,
    conversion_rate_pct,
    revenue,
    revenue_per_order,
    revenue_per_session,
    -- growth vs the previous month, in percent
    ROUND((sessions - LAG(sessions) OVER (ORDER BY `year_month`)) * 100.0
          / LAG(sessions) OVER (ORDER BY `year_month`), 1)  AS sessions_growth_pct,
    ROUND((orders - LAG(orders) OVER (ORDER BY `year_month`)) * 100.0
          / LAG(orders) OVER (ORDER BY `year_month`), 1)    AS orders_growth_pct
FROM monthly;

CREATE OR REPLACE VIEW vw_channel_performance AS
WITH channel_totals AS (
    SELECT
        s.channel,
        COUNT(*)                                AS sessions,
        COUNT(o.order_id)                       AS orders,
        COALESCE(SUM(o.price_usd), 0)           AS revenue,
        COALESCE(SUM(o.gross_profit_usd), 0)    AS gross_profit
    FROM website_sessions s
    LEFT JOIN orders o ON s.website_session_id = o.website_session_id
    GROUP BY s.channel
)
SELECT
    channel,
    sessions,
    orders,
    ROUND(orders * 100.0 / sessions, 2)             AS conversion_rate_pct,
    ROUND(revenue, 2)                               AS revenue,
    ROUND(revenue / sessions, 4)                    AS revenue_per_session,
    ROUND(revenue / orders, 2)                      AS revenue_per_order,
    ROUND(gross_profit / sessions, 4)               AS gross_profit_per_session,
    ROUND(sessions * 100.0 / SUM(sessions) OVER (), 2) AS pct_of_sessions,
    ROUND(orders * 100.0 / SUM(orders) OVER (), 2)     AS pct_of_orders,
    RANK() OVER (ORDER BY revenue / sessions DESC)     AS rank_by_revenue_per_session
FROM channel_totals;

CREATE OR REPLACE VIEW vw_channel_campaign AS
WITH campaign_totals AS (
    SELECT
        s.channel,
        s.campaign,
        COUNT(*)                        AS sessions,
        COUNT(o.order_id)               AS orders,
        COALESCE(SUM(o.price_usd), 0)   AS revenue
    FROM website_sessions s
    LEFT JOIN orders o ON s.website_session_id = o.website_session_id
    GROUP BY s.channel, s.campaign
)
SELECT
    channel,
    campaign,
    sessions,
    orders,
    ROUND(orders * 100.0 / sessions, 2)  AS conversion_rate_pct,
    ROUND(revenue, 2)                    AS revenue,
    ROUND(revenue / sessions, 4)         AS revenue_per_session,
    ROUND(revenue / orders, 2)           AS revenue_per_order
FROM campaign_totals;

CREATE OR REPLACE VIEW vw_device_performance AS
WITH device_totals AS (
    SELECT
        s.device_type,
        COUNT(*)                        AS sessions,
        COUNT(o.order_id)               AS orders,
        COALESCE(SUM(o.price_usd), 0)   AS revenue
    FROM website_sessions s
    LEFT JOIN orders o ON s.website_session_id = o.website_session_id
    GROUP BY s.device_type
)
SELECT
    device_type,
    sessions,
    orders,
    ROUND(orders * 100.0 / sessions, 2)                 AS conversion_rate_pct,
    ROUND(revenue, 2)                                   AS revenue,
    ROUND(revenue / sessions, 4)                        AS revenue_per_session,
    ROUND(sessions * 100.0 / SUM(sessions) OVER (), 2)  AS pct_of_sessions
FROM device_totals;

CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    DATE(p.created_at)                                   AS launch_date,
    COUNT(oi.order_item_id)                              AS items_sold,
    ROUND(SUM(oi.price_usd), 2)                          AS revenue,
    ROUND(SUM(oi.gross_profit_usd), 2)                   AS gross_profit,
    ROUND(SUM(oi.gross_profit_usd) * 100.0 / SUM(oi.price_usd), 1) AS gross_margin_pct,
    COUNT(r.order_item_refund_id)                        AS refunded_items,
    ROUND(COUNT(r.order_item_refund_id) * 100.0 / COUNT(oi.order_item_id), 2) AS refund_rate_pct,
    ROUND(COALESCE(SUM(r.refund_amount_usd), 0), 2)      AS refund_amount
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN order_item_refunds r ON oi.order_item_id = r.order_item_id
GROUP BY p.product_id, p.product_name, p.created_at;

CREATE OR REPLACE VIEW vw_basket_size AS
SELECT
    year,
    items_purchased,
    COUNT(*)                                                    AS orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY year), 1) AS pct_of_year_orders,
    ROUND(SUM(price_usd) / COUNT(*), 2)                         AS revenue_per_order
FROM orders
GROUP BY year, items_purchased;

SELECT * FROM vw_yearly_summary ORDER BY year;
SELECT * FROM vw_monthly_trend ORDER BY month_start;
SELECT * FROM vw_channel_performance ORDER BY rank_by_revenue_per_session;
SELECT * FROM vw_channel_campaign ORDER BY channel, campaign;
SELECT * FROM vw_device_performance;
SELECT * FROM vw_product_performance ORDER BY product_id;
SELECT * FROM vw_basket_size ORDER BY year, items_purchased;
