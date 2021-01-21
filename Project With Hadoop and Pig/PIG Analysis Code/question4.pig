/*List the top 10 most populated cities according to the most recent data*/
cw2data = LOAD 'cw2data.csv'
		USING PigStorage(',')
		AS (country:chararray,
		year:int,
		area:chararray,
		sex:chararray,
		city:chararray,
		cityType:chararray,
		recordType:chararray,
		reliability:chararray,
		sourceYear:chararray,
		value:long);

--Getting scoped data for task 2 question 4
scopeData = FOREACH cw2data GENERATE city, year, value;

--Creates a unique entry for the population of a city and corresponding year
grpByCityYear = GROUP scopeData BY (city, year);

--Iterates through every city and year entry and adds the total population
cityYearPopulation = FOREACH grpByCityYear {
			population = SUM(scopeData.value);

			--Generates a new relation with desired columns
			GENERATE group.city, group.year, 
			population AS population:long;
		     }
						 
--Groups by city for iteration by city
grpByCity = GROUP cityYearPopulation BY city;

--Iterates through every year
recentPopData = FOREACH grpByCity {

		    --Orders the tuples inside very city by DESC year
		    yearDESCOrder = ORDER cityYearPopulation BY year DESC;						
		    --Selects the most recent year tuple in each city
		    recentYear = LIMIT yearDESCOrder 1;
										
		    --Generates a new relation with city recent data as columns
		    GENERATE FLATTEN(recentYear.city) AS city, 
		    FLATTEN(recentYear.year) AS year, 
		    FLATTEN(recentYear.population) AS population;
		}

--Order the relation by population in descending order
topMostPopulatedCities = ORDER recentPopData BY population DESC;

--Selects the top 10 cities in the relation
topTenPopCities = LIMIT topMostPopulatedCities 10;

--Display results
DUMP topTenPopCities;

