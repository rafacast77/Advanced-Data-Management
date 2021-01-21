/*Returns the top biggest difference between cases and death peak in month*/
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
scopeData = FOREACH covid GENERATE country, month, year, deaths, cases;

--Grouping by country, month, year for Iteration
grpByCountry = GROUP scopeData BY (country, month, year);

--Iterates through and sums the total death and cases for each group
countryCasualitPerDate = FOREACH grpByCountry {
			    --Sums total deaths and cases for each group
			    deathsPerDate = SUM(scopeData.deaths);
			    casesPerDate = SUM(scopeData.cases);

			    --Genertes new relation with desired columns
			    GENERATE group.country AS country,
			    group.month AS month, group.year AS year,
			    deathsPerDate AS deathsPerDate:long,
			    casesPerDate AS casesPerDate:long;
			}

--Groups new relation by country for Iteration
grpByCountryDate = GROUP countryCasualitPerDate BY country;

--Iterates through every country date and returns peak month deaths
countryDeathPeakMonth =  FOREACH grpByCountryDate {
			    --Orders death and cases per month descending order
			    sortDeathPeakMonth = ORDER countryCasualitPerDate BY 
			    deathsPerDate DESC;
			    sortCasesPeakMonth = ORDER countryCasualitPerDate BY 
			    casesPerDate DESC;
				
		            --Selects the first tuple of the sorted bags
			    peakDeathsMonth = LIMIT sortDeathPeakMonth 1;
			    peakCasesMonth = LIMIT sortCasesPeakMonth 1;

			    --Selects the month for each peak month tuple
			    deathPmonth = peakDeathsMonth.month;
			    casesPmonth = peakCasesMonth.month;

			    --Generates new relation with desired columns
			    GENERATE group AS country, 
			    peakCasesMonth AS casesPeakDate, 
			    peakDeathsMonth AS deathPeakDate,
			    FLATTEN(casesPmonth) AS casesPmonth:int,
			    FLATTEN(deathPmonth) AS deathPmonth:int;
		        }

--Computes the difference between the peak cases and death months.
countryDeathPeakMonthDiff = FOREACH countryDeathPeakMonth {
				--Returns the difference between month cases-deaths
				peakMonthDeathDiff = ABS(casesPmonth-deathPmonth);

				--Generates new relation with desired columns
				GENERATE country AS country, 
			        casesPeakDate AS casesPeakDate, 
				deathPeakDate AS deathPeakDate,
				peakMonthDeathDiff AS peakMonthDeathDiff:int;
	                    }

--Orders the new relation by the difference between months descending order
diffDeathCasePeakMonth =  ORDER countryDeathPeakMonthDiff BY peakMonthDeathDiff DESC;	

--Display the results					
DUMP diffDeathCasePeakMonth;





