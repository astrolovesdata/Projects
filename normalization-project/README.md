# Data Normalization Tutorial: From UNF to 3NF

---

## Project Overview

In this project, you will learn how to transform messy data into a clean, structured database using **data normalization**.

We will walk step by step through:

- UNF (Unnormalized Form)  
- 1NF (First Normal Form)  
- 2NF (Second Normal Form)  
- 3NF (Third Normal Form)  

This tutorial focuses on understanding the **logic behind normalization**, not complex SQL techniques.

---

## Real-World Scenario

A small business tracks customer orders in a spreadsheet.

Here’s what their data looks like:

| OrderID | CustomerName | CustomerPhone | ProductsOrdered              | ProductPrices     |
|--------|--------------|---------------|------------------------------|-------------------|
| 1001   | John Smith   | 111-222-3333  | Laptop, Mouse                | 1200, 25          |
| 1002   | Emily Davis  | 777-888-9999  | Phone                        | 800               |
| 1003   | Jack Lee     | 333-444-5555  | Laptop, Monitor, Keyboard    | 1200, 300, 100    |

---

## Step 0: UNF (Unnormalized Form)

This data is in **Unnormalized Form (UNF)**.

### Problems

- Multiple values in one column → repeating groups  
- Fields are not atomic → atomic values violation  
- Customer data is repeated → redundancy  
- Difficult to query and maintain  

---

## Step 1: Convert to 1NF

### Goal

Ensure all fields contain **atomic values**.  
One product per row.

### 1NF Table

| OrderID | CustomerName | CustomerPhone | ProductName | ProductPrice |
|--------|--------------|---------------|-------------|--------------|
| 1001   | John Smith   | 111-222-3333  | Laptop      | 1200         |
| 1001   | John Smith   | 111-222-3333  | Mouse       | 25           |
| 1002   | Emily Davis  | 777-888-9999  | Phone       | 800          |
| 1003   | Jack Lee     | 333-444-5555  | Laptop      | 1200         |
| 1003   | Jack Lee     | 333-444-5555  | Monitor     | 300          |
| 1003   | Jack Lee     | 333-444-5555  | Keyboard    | 100          |

---

## Step 2: Convert to 2NF

### Goal

Remove partial dependencies.  
Customer data should not repeat for every product row.

### 2NF Tables

#### Customers

| CustomerID | CustomerName | CustomerPhone |
|-----------|--------------|---------------|
| C1        | John Smith   | 111-222-3333  |
| C2        | Emily Davis  | 777-888-9999  |
| C3        | Jack Lee     | 333-444-5555  |

#### Orders

| OrderID | CustomerID |
|--------|------------|
| 1001   | C1         |
| 1002   | C2         |
| 1003   | C3         |

#### OrderDetails

| OrderID | ProductName | ProductPrice |
|--------|-------------|--------------|
| 1001   | Laptop      | 1200         |
| 1001   | Mouse       | 25           |
| 1002   | Phone       | 800          |
| 1003   | Laptop      | 1200         |
| 1003   | Monitor     | 300          |
| 1003   | Keyboard    | 100          |

---

## Step 3: Convert to 3NF

### Goal

Remove transitive dependencies. Each table should represent a single entity, eliminating redundancy.

### Customers

| CustomerID | CustomerName | CustomerPhone |
|-----------|--------------|---------------|
| C1        | John Smith   | 111-222-3333  |
| C2        | Emily Davis  | 777-888-9999  |
| C3        | Jack Lee     | 333-444-5555  |

### Orders

| OrderID | CustomerID |
|--------|------------|
| 1001   | C1         |
| 1002   | C2         |
| 1003   | C3         |

### Products

| ProductID | ProductName | ProductPrice |
|----------|-------------|--------------|
| P1       | Laptop      | 1200         |
| P2       | Mouse       | 25           |
| P3       | Phone       | 800          |
| P4       | Monitor     | 300          |
| P5       | Keyboard    | 100          |

### OrderDetails

| OrderID | ProductID |
|--------|-----------|
| 1001   | P1        |
| 1001   | P2        |
| 1002   | P3        |
| 1003   | P1        |
| 1003   | P4        |
| 1003   | P5        |

**Explanation:**  
`OrderDetails` is a junction table connecting `Orders` and `Products`.  
- `OrderID` is both a **Primary Key (PK)** and a **Foreign Key (FK)** referencing `Orders`.  
- `ProductID` is both a **PK** and **FK** referencing `Products`.  
- The **composite PK** (`OrderID + ProductID`) ensures that each product appears **at most once per order**, while maintaining referential integrity to both parent tables.

### ERD Diagram

![3NF ERD](images/Normalization ERD.png)

---

## Optional: Rebuilding Original View

Although the database is normalized, we can recreate the original “spreadsheet-style” view using SQL:

```sql
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
