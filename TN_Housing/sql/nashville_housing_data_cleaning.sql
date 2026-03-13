/* ============================================================
PROJECT: Nashville Housing Data Cleaning
AUTHOR: Alfonso Gutierrez
DESCRIPTION:
This SQL script cleans and standardizes the Nashville Housing
dataset. The cleaning process includes:

• Converting text-based dates into SQL DATE format
• Populating missing property addresses
• Splitting address fields into structured columns
• Standardizing categorical values
• Identifying and removing duplicate records

DATASET:
Nashville Housing Data for Data Cleaning.csv

TABLE USED:
nashville_housing
============================================================ */

/* ============================================================
STEP: Review Records Sharing the Same ParcelID
============================================================

Before repairing missing addresses, it is helpful to examine
the dataset and confirm that multiple records exist for the
same ParcelID. In this dataset, the same property can appear
multiple times, which allows missing addresses to be filled
using information from another record.

Ordering by ParcelID groups these records together so they
can be visually inspected.
============================================================ */

SELECT *
FROM nashville_housing
ORDER BY ParcelID;


/* ============================================================
STEP: Disable Safe Update Mode
============================================================

MySQL Workbench enables SQL_SAFE_UPDATES by default to
prevent accidental updates affecting the entire table.

Since some of the cleaning transformations intentionally
update many rows, safe update mode is temporarily disabled.
============================================================ */

SET SQL_SAFE_UPDATES = 0;


/* ============================================================
STEP: Convert Text-Based SaleDate into SQL DATE Format
============================================================

The SaleDate column contains dates stored as text strings
such as:

    April 9, 2013

Text-formatted dates are difficult to use for filtering,
sorting, and time-based analysis. To standardize the data,
a new column called SaleDateConverted is created with the
DATE data type.

Creating a new column preserves the original raw data while
allowing a properly formatted date to be used for analysis.
============================================================ */

ALTER TABLE nashville_housing
ADD SaleDateConverted DATE;


/* ============================================================
STEP: Convert the Text Date into a SQL DATE
============================================================

The STR_TO_DATE() function converts a text string into a
DATE value using a specified format pattern.

Format components used:
    %M → full month name (April)
    %e → day of the month
    %Y → four-digit year

Example conversion:
    April 9, 2013  →  2013-04-09
============================================================ */

UPDATE nashville_housing
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%M %e, %Y');


/* ============================================================
STEP: Verify the Date Conversion
============================================================

Display both the original SaleDate and the converted date
column to confirm the transformation was successful.
============================================================ */

SELECT SaleDate,
       SaleDateConverted
FROM nashville_housing
LIMIT 10;


/* ============================================================
STEP: Identify Rows with Missing Property Addresses
============================================================

Some records contain missing property addresses. Depending
on how the dataset was imported, missing values may appear
as either:

• empty strings ('')
• NULL values

To repair these records, the table is joined to itself
(self-join) using ParcelID, which identifies the same
property across multiple records.

The join pairs each record with another record that has the
same ParcelID but a different UniqueID.

IFNULL(NULLIF()) is used to treat empty strings as NULL so
that the correct address from the matching record can be
displayed.

This query previews the address that will be used to fill
the missing value.
============================================================ */

SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    IFNULL(NULLIF(a.PropertyAddress, ''), b.PropertyAddress) AS UpdatedAddress
FROM nashville_housing a
JOIN nashville_housing b
    ON a.ParcelID = b.ParcelID
   AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress = ''
   OR a.PropertyAddress IS NULL;


/* ============================================================
STEP: Populate Missing Property Addresses
============================================================

Using the same self-join logic, missing PropertyAddress
values are updated using the address from another record
with the same ParcelID.

Conditions:
• ParcelID must match (same property)
• UniqueID must differ (different record)
• The target record must have an empty or NULL address

The IFNULL(NULLIF()) function treats empty strings as NULL so
the correct address from the matching record is applied.
============================================================ */

UPDATE nashville_housing a
JOIN nashville_housing b
    ON a.ParcelID = b.ParcelID
   AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = IFNULL(NULLIF(a.PropertyAddress, ''), b.PropertyAddress)
WHERE a.PropertyAddress = ''
   OR a.PropertyAddress IS NULL;

/* ============================================================
STEP: Preview Split Property Address into Street and City
============================================================

The PropertyAddress column contains both the street address
and city in a single field, separated by a comma.

Example format:
    1129 CAMPBELL RD, GOODLETTSVILLE

To improve data structure and enable better filtering,
analysis, and grouping, the address is split into two
separate components:

• Street Address
• City

The MySQL function SUBSTRING_INDEX() is used to extract
each portion of the address.

SUBSTRING_INDEX(PropertyAddress, ',', 1)
    → returns everything before the comma (street address)

SUBSTRING_INDEX(PropertyAddress, ',', -1)
    → returns everything after the comma (city)

This query previews the results before creating new columns
and updating the table.
============================================================ */

SELECT
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
    TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1)) AS City
FROM nashville_housing;


/* ============================================================
STEP: Create New Columns for Split Property Address
============================================================

To permanently store the separated street address and city,
two new columns are added to the table.

PropertySplitAddress will store the street portion.
PropertySplitCity will store the city portion.
============================================================ */

ALTER TABLE nashville_housing
ADD PropertySplitAddress VARCHAR(255),
ADD PropertySplitCity VARCHAR(255);


/* ============================================================
STEP: Populate the New Split Address Columns
============================================================

The PropertyAddress column is split using SUBSTRING_INDEX().

SUBSTRING_INDEX(PropertyAddress, ',', 1)
    → extracts the street address

SUBSTRING_INDEX(PropertyAddress, ',', -1)
    → extracts the city

TRIM() removes any extra leading spaces from the city value.
============================================================ */

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1),
    PropertySplitCity = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1));


/* ============================================================
STEP: Verify the Address Split
============================================================

Display the original PropertyAddress along with the two new
split columns to confirm the transformation was successful.
============================================================ */

SELECT PropertyAddress,
       PropertySplitAddress,
       PropertySplitCity
FROM nashville_housing
LIMIT 10;

/* ============================================================
STEP: Split OwnerAddress into Address, City, and State Columns
===============================================================

The OwnerAddress column stores multiple pieces of information
in a single field using the format:

    Street Address, City, State

Example:
    1808 FOX CHASE DR, GOODLETTSVILLE, TN

To improve data structure and enable easier filtering,
sorting, and analysis, the address is split into three
separate components:

• OwnerSplitAddress → Street address
• OwnerSplitCity    → City
• OwnerSplitState   → State

First, three new columns are added to the table to store the
separated address components.

Then the MySQL function SUBSTRING_INDEX() is used to extract
each portion of the address based on the comma delimiter.

Extraction logic:
    SUBSTRING_INDEX(OwnerAddress, ',', 1)
        → returns everything before the first comma (street)

    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)
        → extracts the city by isolating the first two
          segments and returning the portion after the comma

    SUBSTRING_INDEX(OwnerAddress, ',', -1)
        → returns everything after the last comma (state)

TRIM() is applied to remove any leading spaces created by
the comma separation.

The extracted values are then stored in the new columns.
============================================================ */

ALTER TABLE nashville_housing
ADD OwnerSplitAddress VARCHAR(255),
ADD OwnerSplitCity VARCHAR(255),
ADD OwnerSplitState VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
    OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)),
    OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));
   

/* ============================================================
STEP: Standardize SoldAsVacant Values
===============================================================

Objective
---------
The SoldAsVacant column contains inconsistent categorical
values representing whether a property was sold as vacant.

Observed values include:
    Y, Yes
    N, No

To improve consistency and simplify analysis, these values
will be standardized to:

    Yes
    No

Process
-------
Before performing the update, the transformation is verified
through a structured validation process:

1. Inspect the existing values and their counts
2. Preview the standardized output using a CASE statement
3. Identify the rows that will be affected
4. Apply the update once the results are confirmed

This approach ensures the transformation behaves as expected
before modifying the dataset.
============================================================ */


/* ============================================================
STEP 1: Inspect Existing Values
===============================================================

This query displays the current values in SoldAsVacant along
with the number of records for each value. This helps confirm
the presence of inconsistent entries such as 'Y' and 'N'.
============================================================ */

SELECT 
    SoldAsVacant AS OriginalValue,
    COUNT(*) AS Records
FROM nashville_housing
GROUP BY SoldAsVacant;


/* ============================================================
STEP 2: Preview the Standardized Values
===============================================================

A CASE statement is used to simulate the transformation
without modifying the table.

Y → Yes
N → No

This query groups the standardized values to confirm that
the final categories will contain only 'Yes' and 'No'.
============================================================ */

SELECT 
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS CleanedValue,
    COUNT(*) AS Records
FROM nashville_housing
GROUP BY CleanedValue;


/* ============================================================
STEP 3: Identify Rows That Will Be Updated
===============================================================

This query returns the specific rows containing the values
'Y' or 'N'. These are the records that will be affected by
the update operation.
============================================================ */

SELECT *
FROM nashville_housing
WHERE SoldAsVacant IN ('Y','N');


/* ============================================================
STEP 4: Apply the Standardization Update
===============================================================

Once the transformation has been validated, the UPDATE
statement converts the abbreviated values to their full
forms.

Y → Yes
N → No

Existing values that are already 'Yes' or 'No' remain
unchanged.
============================================================ */

UPDATE nashville_housing
SET SoldAsVacant =
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;
    
/* ============================================================
STEP: Identify and Remove Duplicate Records
===============================================================

Objective
---------
Some records may appear more than once in the dataset. To
improve data quality, duplicate records need to be identified
and removed.

In this project, duplicates are defined as rows sharing the
same values in the following fields:

    ParcelID
    PropertyAddress
    SalePrice
    SaleDate
    LegalReference

Method
------
Two window functions are used:

1. ROW_NUMBER()
   Assigns a sequence number to each row within a duplicate
   group. The first row is treated as the original record,
   and subsequent rows are treated as duplicates.

2. COUNT() OVER()
   Counts how many rows exist in each duplicate group.

This approach allows all rows within duplicated groups to be
reviewed first, including both:
    • the original record (row_num = 1)
    • the duplicate record(s) (row_num > 1)

Process
-------
1. Preview all duplicate groups
2. Review a smaller sample for easier inspection
3. Isolate only the duplicate rows that should be removed
4. Delete the duplicate rows
5. Verify that no duplicate groups remain
============================================================ */


/* ============================================================
STEP 1: Preview All Duplicate Groups
===============================================================

This query returns all rows that belong to a duplicate group,
including both the original row and the duplicate row(s).

row_num:
    1   → original row
    >1  → duplicate row

group_count:
    shows how many rows exist in each duplicate group
============================================================ */

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num,
           COUNT(*) OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
           ) AS group_count
    FROM nashville_housing
) AS dupes
WHERE group_count > 1
ORDER BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, row_num;


/* ============================================================
STEP 2: Sample Duplicate Groups for Manual Review
===============================================================

This query returns a smaller sample of duplicate groups to
make manual inspection easier before removing any rows.
============================================================ */

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num,
           COUNT(*) OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
           ) AS group_count
    FROM nashville_housing
) AS dupes
WHERE group_count > 1
ORDER BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, row_num
LIMIT 20;


/* ============================================================
STEP 3: Show Only the Duplicate Rows to Be Removed
===============================================================

This query filters the duplicate groups further so that only
the extra copies are returned.

row_num = 1 is preserved as the original row
row_num > 1 is treated as a duplicate and marked for removal
============================================================ */

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM nashville_housing
) AS dupes
WHERE row_num > 1
ORDER BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, row_num;


/* ============================================================
STEP 4: Delete Duplicate Rows
===============================================================

This DELETE statement removes rows identified as duplicates
(row_num > 1) while keeping the first row in each group.

UniqueID is used to target only the duplicate records.
============================================================ */

DELETE FROM nashville_housing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM nashville_housing
    ) AS dupes
    WHERE row_num > 1
);


/* ============================================================
STEP 5: Verify That Duplicates Have Been Removed
===============================================================

After deletion, this query checks whether any duplicate
groups still remain in the dataset.

If the query returns no rows, duplicate removal was
successful.
============================================================ */

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num,
           COUNT(*) OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
           ) AS group_count
    FROM nashville_housing
) AS dupes
WHERE group_count > 1
ORDER BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, row_num;


/* ============================================================
FINAL STEP: Preview Cleaned Dataset
===============================================================

After completing all cleaning transformations, this query
displays a small sample of the dataset to confirm that the
table structure and values appear as expected.

This allows a quick visual inspection of the cleaned columns,
including:

• SaleDateConverted
• PropertySplitAddress
• PropertySplitCity
• OwnerSplitAddress
• OwnerSplitCity
• OwnerSplitState
• Standardized SoldAsVacant values

The LIMIT clause returns only the first 10 rows to keep the
output manageable.
============================================================ */

SELECT *
FROM nashville_housing
LIMIT 10;
