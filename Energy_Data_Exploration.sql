/*
Energy Data Exploration
*/

---- Energy, Electricity and Emissions
-- Country Data for last 2 decades
Select *
From EnergyData
Where code is not null 
		and year >= 2000
Order by country, year

-- GDP per Capita in Nigeria
Select 
	country, year, population, gdp, 
	(gdp/population) as gdp_per_capita
From EnergyData
Where 
	country = 'Nigeria'
	and code is not null 
Order by 5 desc

-- Electricity demand per Capita in Nigeria
Select 
	country, year, population, electricity_demand, 
	(electricity_demand/population) as demand_per_capita
From EnergyData
Where 
	country = 'Nigeria'
	and code is not null 
Order by 5 desc

-- Electricity generation per Capita in Nigeria
Select 
	country, year, gdp, electricity_generation, 
	(electricity_generation/population) as gen_per_capita
From EnergyData
Where 
	country = 'Nigeria'
	and code is not null 
Order by 5 desc

--Maximum Emissions
Select 
	country, year, population, 
	Max(cast(greenhouse_gas_emissions as float)) as max_emissions
From EnergyData
Where code is not null 
Group by country, year, population
Having Max(cast(greenhouse_gas_emissions as float)) > 0
Order by population desc, max_emissions desc

-- Maximum Energy Consumptions
Select 
	country, year, gdp, 
	Max(cast(primary_energy_consumption as float)) as max_consumption
From EnergyData
Where code is not null 
Group by country, year, gdp
Having Max(cast(greenhouse_gas_emissions as float)) > 0
Order by max_consumption desc


-- Total Emissions per Energy Consumptions
Select SUM(cast(greenhouse_gas_emissions as float)) as total_emissions, 
		SUM(cast(primary_energy_consumption as float)) as total_energy_consumption, 
		SUM(cast(greenhouse_gas_emissions as float))/SUM(cast(primary_energy_consumption as float)) 
		as emission_per_energy_consumption
From EnergyData
where code is not null 

-- Total Electricity Demand per Generation
Select SUM(cast(electricity_demand as float)) as total_demand, 
		SUM(cast(electricity_generation as float)) as total_generation, 
		SUM(cast(electricity_demand as float))/SUM(cast(electricity_generation as float)) as demand_per_generation
From EnergyData
where code is not null 


--Renewable and Fossil Fuel Energy

Select * From [Renewables&FossilFuel]

-- Converting Data type
Update [Renewables&FossilFuel] 
--Set Renewables_consumption = cast(Renewables_consumption as float)
--Set Renewable_energy_share = cast(Renewable_energy_share as float)
--Set Fossil_consumption = cast(Fossil_consumption as float)
Set Fossil_energy_share = cast(Fossil_energy_share as float)

Update EnergyData
--Set primary_energy_consumption = Cast(primary_energy_consumption as float)
Set greenhouse_gas_emissions = Cast(greenhouse_gas_emissions as float)


-- Country data for the past decade.
Select e.country, e.year, e.primary_energy_consumption, r.Renewables_consumption, r.Fossil_consumption
From EnergyData as e 
	Left Join [Renewables&FossilFuel] as r
	On e.country = r.country
Where e.code is not null and e.year > 2010
Order by 4 desc, 5 desc


-- Countries with the highest share of renewables in the past decade
Select country, Max(Renewable_energy_share) as RE_Share
From (
		Select e.country, e.year, primary_energy_consumption, Renewable_energy_share
		From EnergyData as e
			Inner Join [Renewables&FossilFuel] as r
			On e.code = r.iso_code
		Where e.year > 2010) as subquery
Group by country
Order by 2 desc

-- Fossil Fuel energy share in the past decade
Select e.country, e.year, greenhouse_gas_emissions, Fossil_energy_share
		From EnergyData as e
			Inner Join [Renewables&FossilFuel] as r
			On e.code = r.iso_code
		Where e.year > 2010
		and Fossil_energy_share in (
		Select Max(Fossil_energy_share) as Fossil_Share
			From (
			Select e.country, e.year, greenhouse_gas_emissions, Fossil_energy_share
			From EnergyData as e
				Inner Join [Renewables&FossilFuel] as r
				On e.code = r.iso_code
			Where e.year > 2010) as subquery
			Group by country)
Order by 4 desc
