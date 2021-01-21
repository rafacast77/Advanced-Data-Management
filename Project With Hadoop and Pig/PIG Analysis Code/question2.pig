/*List the countries together with the number of cities in each country*/
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


--Getting scoped data for task 2 question 1
contryNCity = FOREACH cw2data GENERATE country, city;

--Removing duplicate
noDuplicates = DISTINCT contryNCity;

--Grouping countries
grpByCountry = GROUP noDuplicates BY country;

--Iterate through every country bag to count tuples containing cities
cityCountInCountry = FOREACH grpByCountry {
			   cityCount = COUNT(noDuplicates.city);
			   GENERATE group as city, cityCount as cityCount;
		     }

--Display results									
DUMP cityCountInCountry;
