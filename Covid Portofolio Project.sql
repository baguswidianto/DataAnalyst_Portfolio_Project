SELECT *
From PortofolioProject..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--From PortofolioProject..CovidVaccinations
--order by 3,4

-- Select Data That we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
From PortofolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at total cases vs population
-- shows what precentage of populatio got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as DeathPrecentage
From PortofolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- looking country with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighesstInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfcted
From PortofolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfcted desc



-- Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- let's break things down by continent


-- showing continent with the highest  death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- global numbers

Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM
(new_cases)*100 as DeathPrecentage
From PortofolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2


--looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create visualitation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated