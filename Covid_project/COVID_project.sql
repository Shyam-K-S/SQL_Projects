---------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM Covid_project..CovidDeaths
WHERE continent is not NULL
ORDER BY location,date

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Covid_project..CovidDeaths
WHERE continent is not NULL
ORDER BY location,date

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- +ve cases vs deaths --

SELECT location,date,total_cases,total_deaths,((total_deaths/total_cases)*100) AS death_percentage
FROM Covid_project..CovidDeaths
WHERE location LIKE '%ndia' and continent is not NULL
ORDER BY location,date

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- +ve cases vs population --

SELECT location,date,total_cases,population,((total_cases/population)*100) AS positive_cases_percentage
FROM Covid_project..CovidDeaths
WHERE location LIKE '%ndia' and continent is not NULL
ORDER BY location,date

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- countries with highest positive cases --

SELECT location,population,MAX(total_cases) AS 'highest_no.of_positivecases',MAX((total_cases/population)*100) AS max_positive_cases_percentage
FROM Covid_project..CovidDeaths
--WHERE continent is not NULL
--WHERE location LIKE '%ndia'
GROUP BY location,population
ORDER BY max_positive_cases_percentage DESC

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- countries with max deaths --

SELECT location,MAX(CAST (total_deaths AS int)) AS 'total_death_count'
FROM Covid_project..CovidDeaths
WHERE continent is not NULL 
GROUP BY location
--WHERE location LIKE '%ndia'
ORDER BY total_death_count DESC

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- deaths by continent --

SELECT location,SUM(CAST (new_deaths AS int)) AS 'total_death_count'
FROM Covid_project..CovidDeaths
WHERE continent is null 
and location not in('World','European Union','International')
GROUP BY location
ORDER BY total_death_count DESC

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- global deaths and cases --

SELECT SUM(new_cases) AS "total_cases",SUM(CAST (new_deaths AS int)) AS "total_death's", (SUM(CAST (new_deaths AS int))/SUM(new_cases))*100 AS death_percentage
FROM Covid_project..CovidDeaths
WHERE continent is not NULL 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- global deaths and new cases each day --

SELECT date,SUM(new_cases) AS "total_cases",SUM(CAST (new_deaths AS int)) AS "total_death's", (SUM(CAST (new_deaths AS int))/SUM(new_cases))*100 AS death_percentage
FROM Covid_project..CovidDeaths
WHERE continent is not NULL 
GROUP BY date
ORDER BY date

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- population that got vaccinated cte--

WITH pgvax AS(
SELECT dea.continent,dea.location,dea.date,population,vax.new_vaccinations AS 'vacc_each_day',
SUM(CONVERT(int,vax.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS 'total_vacc_each_day'
FROM Covid_project..CovidDeaths AS dea
JOIN Covid_project..Vaccine AS vax
	ON dea.location=vax.location
	and dea.date=vax.date
WHERE dea.continent is not NULL)
--ORDER BY dea.location,dea.date

SELECT *,((total_vacc_each_day/population)*100) AS percent_of_peoples_vaccinated
FROM pgvax
ORDER BY pgvax.location,pgvax.date

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Temp table --

DROP TABLE IF EXISTS percent_people_vaccinated
CREATE TABLE percent_people_vaccinated(
continent varchar(100),
location varchar(100),
date datetime,
population numeric,
vacc_each_day numeric,
total_vacc_each_day numeric,
)
INSERT INTO percent_people_vaccinated
SELECT dea.continent,dea.location,dea.date,population,vax.new_vaccinations AS 'vacc_each_day',
SUM(CONVERT(int,vax.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS 'total_vacc_each_day'
FROM Covid_project..CovidDeaths AS dea
JOIN Covid_project..Vaccine AS vax
	ON dea.location=vax.location
	and dea.date=vax.date
WHERE dea.continent is not NULL
SELECT *,((total_vacc_each_day/population)*100) AS percent_of_peoples_vaccinated
FROM percent_people_vaccinated
ORDER BY percent_people_vaccinated.location,percent_people_vaccinated.date

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- creating view --

CREATE VIEW percentage_of_people_vacc_ AS
SELECT dea.continent,dea.location,dea.date,population,vax.new_vaccinations AS 'vacc_each_day',
SUM(CONVERT(int,vax.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS 'total_vacc_each_day'
FROM Covid_project..CovidDeaths AS dea
JOIN Covid_project..Vaccine AS vax
	ON dea.location=vax.location
	and dea.date=vax.date
WHERE dea.continent is not NULL

SELECT *
FROM percentage_of_people_vacc_

---------------------------------------------------------------------------------------------------------------------------------------------------------------------