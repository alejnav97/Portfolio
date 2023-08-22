select *
from PortfolioProject..CovidDeaths
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2  


-- Likelihood of Dying if You Contract Covid in Your Country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2 

-- Percentage of United States Population Who Had Covid.

select Location, date, population, total_cases,  (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2 

-- Percentage of Populationn Infected by Country

select Location, population, MAX(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
Group by location, population
order by PopulationInfectedPercentage desc

-- Continents With Highest Death Count per Population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2 

-- Total Cases VS Total Deaths 

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 

-- Total Population VS Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


with PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View To Store Data for Later Visualizations

create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated