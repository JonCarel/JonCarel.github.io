--Total Cases and Deaths World

select 
sum(new_cases) as Total_cases
,sum(new_deaths) as Total_Deaths
,round((sum(new_deaths)/sum(new_cases) )*100,4) as death_percentage
from
Project_1_Health_Care.dbo.covid_deaths

where 
continent is not null
and continent != ''


--Total Cases and Deaths Per Continent

select 
continent
,sum(new_cases) as Total_cases
,sum(new_deaths) as Total_Deaths
,round((sum(new_deaths)/sum(new_cases) )*100,4) as death_percentage
from
Project_1_Health_Care.dbo.covid_deaths

where 
continent is not null
and continent != ''

group by
continent

order by 1

--Rolling Total Vaccinations with percentages by location
--Joining Two Tables and CTE



With PercentVac (Continent,Location,date,Population,New_vaccinations,rolling_total_vaccination)
as
(

select 
deaths_tbl.continent
,deaths_tbl.location
,deaths_tbl.date
,deaths_tbl.population
,vaccination_tbl.new_vaccinations
,sum(convert(float,vaccination_tbl.new_vaccinations)) 
over (partition by deaths_tbl.location order by deaths_tbl.location,deaths_tbl.date) 
as rolling_total_vaccination

from
Project_1_Health_Care.dbo.covid_deaths deaths_tbl
join Project_1_Health_Care.dbo.covid_vaccinations vaccination_tbl

on	
deaths_tbl.location = vaccination_tbl.location
and deaths_tbl.date = vaccination_tbl.date

where
new_vaccinations != ''
and deaths_tbl.continent != ''

)

select 
*
,round((rolling_total_vaccination/Population)*100,2) as vaccination_percentage

from Percentvac

order by 2,3

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Project_1_Health_Care.dbo.covid_deaths
Group by Location, Population, date
order by PercentPopulationInfected desc

-- Total Cases vs Population
-- Shows the countries with the highest infection percentage

select 
location,
max(population) as population,
max(total_cases) as total_cases,
round((max(total_cases)/max(population))*100,2) as Infection_percentage

from Project_1_Health_Care.dbo.covid_deaths

where 
continent is not null
and continent != ''


group by location

order by 4 desc

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select 
location,
max(total_deaths) as Total_deaths,
max(total_cases) as total_cases,
round((max(total_deaths)/nullif(max(total_cases),0))*100,2) as death_percentage

from Project_1_Health_Care.dbo.covid_deaths

where 
continent is not null
and continent != ''

group by location

order by 1

--ranking death percentage by economy class with infection rate

with gdp as
(
select 
vaccination_tbl.location
,max(gdp_per_capita) as gdp_per_capita
,round((max(total_deaths)/nullif(max(total_cases),0))*100,2) as death_percentage
,round((max(total_cases)/nullif(max(deaths_tbl.population),0))*100,2) as infection_percentage
,round((max(total_vaccinations)/nullif(max(deaths_tbl.population),0))*100,2) as vaccination_percentage

from Project_1_Health_Care.dbo.covid_vaccinations vaccination_tbl
join Project_1_Health_Care.dbo.covid_deaths deaths_tbl

on
deaths_tbl.location = vaccination_tbl.location
and deaths_tbl.date = vaccination_tbl.date

where vaccination_tbl.continent != ''
and gdp_per_capita !=''

group by vaccination_tbl.location
)

select
--AVG(convert(float,gdp_per_capita))

location
,case 
	when convert(float,gdp_per_capita) > 19192.6091794872 then 'Above average' 
	else 'Below average' end as economy_class
,gdp_per_capita
,death_percentage
,infection_percentage
,vaccination_percentage
from gdp

where death_percentage is not null

order by 2 desc,3 desc

-- Total Cases vs Total Deaths vs Date
-- Shows the progression of deaths and cases with respect to time per location

select 
max(location) as location
,min(date) as date
,max(total_deaths) as total_deaths
,max(total_cases) as totalcases
,max(round((total_deaths/nullif(total_cases,0))*100,2)) as DeathPercentage

from Project_1_Health_Care.dbo.covid_deaths

where 
continent is not null 
and location = 'Philippines'
and total_deaths != 0

group by total_cases

order by 3
