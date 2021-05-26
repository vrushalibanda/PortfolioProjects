select *
from PortfolioProject.dbo.coviddeaths
where continent is not null
order by 3,4


-- Select Data that we are going to be starting with
select location,date,total_cases, new_cases, total_deaths,population
from PortfolioProject.dbo.coviddeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as Deathpercentage
from PortfolioProject.dbo.coviddeaths
where location like '%India%'
and continent is not null
order by 1,2

--Looking at the total cases vs percentage
--show what percentage of population got covid
select location,date,population,total_cases,(total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject.dbo.coviddeaths
where location like '%India%'
and continent is not null
order by 1,2

---- Countries with Highest Infection Rate compared to Population
select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject.dbo.coviddeaths
group by location,population
order by 4 DESC

---- Countries with Highest Death Count per Population
select location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject.dbo.coviddeaths
where continent is not null
group by location
order by totaldeathcount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject.dbo.coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc

-- GLOBAL NUMBERS
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100  as Deathpercentage
from PortfolioProject.dbo.coviddeaths
where continent is not null
--group by date
order by 1,2

--joining two tables
--looking at the total population vs vaccination
select dea.continent,dea.location,dea.population,vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject.dbo.covidvaccinations  vac
join PortfolioProject.dbo.coviddeaths dea
on vac.location =dea.location and vac.date =dea.date
where dea.continent is not null
order by 2,3

---- Using CTE to perform Calculation on Partition By in previous query
with PopvsVac (continent,location,Date,population,new_vaccination,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject.dbo.covidvaccinations  vac
join PortfolioProject.dbo.coviddeaths dea
on vac.location =dea.location and vac.date =dea.date
where dea.continent is not null
)
Select * ,(RollingPeopleVaccinated/Population)*100
From PopvsVac


---- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--creating view to store data for later visulization.
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 