Select * 
From PortfolioProject1.dbo.CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From PortfolioProject1.dbo.CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1.dbo.CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1.dbo.CovidDeaths
Where location like '%Portugal'
and continent is not null
order by 1,2

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1.dbo.CovidDeaths
Where location like '%Kingdom'
and continent is not null
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, total_cases, Population,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1.dbo.CovidDeaths
Where location like '%Portugal'
and continent is not null
order by 1,2

Select Location, date, total_cases, Population,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1.dbo.CovidDeaths
Where location like '%Kingdom'
and continent is not null
order by 1,2

-- Looking at Countries with Highest infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1.dbo.CovidDeaths
--Where location like '%Kingdom'
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject1.dbo.CovidDeaths
--Where location like '%Kingdom'
Where continent is not null
Group by Location
order by TotalDeathsCount desc


-- Breaking down by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject1.dbo.CovidDeaths
--Where location like '%Kingdom'
Where continent is not null
Group by continent
order by TotalDeathsCount desc

--Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject1.dbo.CovidDeaths
--Where location like '%Kingdom'
Where continent is not null
Group by continent
order by TotalDeathsCount desc

-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1.dbo.CovidDeaths
--Where location like '%Kingdom'
Where continent is not null
Group by date
order by 1,2

-- Total cases
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1.dbo.CovidDeaths
--Where location like '%Kingdom'
Where continent is not null
--Group by date
order by 1,2



-- Join tables together // Looking at Total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Same again 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location)
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

---Seeing the vaccinations properly by the percentage of people vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated / Population)*100
From PopvsVac



--  TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated / Population)*100
From #PercentPopulationVaccinated

--- Same againg but with drop table

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVaccinated / Population)*100
From #PercentPopulationVaccinated


-- Creating a view to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated /population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


-- Creating other views

Create View WorldDeath as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathsCount
From PortfolioProject1.dbo.CovidDeaths
--Where location like '%Kingdom'
Where continent is not null
Group by continent
--order by TotalDeathsCount desc



Select *
From PercentPopulationVaccinated