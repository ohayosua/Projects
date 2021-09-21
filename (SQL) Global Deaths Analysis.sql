/* 
Research Topic: Causes of Deaths Around the World
Main Focus: Cardiovascular Disease
Skills Demonstrated: Aggregate Functions, Joins, Data Cleaning, Temp Tables, CTE's, 
*/



-- Table 1: Data of Deaths by Natural Causes
SELECT *
FROM PortfolioProject..DeathsNatural
ORDER BY 1,2


-- Table 2: Data of Deaths by Homicide
SELECT *
FROM PortfolioProject..DeathsHomicide







---================================================================================================================================================================================

-- Question 1a: For each country and its year, find the Total Deaths caused by Cardiovascular diseases 
SELECT Entity, Year, [Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu] AS 'Total Deaths by Cardiovascular Diseases Worldwide'
FROM PortfolioProject..DeathsNatural
ORDER BY Entity, Year

-- Question 1b: Find the top 3 years with most number of deaths caused by Cardiovascular Diseases
SELECT Year, [Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu] AS 'Total Deaths by Cardiovascular Diseases Worldwide'
FROM PortfolioProject..DeathsNatural
WHERE Entity = 'World'
ORDER BY [Deaths - Meningitis - Sex: Both - Age: All Ages (Number)] ASC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY

---================================================================================================================================================================================

-- Question 2: List Each Country and its TOTAL Number of deaths caused by Cardiovascular Diseases from total years (1990-2017)
SELECT Entity, SUM([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu]) AS 'Cardiovascular(Total)'
FROM PortfolioProject..DeathsNatural
WHERE [Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu] is not Null
GROUP BY Entity
ORDER BY 1

---================================================================================================================================================================================

-- Question 3: The U.S makes up for what percentage of the total deaths caused by cardiovascular disease worldwide?
SELECT Entity, 
	SUM([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu]) AS 'Total Cardiovascular Deaths',
	(SUM([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu])/ 
	(
	SELECT SUM([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu]) AS Cardiovascular
	FROM PortfolioProject..DeathsNatural
	WHERE Entity = 'World') * 100
	) AS Percentage

FROM PortfolioProject..DeathsNatural
WHERE Entity LIKE '%states'
--WHERE Entity = 'United States'
GROUP BY Entity
ORDER BY 1,2

---================================================================================================================================================================================

-- Question 4: Which country/region suffers the most casualties from Cardiovascular disease? List the percentage of total deaths every country makes up for worldwide.
SELECT Entity, 
	SUM([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu]) AS Cardiovascular,
	(SUM([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu])/ 
	(
	SELECT SUM([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu]) AS Cardiovascular
	FROM PortfolioProject..DeathsNatural
	WHERE Entity = 'World') * 100
	) AS Percentage

FROM PortfolioProject..DeathsNatural
WHERE [Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu] is not NULL
GROUP BY Entity
ORDER BY Percentage DESC


---================================================================================================================================================================================

-- Question 5: For each country, find the growth rate of the total deaths caused by Cardiovascular Disease since first year its data was recorded.
--(For this problem I broke down my thought process into 4 steps)

--Step 1: Create first temp table
DROP TABLE IF EXISTS #temp_1990
CREATE TABLE #temp_1990 (
Entity nvarchar(255),
Deaths_1990 float) 

INSERT INTO #temp_1990
SELECT Entity, [Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu] AS 'Deaths: 1990'
FROM PortfolioProject..DeathsNatural  
WHERE Year = 1990
AND [Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu] IS NOT NULL
ORDER BY Entity

SELECT *
FROM #temp_1990



-- Step 2: Create second temp table
DROP TABLE IF EXISTS #temp_2017
CREATE TABLE #temp_2017 (
Entity nvarchar(255),
Deaths_2017 float) 

INSERT INTO #temp_2017
SELECT Entity, [Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu] AS 'Deaths: 2017'
FROM PortfolioProject..DeathsNatural  
WHERE Year = 2017
AND [Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu] IS NOT NULL
ORDER BY Entity

SELECT *
FROM #temp_2017


-- Step 3: Create thrid temp table joining the two previous temp tables together
DROP TABLE IF EXISTS #temp_join
CREATE TABLE #temp_join (
Entity nvarchar(255), 
Deaths_1990 float,
Deaths_2017 float)

INSERT INTO #temp_join
SELECT temp1.Entity, Deaths_1990, Deaths_2017
FROM #temp_1990 temp1
JOIN #temp_2017 temp2
ON temp1.Entity = temp2.Entity
ORDER BY temp1.Entity

SELECT *
FROM #temp_join
ORDER BY Entity


-- Step 4: Finally, we find the Growth Rate of each country given the joined data above
SELECT Entity, Deaths_1990, Deaths_2017,  ( (Deaths_2017 - Deaths_1990)/ (Deaths_1990) ) * 100 AS 'Growth Rate'
FROM #temp_join
ORDER BY Entity



---================================================================================================================================================================================



-- Question 6a: Join the two tables to compare the deaths caused by Nutritional deficiencies per country and deaths caused by Environmental heat and cold exposure
SELECT Entity, 
	SUM(DN.[Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N]) AS 'Nutritional Deficiencies', 
	SUM(DH.[Deaths - Environmental heat and cold exposure - Sex: Both - Age:]) AS 'Heat/Cold Exposure'

FROM PortfolioProject..DeathsNatural DN
JOIN PortfolioProject..DeathsHomicide DH
ON DN.Code = DH.Code
AND DN.Year = DH.Year
GROUP BY Entity
ORDER BY 2;



-- Question 6b: USING CTE, find the United States's growth rate of total deaths caused by Nutritional deficiencies per country and deaths caused by Environmental heat and cold exposure
WITH CTE_Rate AS 
(SELECT Entity, 
	DN.Year,
	DN.[Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N] , 
	DH.[Deaths - Environmental heat and cold exposure - Sex: Both - Age:] 

FROM PortfolioProject..DeathsNatural DN
JOIN PortfolioProject..DeathsHomicide DH
ON DN.Code = DH.Code
AND DN.Year = DH.Year
WHERE (DN.Year = 1990 OR DN.Year = 2017)
)
SELECT Entity,
((MAX([Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N])) - (MIN([Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N])) )
/(MIN([Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N])) * 100 AS 'Growth Rate %: Deaths by Nutritional Def.'
,
((MAX([Deaths - Environmental heat and cold exposure - Sex: Both - Age:] )) - (MIN([Deaths - Environmental heat and cold exposure - Sex: Both - Age:] )) )
/(MIN([Deaths - Environmental heat and cold exposure - Sex: Both - Age:] )) * 100 AS 'Growth Rate %: Deaths by Environmental Exp.'
FROM CTE_Rate
WHERE Entity = 'United States'
GROUP BY Entity


---================================================================================================================================================================================
--DATA VISUALIZATION--
---================================================================================================================================================================================
/*
Questions 1,2,4,5 were used for visualization on Tableau. 
Link: https://public.tableau.com/app/profile/yosua4303/viz/CardiovascularDeathsWorldwide1990-2017/Dashboard1
*/
---================================================================================================================================================================================
