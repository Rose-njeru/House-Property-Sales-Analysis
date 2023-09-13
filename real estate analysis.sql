   SELECT * FROM housepropertysalesanalysis.raw_sales;

/*Data Cleaning*/
-- Identify Missing Values
SELECT 
datesold
FROM housepropertysalesanalysis.raw_sales
WHERE datesold IS NULL;

SELECT
datesold,
postcode,
price,
propertyType
FROM housepropertysalesanalysis.raw_sales
WHERE postcode IS NULL OR datesold IS NULL OR price IS NULL OR propertyType IS NULL;

-- Checking for Duplicates
SELECT
datesold,
postcode,
price,
propertyType,
COUNT(*)
FROM housepropertysalesanalysis.raw_sales
GROUP BY datesold,postcode
HAVING COUNT(*) >1 ;
-- We get  5887 rows with more than one count 
-- Breakdown the query and here we filer one particular postcode the data has no duplicates
SELECT
datesold,
postcode,
price,
propertyType
FROM housepropertysalesanalysis.raw_sales
WHERE postcode=2602
GROUP BY datesold;

/* Question  One
What are the main factors contributing to variations in property prices for houses in the dataset?
*/
SELECT 
propertyType,
bedrooms,
round(AVG(price),2) AS average_price,
MAX(price) AS maximum_price,
MIN(price) AS minimum_price,
COUNT(*) AS number_of_sales
FROM housepropertysalesanalysis.raw_sales
GROUP BY propertyType,bedrooms
ORDER BY 
average_price DESC,
maximum_price DESC,
minimum_price DESC;

/* Question Two
Does the number of bedrooms have a noticeable impact on property prices, and if so, what is the relationship?
*/
-- House; stand-alone free standing dwelling on land
SELECT
bedrooms,
propertyType,
round(AVG(price),2) AS average_price
FROM housepropertysalesanalysis.raw_sales
WHERE propertyType ='house'
GROUP BY bedrooms
ORDER BY average_price DESC; 

-- units;means an apartment
SELECT
bedrooms,
propertyType,
round(AVG(price),2) AS average_price
FROM housepropertysalesanalysis.raw_sales
WHERE propertyType ='unit'
GROUP BY bedrooms
ORDER BY average_price DESC; 

/* Question Three
How has the average property price changed over time? Are there any seasonal patterns or long-term trends?
*/
SELECT
round(AVG(price),2) AS average_price,
year(datesold) AS sales_year
FROM housepropertysalesanalysis.raw_sales
GROUP BY sales_year
ORDER BY average_price ;

/* Question Four
Is there any correlation between property prices and property type (e.g., house, unit)?
*/

SELECT 
propertyType,
round(AVG(price),2) AS average_price
FROM housepropertysalesanalysis.raw_sales
GROUP BY propertyType
ORDER BY average_price DESC;

/* Question Five 
Are there significant differences in property prices between different postcodes ?
*/

SELECT
postcode,
round(AVG(price),2) AS average_price
FROM housepropertysalesanalysis.raw_sales
GROUP BY postcode
ORDER BY average_price;
-- further on properttype
SELECT
postcode,
propertyType,
round(AVG(price),2) AS average_price
FROM housepropertysalesanalysis.raw_sales
GROUP BY postcode,propertyType
ORDER BY average_price DESC;

/* Question Six
Deduce the top six postcodes by year's price.
*/
-- we shall use window functions and CTE  to solve this
WITH YearlyPrices AS (
SELECT
EXTRACT(YEAR FROM datesold) AS sale_year,
postcode,
SUM(price) AS total_price
FROM housepropertysalesanalysis.raw_sales
GROUP BY
sale_year,
postcode
),
ranking AS(
SELECT
sale_year,
postcode,
total_price,
ROW_NUMBER() OVER(PARTITION BY sale_year ORDER BY total_price DESC) AS row_num
FROM YearlyPrices
) 
SELECT 
sale_year,
postcode,
total_price
FROM ranking
WHERE row_num <= 6
ORDER BY sale_year, total_price DESC ;

/* Question Seven
Are there specific neighborhoods or postcodes that have shown consistent growth in property prices?
*/
-- consistent growth in this case referring to an upward trajectory over the years
WITH growth AS(
SELECT 
postcode,
AVG(price) AS average_price,
YEAR(datesold) AS sale_year
FROM housepropertysalesanalysis.raw_sales
GROUP BY 
sale_year,postcode
)
SELECT
growth1.sale_year,
growth1.postcode,
(growth2.average_price - growth1.average_price) / growth1.average_price *100 AS price_growth_percentage
FROM growth AS growth1
JOIN growth AS growth2
ON growth1.postcode=growth2.postcode
AND growth1.sale_year=(growth2.sale_year -1 )
WHERE growth1.sale_year>=2007
ORDER BY 
growth1.postcode,
growth1.sale_year;

 /* Question Eight
 Which date corresponds to the highest number of sales?
*/
SELECT
datesold,
COUNT(*) AS number_of_sales
FROM housepropertysalesanalysis.raw_sales
GROUP BY datesold
ORDER BY number_of_sales DESC
LIMIT 1;

/* Question Ten
Find out the postcode with the highest average price per sale.
*/
SELECT
postcode,
round(AVG(price),2) AS average_price
FROM housepropertysalesanalysis.raw_sales
GROUP BY postcode
ORDER BY average_price DESC
LIMIT 1;

/*Question Eleven
Are there any patterns or trends in the dates of property sales?
*/
SELECT 
EXTRACT(YEAR from datesold) AS sale_year,
EXTRACT(MONTH FROM datesold) AS sale_month,
quarter(datesold) AS sale_quarter,
COUNT(*) AS number_of_sales
FROM housepropertysalesanalysis.raw_sales
GROUP BY 
sale_year,
sale_month
ORDER BY 
sale_year,
sale_month;

/* Question Twelve
What is the overall health of the real estate market based on the sales data?
*/
WITH SalesData AS (
SELECT
EXTRACT(YEAR FROM datesold) AS sale_year,
COUNT(*) AS num_sales,
SUM(price) AS total_sales_volume,
AVG(price) AS average_price
FROM
housepropertysalesanalysis.raw_sales
GROUP BY sale_year
)
SELECT
sale_year,
num_sales,
total_sales_volume,
round(average_price,2) AS average_price
FROM SalesData
ORDER BY sale_year;

/* Question Thirteen
Can we identify any potential investment opportunities or areas where property prices have the potential to increase significantly?
*/
WITH growth AS(
SELECT 
postcode,
AVG(price) AS average_price,
YEAR(datesold) AS sale_year
FROM housepropertysalesanalysis.raw_sales
GROUP BY 
sale_year,postcode
)
SELECT
growth1.sale_year,
growth1.postcode,
(growth2.average_price - growth1.average_price) / growth1.average_price *100 AS price_growth_percentage
FROM growth AS growth1
JOIN growth AS growth2
ON growth1.postcode=growth2.postcode
AND growth1.sale_year=(growth2.sale_year -1 )
WHERE growth1.sale_year>=2007
ORDER BY 
growth1.postcode,
growth1.sale_year;
