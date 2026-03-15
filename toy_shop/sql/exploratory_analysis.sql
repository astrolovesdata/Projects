/*
==============================================================
Maven Fuzzy Factory - Exploratory Analysis & Core KPI Trends
==============================================================

Purpose
-------
Initial exploration of the Maven Fuzzy Factory dataset to
understand traffic, orders, conversion performance,
marketing channels, and monetization efficiency.

Key Questions
-------------
1. What is the time range of the dataset?
2. Did all tables load correctly?
3. How is website traffic trending?
4. How many orders are generated?
5. What percentage of sessions convert to orders?
6. Which marketing channels drive traffic?
7. How much revenue does each order generate?
8. How much revenue does each visitor generate?

Revenue Notes
-------------
orders.price_usd       → total order value
order_items.price_usd  → individual product value

Use order_items when analyzing:
• product performance
• refunds
• basket size
• item-level metrics

Use orders when analyzing:
• total order-level revenue
*/


USE portfolioproject;



/* ==========================================================
1. DETERMINE DATA TIME RANGE
========================================================== */

-- Determine the full date range of website sessions
SELECT
    MIN(created_at) AS first_session,
    MAX(created_at) AS last_session
FROM website_sessions;

-- Determine the full date range of orders
SELECT
    MIN(created_at) AS first_order,
    MAX(created_at) AS last_order
FROM orders;

/*
Interpretation
--------------
Confirms the dataset covers approximately
March 2012 – March 2015 (~3 years of ecommerce data).
*/



/* ==========================================================
2. VALIDATE TABLE LOADS
========================================================== */

-- Verify all tables loaded successfully
-- and get a quick overview of dataset size

SELECT 'website_sessions' AS table_name, COUNT(*) AS row_count
FROM website_sessions

UNION ALL

SELECT 'website_pageviews', COUNT(*)
FROM website_pageviews

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'order_item_refunds', COUNT(*)
FROM order_item_refunds

UNION ALL

SELECT 'products', COUNT(*)
FROM products;

/*
Purpose
-------
Standard validation step to confirm that
all expected tables loaded correctly.
*/



/* ==========================================================
3. WEBSITE SESSION TREND
========================================================== */

-- Monthly website traffic trend

SELECT
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year, month;

/*
Interpretation
--------------
Each website_session_id represents one visit.
This query reveals traffic growth over time.
*/



/* ==========================================================
4. MONTHLY ORDER VOLUME
========================================================== */

-- Monthly number of orders

SELECT
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(DISTINCT order_id) AS orders
FROM orders
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year, month;

/*
Interpretation
--------------
Shows purchase volume over time.
Can be compared against session trends
to understand demand growth.
*/



/* ==========================================================
5. SESSION-TO-ORDER CONVERSION RATE
========================================================== */

-- Percentage of sessions that result in orders

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

/*
Notes
-----
LEFT JOIN ensures sessions without purchases remain included.

conversion_rate =
orders / sessions * 100

NULLIF prevents divide-by-zero errors.
*/



/* ==========================================================
6. MARKETING CHANNEL EXPLORATION
========================================================== */

-- High-level traffic sources

SELECT
    utm_source,
    COUNT(*) AS sessions
FROM website_sessions
GROUP BY utm_source
ORDER BY sessions DESC;

/*
NULL values typically indicate:
• direct traffic
• organic search
• untagged traffic
*/


-- Detailed marketing channel breakdown

SELECT
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC;

/*
Purpose
-------
Identifies which marketing channels
generate the most website traffic.
*/



/* ==========================================================
7. REVENUE PER ORDER (Average Order Value)
========================================================== */

-- Monthly revenue and average revenue per order

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

/*
Explanation
-----------
Revenue calculated using order_items.price_usd
to allow future item-level analysis.

Metric:
revenue_per_order = revenue / orders
*/



/* ==========================================================
8. REVENUE PER SESSION (Visitor Monetization)
========================================================== */

-- Monthly revenue generated per website visit

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

/*
Explanation
-----------
Revenue per Session = Revenue / Sessions

This metric measures overall monetization efficiency.

Important relationship:

Revenue per Session
= Conversion Rate × Revenue per Order

It captures both:
• website conversion performance
• average customer spending

Making it a strong KPI for ecommerce performance.
*/
