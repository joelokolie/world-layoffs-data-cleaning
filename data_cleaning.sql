-- SQL Data Cleaning Project

-- CSV was downloaded from -- https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- I created the database 'world_layoffs' in MySQL server, then created 'layoffs' table and imported the downloaded CSV imported into it.

SELECT *
FROM layoffs;

-- I want to check and remove duplicates if there are any
-- I want to standardize the data in columns like Date
-- I will look at the blank and NULL values to see what I can do with it
-- I will remove any column or rows that is not important to save time when querying the data.

-- But first, I have to create and work from a copy of the original table, to preserve the original data.

CREATE TABLE layoffs_copy          -- I copied the columns of the original table
LIKE layoffs;

INSERT layoffs_copy                -- I copied data from original table into the copy
SELECT *
FROM layoffs;

SELECT *                           -- I can now work the copy of the original table while the raw data is still intact.
FROM layoffs_copy;

-- Checking for dublicate
-- from the table there is no column that can be used to identify all the rows, something like a company or industry id or sort
-- so I have to assign row_number and match it across all the columns to see if thers is any duplicate.

SELECT *,
    ROW_NUMBER() OVER (PARTITION BY
    company,                                 -- by partitioning by all the columns, I am assigning 1 to each unique row,
    industry,                                -- if there is 2 and above on the row_number that means its a duplicate
    total_laid_off,
    percentage_laid_off,
    `date`) AS `row_number`
FROM layoffs_copy;

WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY
        company,
        location,                                -- I have to use a subquery or CTE in order to filter a window function column like 
        industry,                                -- ROW_NUMBER, using CTE here I filtered for rows greater than 1, which are of course
        total_laid_off,                          -- the duplicates that have to be removed.
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions) AS `row_number`
    FROM layoffs_copy)
SELECT *
FROM duplicate_cte
WHERE `row_number` > 1;

SELECT *                                    -- I checked on some of the data to make sure they are actually duplicates.
FROM layoffs_copy
WHERE company = 'Casper';

-- Deleting the duplicates
-- I could have simply deleted the identified duplicates from the layoffs_copy table, directly from the CTE,
-- but MySQL Server unfortunately does not allow update from a CTE. This can be done in PostgreSQL though.
/*
WITH duplicate_cte AS
(SELECT *,
    ROW_NUMBER() OVER (PARTITION BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions) AS `row_number`
FROM layoffs_copy)
DELETE
FROM duplicate_cte
WHERE `row_number` > 1;
*/

-- With MySQL I have to create an actual table with row_number column and then insert same content I used in
-- creating CTE then go ahead delete the duplicate rows.

CREATE TABLE `layoffs_copy2` (                     -- I created a new table 'layoffs_copy2' with row_number column
    `company` text,
    `location` text,
    `industry` text,
    `total_laid_off` int DEFAULT NULL,
    `percentage_laid_off` text,
    `date` text,
    `stage` text,
    `country` text,
    `funds_raised_millions` int DEFAULT NULL,
    `row_number` int
    )ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT layoffs_copy2
SELECT *,                                 -- Copied the 'layoffs_copy' table data I used in creating CTE which have row_number column values
    ROW_NUMBER() OVER (PARTITION BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions) AS `row_number`
FROM layoffs_copy;

SELECT *                          -- I now have the 5 dublicate rows filtered from an actual table, no longer from CTE.
FROM layoffs_copy2                -- #the next query have deleted the duplicates, so this query will return an empty table.
WHERE `row_number` > 1;

DELETE
FROM layoffs_copy2                -- I proceeded to remove the duplicates, 5 rows were deleted.
WHERE `row_number` > 1;

SELECT *                          -- Duplicate rows have been deleted
FROM layoffs_copy2;

-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardizing data
-- I will try to find issues in the data and fix it.

SELECT company, TRIM(company)           -- I saw some whitespaces on the company column
FROM layoffs_copy2;

UPDATE layoffs_copy2                    -- So I trimmed and updated the table, 11 rows were changed.
SET company = TRIM(company);

SELECT DISTINCT industry                -- Found an issue in industry column, there is null, empty and entries like
FROM layoffs_copy2                      -- Crypto, CryptoCurrency and Crypto Currency
ORDER BY 1;

UPDATE layoffs_copy2                    -- I updated all crypto-currency industries to 'Crypto' 3 rows were changed
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location                -- I found wrong spelt locations,
FROM layoffs_copy2
ORDER BY location;

UPDATE layoffs_copy2
SET location =
    CASE
        WHEN location IN ('FlorianÃ³polis') THEN 'Florianopolis'      -- I updated and corrected them, 2 rows were changed.
        WHEN location IN ('DÃ¼sseldorf') THEN 'Dusseldorf'
        ELSE location
    END
WHERE location IN ('FlorianÃ³polis', 'DÃ¼sseldorf');

SELECT   country                            -- I found some punctuated entry on 'country column'
FROM layoffs_copy2
ORDER BY country;

UPDATE layoffs_copy2                        -- I standardized and updated 'country'column
SET country = 'United States'
WHERE country = 'United States.';

SELECT date                                 -- I noticed the data type of the date column is TEXT, and timeseries analysis
FROM layoffs_copy2;                         -- and visualization can't be done with that, so I have to change it.

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')             -- first I have to format it to a standard date format
FROM layoffs_copy2;

UPDATE layoffs_copy2                        -- Updated the table, 2355 rows changed.
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');      

ALTER TABLE layoffs_copy2                   -- then modified the data type from text to date, 2356 rows were affected.
MODIFY `date` DATE,                         -- I modified the percentage laid off column alongside from text to DECIMAL
MODIFY `percentage_laid_off` DECIMAL(5,4);

-- -------------------------------------------------------------------------------------------------------------------------------------------

-- Checking and handling NULL values

SELECT *                                    -- Found 4 rows with a blank or NULL industry, 
FROM layoffs_copy2
WHERE industry IS NULL
OR industry = '';

SELECT *                                    -- I will to populate it by checking each company
FROM layoffs_copy2                          -- to see if there's same company with the industry data. -- found for 3 companies
WHERE company = 'Juul';

UPDATE layoffs_copy2                        -- Updated 3 rows -- nothing can be done for the remaining 1 row
SET industry =
    CASE
        WHEN industry IN ('') AND company IN ('Juul') THEN 'Consumer'
        WHEN industry IN ('') AND company IN ('Carvana') THEN 'Transportation'
        WHEN industry IN ('') AND company IN ('Airbnb') THEN 'Travel'
    END
WHERE industry IS NULL OR industry = '';

SELECT *                                    -- This two columns are the most important for this project,
FROM layoffs_copy2                          -- 361 rows have no information on both column, so they useless to this project
WHERE total_laid_off IS NULL                -- and i will have to remove them.
AND percentage_laid_off IS NULL;

DELETE                                      -- 361 rows removed
FROM layoffs_copy2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- The remaining NULL values can not be calculated or gotten from the available information on the table, so I'm done with NULL values
-- -----------------------------------------------------------------------------------------------------------------------------------

-- Adding additional column for estimated total employees and removing the row_number column which I wont be needing anymore.

ALTER TABLE layoffs_copy2                   -- Added new column to calculate total employees estimate
ADD total_est_employees INT;

UPDATE layoffs_copy2                        -- Calculated the values into the column
SET total_est_employees = 
    CASE
        WHEN percentage_laid_off IS NULL OR percentage_laid_off = 0 THEN NULL
        ELSE ROUND(total_laid_off / percentage_laid_off, 0)
    END
WHERE total_est_employees IS NULL;

ALTER TABLE layoffs_copy2                   -- I removed the row_number column since I wont be needing it anymore.
DROP `row_number`;

SELECT *                                    -- Now, I think this table is ready to be explored!
FROM layoffs_copy2;
-- ------------------------------------------------------------------------------------------------------------------------------
