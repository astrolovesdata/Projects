Below is a **clean section you can place in your GitHub README** explaining only the **data loading process** you went through. This documents the troubleshooting and shows you understand **real-world database ingestion issues**.

---

# Data Loading Process (MySQL)

The Maven Fuzzy Factory dataset contains several large CSV files (over **1.6 million rows combined**). Due to the size of the dataset, the tables were imported using MySQL’s high-performance bulk loading method:

```
LOAD DATA LOCAL INFILE
```

This method is significantly faster than GUI-based import tools and is commonly used in real-world data engineering and ETL pipelines.

However, importing the dataset required resolving several MySQL security and configuration restrictions.

---

# Step 1 — Use an Administrative MySQL Account

The default user account initially used (`powerbi_user`) did not have sufficient privileges to create databases or modify server variables.

To perform the import, the database connection was switched to the **root account**, which has administrative privileges.

---

# Step 2 — Enable Local File Imports in MySQL Server

MySQL disables local file loading by default for security reasons.

The following command was used to enable the feature:

```sql
SET GLOBAL local_infile = 1;
```

Verification:

```sql
SHOW VARIABLES LIKE 'local_infile';
```

Expected result:

```
local_infile | ON
```

---

# Step 3 — Use the MySQL Command Line Client

MySQL Workbench may block local file imports even when the server allows them.

To bypass this restriction, the **MySQL command line client** was used instead.

The client was started with the following command:

```
mysql --local-infile=1 -u root -p
```

If the MySQL executable is not in the system PATH, the full path can be used:

```
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" --local-infile=1 -u root -p
```

This enables local file loading for the client session.

---

# Step 4 — Select the Target Database

After connecting to MySQL, the project database was selected:

```sql
USE portfolioproject;
```

---

# Step 5 — Prepare CSV File Location

The CSV files were moved to a local directory to avoid permission issues with cloud-synced folders.

Example location:

```
C:\SQLdata\
```

Example file path used in imports:

```
C:/SQLdata/products.csv
```

---

# Step 6 — Bulk Load the Data

Data was imported using `LOAD DATA LOCAL INFILE`.

Example:

```sql
LOAD DATA LOCAL INFILE 'C:/SQLdata/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

Explanation:

| Clause                   | Purpose                      |
| ------------------------ | ---------------------------- |
| FIELDS TERMINATED BY ',' | Defines CSV column separator |
| ENCLOSED BY '"'          | Handles quoted text values   |
| LINES TERMINATED BY '\n' | Defines row separation       |
| IGNORE 1 ROWS            | Skips the header row         |

This process was repeated for all dataset tables.

---

# Step 7 — Validate Successful Import

After loading the data, row counts were verified to confirm successful ingestion.

```sql
SELECT 'website_sessions' AS table_name, COUNT(*) FROM website_sessions
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

Expected dataset size:

| Table              | Rows      |
| ------------------ | --------- |
| website_sessions   | 472,871   |
| website_pageviews  | 1,188,124 |
| orders             | 32,313    |
| order_items        | 40,025    |
| order_item_refunds | 1,731     |
| products           | 4         |

---

# Why This Method Was Used

`LOAD DATA LOCAL INFILE` was chosen because:

* It is **much faster** than graphical import tools
* It is commonly used in **production data pipelines**
* It efficiently loads **large datasets into relational databases**

This approach demonstrates familiarity with **real-world database ingestion workflows**.

---

If you want, I can also give you a **shorter “interview-ready explanation”** of this process that you could use when discussing this project with recruiters or hiring managers.
