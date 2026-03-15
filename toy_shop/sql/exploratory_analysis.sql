/*
==============================================================
Maven Fuzzy Factory - Exploratory Analysis & Core KPI Trends
==============================================================

Purpose:
This script performs the initial exploration of the Maven Fuzzy
Factory dataset and answers key business questions around:

1. Data coverage and table validation
2. Website traffic trends
3. Order volume trends
4. Session-to-order conversion rate
5. Marketing channel contribution
6. Revenue per order
7. Revenue per session

Notes:
- Revenue logic must be chosen carefully in this dataset.
- orders.price_usd represents total order-level revenue.
- order_items.price_usd represents item-level revenue.
- For high-level revenue metrics, either can work if used correctly.
- For product-level and refund analysis, item-level tables will be needed.

==============================================================
*/


/* ==========================================================
1. DETERMINE DATA TIME RANGE
========================================================== */

-- Check the full date range of website session data
SELECT
    MIN(created_at) AS first_session,
    MAX(created_at) AS last_session
FROM website_sessions;

-- Check the full date range of order data
SELECT
    MIN(created_at) AS first_order,
    MAX(created_at) AS last_order
FROM orders;

-- Interpretation:
-- These queries confirm the approximate business analysis window.
-- Based on the dataset, the time range is expected to cover
-- about 3 years of activity, roughly from March 2012 to March 2015.



/* ==========================================================
2. VALIDATE TABLE LOADS AND UNDERSTAND TABLE SIZE
========================================================== */

-- Confirm that all core tables loaded properly
-- and get a quick sense of dataset size
SELECT 'website_sessions' AS table_name, COUNT(*) AS row_count
FROM website_sessions

UNION ALL

SELECT 'website_pageviews' AS table_name, COUNT(*) AS row_count
FROM website_pageviews

UNION ALL

SELECT 'orders' AS table_name, COUNT(*) AS row_count
FROM orders

UNION ALL

SELECT 'order_items' AS table_name, COUNT(*) AS row_count
FROM order_items

UNION ALL

SELECT 'order_item_refunds' AS table_name, COUNT(*) AS row_count
FROM order_item_refunds

UNION ALL

SELECT 'products' AS table_name, COUNT(*) AS row_count
FROM products;

-- Interpretation:
-- This is a standard post-load validation step.
-- It confirms that all expected tables were imported successfully
-- and gives a quick overview of dataset scale.



/* ==========================================================
3. ANALYSIS #1 - TREND IN WEBSITE SESSIONS
========================================================== */

-- Count monthly website sessions to identify traffic growth over time
SELECT
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year, month;

-- Interpretation:
-- This query shows the monthly website traffic trend.
-- Each website_session_id represents one visit/session.
-- DISTINCT is used to ensure each session is counted only once.



/* ==========================================================
4. MONTHLY ORDER VOLUME
========================================================== */

-- Count how many orders were generated each month
SELECT
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(DISTINCT order_id) AS orders
FROM orders
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year, month;

-- Interpretation:
-- This measures monthly purchase volume.
-- It is the basic demand trend and can be compared against
-- traffic growth to understand business performance.



/* ==========================================================
5. SESSION-TO-ORDER CONVERSION RATE
========================================================== */

-- Calculate monthly conversion rate:
-- orders / sessions
SELECT
    YEAR(ws.created_at) AS year,
    MONTH(ws.created_at) AS month,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id) /
        NULLIF(COUNT(DISTINCT ws.website_session_id), 0) * 100,
        2
    ) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY year, month;

-- Interpretation:
-- LEFT JOIN is used so that all sessions are retained,
-- including those that did not result in an order.
--
-- conversion_rate = orders / sessions * 100
--
-- NULLIF(..., 0) prevents divide-by-zero errors.
-- In practice, monthly session counts should not be zero here,
-- but this is good defensive SQL practice.



/* ==========================================================
6. MARKETING CHANNEL EXPLORATION
========================================================== */

-- Preview high-level session sources
-- NULL values often indicate direct, organic, or untagged traffic
SELECT
    utm_source,
    COUNT(*) AS sessions
FROM website_sessions
GROUP BY utm_source
ORDER BY sessions DESC;

-- Breakdown sessions by source / campaign / referrer combination
SELECT
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC;

-- Interpretation:
-- These queries help identify which marketing channels
-- and campaign structures drive the most traffic.
--
-- Common patterns:
-- - utm_source identifies the traffic platform (e.g. gsearch, bsearch)
-- - utm_campaign identifies campaign intent (e.g. brand vs nonbrand)
-- - http_referer helps distinguish paid vs direct/organic traffic



/* ==========================================================
7. REVENUE PER ORDER
========================================================== */

-- Calculate total monthly revenue and average revenue per order
-- using item-level revenue
SELECT
    YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    COUNT(DISTINCT order_id) AS orders,
    SUM(price_usd) AS revenue,
    ROUND(
        SUM(price_usd) /
        NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS revenue_per_order
FROM order_items
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year, month;

-- Interpretation:
-- This query calculates:
-- 1. total revenue
-- 2. average revenue per order
--
-- Revenue is summed from order_items.price_usd, which provides
-- item-level granularity.
--
-- Important:
-- In this dataset, revenue could also be analyzed using orders.price_usd.
-- However, using order_items is helpful when later analyses may require
-- item-level detail such as product mix or refunds.



/* ==========================================================
8. REVENUE PER SESSION
========================================================== */

-- Calculate total monthly revenue and average revenue generated
-- per website session
SELECT
    YEAR(ws.created_at) AS year,
    MONTH(ws.created_at) AS month,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    SUM(oi.price_usd) AS revenue,
    ROUND(
        SUM(oi.price_usd) /
        NULLIF(COUNT(DISTINCT ws.website_session_id), 0),
        2
    ) AS revenue_per_session
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY year, month;

-- Interpretation:
-- This query measures monetization efficiency:
--
-- revenue_per_session = revenue / sessions
--
-- It is not the same as revenue per order.
-- Instead, it shows how much revenue each visit generates on average.
--
-- This metric combines both:
-- 1. conversion rate
-- 2. revenue per order
--
-- In other words:
--
-- revenue_per_session = conversion_rate × revenue_per_order
