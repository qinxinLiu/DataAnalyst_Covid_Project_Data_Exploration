SELECT *
FROM coviddeaths
WHERE continent IS NOT null 
ORDER BY 3,4;


-- Select Data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT null 
ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if infected with COVIDin USA

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM coviddeaths
WHERE LOCATION LIKE '%states%'
AND continent IS NOT null 
ORDER BY 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS percent_population_infected
FROM coviddeaths
ORDER BY 1,2;


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection_count,  MAX((total_cases/population))*100 as percent_population_infected
FROM coviddeaths
GROUP BY location, population
ORDER BY percent_population_Infected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as total_death_count
FROM coviddeaths
WHERE continent IS NOT null 
GROUP BY location
ORDER BY total_death_count DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(total_deaths ) as total_death_count
FROM coviddeaths
WHERE continent IS NOY null 
GROUP BY continent
ORDER BY total_death_count DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths ) AS total_deaths, SUM(new_deaths )/SUM(New_Cases)*100 as death_percentage
FROM coviddeaths
WHERE continent IS NOT null 
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_people_vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null 
ORDER BY 2,3


-- A. UCE CTE
-- number of columns in the braket must be the same as #columns in the table
With pop_vs_vac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, cv.new_vaccinations
,SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covidvaccinations cv
INNER JOIN coviddeaths dea
ON cv.location = dea.location
AND cv.date = dea.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT * , CAST((rolling_people_vaccinated/population)*100 AS decimal)
FROM pop_vs_vac


--B. TEMP TABLE
CREATE TABLE precent_population_vaccinated(
	location varchar(255),
	continent varchar(255),
	"date" DATE,
	population NUMERIC(10,3),
	new_vaccinations NUMERIC(10,3),
	rolling_people_vaccinated NUMERIC(10,3)
)
INSERT INTO precent_population_vaccinated(continent,location, date, population, new_vaccinations, rolling_people_vaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, cv.new_vaccinations
,SUM(new_vaccinations)OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covidvaccinations cv
INNER JOIN coviddeaths dea
ON cv.location = dea.location
AND cv.date = dea.date
WHERE dea.continent IS NOT NULL
--order by 2,3
SELECT * , CAST((rolling_people_vaccinated/population)*100 AS decimal)
FROM precent_population_vaccinated

--C. Subquery
SELECT * , (rolling_people_vaccinated/population)*100 
FROM (SELECT dea.continent, dea.location, dea.date, dea.population, cv.new_vaccinations
,SUM(new_vaccinations)OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covidvaccinations cv
INNER JOIN coviddeaths dea
ON cv.location = dea.location
AND cv.date = dea.date
WHERE dea.continent IS NOT NULL) A

CREATE VIEW recent_population_vaccinated 
AS
SELECT dea.continent, dea.location, dea.date, dea.population, cv.new_vaccinations
,SUM(new_vaccinations)OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covidvaccinations cv
INNER JOIN coviddeaths dea
ON cv.location = dea.location
AND cv.date = dea.date
WHERE dea.continent IS NOT NULL
