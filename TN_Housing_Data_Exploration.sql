```sql
/*
------------------------------------------------------------
STEP 1: Create a new column to store the cleaned sale date.
------------------------------------------------------------

The original SaleDate column contains dates stored as text
(e.g., "April 9, 2013"). Text dates are difficult to use
for filtering, sorting, and time-based analysis.

To preserve the original raw data, a new column called
SaleDateConverted is created with the DATE data type.
*/

ALTER TABLE nashville_housing
ADD SaleDateConverted DATE;


/*
------------------------------------------------------------
STEP 2: Disable Safe Update Mode
------------------------------------------------------------

MySQL Workbench enables SQL_SAFE_UPDATES by default to
prevent accidental updates to all rows in a table.

Since the goal here is to update every row, safe update
mode is temporarily disabled.
*/

SET SQL_SAFE_UPDATES = 0;


/*
------------------------------------------------------------
STEP 3: Convert the text-based date into a proper SQL DATE
------------------------------------------------------------

The STR_TO_DATE() function converts a string into a DATE
using a specified format.

Original format example:
    April 9, 2013

Format codes used:
    %M = full month name
    %e = day of the month
    %Y = four-digit year

Example conversion:
    April 9, 2013  ->  2013-04-09
*/

UPDATE nashville_housing
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%M %e, %Y');


/*
------------------------------------------------------------
STEP 4: Verify the conversion
------------------------------------------------------------

Display both the original and cleaned date columns to
confirm the transformation was successful.
*/

SELECT SaleDate,
       SaleDateConverted
FROM nashville_housing
LIMIT 10;
```

### What this code accomplishes

1. **Adds a new column** to store standardized dates.
2. **Disables safe update mode** so the entire table can be updated.
3. **Converts text dates into SQL DATE format** using `STR_TO_DATE`.
4. **Verifies the results** by displaying both columns.

---
