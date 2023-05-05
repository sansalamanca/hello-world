/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

/*The Excel file CovidDeaths is made in an particular way. It has the columns "Continent " and " Location" (country) but the author decided to place the continents in 
the column location as if they were countries. Wherever they placed a continent in the "location" column, they left empty the field "continent" of that record  */


Select *
From PortfolioProject..CovidDeaths
Where continent is  null 
order by 3,4

--  =========================================== Infected people ================================================

-- Total Cases vs Population
-- Shows what percentage of population was infected with Covid. France, for instance, had its peak of infected people in april 2021 (8.33%)

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE location='france'
order by 1,2

-- List of countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--- ============================DEATHS=========================================================
-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country



-- In Italy we see a peak of motality in may 2020 reaching a 14% ratio between Infected Vs Death cases

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Italy'
and continent is not null 
order by 1,2


-- The US  shows its mortality peak between feb and may 2020 reaching a 6% ratio between Infected Vs Death cases

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2



-- List of countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS. Total death cases all around the globe  (2.11%).

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--- ========================================= People who were vaccinated ========================================

-- Total Population vs Vaccinations
-- Following the date, shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- this calculation is not allowed, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths          dea   Join     PortfolioProject..CovidVaccinations    vac
	On dea.location = vac.location   and    dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS Percentage_Vaccinated
From PopvsVac

