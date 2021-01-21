/*Returns the top most and least affected contries by cases in proportion to population*/
covid = LOAD 'COVID.csv'
	USING PigStorage(',')
	AS (date:chararray,
	day:int,
	month:int,
	year:int,
	cases:int,
	deaths:long,
	country:chararray,
	population:long);

--Generating new relation with desired columns
scopeData = FOREACH covid GENERATE country, cases, population;

--Pre-process data by removing countries with 0 population
scopeData = FILTER scopeData BY population > 0;

--Grouping by country for Iteration
grpByCountry = GROUP scopeData BY country;

--Iterating through every country and adding the total of cases
countryTotalCases = FOREACH grpByCountry {
			--Adds total of cases
			totalCases = SUM(scopeData.cases);

			--Removes duplicates from bag
			population = DISTINCT scopeData.population;

			--Generates a single entry for each country
			GENERATE group AS country:chararray,
			totalCases AS totalCases:long,
			FLATTEN(population) AS population:long;
		    }

--Computes the number of cases in proportion to the population in percentage
casesNProportionTPopu = FOREACH countryTotalCases {
			    --Computes cases by population rate
			    casesNPropTPopu = (double) totalCases/population;

			    --Generates new relation with desired columns
			    GENERATE country, 
			    casesNPropTPopu AS casesNPropToPopu:double,
		            totalCases, population;
			}

--Orders the relation in DESC and ASC order
casesNProportionTPopuDesc = ORDER casesNProportionTPopu BY casesNPropToPopu DESC;
casesNProportionTPopuAsc = ORDER casesNProportionTPopu BY casesNPropToPopu ASC;

--Selects the top 10 tuples in the relations
topTenMostAffectedByPopulation = LIMIT casesNProportionTPopuDesc 10;
topTenLeastAffected = LIMIT casesNProportionTPopuAsc 10;

--Display the results
DUMP topTenMostAffectedByPopulation;
DUMP topTenLeastAffectedByPopulation;

