# Data Normalization Tutorial: From UNF to 3NF

---

## Project Overview

In this project, you will learn how to transform messy data into a clean, structured database using data normalization.

We will walk step by step through:

- UNF (Unnormalized Form)
- 1NF (First Normal Form)
- 2NF (Second Normal Form)
- 3NF (Third Normal Form)

This tutorial focuses on understanding the logic behind normalization, not complex SQL techniques.

---

## Important Note (Real-World Design)

The original dataset does NOT include:
- CustomerID  
- ProductID  

These are introduced later as surrogate keys.

### What are surrogate keys?

Surrogate keys are artificial IDs used to uniquely identify records.

They are used because:
- Names can repeat (e.g., multiple "John Smith")
- Text fields are inefficient for joins
- IDs create cleaner and more reliable relationships

This is standard practice in real-world database design.

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

This data is in Unnormalized Form (UNF).

### Problems:

- Multiple values in one column (repeating groups)  
- Fields are not atomic  
- Customer data is repeated (redundancy)  
- Difficult to query and maintain  

---

## Step 1: Convert to 1NF

### Goal

Ensure all fields contain atomic values.

One product per row.

---

### 1NF Table

| OrderID | CustomerName | CustomerPhone | ProductName | ProductPrice |
|--------|--------------|---------------|-------------|--------------|
| 1001   | John Smith   | 111-222-3333  | Laptop      | 1200         |
| 1001   | John Smith   | 111-222-3333  | Mouse       | 25           |
| 1002   | Emily Davis  | 777-888-9999  | Phone       | 800          |
| 1003   | Jack Lee     | 333-444-5555  | Laptop      | 1200         |
| 1003   | Jack Lee     | 333-444-5555  | Monitor     | 300          |
| 1003   | Jack Lee     | 333-444-5555  | Keyboard    | 100          |

### Remaining Issue

Customer information is still repeated for every product.

---

## Step 2: Convert to 2NF

### Goal

Remove partial dependencies.

### What is a partial dependency?

If a table uses a composite key (more than one column), like:

(OrderID, ProductName)

Then every column must depend on both parts of that key.

### Problem

- CustomerName depends only on OrderID  
- It does NOT depend on ProductName  

This is a partial dependency.

---

### Solution

Split the data into separate tables:

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

Remove transitive dependencies.

### What is a transitive dependency?

A column depends on another non-key column instead of the primary key.

### Problem

- ProductPrice depends on ProductName  
- Not directly on OrderID  

This creates a dependency chain:

Order → Product → Price

---

### Solution

Move product information into its own table.

#### Products

| ProductID | ProductName | ProductPrice |
|----------|-------------|--------------|
| P1       | Laptop      | 1200         |
| P2       | Mouse       | 25           |
| P3       | Phone       | 800          |
| P4       | Monitor     | 300          |
| P5       | Keyboard    | 100          |

#### OrderDetails

| OrderID | ProductID |
|--------|-----------|
| 1001   | P1        |
| 1001   | P2        |
| 1002   | P3        |
| 1003   | P1        |
| 1003   | P4        |
| 1003   | P5        |

---

## Final Query (Reporting View)

The final query demonstrates how normalized data can be recombined into a denormalized, business-friendly format for reporting purposes.

The database remains normalized for storage efficiency, while this query produces a denormalized view for readability and analysis.

From a business perspective, this allows teams to generate clear, report-ready outputs (e.g., customer orders with product summaries) without compromising the integrity and efficiency of the underlying database design.

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
```

## Glossary

- **UNF (Unnormalized Form):** Data with repeating groups or multiple values in a single field  
- **1NF (First Normal Form):** Ensures all values are atomic (one value per cell)  
- **2NF (Second Normal Form):** Removes partial dependencies (columns must depend on the full key)  
- **3NF (Third Normal Form):** Removes transitive dependencies (columns depend only on the primary key)  
- **Partial Dependency:** When a column depends on only part of a composite key  
- **Transitive Dependency:** When a column depends on another non-key column  
- **Surrogate Key:** An artificial ID used to uniquely identify records  
