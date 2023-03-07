SELECT * 
FROM CovidPortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM CovidPortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

-- Selecting the data I will be using
SELECT location, date, total_cases, new_cases, total_deaths,population
FROM CovidPortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Selecting Total Cases vs Total Deaths
-- Shows the probability of dying if you catch COVID-19 in the United Kingdom
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidPortfolioProject.dbo.CovidDeaths
WHERE location like '%Kingdom' 
ORDER BY 1,2

-- Selecting Total Cases Vs Population
-- Shows Percentage of population that got infected (can choose specific country)
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
FROM CovidPortfolioProject.dbo.CovidDeaths
--WHERE  location like '%kingdom'
WHERE continent is not null
ORDER BY 1,2

-- Selecting Countries with Highest Infection Rates Compared to Population

SELECT location, population, MAX(total_cases) AS TotalInfectionsCount, (MAX(total_cases)/MAX(population))*100 AS InfectionPercentage
FROM CovidPortfolioProject.dbo.CovidDeaths
--WHERE location like '%kingdom'
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectionPercentage DESC

-- Showing Countries Total Death Count and Death Rates (Highest Death count/ Population) in Descending Order

SELECT location, population, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, MAX(total_deaths/population)*100 AS DeathRate
FROM CovidPortfolioProject.dbo.CovidDeaths
--WHERE location like '%kingdom'
WHERE continent is not null
GROUP BY location, population
ORDER BY DeathRate DESC

-- Showing Continents Death Count

SELECT continent, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM CovidPortfolioProject.dbo.CovidDeaths
WHERE  continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS (Total Cases, Deaths and Death Percentage)

SELECT date, SUM(new_cases) AS TotalCases , SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/NULLIF(SUM(new_cases), 0)*100
	AS DeathPercentage
FROM CovidPortfolioProject.dbo.CovidDeaths		--Rolling Count
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS TotalCases , SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/NULLIF(SUM(new_cases), 0)*100
	AS DeathPercentage
FROM CovidPortfolioProject.dbo.CovidDeaths   		 --Totalled
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Totalled Global Cases, Deaths and Death Rate

SELECT SUM(new_cases) AS TotalCases , SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/NULLIF(SUM(new_cases), 0)*100
	AS DeathPercentage
FROM CovidPortfolioProject.dbo.CovidDeaths
WHERE location IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at Vaccination Percentage (Total Population Vs Vaccinations)

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations
, SUM(CONVERT(bigint, Vax.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Deaths.population)		Could not use this as a column so had to create CTE/TempTable
FROM CovidPortfolioProject.dbo.CovidDeaths AS Deaths
JOIN CovidPortfolioProject.dbo.CovidVaccinations AS Vax
	ON Deaths.location = Vax.location 
	and Deaths.date = Vax.date
WHERE Deaths.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to Calculate Rolling Percentage of Poeople Vaccinated Vs Population by Country

WITH PopulationVsVax (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)

AS

(
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations
, SUM(CONVERT(bigint, Vax.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Deaths.population)
FROM CovidPortfolioProject.dbo.CovidDeaths AS Deaths
JOIN CovidPortfolioProject.dbo.CovidVaccinations AS Vax
	ON Deaths.location = Vax.location 
	and Deaths.date = Vax.date
WHERE Deaths.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopulationVsVax



--Using Temp Table

DROP TABLE if exists #PercentOfPopulationVaccinated
CREATE TABLE #PercentOfPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations bigint,
RollingPeopleVaccinated bigint,
)

INSERT INTO #PercentOfPopulationVaccinated
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations
, SUM(CONVERT(bigint, Vax.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Deaths.population)
FROM CovidPortfolioProject.dbo.CovidDeaths AS Deaths
JOIN CovidPortfolioProject.dbo.CovidVaccinations AS Vax
	ON Deaths.location = Vax.location 
	and Deaths.date = Vax.date
WHERE Deaths.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentOfPopulationVaccinated



--Creating a View to Store Data (Same data as above)

Create View PercentOfPopulationVaccinated AS
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations
, SUM(CONVERT(bigint, Vax.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Deaths.population)
FROM CovidPortfolioProject.dbo.CovidDeaths AS Deaths
JOIN CovidPortfolioProject.dbo.CovidVaccinations AS Vax
	ON Deaths.location = Vax.location 
	and Deaths.date = Vax.date
WHERE Deaths.continent IS NOT NULL


SELECT *
FROM PercentOfPopulationVaccinated


