# Nashville Housing Data Cleaning Process

This document explains the **data cleaning steps performed on the Nashville Housing dataset** using SQL.

The objective of the cleaning process was to transform the raw dataset into a **structured and analysis-ready format** by addressing issues such as inconsistent data types, missing values, combined fields, and duplicate records.

## Data Cleaning Summary

| Step | Problem Identified | Solution Applied | SQL Technique |
|-----|--------------------|-----------------|--------------|
| 1 | `SaleDate` stored as text | Converted to SQL `DATE` format using `STR_TO_DATE()` | Data type conversion |
| 2 | Missing property addresses | Filled missing values using a self join on `ParcelID` | Self join |
| 3 | Property address stored in one field | Split into `PropertySplitAddress` and `PropertySplitCity` | String manipulation |
| 4 | Owner address stored in one field | Split into address, city, and state columns | String manipulation |
| 5 | Inconsistent `SoldAsVacant` values (`Y/N/Yes/No`) | Standardized values to `Yes` and `No` | CASE statement |
| 6 | Duplicate property records | Identified and removed duplicates using `ROW_NUMBER()` window function | Window functions |

The full SQL implementation of these steps can be found in:

```
sql/nashville_housing_data_cleaning.sql
```

---

# Dataset

The original dataset used for this project is included in the repository:

```
data/nashville_housing_raw.csv
```

This file represents the **raw data prior to any cleaning transformations**.

---

# Data Cleaning Steps

## 1. Convert Text-Based Sale Date to SQL Date Format

The `SaleDate` column contained dates stored as **text strings**, such as:

```
April 9, 2013
June 10, 2014
```

Text-based dates make filtering and time-based analysis difficult.

To standardize the data while preserving the original values, a new column called `SaleDateConverted` was created with the `DATE` data type.

Example conversion:

```
April 9, 2013 → 2013-04-09
```

---

## 2. Populate Missing Property Addresses

Some rows contained **missing property addresses**.

Because the same property can appear multiple times in the dataset, the table was **joined to itself using ParcelID** to retrieve the address from another record belonging to the same property.

This allowed missing addresses to be filled without external data sources.

---

## 3. Split Property Address into Separate Columns

The `PropertyAddress` column originally contained both the **street address and city** in a single field:

```
1129 CAMPBELL RD, GOODLETTSVILLE
```

To improve data structure, this field was split into two columns:

* `PropertySplitAddress`
* `PropertySplitCity`

This allows the city to be used independently for filtering and analysis.

---

## 4. Split Owner Address into Address, City, and State

The `OwnerAddress` column contained three components stored in a single field:

```
Street Address, City, State
```

Example:

```
1808 FOX CHASE DR, GOODLETTSVILLE, TN
```

This column was separated into three new fields:

* `OwnerSplitAddress`
* `OwnerSplitCity`
* `OwnerSplitState`

Separating these values improves data usability and enables geographic analysis.

---

## 5. Standardize `SoldAsVacant` Values

The `SoldAsVacant` column contained inconsistent categorical values:

```
Y
Yes
N
No
```

These were standardized so that all values follow a consistent format:

```
Yes
No
```

This ensures accurate grouping and aggregation in analysis.

---

## 6. Identify and Remove Duplicate Records

Duplicate records were identified using the following fields:

* `ParcelID`
* `PropertyAddress`
* `SalePrice`
* `SaleDate`
* `LegalReference`

Window functions were used to detect duplicate rows:

* `ROW_NUMBER()` to identify duplicates within groups
* `COUNT()` to verify duplicate groups

Duplicate rows were then removed while keeping the original record.

---

# Result

After cleaning, the dataset:

* Contains standardized date formats
* Has consistent categorical values
* Stores addresses in structured columns
* Contains no duplicate records
* Is ready for further analysis or visualization

---

# Skills Demonstrated

This project demonstrates the use of SQL for data preparation, including:

* Data type conversion
* Handling missing values
* String manipulation
* Self joins
* Window functions
* Duplicate detection and removal
* Data standardization

---

# Project Workflow

The overall workflow of the project was:

```
Raw Dataset
     ↓
SQL Data Exploration
     ↓
Data Cleaning & Transformation
     ↓
Analysis-Ready Dataset
```

---

## Author

**Alfonso Gutierrez**

Data Analytics | SQL | Business Intelligence
