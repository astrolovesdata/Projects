-- =========================================================
-- NORMALIZATION WALKTHROUGH
-- =========================================================
-- Goal:
-- Start with a flat table and progressively organize it into
-- better-designed tables (1NF → 2NF → 3NF).
--
-- IMPORTANT NOTE:
-- The original dataset did NOT include CustomerID or ProductID.
-- These were introduced later as "surrogate keys" (artificial IDs)
-- to create cleaner relationships between tables.
--
-- In real-world databases, this is common practice because:
-- - Names can repeat (e.g., two "John Smiths")
-- - Text fields are inefficient for joins
-- - IDs make relationships more stable and scalable
-- =========================================================


-- =========================================================
-- STEP 1: FIRST NORMAL FORM (1NF)
-- =========================================================
-- Plain English:
-- Each column should contain only ONE value (no lists).
--
-- Example of BAD (not 1NF):
-- Products = "Laptop, Mouse"
--
-- Example of GOOD (1NF):
-- Each product gets its own row.
--
-- Result:
-- Data is now atomic (one value per cell), but still contains
-- redundancy (customer info repeats across rows).
-- =========================================================

DROP TABLE IF EXISTS orders_1nf;

CREATE TABLE orders_1nf (
    OrderID INT,
    CustomerName VARCHAR(100),
    CustomerPhone VARCHAR(20),
    ProductName VARCHAR(100),
    ProductPrice DECIMAL(10,2)
);

INSERT INTO orders_1nf VALUES
(1001, 'John Smith', '111-222-3333', 'Laptop', 1200),
(1001, 'John Smith', '111-222-3333', 'Mouse', 25),
(1002, 'Emily Davis', '777-888-9999', 'Phone', 800),
(1003, 'Jack Lee', '333-444-5555', 'Laptop', 1200),
(1003, 'Jack Lee', '333-444-5555', 'Monitor', 300),
(1003, 'Jack Lee', '333-444-5555', 'Keyboard', 100);

SELECT * FROM orders_1nf;


-- =========================================================
-- STEP 2: SECOND NORMAL FORM (2NF)
-- =========================================================
-- Plain English:
-- If a table has a "combined key" (like OrderID + ProductName),
-- every column must depend on BOTH parts of that key.
--
-- Problem in 1NF:
-- CustomerName and CustomerPhone depend ONLY on OrderID,
-- not on ProductName.
--
-- That means:
-- We are storing customer info repeatedly for each product row.
--
-- Solution:
-- Move customer data into its own table.
-- Now:
-- - customers table = customer info
-- - orders table = links order → customer
-- - order_details table = products within each order
-- =========================================================

DROP TABLE IF EXISTS order_details_2nf;
DROP TABLE IF EXISTS orders_2nf;
DROP TABLE IF EXISTS customers_2nf;

CREATE TABLE customers_2nf (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CustomerName VARCHAR(100),
    CustomerPhone VARCHAR(20)
);

CREATE TABLE orders_2nf (
    OrderID INT PRIMARY KEY,
    CustomerID VARCHAR(10),
    CONSTRAINT fk_orders_2nf_customer
        FOREIGN KEY (CustomerID) REFERENCES customers_2nf(CustomerID)
);

CREATE TABLE order_details_2nf (
    OrderID INT,
    ProductName VARCHAR(100),
    ProductPrice DECIMAL(10,2),
    PRIMARY KEY (OrderID, ProductName),
    CONSTRAINT fk_order_details_2nf_order
        FOREIGN KEY (OrderID) REFERENCES orders_2nf(OrderID)
);

INSERT INTO customers_2nf VALUES
('C1', 'John Smith', '111-222-3333'),
('C2', 'Emily Davis', '777-888-9999'),
('C3', 'Jack Lee', '333-444-5555');

SELECT * FROM customers_2nf;

INSERT INTO orders_2nf VALUES
(1001, 'C1'),
(1002, 'C2'),
(1003, 'C3');

SELECT * FROM orders_2nf;

INSERT INTO order_details_2nf VALUES
(1001, 'Laptop', 1200),
(1001, 'Mouse', 25),
(1002, 'Phone', 800),
(1003, 'Laptop', 1200),
(1003, 'Monitor', 300),
(1003, 'Keyboard', 100);

SELECT * FROM order_details_2nf;


-- =========================================================
-- STEP 3: THIRD NORMAL FORM (3NF)
-- =========================================================
-- Plain English:
-- Columns should depend ONLY on the primary key,
-- not on another non-key column.
--
-- Problem in 2NF:
-- ProductPrice depends on ProductName,
-- NOT on (OrderID + ProductName).
--
-- This creates a "transitive dependency":
-- Order → Product → Price
--
-- Solution:
-- Move product info into a separate products table.
--
-- Result:
-- - products table = product info
-- - order_details now only stores relationships (OrderID + ProductID)
-- =========================================================

DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    CustomerID VARCHAR(10) PRIMARY KEY,
    CustomerName VARCHAR(100),
    CustomerPhone VARCHAR(20)
);

CREATE TABLE orders (
    OrderID INT PRIMARY KEY,
    CustomerID VARCHAR(10),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID)
);

CREATE TABLE products (
    ProductID VARCHAR(10) PRIMARY KEY,
    ProductName VARCHAR(100),
    ProductPrice DECIMAL(10,2)
);

CREATE TABLE order_details (
    OrderID INT,
    ProductID VARCHAR(10),
    PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT fk_order_details_order
        FOREIGN KEY (OrderID) REFERENCES orders(OrderID),
    CONSTRAINT fk_order_details_product
        FOREIGN KEY (ProductID) REFERENCES products(ProductID)
);

INSERT INTO customers SELECT * FROM customers_2nf;
INSERT INTO orders SELECT * FROM orders_2nf;

INSERT INTO products VALUES
('P1', 'Laptop', 1200),
('P2', 'Mouse', 25),
('P3', 'Phone', 800),
('P4', 'Monitor', 300),
('P5', 'Keyboard', 100);

SELECT * FROM products;

INSERT INTO order_details VALUES
(1001, 'P1'),
(1001, 'P2'),
(1002, 'P3'),
(1003, 'P1'),
(1003, 'P4'),
(1003, 'P5');

SELECT * FROM order_details;


-- =========================================================
-- FINAL QUERY 1
-- =========================================================
-- Rebuild a usable dataset from normalized tables.
-- Result: one row per product per order (clean 1NF output)
-- =========================================================

SELECT
    o.OrderID,
    c.CustomerName,
    p.ProductName,
    p.ProductPrice
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
JOIN order_details od ON o.OrderID = od.OrderID
JOIN products p ON od.ProductID = p.ProductID;


-- =========================================================
-- FINAL QUERY 2
-- =========================================================
-- Combine products back into one row per order using GROUP_CONCAT.
-- This mimics the original "messy" structure, but only for display.
-- =========================================================

SELECT
    o.OrderID,
    c.CustomerName,
    GROUP_CONCAT(p.ProductName) AS Products,
    GROUP_CONCAT(p.ProductPrice) AS Prices
FROM orders o
JOIN customers c ON o.CustomerID = c.CustomerID
JOIN order_details od ON o.OrderID = od.OrderID
JOIN products p ON od.ProductID = p.ProductID
GROUP BY o.OrderID, c.CustomerName;