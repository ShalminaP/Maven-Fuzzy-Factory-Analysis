# Data dictionary
## Tables in the dataset described:

| Table | Grain / purpose | Fields or relationships identified |
| --- | --- | --- |
| `website_sessions` | One website visit/session | `website_session_id`, `created_at`, `user_id`, repeat-session flag, UTM tags, device type, referrer, derived `channel`, `campaign`, and date parts. |
| `website_pageviews` | One pageview event | `website_pageview_id`, `created_at`, `website_session_id`, `pageview_url`. |
| `orders` | One ecommerce order | `order_id`, session and user IDs, product and item fields, `price_usd`, `cogs_usd`, derived date parts, and `gross_profit_usd`. |
| `order_items` | One product line within an order | `order_item_id`, `order_id`, `product_id`, primary-item flag, price, COGS, date parts, and gross profit. |
| `order_item_refunds` | One refund for an order item | `order_item_refund_id`, `order_item_id`, `order_id`, `refund_amount_usd`, `created_at`, and date parts. |
| `products` | Product catalog entry | `product_id`, `created_at`, and `product_name`. |

## Derived fields and metrics

| Name | Meaning / calculation | Notes |
| --- | --- | --- |
| `channel` | Session traffic source group | The notebook sets it to `utm_source` when non-null; otherwise `organic_search` when `http_referer` is non-null; otherwise `direct`. |
| Conversion rate | Orders divided by sessions | Presentation reports 6.83% for the full stated period. Confirm whether the denominator and date filter use the same session cohort. |
| Revenue per order | Revenue divided by orders | Exact revenue inclusion/exclusion rules need confirmation. |
| Revenue per session | Revenue divided by sessions | Exact attribution and refund treatment need confirmation. |
| Date | Calendar date used to filter activity | Presentation says a shared Date table filters sessions, orders, items, and refunds. Confirm the model relationships and date roles in the PBIX. |

## Keys and relationships described :

- Sessions connect to orders through session ID.
- Orders connect to order items; one order can contain multiple items.
- Products connect to order items.
- Order items connect to refunds.
- A shared Date table is described as connected to sessions, orders, items, and refunds.

The notebook explicitly checks orphans on pageviews-to-sessions, orders-to-sessions, items-to-orders, refunds-to-items, and items-to-products. The included cleaned files have 472,871 sessions, 1,188,124 pageviews, 32,313 orders, 40,025 order items, 1,731 refunds, and 4 products.

## Validation figures quoted in the presentation

- 472,871 sessions
- 32,313 orders
- 6.83% session-to-order conversion
- $1,938,509.75 revenue
- 19 March 2012 through 19 March 2015

These are expected/reference figures.


## Included cleaned CSV files

The included files were inspected for row counts and headers. Counts match the expected counts written in the SQL checks.

| CSV | Rows | Fields |
| --- | ---: | ---: |
| `clean_website_sessions.csv` | 472,871 | 15 |
| `clean_website_pageviews.csv` | 1,188,124 | 4 |
| `clean_orders.csv` | 32,313 | 13 |
| `clean_order_items.csv` | 40,025 | 12 |
| `clean_order_item_refunds.csv` | 1,731 | 9 |
| `clean_products.csv` | 4 | 3 |

The files include session/pageview/order/product/refund identifiers, event timestamps, marketing/device attributes, prices and costs, derived calendar fields, and the derived gross profit field where applicable.
