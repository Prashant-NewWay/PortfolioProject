SELECT *
FROM Portfolio_covidproject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM Portfolio_covidproject..CovidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Portfolio_covidproject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Total cases vs Total Deaths
-- Shows Likelihood of death if you contract covid in a specific country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
FROM Portfolio_covidproject..CovidDeaths
WHERE location = 'India' 
and continent is not NULL
ORDER BY 1,2

-- Looking at Total cases vs Population
-- Shows the percentage of population who contracted covid

SELECT location,date,population ,total_cases,(total_cases/population)*100 AS PercentePopulationInfected
FROM Portfolio_covidproject..CovidDeaths
WHERE continent is not NULL
--WHERE location = 'India'
ORDER BY 1,2

-- Countries with Highest infection rate compared to the Population

SELECT location,population ,max(total_cases) AS HighestInfectionCount,Max((total_cases/population))*100 AS PercentePopulationInfected
FROM Portfolio_covidproject..CovidDeaths
--WHERE location = 'India'
Group By location,population
ORDER BY PercentePopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT location,max(cast(total_deaths as int)) AS HighestDeathCount
FROM Portfolio_covidproject..CovidDeaths
WHERE continent is not NULL
--WHERE location = 'India'
Group By location
ORDER BY HighestDeathCount DESC


--By Continent
--Showing Continents with the Highest Death Count per population

SELECT Continent,max(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolio_covidproject..CovidDeaths
WHERE continent is not NULL
--WHERE location = 'India'
Group By continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths AS int)) as total_deaths,(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 as Death_Percentage
FROM Portfolio_covidproject..CovidDeaths
--WHERE location = 'India' 
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2

--Looking at total Population vs Vaccination

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT D.continent,D.location,D.date,D.population, V.new_vaccinations
		,SUM(cast(V.new_vaccinations as int)) over( partition by D.location order by D.location ,D.date) as RollingVaccinations
		--,(RollingVaccinations/population)
FROM Portfolio_covidproject..CovidDeaths D
JOIN Portfolio_covidproject..CovidVaccinations V
	ON D.date=V.date AND D.location=V.location 
WHERE D.continent is not NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac_Table (continent,location,date, population,new_vaccinations,RollingVaccinations ) AS

(SELECT D.continent,D.location,D.date,D.population, V.new_vaccinations
		,SUM(cast(V.new_vaccinations as int)) over( partition by D.location order by D.location ,D.date) as RollingVaccinations
		--,(RollingVaccinations/population)
FROM Portfolio_covidproject..CovidDeaths D
JOIN Portfolio_covidproject..CovidVaccinations V
	ON D.date=V.date AND D.location=V.location 
WHERE D.continent is not NULL
--ORDER BY 2,3
)
SELECT * , (RollingVaccinations/population)*100
FROM PopVsVac_Table

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
	SELECT D.continent,D.location,D.date,D.population, V.new_vaccinations
		,SUM(cast(V.new_vaccinations as int)) over( partition by D.location order by D.location ,D.date) as RollingVaccinations
		--,(RollingVaccinations/population)
FROM Portfolio_covidproject..CovidDeaths D
JOIN Portfolio_covidproject..CovidVaccinations V
	ON D.date=V.date AND D.location=V.location 
--WHERE D.continent is not NULL
--ORDER BY 2,3		

SELECT * , (RollingVaccinations/population)*100
FROM #PercentPopulationVaccinated



-- Creating View to Store data for Visualization later

Create View PercentPopulationVaccinated as
SELECT D.continent,D.location,D.date,D.population, V.new_vaccinations
		,SUM(cast(V.new_vaccinations as int)) over( partition by D.location order by D.location ,D.date) as RollingVaccinations
		--,(RollingVaccinations/population)
FROM Portfolio_covidproject..CovidDeaths D
JOIN Portfolio_covidproject..CovidVaccinations V
	ON D.date=V.date AND D.location=V.location 
WHERE D.continent is not NULL

SELECT * From PercentPopulationVaccinated