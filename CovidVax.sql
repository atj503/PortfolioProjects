
----Select *
----From [Portfolio Project]..['COVIDvaccinations']
------order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..['COVIDdeaths']
order by 1,2

--Looking at total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
From [Portfolio Project]..['COVIDdeaths']
Where location like '%states%' 
order by 1,2

-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, population, total_cases,  round((total_cases/population)*100,2) as DeathPercentage
From [Portfolio Project]..['COVIDdeaths']
Where location like '%states%' 
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population))*100,2) as PercentPopInfected
From [Portfolio Project]..['COVIDdeaths']
--Where location like '%states%'
Group by location, population
order by PercentPopInfected desc

--Showing the countries with the highest death count per capita


Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Portfolio Project]..['COVIDdeaths']
--Where location like '%states%' 
Where continent is not null
Group by location
order by TotalDeathCount desc

--Broken down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Portfolio Project]..['COVIDdeaths']
--Where location like '%states%' 
Where continent is not null
Group by continent
order by TotalDeathCount desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Portfolio Project]..['COVIDdeaths']
--Where location like '%states%' 
Where continent is not null
Group by location
order by TotalDeathCount desc

--showing continents with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From [Portfolio Project]..['COVIDdeaths']
--Where location like '%states%' 
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Breaking down Global numbers
--sum of new cases by date
Select date, SUM(new_cases) --total_deaths,  round((total_cases/population)*100,2) as DeathPercentage
From [Portfolio Project]..['COVIDdeaths']
--Where location like '%states%' 
Where continent is not null
Group by date
order by 1,2

--Total Cases worldwide

Select  SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..['COVIDdeaths']
--Where location like '%states%' 
Where continent is not null
--Group by date
order by 1,2
--Total Cases by day
Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..['COVIDdeaths']
--Where location like '%states%' 
Where continent is not null
Group by date
order by 1,2

--Join COVID deaths and COVID vaccinations table

Select *
From [Portfolio Project]..['COVIDdeaths'] dea
Join [Portfolio Project]..['COVIDvaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Total populations vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVac
From [Portfolio Project]..['COVIDdeaths'] dea
Join [Portfolio Project]..['COVIDvaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVac)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVac
From [Portfolio Project]..['COVIDdeaths'] dea
Join [Portfolio Project]..['COVIDvaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, round((RollingPeopleVac/Population)*100,5)
From PopvsVac
---- CTE did not work properly, RollingPeopleVac was off

Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVac numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVac
From [Portfolio Project]..['COVIDdeaths'] dea
Join [Portfolio Project]..['COVIDvaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Select *, round((RollingPeopleVac/Population)*100,5)
From #PercentPopulationVaccinated


--Creating View to store data for visualizations

Create View PercentPopulationVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVac
From [Portfolio Project]..['COVIDdeaths'] dea
Join [Portfolio Project]..['COVIDvaccinations'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVac