Select * from vaccinations;
Select * from coviddeaths;

--1. Table 1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2

-- 2. Table 2

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Sel ect location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount des


-- 3. Table 3

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- 4. Table 4


Select Location, Population,dates, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population, dates
order by PercentPopulationInfected desc


-- Other queries involving data exploration
-- 5.

SELECT dea.continent, dea.location, dea.dates, dea.population,
       MAX(vac.total_vaccinations) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN Vaccinations vac
    ON dea.location = vac.location
   AND dea.dates = vac.dates
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.dates, dea.population
HAVING MAX(vac.total_vaccinations) IS NOT NULL
ORDER BY dea.continent, dea.location, dea.dates;



-- 6.
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS NUMBER)) AS total_deaths,
    CASE WHEN SUM(new_cases) = 0 THEN 0
         ELSE SUM(CAST(new_deaths AS NUMBER)) / SUM(new_cases) * 100
    END AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths;


-- 7.
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 8.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 9.
Select Location, dates, population, total_cases, total_deaths
From CovidDeaths
where continent is not null 
order by 1,2


-- 10.
WITH PopvsVac (Continent, Location, Dates, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.dates, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS NUMBER)) OVER (
            PARTITION BY dea.location 
            ORDER BY dea.dates
        ) AS RollingPeopleVaccinated
    FROM CovidDeaths dea
    JOIN Vaccinations vac
        ON dea.location = vac.location
       AND dea.dates = vac.dates
    WHERE dea.continent IS NOT NULL
)
SELECT 
       Continent, 
       Location, 
       Dates, 
       Population, 
       New_Vaccinations, 
       RollingPeopleVaccinated, 
       CASE WHEN Population = 0 THEN 0
            ELSE (RollingPeopleVaccinated / Population) * 100
       END AS PercentPeopleVaccinated
FROM PopvsVac;






