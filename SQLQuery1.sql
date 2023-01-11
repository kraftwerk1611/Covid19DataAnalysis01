use project_CovidDataAnalysis;

select * from CovidDeaths$
where continent is not null
order by 3,4;

--select * from CovidVaccinations$;


-- quick overview of important columns
select location, date, total_cases, new_cases, total_deaths, population from CovidDeaths$
order by 1,2;

--total cases vs deaths
select date,location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from CovidDeaths$ 
order by DeathPercentage  Desc;


-- where there were at least 1000 reported cases
select date,location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from CovidDeaths$ 
where total_cases >1000 order by DeathPercentage  Desc;

-- in U.S only
select date,location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from CovidDeaths$ 
where location like '%states%' order by DeathPercentage  Desc;

-- what percentage of population is infected/
select location, (total_cases/population)*100 as infected from CovidDeaths$ 
where location like '%states%';

-- country with most infections
-- what percentage of population is infected/
select location, population, max(total_cases) as highest_infection_rate, max(total_cases/population)*100 as Percent_infected from CovidDeaths$ 
group by location, population
order by Percent_infected desc;

-- Highest death count per population
select location, max(cast(total_deaths as int)) as highest_casualty_rate from CovidDeaths$ 
where continent is not null --without this the continents will also show up in location column
group by location
order by highest_casualty_rate desc;

-- view by continents.
select continent, max(cast(total_deaths as int)) as total_casualties from CovidDeaths$ 
where continent is not null --without this the continents will also show up in location column
group by continent
order by total_casualties desc;

--second query
--when continent is set to null, the location column only shows continents.
select location, max(cast(total_deaths as int)) as highest_casualty_rate from CovidDeaths$ 
where continent is null 
group by location
order by highest_casualty_rate desc;

-- global Covid-19 figures
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage from CovidDeaths$
where continent is not null
order by 1,2;

-- checking out Vaccination data now
select * from CovidVaccinations$;

select location, sum(cast(total_vaccinations as bigint)) as total_vaccinations,
sum(cast(people_vaccinated as bigint)) as people_vaccinated,
sum(cast(people_fully_vaccinated as bigint)) as people_fully_vaccinated 
--(cast(people_vaccinated as bigint)/cast(total_vaccinations as bigint)) as percentage_fully_vaccinated
from CovidVaccinations$
where continent is not null and total_vaccinations is not null
group by location
order by people_fully_vaccinated desc;


-- joining CovidDeaths and CovidVaccination tables to check the relationship between total populations and vaccinations.
select Cd.continent, CD.location,CD.date, CD.population, CV.new_vaccinations from CovidDeaths$ CD
join CovidVaccinations$ CV
on CD.date=CV.date and CD.location=CV.location
where CD.continent is not null 
order by 1,2,3
;

-- only the dates on which new vaccinations were administered
-- joining CovidDeaths and CovidVaccination tables to check the relationship between total populations and vaccinations.
select Cd.continent, CD.location,CD.date, CD.population, CV.new_vaccinations from CovidDeaths$ CD
join CovidVaccinations$ CV
on CD.date=CV.date and CD.location=CV.location
where CD.continent is not null and new_vaccinations is not null
order by 1,2,3;
;

-- windows functions for rolling count
select Cd.continent, CD.location,CD.date, CD.population, CV.new_vaccinations ,
sum(cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location,CD.date) as running_sum_vaccinations
from CovidDeaths$ CD
join CovidVaccinations$ CV
on CD.date=CV.date and CD.location=CV.location
where CD.continent is not null 
order by 2,3
;

