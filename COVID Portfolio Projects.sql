SELECT *
FROM CovidDeath
where continent is not null
ORDER BY 3,4

SELECT *
FROM CovidVaccination
where continent is not null
ORDER BY 3,4

SELECT location, date, total_deaths, new_cases, total_cases, population
FROM CovidDeath
where continent is not null
ORDER BY 1,2

ALTER TABLE CovidDeath
ALTER column total_deaths float
GO


-- TOTAL CASES VS TOTAL DEATHS


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeath
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2


--TOTAL CASES VS POPULATION

SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 as PercentPopulation
FROM CovidDeath
WHERE location = 'United States'
AND continent is not null
ORDER BY 1,2

--COUNTRY WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 as HighestPercentPopulation
FROM CovidDeath
--WHERE location = 'United States'
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestPercentPopulation desc

--HIGHEST DEATH COUNT PER POPULATION BY COUNTRY

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeath
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--BY CONTINENT

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeath
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--testing

SELECT date, new_cases
FROM CovidDeath
WHERE new_cases = 0
	SELECT ,REPLACE(new_cases,'0','')
	as new_casefixed


--GLOBAL

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeath
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBER

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeath
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--TOTAL VACCINATION VS TOTAL POPULATION 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeath dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date  = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


---TOTAL POPULATION VS VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date  = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- to convert new_vaccinations from varchar into int
ALTER TABLE CovidVaccination
ALTER column new_vaccinations float
GO



---CTE  create temporary table

With PopvsVAc (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date  = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVAc





--TEMP TABLE


CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date  = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



---VIEW FOR PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeath dea
JOIN CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date  = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3