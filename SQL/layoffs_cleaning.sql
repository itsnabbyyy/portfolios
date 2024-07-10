/* Examine the data */
SELECT * 
FROM layoffs;

/* Create a staging table for data cleaning and transformation */
CREATE TABLE layoffs_staging
LIKE layoffs;

/* Insert the data from raw table to staging table */
INSERT layoffs_staging
SELECT *
FROM layoffs;

/* Inspect the staging table */
SELECT *
FROM layoffs_staging;

/* Create row number to identify and remove duplicates */
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num >1;

/* Create second staging table to delete the duplicates */
CREATE TABLE `layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
`row_num` INT
);

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

/* Verify the second staging table */
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

/* Delete the duplicates */
DELETE 
FROM layoffs_staging2
WHERE row_num > 1; 

/* Standardizing data for company, industry, location and company */
SELECT DISTINCT company
FROM layoffs_staging2;

/* Remove unwanted trailings or spaces */
UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT distinct industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

/* Changing Crypto Currency to Crypto */ 
UPDATE layoffs_staging2
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

/* Remove . in United States */
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

/* Changing the data type of 'date' from text to date */
SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

/* Handling null and missing values */
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

/* Change missing values to null */
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

/* Confirm if missing values changed to NULL */
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

/* Populate the null by matching the industry to fill */
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

/* Remove columns or rows that is deem useless */
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

/* Remove the rom num column*/
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

/* Verify the clean data */
SELECT *
FROM layoffs_staging2;











