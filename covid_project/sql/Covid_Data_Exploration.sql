/* ============================================================
Project: COVID-19 Global Data Analysis
Author: Alfonso G.
Tools: MySQL, Tableau Public
Dataset Source: Our World in Data

Description:
SQL analysis exploring infection rates, mortality metrics,
global trends, and vaccination progress using the
covid_deaths and covid_vaccines datasets.

Sections:
1. Case Fatality Analysis
2. Infection Rate Analysis
3. Mortality Impact Analysis
4. Continent-Level Aggregations
5. Global Time Series Trends
6. Vaccination Progress Tracking
============================================================ */

/* ============================================================
SECTION 1: Case Fatality Analysis
Purpose:
Calculate the percentage of confirmed infections that resulted
in death for each country and date.
============================================================ */

SELECT
    cd.location,
    cd.date,
    cd.total_cases,
    cd.total_deaths,
    ROUND(
        cd.total_deaths / NULLIF(cd.total_cases,0) * 100,
        2
    ) AS death_percentage
FROM portfolioproject.covid_deaths cd
WHERE cd.continent IS NOT NULL
ORDER BY death_percentage DESC;

/* ============================================================
SECTION 2: Infection Rate Analysis
Purpose:
Identify countries with the highest infection levels relative
to their population.
============================================================ */

SELECT
    cd.location,
    cd.population,
    MAX(cd.total_cases) AS highest_infection_count,
    ROUND(
        MAX(cd.total_cases) / NULLIF(cd.population,0) * 100,
        2
    ) AS infection_percentage
FROM portfolioproject.covid_deaths cd
WHERE cd.continent IS NOT NULL
GROUP BY
    cd.location,
    cd.population
ORDER BY infection_percentage DESC;

/* ============================================================
SECTION 3: Mortality Impact by Population
Purpose:
Identify countries with the highest death totals relative
to their population size.
============================================================ */

SELECT
    cd.location,
    cd.population,
    MAX(cd.total_deaths) AS highest_death_count,
    ROUND(
        MAX(cd.total_deaths) / NULLIF(cd.population,0) * 100,
        2
    ) AS deaths_per_population
FROM portfolioproject.covid_deaths cd
WHERE cd.continent IS NOT NULL
GROUP BY
    cd.location,
    cd.population
ORDER BY deaths_per_population DESC;

/* ============================================================
SECTION 4: Continent-Level Death Metrics
Purpose:
Analyze continent-level deaths using rows where continent is NULL.
In this dataset, continent totals are stored in the location column
when continent is NULL.
============================================================ */

SELECT
    cd.location AS continent,
    MAX(cd.total_deaths) AS total_deaths,
    ROUND(
        MAX(cd.total_deaths) / NULLIF(MAX(cd.population),0) * 100,
        2
    ) AS death_percentage
FROM portfolioproject.covid_deaths cd
WHERE cd.continent IS NULL
GROUP BY cd.location
ORDER BY total_deaths DESC;

/* ============================================================
SECTION 5: Highest Country Death Count per Continent
Purpose:
Identify the country within each continent that recorded the
highest total number of COVID-19 deaths.

Explanation:
The query groups data by continent and retrieves the maximum
value of total_deaths among all countries in that continent.

Because total_deaths is a cumulative metric that increases
over time, the MAX() function effectively captures the
highest reported death count for a country within each
continent during the dataset period.
============================================================ */

SELECT
    cd.continent,
    MAX(cd.total_deaths) AS total_deaths
FROM portfolioproject.covid_deaths cd
WHERE cd.continent IS NOT NULL
GROUP BY cd.continent
ORDER BY total_deaths DESC;

/* ============================================================
SECTION 6: Global Daily COVID Metrics
Purpose:
Calculate total new cases and deaths worldwide per day
along with daily mortality percentage.
============================================================ */

SELECT
    cd.date,
    SUM(cd.new_cases) AS total_new_cases,
    SUM(cd.new_deaths) AS total_new_deaths,
    ROUND(
        SUM(cd.new_deaths) /
        NULLIF(SUM(cd.new_cases),0) * 100,
        2
    ) AS death_percentage
FROM portfolioproject.covid_deaths cd
WHERE cd.continent IS NOT NULL
GROUP BY cd.date
ORDER BY cd.date;
    

/* ============================================================
SECTION 7: Vaccination Progress vs Population
Purpose:
Track vaccination rollout progress by calculating a cumulative
(running total) number of vaccinations administered for each
country over time and measuring vaccination coverage relative
to population size.

Technique:
Common Table Expression (CTE) + Window Function

Explanation:
- The CTE (PopvsVac) creates a temporary result set combining
  vaccination data with population data.
- SUM() OVER() calculates a running total of vaccinations.
- PARTITION BY location resets the running total for each country.
- ORDER BY date ensures vaccinations accumulate chronologically.
- COALESCE converts NULL vaccination values to zero to prevent
  calculation errors.
- The final query calculates the percentage of the population
  vaccinated using the cumulative vaccination total.
============================================================ */

WITH PopvsVac AS (
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(COALESCE(cv.new_vaccinations,0)) OVER(PARTITION BY cd.location ORDER BY cd.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rolling_people_vaccinated
FROM portfolioproject.covid_deaths cd
JOIN portfolioproject.covid_vaccines cv
ON cd.location=cv.location AND cd.date=cv.date
WHERE cd.continent IS NOT NULL
)
SELECT continent, location, date, population, new_vaccinations, rolling_people_vaccinated,
ROUND(rolling_people_vaccinated/NULLIF(population,0)*100,2) AS percent_vaccinated
FROM PopvsVac
ORDER BY location, date;

/* ============================================================
VIEW: vw_vaccination_progress
Purpose:
Create a reusable dataset that tracks vaccination rollout
progress by country over time.

Description:
This view joins COVID death and vaccination datasets and
calculates a cumulative (running) total of vaccinations
administered for each country.

Key Logic:
- PARTITION BY cd.location resets the running total for each country.
- ORDER BY cd.date ensures vaccinations accumulate chronologically.
- COALESCE converts NULL vaccination values to zero to prevent
  calculation errors.
- The view can be queried later to calculate vaccination
  percentages or feed BI dashboards such as Power BI.

Output Columns:
continent
location
date
population
new_vaccinations
rolling_people_vaccinated
============================================================ */

CREATE VIEW vw_vaccination_progress AS
SELECT
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(COALESCE(cv.new_vaccinations,0)) OVER (
        PARTITION BY cd.location
        ORDER BY cd.date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS rolling_people_vaccinated
FROM portfolioproject.covid_deaths cd
JOIN portfolioproject.covid_vaccines cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL;
