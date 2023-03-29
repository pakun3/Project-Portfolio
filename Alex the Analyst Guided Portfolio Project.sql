Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

--Select Location, date, total_cases, new_cases, total_deaths, population

From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total cases vs Population
-- Shows What percentage of population got Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2

--Countries with Highest Infection Rate compared to Populatioin

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death count Per Pop

SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CtE to Perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

Temp Table

--DROP Table if exists #PercentPopulationVaccinated

--Create Table #PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

--Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 