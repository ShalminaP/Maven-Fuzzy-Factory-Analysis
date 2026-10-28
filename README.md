# Maven Fuzzy Factory Analytics Capstone

Hi! This is a project I put together to learn more about how an online shop can use data to understand its marketing, website, and sales. I worked through the whole process: cleaning the source files with Python, checking and exploring the data with MySQL, and building an interactive Power BI dashboard.

I learned a lot while working on this, especially about checking data quality and making sure the numbers agree across tools. I’m excited to keep learning, improve my analysis and storytelling skills, and keep making this project better.

## What I wanted to find out

- How did website sessions and orders change over time?
- How did the session-to-order conversion rate change?
- Which marketing channels performed best?
- How did revenue per order and revenue per session evolve?

## What I found

- Traffic and orders grew substantially between 2013 and 2014, and order volume peaked in November and December.
- Conversion improved over the period covered by the data.
- Gsearch brought the most visits, while organic search had the highest reported revenue per session.
- Mobile converted less often than desktop, making the mobile buying journey an area I’d like to investigate further.
- Revenue per order and revenue per session rose as two-item orders became more common. The timing is consistent with cross-selling helping, but this analysis can’t prove that it caused the change.

More detail, recommendations, and caveats are in [my insights summary](insights/insights.md). The findings are descriptive; they show patterns in the data, not proof of what caused them.

## The project

| Folder or file | What’s inside |
| --- | --- |
| `dashboard/Maven_Fuzzy_Factory.pbix` | The interactive Power BI report. |
| `screenshots/` | Captures of the five visible dashboard pages. |
| `insights/insights.md` | A short summary of findings and possible next steps. |
| `scripts/python_cleaning.ipynb` | The Python notebook I used to clean and check the six tables. Saved notebook outputs were cleared; the code remains. |
| `sql/` | MySQL table setup, validation checks, conversion funnel, and analysis views. |
| `data/raw/` | The six public source CSV files. |
| `data/cleaned/` | The six cleaned CSV files used for analysis. |
| `docs/` | A data dictionary and notes on my methods and assumptions. |

## How I approached it

1. Loaded the six CSV tables into Python with pandas and NumPy.
2. Checked dates, missing values, duplicate IDs, and relationships between tables; cleaned text fields and added date and analysis columns.
3. Loaded the cleaned data into MySQL, created analysis views, and checked the row counts and headline totals.
4. Built a Power BI report to explore the trends, channels, product performance, and website funnel.

To try the notebook, open it from the repository root. It expects the original CSVs in `data/raw/` and writes cleaned exports to `data/cleaned/`. The notebook uses pandas and NumPy. The SQL files use MySQL syntax; update the local CSV path in `created_tables.sql` if you use its import example.

## Data source

The data comes from Maven Analytics’ [Toy Store E-Commerce Database](https://mavenanalytics.io/data-playground/toy-store-e-commerce-database), which describes the Maven Fuzzy Factory teddy bear retailer dataset and lists it as public domain.

## A note on the analysis

The date range is 19 March 2012 to 19 March 2015. The first and last months are partial. My channel labels use rules based on the available UTM source and referrer fields, so they’re an assumption. The dataset doesn’t include advertising spend or location, and these observational results can’t establish cause and effect.

The cleaned CSV row counts are 472,871 sessions, 1,188,124 pageviews, 32,313 orders, 40,025 order items, 1,731 refunds, and 4 products. My reported headline figures include a 6.83% session-to-order conversion rate and $1,938,509.75 in revenue. I’ve documented the metric and data-quality caveats in `docs/` and `insights/`.

## File size

Some CSV files exceed GitHub’s 50 MiB warning threshold but are below its 100 MiB per-file limit. Push this project with GitHub Desktop or Git; the browser upload form has a lower per-file limit. See [GitHub’s large-file guidance](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github).
