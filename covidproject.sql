select *
from PortfolioProject..coviddeaths
where continent is not null
order by 3,4 

--select *
--from PortfolioProject..covidvaccinations
--order by 3,4 


--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1,2

--looking at total cases vs total deaths

select location, date, total_cases,total_deaths
from PortfolioProject..coviddeaths
order by 1,2

--shows likelihood of dying if you contract covid in your country
SELECT location, date, 
total_cases,total_deaths, ((convert(float, total_deaths))/(convert(float, total_cases)))*100 as DeathPercentage
from PortfolioProject..coviddeaths
where location like '%states%'
order by 1,2

--looking at Total Cases vs Population
--shows what percentage of population got Covid
SELECT location, date, 
population,total_cases, ((convert(float, total_cases))/(convert(float, population)))*100 as PercentPopulationInfected
from PortfolioProject..coviddeaths
--where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population
SELECT location, 
population, max(total_cases) as HighestInfectionCount, max((convert(float, total_cases))/(convert(float, population)))*100 as PercentPopulationInfected
from PortfolioProject..coviddeaths
group by location, population
--where location like '%states%'
order by PercentPopulationInfected desc

SELECT location, 
population, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..coviddeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


--showing countries with highest death count per population

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc 


--let's break things down by continent

SELECT continent, max(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc 


--showing continents with the highest death count per population

SELECT continent, max(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers

SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases), 0)*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases), 0)*100 as DeathPercentage
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select*, (RollingPeopleVaccinated/population)*100 percentage
from PopvsVac

-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select*, (RollingPeopleVaccinated/population)*100 percentage
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationVaccinated
