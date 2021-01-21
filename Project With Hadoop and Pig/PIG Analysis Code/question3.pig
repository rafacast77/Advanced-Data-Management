/*List countries in ascending order of female-to-male ratio, throughout the years.*/
cw2data = LOAD 'cw2data.csv'
		USING PigStorage(',')
		AS (country:chararray,
		year:chararray,
		area:chararray,
		sex:chararray,
		city:chararray,
		cityType:chararray,
		recordType:chararray,
		reliability:chararray,
		sourceYear:chararray,
		value:double);

--Getting scoped data for task 2 question 3
scopeData = FOREACH cw2data GENERATE country, year, sex, value;

--Creates unique country & year bags with sex and value tuples
grpDataByCountryYear = GROUP scopeData BY (country, year);

--Iterate through country & year bags and computes female to male ratio
femaleToMaleRatioData = FOREACH grpDataByCountryYear {
			    --Separates female and male tuples in bags
			    men = FILTER scopeData BY sex == 'Male';
			    women = FILTER scopeData BY sex == 'Female';

			    --Adds the sum total of "value" for each gender bag
			    numbMen = SUM(men.value);
			    numbWom = SUM(women.value);
												
			    --Generates new relation with desire columns
			    GENERATE group.country, group.year, 
			    numbWom/numbMen AS femaleToMaleRatio;
			}

--Orders relation in ascending order of female to male ratio			
sortedFemaleToMaleRatio = ORDER femaleToMaleRatioData BY femaleToMaleRatio ASC;

--Display results
DUMP sortedFemaleToMaleRatio;


