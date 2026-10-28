# Methodology and analysis notes

## Workflow from the supplied files

1. The notebook uses pandas and NumPy to read six CSVs: `website_sessions.csv`, `website_pageviews.csv`, `orders.csv`, `order_items.csv`, `order_item_refunds.csv`, and `products.csv`.
2. It parses `created_at` as a datetime where present, reports missing values and duplicate primary-key IDs, and drops exact duplicate rows if found. It strips whitespace from string columns and lowercases selected session fields (`utm_source`, `utm_campaign`, and `device_type`).
3. It derives `channel` from session marketing fields: a non-null `utm_source` is used as the channel; otherwise a non-null `http_referer` becomes `organic_search`; otherwise the value is `direct`. Campaigns and selected tag/referrer fields use the literal `none` for missing values.
4. For sessions, orders, order items, and refunds, it adds `date`, `year`, `month`, and `year_month` from `created_at`. It calculates `gross_profit_usd` as `price_usd - cogs_usd` on orders and order items.
5. It checks referential matches for pageviews, orders, items, refunds, and products, then prints overall and yearly session/order/revenue metrics. It exports each table to `data/cleaned/clean_<source-name>.csv`. A final notebook cell also exports `clean_website_sessions_rest.csv` for session IDs above 436089.
6. The SQL scripts create the MySQL schema, define analysis views for yearly/monthly trends, channel/campaign performance and the website funnel, and provide post-load integrity checks. The checks compare row counts and key totals with expected values.
7. The presentation describes a Power BI report with date filtering and summary pages. The dashboard model and measures were not independently audited here.

The notebook's saved cell outputs were cleared in the repository copy to avoid committing sampled data and stale run results. The code cells remain. The six raw source CSVs are present under `data/raw/`; the six cleaned exports are present under `data/cleaned/`. Both raw and cleaned source CSVs are included and tracked by Git. Python version and dependency versions have not been specified; pandas and NumPy are imported by the notebook. SQL uses MySQL syntax.

## Report scope and reported checks

The presentation describes a date range from 19 March 2012 to 19 March 2015 and five dashboard pages: Overview, Marketing & Conversion, Revenue & Products, Website Funnel, and Key Insights. It notes that the first and last months are partial periods.

The SQL validation files state expected totals of 472,871 sessions, 1,188,124 pageviews, 32,313 orders, 40,025 order items, 1,731 refunds, and 4 products; the presentation also reports 6.83% conversion and $1,938,509.75 in order revenue. These are expected/reference values in the files, not results independently rerun for this repository.

## Assumptions and limitations

- The channel mapping is analyst-defined and gives non-null UTM source precedence over the referrer; results depend on this rule.
- The notebook checks duplicate IDs but only removes exact duplicate rows. It does not deduplicate rows solely because their primary key repeats.
- The final session subset uses a hard-coded ID threshold (`website_session_id > 436089`); its purpose should be clarified before reuse.
- The notebook computes gross profit from price minus COGS but does not subtract refunds in that calculation.
- The SQL views use revenue per order/session and conversion calculations; confirm refund inclusion and the precise order attribution in the Power BI measures.
- Partial March 2012 and March 2015 periods should not be compared directly with full months. Boundary years are incomplete.
- The presentation's conclusions are descriptive and do not prove that a marketing campaign or website change caused a metric change.
- Neither the SQL nor Python was executed as part of this documentation update. The cleaned CSV row counts were inspected and match the expected counts stated by the SQL checks.

## Reproducibility steps to complete

Install pandas and NumPy in a documented Python environment, and run the notebook from the repository root. Then load the cleaned CSVs into MySQL using paths valid on the running machine, run the SQL checks/views, and refresh Power BI. Record actual row counts, software versions, and DAX/model definitions after verifying the results.
