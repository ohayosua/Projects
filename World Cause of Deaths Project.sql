/* 
Research Topic: Causes of Deaths Around the World
Skills Demonstrated: 
*/

SELECT *
FROM PortfolioProject..DeathsNatural
ORDER BY 1,2

SELECT *
FROM PortfolioProject..DeathsHomicide
ORDER BY 1,2


-- Question 1: Find the top 3 years with most number of deaths caused by Cardiovascular Diseases
SELECT Year, [Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu]
FROM PortfolioProject..DeathsNatural
WHERE Entity = 'World'
--GROUP BY Year, Entity
ORDER BY [Deaths - Meningitis - Sex: Both - Age: All Ages (Number)] DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY


-- Question 2: List Each Country and its TOTAL Number of deaths caused by Cardiovascular Diseases from total years (1990-2017)
SELECT Entity, SUM([Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu]) AS 'Cardiovascular(Total)'
FROM PortfolioProject..DeathsNatural
WHERE [Deaths - Cardiovascular diseases - Sex: Both - Age: All Ages (Nu] is not Null
GROUP BY Entity
ORDER BY 1


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



-- Question 5: Join the two tables to compare the deaths caused by Nutritional deficiencies per country and deaths caused by Environmental heat and cold exposure
SELECT Entity, 
	SUM(DN.[Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N]) AS 'Nutritional Deficiencies', 
	SUM(DH.[Deaths - Environmental heat and cold exposure - Sex: Both - Age:]) AS 'Heat/Cold Exposure'

FROM PortfolioProject..DeathsNatural DN
JOIN PortfolioProject..DeathsHomicide DH
ON DN.Code = DH.Code
AND DN.Year = DH.Year
GROUP BY Entity
ORDER BY 2


-- Question 6: For each country, find the growth rate of the total deaths from the two columns in Question 5. (Note: Remember the data is given from years 1990-2017)
WITH CTE_Rate AS 
(SELECT Entity, 
	DN.Year,
	DN.[Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N] , 
	DH.[Deaths - Environmental heat and cold exposure - Sex: Both - Age:] 

FROM PortfolioProject..DeathsNatural DN
JOIN PortfolioProject..DeathsHomicide DH
ON DN.Code = DH.Code
AND DN.Year = DH.Year
--WHERE Entity = 'United States'
AND (DN.Year = 1990 OR DN.Year = 2017)
)
SELECT Entity,
((MAX([Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N])) - (MIN([Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N])) )
/(MIN([Deaths - Nutritional deficiencies - Sex: Both - Age: All Ages (N])) * 100 AS 'Growth Rate %: Deaths by Nutritional Def.'
,
((MAX([Deaths - Environmental heat and cold exposure - Sex: Both - Age:] )) - (MIN([Deaths - Environmental heat and cold exposure - Sex: Both - Age:] )) )
/(MIN([Deaths - Environmental heat and cold exposure - Sex: Both - Age:] )) * 100 AS 'Growth Rate %: Deaths by Environmental Exp.'
FROM CTE_Rate
GROUP BY Entity





