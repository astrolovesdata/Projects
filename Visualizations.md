# Tableau Dashboard – COVID-19 Visualization

## Overview

This section of the project focuses on building a **Tableau dashboard using SQL queries prepared in MySQL**. The goal was to transform COVID-19 data into visual insights that allow users to quickly understand global trends, infection rates, and death statistics.

The visualizations were built using **aggregated SQL queries designed specifically for Tableau**, ensuring that the data returned was already structured at the correct level of detail for dashboard reporting.

The final dashboard highlights:

* Global COVID-19 summary metrics
* Death counts by continent
* Countries with the highest infection rates
* Infection trends over time

---

## Tools Used

* **MySQL** – data aggregation and preparation
* **Tableau Public** – visualization and dashboard creation
* **GitHub** – documentation and project presentation

---

## Tableau Dashboard

The final Tableau dashboard contains four visualizations:

### 1. Global COVID KPI Summary

Displays:

* Total global cases
* Total global deaths
* Global death percentage

This visualization provides a quick high-level overview of the pandemic.

---

### 2. Death Count by Continent

Ranks continents based on the total number of COVID-19 deaths.

This allows users to quickly identify which regions experienced the highest death totals.

---

### 3. Highest Infection Count by Country

Ranks countries by:

* Highest infection count
* Percentage of population infected

This highlights which countries were most affected relative to population size.

---

### 4. Infection Trend Over Time

A time-series visualization showing how the **percentage of population infected evolves over time by country**.

This allows comparison of infection growth patterns across countries.

---

# SQL Queries Used for the Visualizations

### Visualization 1 – Global KPI

```sql
SELECT
    SUM(cd.new_cases) AS total_cases,
    SUM(cd.new_deaths) AS total_deaths,
    ROUND(SUM(cd.new_deaths) / NULLIF(SUM(cd.new_cases), 0) * 100, 2) AS death_percentage
FROM portfolioproject.covid_deaths cd
WHERE cd.continent IS NOT NULL;
```

Purpose:
Calculate global totals for cases, deaths, and death percentage.

---

### Visualization 2 – Death Count by Continent

```sql
SELECT
    cd.location,
    SUM(cd.new_deaths) AS total_death_count
FROM portfolioproject.covid_deaths cd
WHERE cd.continent IS NULL
  AND cd.location NOT IN ('World', 'European Union', 'International')
GROUP BY cd.location
ORDER BY total_death_count DESC;
```

Purpose:
Aggregate deaths by continent-level regions for comparison.

---

### Visualization 3 – Highest Infection Count by Country

```sql
SELECT
    cd.location,
    cd.population,
    MAX(cd.total_cases) AS highest_infection_count,
    ROUND(MAX(cd.total_cases) / NULLIF(cd.population, 0) * 100, 2) AS percent_population_infected
FROM portfolioproject.covid_deaths cd
WHERE cd.continent IS NOT NULL
GROUP BY cd.location, cd.population
ORDER BY percent_population_infected DESC;
```

Purpose:
Determine the maximum infection level reached in each country and calculate the percentage of the population infected.

---

### Visualization 4 – Infection Percentage Over Time

```sql
SELECT
    cd.location,
    cd.population,
    cd.date,
    cd.total_cases AS total_cases_to_date,
    ROUND(cd.total_cases / NULLIF(cd.population, 0) * 100, 4) AS percent_population_infected
FROM portfolioproject.covid_deaths cd
WHERE cd.continent IS NOT NULL
ORDER BY cd.location, cd.date;
```

Purpose:
Create a time-series dataset showing infection growth over time.

---

# Tableau Dashboard Preview
[COVID Dashboard](images/tableau_dashboard_preview.png)](https://github.com/astrolovesdata/Projects/blob/main/Tableau%20Covid%20Dashboard.png)
