/*List the top 10 cities which have the highest population change per year*/
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
		value:double);

--Getting scoped data for task 2 question 5
scopeData = FOREACH cw2data GENERATE city, year, value;

--Grouping city and year for Iteration
grpByCityYear = GROUP scopeData BY (city, year);

--Iterating on every cityYear group and adding the population
cityPopYears = FOREACH grpByCityYear {
		   popu = SUM(scopeData.value);
									
		   --Generates a new relation with desired columns
	           GENERATE group.city, group.year, popu AS population;
	       }

--Grouping by city for iteration
grpByCity = GROUP cityPopYears BY city;

--Iterates through each city and returns earliest and latest year population
cityPopData = FOREACH grpByCity {
		 --Generate two bags with tuples in year DESC and ASC order
		 sortYearDESC = ORDER cityPopYears BY year DESC;
	         sortYearsASC = ORDER cityPopYears BY year ASC;
								
		 --Returns the tuple with the population of first and last year
		 latestYear = LIMIT sortYearDESC 1;
		 earliestYear = LIMIT sortYearsASC 1;
								
		 --Generates a new relation with desired columns
		 GENERATE group AS city,
		 FLATTEN(latestYear.population) AS popLatestYear,
		 FLATTEN(earliestYear.population) AS popEarliestYear,
		 FLATTEN(latestYear.year) AS lastestYear,
		 FLATTEN(earliestYear.year) AS earliestYear;
	      }

--Iterates through every tuple and computes population change per year
cityChangeInPop = FOREACH cityPopData {
		    --Computes difference in years
		    numbYears = lastestYear - earliestYear;
		    --computes absolute change in year in percentage
		    changeInYears = ABS((popLatestYear - popEarliestYear) /
		      (popEarliestYear) / numbYears);

		    --Generates a new relation with desired columns
		    GENERATE city, changeInYears AS changeInYears;
		  }

--Sorting population by descending order
changeInYearsDescOrder = ORDER cityChangeInPop BY changeInYears DESC;

--selects the first 10 instances of the relation
topTenPopulatedCities = LIMIT changeInYearsDescOrder 10;

--Displays results
DUMP topTenPopulatedCities;
