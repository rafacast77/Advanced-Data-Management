/*Returns the sequence of countries in which covid 19 propagated*/
covid = LOAD 'COVID.csv'
	USING PigStorage(',')
	AS (time:chararray,
	day:int,
	month:int,
	year:int,
	cases:int,
	deaths:long,
	country:chararray,
	population:long);

--Generates new relation with scope data
scopeData = FOREACH covid GENERATE 
				ToDate(time,'dd/MM/YYYY') AS time:datetime, 
				cases, 
				country;

--Filter out dates for countries with 0 cases
countryValidCases = FILTER scopeData BY cases > 0;

--Group by country for bag iteration
grpByCountry = GROUP countryValidCases BY country;

--Iterate throughe very country bag, and obtains date with first case
countryDateFirstCase = FOREACH grpByCountry {
		           /*order date by time Ascending order*/
			   dateAsc = ORDER countryValidCases BY time ASC;

			   /*selects the first tuple containing first case date*/
			   dateFirstCase = LIMIT dateAsc 1;
													
			   /*Generates a new relation with desired columns*/
			   GENERATE FLATTEN(dateFirstCase.time) AS date:datetime,
			   FLATTEN(dateFirstCase.cases) AS cases:int,
			   FLATTEN(dateFirstCase.country) AS country:chararray;
		       }

/*Orders the relation in the order that COVID-19 spread through the world*/
covidPropagationSequence = ORDER countryDateFirstCase BY date ASC;								

/*Displays the results*/
DUMP covidPropagationSequence;


