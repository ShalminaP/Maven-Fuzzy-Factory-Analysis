USE maven_fuzzy_factory;

CREATE OR REPLACE VIEW vw_funnel AS
WITH session_pages AS (                    -- CTE: one row per session with 0/1 flags
    SELECT
        website_session_id,
        MAX(CASE WHEN pageview_url = '/products'                 THEN 1 ELSE 0 END) AS saw_products,
        MAX(CASE WHEN pageview_url LIKE '/the-%'                 THEN 1 ELSE 0 END) AS saw_product_page,
        MAX(CASE WHEN pageview_url = '/cart'                     THEN 1 ELSE 0 END) AS saw_cart,
        MAX(CASE WHEN pageview_url = '/shipping'                 THEN 1 ELSE 0 END) AS saw_shipping,
        MAX(CASE WHEN pageview_url IN ('/billing', '/billing-2') THEN 1 ELSE 0 END) AS saw_billing,
        MAX(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS saw_order
    FROM website_pageviews
    GROUP BY website_session_id
),
funnel_counts AS (                         -- CTE: add up the flags for each device
    SELECT
        s.device_type,
        COUNT(*)                  AS sessions,
        SUM(sp.saw_products)      AS products_page,
        SUM(sp.saw_product_page)  AS product_page,
        SUM(sp.saw_cart)          AS cart,
        SUM(sp.saw_shipping)      AS shipping,
        SUM(sp.saw_billing)       AS billing,
        SUM(sp.saw_order)         AS orders_placed
    FROM website_sessions s
    JOIN session_pages sp ON s.website_session_id = sp.website_session_id
    GROUP BY s.device_type
)
SELECT
    device_type,
    sessions,
    products_page,
    product_page,
    cart,
    shipping,
    billing,
    orders_placed,
    -- step conversion: of the people who reached the previous page, how many reached this one?
    ROUND(products_page * 100.0 / sessions, 1)      AS pct_sessions_to_products,
    ROUND(product_page  * 100.0 / products_page, 1) AS pct_products_to_product_page,
    ROUND(cart          * 100.0 / product_page, 1)  AS pct_product_page_to_cart,
    ROUND(shipping      * 100.0 / cart, 1)          AS pct_cart_to_shipping,
    ROUND(billing       * 100.0 / shipping, 1)      AS pct_shipping_to_billing,
    ROUND(orders_placed * 100.0 / billing, 1)       AS pct_billing_to_order
FROM funnel_counts;

SELECT * FROM vw_funnel;