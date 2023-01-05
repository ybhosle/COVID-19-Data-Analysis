SELECT * 
FROM CovidDeaths
ORDER BY 3,4


--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your Country
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE 'India%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of Population got Covid
SELECT location, date,  population, MAX(total_cases) AS HighestInfectionCount, MAX(ROUND((total_cases/population)*100,2)) AS PercentagePopulationInfected
FROM CovidDeaths
--WHERE location LIKE 'India%'
GROUP BY location, population,date
ORDER BY PercentagePopulationInfected DESC

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location,  population, MAX(total_cases) AS HighestInfection, MAX(ROUND((total_cases/population)*100,2)) AS PercentagePopulationInfected
FROM CovidDeaths
--WHERE location LIKE 'India%'
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC

--Showing Countries with Highest Death Count per Percentage
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE 'India%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--We take these out as they are not included in the above queries and want to stay consistent 
--European Union is part of Europe
SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World','European Union','International')
GROUP BY location
ORDER BY TotalDeathCount DESC

--Let's Break things down by Continent
--Showing Continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE 'India%'
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers
SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Death, 
SUM(cast (new_deaths AS int))/ SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Population vs Vaccinations using WINDOW FUNCTION
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location Order by d.Date) AS RollingPeopleVaccinated
FROM CovidDeaths AS d
JOIN CovidVaccinations AS v
ON d.location=v.location
AND d.date=v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3


--Use CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location Order by d.Date) AS RollingPeopleVaccinated
FROM CovidDeaths AS d
JOIN CovidVaccinations AS v
ON d.location=v.location
AND d.date=v.date
WHERE d.continent IS NOT NULL)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location Order by d.Date) AS RollingPeopleVaccinated
FROM CovidDeaths AS d
JOIN CovidVaccinations AS v
ON d.location=v.location
AND d.date=v.date
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store Data for Later Visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.Location Order by d.Date) AS RollingPeopleVaccinated
FROM CovidDeaths AS d
JOIN CovidVaccinations AS v
ON d.location=v.location
AND d.date=v.date
WHERE d.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated

























































