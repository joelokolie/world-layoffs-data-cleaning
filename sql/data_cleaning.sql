-- ==========================================================
-- World Layoffs Data Cleaning
-- ==========================================================
-- Author: Joel Chukwudi Okolie
-- Database: MySQL Server 8.x
-- SQL Editor: Visual Studio Code
--
-- Description:
-- This script cleans and standardizes the World Layoffs dataset
-- imported from Kaggle. The output is a cleaned dataset suitable
-- for exploratory analysis and visualization.
--
-- Dataset:
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- ==========================================================
-- STEP 1: REVIEW THE RAW DATASET
-- ==========================================================

SELECT *
FROM layoffs;

-- ==========================================================
-- STEP 2: CREATE A STAGING TABLE
-- ==========================================================
-- Create a working copy of the original dataset to preserve the raw data.

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- ==========================================================
-- STEP 3: IDENTIFY DUPLICATE RECORDS
-- ==========================================================
-- Assign a row number to each record to identify duplicate rows.

SELECT *,
    ROW_NUMBER() OVER (PARTITION BY
    company,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`) AS `row_number`
FROM layoffs_staging;

WITH duplicate_cte AS (
    SELECT *,
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
    FROM layoffs_staging)
    
-- Records with ROW_NUMBER() greater than 1 are duplicate records.
    
SELECT *
FROM duplicate_cte
WHERE `row_number` > 1;

-- Verify identified duplicates before deletion.

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- ==========================================================
-- STEP 4: DELETING DUPLICATE RECORDS
-- ==========================================================
-- MySQL does not support deleting directly from a CTE.
-- Create a new table with an additional ROW_NUMBER() column
-- to facilitate duplicate removal.

CREATE TABLE `layoffs_clean` (
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

-- Copy the 'layoffs_staging' table data and also insert the row_number values

INSERT layoffs_clean
SELECT *,
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
FROM layoffs_staging;

-- These are the duplicates to be deleted

SELECT *
FROM layoffs_clean
WHERE `row_number` > 1;

-- Remove duplicate records from the dataset.

DELETE
FROM layoffs_clean
WHERE `row_number` > 1;

-- Verify duplicate records have been removed.

SELECT *
FROM layoffs_clean;

-- ==========================================================
-- STEP 5: STANDARDIZE DATA
-- ==========================================================
-- Objective:
-- Correct inconsistencies in text values and data types to
-- improve data quality and ensure consistent analysis.
-- ----------------------------------------------------------
-- Standardize company names
-- ----------------------------------------------------------
SELECT
    company,
    TRIM(company)
FROM layoffs_clean;

UPDATE layoffs_clean
SET company = TRIM(company);

-- ----------------------------------------------------------
-- Standardize industry values
-- ----------------------------------------------------------
SELECT DISTINCT industry
FROM layoffs_clean
ORDER BY 1;

UPDATE layoffs_clean
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- ----------------------------------------------------------
-- Standardize location names
-- ----------------------------------------------------------
SELECT DISTINCT location
FROM layoffs_clean
ORDER BY location;

UPDATE layoffs_clean
SET location =
    CASE
        WHEN location IN ('FlorianÃ³polis') THEN 'Florianopolis'
        WHEN location IN ('DÃ¼sseldorf') THEN 'Dusseldorf'
        ELSE location
    END
WHERE location IN ('FlorianÃ³polis', 'DÃ¼sseldorf');

-- ----------------------------------------------------------
-- Standardize country names
-- ----------------------------------------------------------
SELECT DISTINCT country
FROM layoffs_clean
ORDER BY country;

UPDATE layoffs_clean
SET country = 'United States'
WHERE country = 'United States.';

-- ----------------------------------------------------------
-- Convert date column to DATE datatype
-- ----------------------------------------------------------
-- The date column should be DATE datatype for easy timeseries analysis and visualization

SELECT date
FROM layoffs_clean;

-- Convert text values to MySQL DATE format.

SELECT `date`,
    STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_clean;

-- Update the data types of the date and percentage_laid_off columns.

UPDATE layoffs_clean
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');      

-- Modify date column datatype as well as the percentage laid off column

ALTER TABLE layoffs_clean
MODIFY `date` DATE,
MODIFY `percentage_laid_off` DECIMAL(5,4);

-- ==========================================================
-- STEP 6: HANDLE MISSING VALUES
-- ==========================================================
-- Objective:
-- Identify missing values and populate them where reliable
-- information is available. Remove records that cannot be
-- used for meaningful analysis.

-- ----------------------------------------------------------
-- Identify missing industry values
-- ----------------------------------------------------------
SELECT * 
FROM layoffs_clean
WHERE industry IS NULL
OR industry = '';

-- Check whether another record for the same company contains
-- the missing industry value.

SELECT *
FROM layoffs_clean
WHERE company = 'Juul';

SELECT *
FROM layoffs_clean
WHERE company = 'Carvana';

SELECT *
FROM layoffs_clean
WHERE company = 'Airbnb';

-- ----------------------------------------------------------
-- Populate missing industry values
-- ----------------------------------------------------------

UPDATE layoffs_clean
SET industry =
    CASE
        WHEN industry IN ('') AND company IN ('Juul') THEN 'Consumer'
        WHEN industry IN ('') AND company IN ('Carvana') THEN 'Transportation'
        WHEN industry IN ('') AND company IN ('Airbnb') THEN 'Travel'
    END
WHERE industry IS NULL OR industry = '';

-- ----------------------------------------------------------
-- Identify incomplete records
-- ----------------------------------------------------------
-- Find records that have null or blank values in total_laid_off and
-- percentage_laid_off columns, these records are not needed because
-- they lack value in the two most important column of the subject

SELECT *
FROM layoffs_clean
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- ----------------------------------------------------------
-- Remove incomplete records
-- ----------------------------------------------------------
-- Delete the found irrelevant records

DELETE
FROM layoffs_clean
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- The remaining NULL values can not be calculated or gotten from the available information on the table.

-- ==========================================================
-- STEP 7: FEATURE ENGINEERING
-- ==========================================================
-- Objective:
-- Create additional features that improve the dataset for
-- downstream analysis and remove temporary columns that are
-- no longer required.

ALTER TABLE layoffs_clean
ADD total_est_employees INT;

UPDATE layoffs_clean
SET total_est_employees = 
    CASE
        WHEN percentage_laid_off IS NULL OR percentage_laid_off = 0 THEN NULL
        ELSE ROUND(total_laid_off / percentage_laid_off, 0)
    END
WHERE total_est_employees IS NULL;

-- Removed the row_number column

ALTER TABLE layoffs_clean
DROP `row_number`;

-- ==========================================================
-- DATA CLEANING COMPLETE
-- ==========================================================
-- The dataset has been cleaned, standardized and validated.
-- It is now ready for exploratory data analysis and
-- visualization.

SELECT *
FROM layoffs_clean;

