# Converting `SaleDate` to a Standard SQL Date

The original `SaleDate` column contained dates stored as **text strings** such as:

```
April 9, 2013
June 10, 2014
```

Text-formatted dates are not ideal for analysis because they cannot be reliably used for **sorting, filtering, or time-based calculations**.
To standardize the data while preserving the original values, a new column was created to store the converted date.

---

## Step 1 — Add a new column for the cleaned date

```sql
ALTER TABLE nashville_housing
ADD SaleDateConverted DATE;
```

This statement modifies the table structure by adding a new column called `SaleDateConverted` with the `DATE` data type.

Creating a new column instead of modifying the original one helps **preserve the raw data**, which is considered good data-cleaning practice.

---

## Step 2 — Disable Safe Update Mode

```sql
SET SQL_SAFE_UPDATES = 0;
```

MySQL Workbench often enables **Safe Update Mode**, which prevents updates to an entire table without a `WHERE` clause.

Because the goal is to update **all rows in the dataset**, safe update mode was temporarily disabled to allow the transformation.

---

## Step 3 — Convert the text date into a SQL date

```sql
UPDATE nashville_housing
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%M %e, %Y');
```

The `STR_TO_DATE()` function converts a text string into a proper SQL date.

The format specification tells MySQL how to interpret the text format:

| Format | Meaning          | Example |
| ------ | ---------------- | ------- |
| `%M`   | Full month name  | April   |
| `%e`   | Day of the month | 9       |
| `%Y`   | Four-digit year  | 2013    |

Example conversion:

```
April 9, 2013 → 2013-04-09
```

---

## Step 4 — Verify the conversion

```sql
SELECT SaleDate, SaleDateConverted
FROM nashville_housing
LIMIT 10;
```

This query displays both the original and converted date columns to confirm the transformation was successful.

The resulting `SaleDateConverted` column now stores dates in the standard SQL format:

```
YYYY-MM-DD
```

which allows for easier **time-based analysis, filtering, and aggregation** in later queries.

