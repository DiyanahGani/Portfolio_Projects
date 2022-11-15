SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date , total_cases , new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Exploring total cases vs total deaths -- 


SELECT location, date , total_cases , total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location =  'Malaysia'
ORDER BY 1,2

--Total cases vs Population (In Malaysia)

SELECT location, date  , population, total_cases, (total_cases/population) * 100 AS 'Infected Percentage by Population'
FROM PortfolioProject..CovidDeaths
WHERE location =  'Malaysia'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS 'Total Cases', 
MAX((total_cases/population)) * 100 AS 'Infected Percentage by Population'
FROM PortfolioProject..CovidDeaths
--WHERE location =  'Malaysia'
WHERE continent is not null
GROUP BY location , population
ORDER BY 'Infected Percentage by Population' DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS 'Total Death Count'
FROM PortfolioProject..CovidDeaths
--WHERE location =  'Malaysia'
WHERE continent is not null
GROUP BY location
ORDER BY 'Total Death Count' DESC

-- Breaking things down by Continent

--Showing Continent with Highest Death Count per Population

SELECT continent , MAX(cast(total_deaths as int)) AS 'Total Death Count'
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent 
ORDER BY 'Total Death Count' DESC

-- GLOBAL NUMBERS
SELECT location, date , total_cases , total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

SELECT Continent, SUM(new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, 
SUM (cast(new_deaths as int)) / SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 1,2

-- Total Cases

SELECT SUM(new_cases) as total_cases, SUM (cast(new_deaths as int)) as total_deaths, 
SUM (cast(new_deaths as int)) / SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Population vs Vaccination

SELECT cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(Convert(int,cv.new_vaccinations))
OVER (Partition by cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2,3

--USE CTE

With PopVsVac ( Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as (
SELECT cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(Convert(int,cv.new_vaccinations))
OVER (Partition by cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100 AS RollingVaccinatedPercentage
FROM PopVsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(Convert(int,cv.new_vaccinations))
OVER (Partition by cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/Population)*100 AS RollingVaccinatedPercentage
FROM #PercentPopulationVaccinated


--Creating View for Data Visualization

CREATE VIEW PercentPopulationVaccinated AS 
SELECT cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations,
SUM(Convert(int,cv.new_vaccinations))
OVER (Partition by cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null

SELECT *
FROM PercentPopulationVaccinated
