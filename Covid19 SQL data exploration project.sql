select location, date, population from Portfolio_project.dbo.covid_deaths

select * from Portfolio_project.dbo.covid_deaths
order by 3, 4

select * from Portfolio_project.dbo.covid_vaccinations
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_project.dbo.covid_deaths
order by 1, 2

-- #Looking at the rate of total cases vs Total deaths--
-- shows likelihood of dying if you contract covid in your country --  

select location, date, total_cases, total_deaths, (convert(numeric,total_deaths)/total_cases)*100 as death_percentage
from Portfolio_project.dbo.covid_deaths
where location like '%States%'
order by 1, 2

-- Looking at the total cases by the population -- 
select location, date, total_cases, population, (total_cases/population)*100 
	as cases_population_percentage
from Portfolio_project.dbo.covid_deaths
order by 1, 2

-- Looking at countries with highest infection rate compared to population 
select location, population, max(total_cases) as highest_infection_count,  
max((total_cases/population))*100 as percent_population_infected
from Portfolio_project.dbo.covid_deaths
group by location, population
order by percent_population_infected desc


-- Showing countries with highest death count per population --  
select location, max(cast(total_deaths as int)) as total_death_counts 
from Portfolio_project.dbo.covid_deaths
where continent is not null
group by location
order by total_death_counts desc



-- ##Doing it by continent --
select continent, max(cast(total_deaths as int)) as total_death_counts 
from Portfolio_project.dbo.covid_deaths
where continent is not null
group by continent
order by total_death_counts desc 

-- #Showing the continent with the death count per population -- 
select continent, max(cast(total_deaths as int)) as total_death_counts 
from Portfolio_project.dbo.covid_deaths
where continent is not null
group by continent
order by total_death_counts desc 

-- Global numbers --
select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
-- total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from Portfolio_project.dbo.covid_deaths
where continent is not null
-- where location like '%Africa%'
--group by date
order by 1, 2 

select * from Portfolio_project.dbo.covid_vaccinations

-- #Joining the two tables to look at total poulation vs vaccinations --
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as rolling_people_vaccinated
 from Portfolio_project.dbo.covid_deaths dea
join Portfolio_project.dbo.covid_vaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
order by 2, 3

-- #USE CTE --  
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as rolling_people_vaccinated
 from Portfolio_project.dbo.covid_deaths dea
join Portfolio_project.dbo.covid_vaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
	where dea.continent is not null
--order by 2, 3
)
select *, (rolling_people_vaccinated/population)*100 as rolling_people_percentage
from PopvsVac


-- #Temp table --
drop table if exists #Percent_Population_Vacinated
create Table #Percent_Population_Vacinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
insert into #Percent_Population_Vacinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as rolling_people_vaccinated
 from Portfolio_project.dbo.covid_deaths dea
join Portfolio_project.dbo.covid_vaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
	--where dea.continent is not null
--order by 2, 3
select *, (rolling_people_vaccinated/population)*100 as rolling_people_percentage
from #Percent_Population_Vacinated


---Creating view to store data for later visualisation -
create view Percent_Population_Vacinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as rolling_people_vaccinated
 from Portfolio_project.dbo.covid_deaths dea
join Portfolio_project.dbo.covid_vaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2, 3



select * 
from Percent_Population_Vacinated
 

