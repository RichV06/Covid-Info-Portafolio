/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From [Portafolio Project]..CovidDeaths
Where continent is not null
order by 3, 4


Select location, date, total_cases, new_cases, total_deaths, population
From [Portafolio Project]..CovidDeaths
Where continent is not null
order by 1, 2


Alter table CovidDeaths alter column total_deaths numeric(18, 0)

Alter Table CovidDeaths alter column total_cases numeric(18, 0)

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portafolio Project]..CovidDeaths
Where continent is not null
order by 1, 2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Alter table CovidDeaths alter column population numeric(18, 0)

Select Location, date, population, total_cases, (total_cases/population)*100 as PopulationInfected
From [Portafolio Project]..CovidDeaths
order by 1, 2

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfected
From [Portafolio Project]..CovidDeaths
Group by Location, Population
order by PopulationInfected desc

-- Countries with Highest Death Count per Population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portafolio Project]..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portafolio Project]..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

 --GLOBAL NUMBERS

 Alter table CovidDeaths alter column new_cases numeric(18, 0)
 Alter table CovidDeaths alter column new_deaths numeric(18, 0)

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
 From [Portafolio Project]..CovidDeaths
 Where continent is not null 
 Group by date
 order by 1, 2

 -- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Alter table CovidVax alter column new_vaccinations numeric(18, 0)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portafolio Project]..CovidDeaths dea
Join [Portafolio Project]..CovidVax vac
         on dea.location = vac.location
		 and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portafolio Project]..CovidDeaths dea
Join [Portafolio Project]..CovidVax vac
         On dea.location = vac.location 
		 and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

Select (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated





