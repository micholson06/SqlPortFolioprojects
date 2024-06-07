--Analysis of covid 19 database from 2020 - 2024
USE ProjectPortfolio;
GO
--viewing all the columns in the covid deaths table 
SELECT *
FROM covid_deaths_data;

--viewing all the columns in the covid vaccination table
SELECT *
FROM covid_vacinations_data;

--Total covid reported cases by country
SELECT location,MAX(population) Population, MAX(CONVERT(INT, total_cases)) Total_cases	
FROM covid_deaths_data
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_cases;

--Total reported death cases by countries
SELECT location, MAX(population) Population, MAX(CONVERT(INT, total_deaths)) Total_deaths
FROM covid_deaths_data
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_deaths desc;

--Ranking of countries based on the rate of reported cases
SELECT location, MAX(CONVERT(INT, total_cases)) Total_cases, RANK() OVER (ORDER BY MAX(CONVERT(INT, total_cases)) DESC) AS Ranking
FROM covid_deaths_data
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Ranking ASC;

--culmulative sum of covid cases on daily basis by location from 2020-2024
SELECT location, date, convert(int, new_cases) new_cases, sum(convert(int, new_cases)) over (partition by location order by convert(int, new_cases), date)as sum_of_cases 
FROM covid_deaths_data
where continent IS NOT NULL
ORDER BY 1, 2;

--ranking countries with the highest death rates in different continent
select continent, location, max(convert(int, total_deaths)) total_death_cases, RANK() over ( partition by continent order by max(convert(int, total_deaths)) desc) as ranking 
from covid_deaths_data
where continent is not null
group by location, continent;

--Ranking countries with the highest death rates in the world
SELECT location, Max(convert(int, total_deaths)) total_deaths, RANK() OVER (ORDER BY Max(convert(int, total_deaths)) desc) AS Ranking
FROM covid_deaths_data
WHERE continent is not null
GROUP BY location;


--ranking continent with the highest covid cases
select continent, max(convert(int, total_cases)) total_case, RANK() over (order by max(convert(int, total_cases)) desc) as ranking 
from covid_deaths_data
where continent is not null
group by continent;

--global covid death percentage from world population
select location, population, Max(convert(int, total_deaths)) total_death, (max(convert(int, total_deaths)) / population) * 100 as percentages
from covid_deaths_data
where location = 'World'
group by location, population;


--global percentage of reported cases from world population
select location, population, Max(convert(int, total_cases)) total_case, (max(convert(int, total_cases)) / population) * 100 as percentages
from covid_deaths_data
where location = 'World'
group by location, population;


--TEMP TABLE for joining vaccination and death cases table
DROP TABLE IF EXISTS #covid_cases
CREATE TABLE #covid_cases
(continent varchar(50),
 location varchar(50),
 population float,
 dates datetime,
 vaccination bigint,
 death_cases bigint);

 insert into #covid_cases
SELECT cv.continent, cv.location, population, cv.date, convert(bigint, total_vaccinations), cast(total_deaths as bigint)
FROM covid_deaths_data cd
JOIN covid_vacinations_data cv
ON cd.location = cv.location
and cd.date = cv.date;

select *
from #covid_cases
where continent is not null
order by continent, location, dates;


--total death percentage from reported cases 
SELECT sum(new_cases) total_cases, sum(convert(int, new_deaths)) total_deaths, (sum(convert(int, new_deaths)) / sum(new_cases))*100 as death_percent
FROM covid_deaths_data
WHERE continent is not null;

--creating views

create view total_coviddeath_percentage as
SELECT sum(new_cases) total_cases, sum(convert(int, new_deaths)) total_deaths, (sum(convert(int, new_deaths)) / sum(new_cases))*100 as death_percent
FROM covid_deaths_data
WHERE continent is not null;

create view death_rate_rank as
select continent, location, max(convert(int, total_deaths)) total_death_cases, RANK() over ( partition by continent order by max(convert(int, total_deaths)) desc) as ranking 
from covid_deaths_data
where continent is not null
group by location, continent;
