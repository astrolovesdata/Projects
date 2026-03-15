# Maven Fuzzy Factory — Ecommerce Performance Analysis

## Project Overview

This project analyzes the **Maven Fuzzy Factory ecommerce dataset** to understand how the business has grown over time and what factors drive revenue performance.

The analysis focuses on the relationship between:

- Website traffic
- Customer conversions
- Marketing channels
- Revenue generation
- Monetization efficiency

The goal is to identify **key trends in website performance and ecommerce revenue drivers** over a three-year period.

---

# Dataset Overview

The dataset contains approximately **three years of ecommerce activity (March 2012 – March 2015)**.

The database includes the following core tables:

| Table | Description |
|------|-------------|
| website_sessions | Records of website visits |
| website_pageviews | Individual pageviews within sessions |
| orders | Completed purchases |
| order_items | Products purchased within each order |
| order_item_refunds | Refunded items |
| products | Product catalog |

---

# Data Model

The tables are connected through the following relationships:

```

website_sessions
│
│ website_session_id
▼
orders
│
│ order_id
▼
order_items

````

Key identifiers:

- **website_session_id** → unique visitor session
- **order_id** → purchase transaction
- **order_item_id** → individual product within an order

Revenue data can appear in two places:

| Field | Meaning |
|------|---------|
| orders.price_usd | Total order value |
| order_items.price_usd | Individual product price |

For this project, **item-level revenue (`order_items.price_usd`) is used** to allow deeper product-level analysis.

---

# Key Business Questions

The analysis answers the following questions:

1. What is the overall **traffic trend**?
2. How has **order volume** changed over time?
3. What percentage of sessions convert into purchases?
4. Which **marketing channels** drive the most traffic?
5. How much revenue does each order generate?
6. How much revenue does each visitor generate?

---

# Analysis Steps

## 1. Data Coverage Validation

The first step verifies the time range of the dataset.

```sql
SELECT
MIN(created_at) AS first_session,
MAX(created_at) AS last_session
FROM website_sessions;

SELECT
MIN(created_at) AS first_order,
MAX(created_at) AS last_order
FROM orders;
````

**Result**

The dataset spans approximately **March 2012 – March 2015**.

---

## 2. Table Validation

To ensure all tables loaded properly:

```sql
SELECT 'website_sessions', COUNT(*) FROM website_sessions
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
```

This confirms the dataset contains **complete ecommerce records**.

---

# Website Traffic Trend

Monthly sessions were calculated using:

```sql
SELECT
YEAR(created_at) AS year,
MONTH(created_at) AS month,
COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year, month;
```

### Insight

Website traffic increased dramatically over time, growing from a few thousand monthly sessions to more than **25,000 sessions per month** by the end of the dataset.

This indicates successful growth in **customer acquisition efforts**.

---

# Order Volume Trend

Monthly orders were calculated using:

```sql
SELECT
YEAR(created_at) AS year,
MONTH(created_at) AS month,
COUNT(DISTINCT order_id) AS orders
FROM orders
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year, month;
```

### Insight

Orders increased alongside traffic, confirming **growing customer demand**.

However, order growth alone does not reveal whether the website is becoming more effective at converting visitors.

---

# Conversion Rate

Conversion rate measures the percentage of visitors who place an order.

```sql
SELECT
YEAR(ws.created_at) AS year,
MONTH(ws.created_at) AS month,
COUNT(DISTINCT ws.website_session_id) AS sessions,
COUNT(DISTINCT o.order_id) AS orders,
ROUND(
COUNT(DISTINCT o.order_id) /
NULLIF(COUNT(DISTINCT ws.website_session_id),0) * 100,
2
) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY year, month;
```

### Insight

Conversion rate improved significantly during the analysis period, indicating that the website became **more effective at converting visitors into customers**.

---

# Marketing Channel Analysis

Traffic sources were analyzed using UTM parameters.

```sql
SELECT
utm_source,
utm_campaign,
http_referer,
COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC;
```

### Insight

Paid search marketing (especially Google non-brand campaigns) drove the majority of website traffic.

Other channels contributed significantly less traffic, indicating a **strong reliance on search advertising**.

---

# Revenue per Order (Average Order Value)

Average order value was calculated using item-level revenue.

```sql
SELECT
YEAR(created_at) AS year,
MONTH(created_at) AS month,
COUNT(DISTINCT order_id) AS orders,
SUM(price_usd) AS revenue,
ROUND(
SUM(price_usd) /
NULLIF(COUNT(DISTINCT order_id),0),
2
) AS revenue_per_order
FROM order_items
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year, month;
```

### Insight

Average revenue per order increased gradually over time, suggesting that customers were either:

* purchasing more products per order, or
* purchasing higher-value products.

---

# Revenue per Session (Monetization Efficiency)

Revenue per session measures how much revenue each visitor generates on average.

```sql
SELECT
YEAR(ws.created_at) AS year,
MONTH(ws.created_at) AS month,
COUNT(DISTINCT ws.website_session_id) AS sessions,
SUM(oi.price_usd) AS revenue,
ROUND(
SUM(oi.price_usd) /
NULLIF(COUNT(DISTINCT ws.website_session_id),0),
2
) AS revenue_per_session
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id = o.website_session_id
LEFT JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY year, month;
```

Revenue per session can be interpreted as:

```
Revenue per Session =
Conversion Rate × Revenue per Order
```

### Insight

Revenue per session increased steadily over time, indicating improvements in both:

* conversion performance
* customer spending behavior

This makes it a powerful summary metric for **overall ecommerce performance**.

---

# Key Takeaways

* Website traffic grew substantially over the three-year period.
* Order volume increased alongside traffic.
* Conversion rates improved significantly.
* Average order value increased gradually.
* Revenue per visitor improved consistently.

Overall, the business experienced strong growth driven by **both increased traffic and improved conversion performance**.

---

# Tools Used

* MySQL
* SQL
* Google Sheets (visualization)
* GitHub

---

# Project Structure

```
maven-fuzzy-factory-analysis
│
├── README.md
├── exploratory_analysis.sql
├── data_loading.sql
└── visualizations
```
