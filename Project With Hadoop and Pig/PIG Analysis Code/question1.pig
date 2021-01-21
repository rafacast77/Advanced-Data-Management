/*Find the number of countries in the dataset*/ 

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
contries = FOREACH cw2data GENERATE country;

--Removing duplicate countries
removeDuplicate = DISTINCT contries;

--Grouping All countries inside a bag to perfrom COUNT
grpAllCountries = GROUP removeDuplicate All;

--Counts all tuples (i.e.countries) inside bag
countryCount = FOREACH grpAllCountries GENERATE COUNT(removeDuplicate.country);

--Displays the result
DUMP countryCount;

