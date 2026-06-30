# 🌍 World Layoffs Data Cleaning Using SQL

## Project Overview

This project demonstrates a complete SQL data cleaning workflow using the **World Layoffs** dataset from Kaggle.

The objective was to transform raw company layoff data into a clean, standardized dataset suitable for analysis and visualization.

---

## Dataset

**Source:** Kaggle – World Layoffs Dataset

The dataset contains information such as:

- Company
- Industry
- Location
- Country
- Total Employees Laid Off
- Percentage Laid Off
- Date
- Company Stage
- Funds Raised

---

## Business Problem

Raw datasets often contain issues that make analysis unreliable, including:

- Duplicate records
- Missing values
- Inconsistent text formatting
- Incorrect data types
- Inconsistent category names

The goal of this project is to identify and correct these issues, resulting in a clean dataset ready for analysis.

---

## Project Objectives

- Preserve the original dataset
- Remove duplicate records
- Standardize text values
- Correct data types
- Handle missing values
- Create additional useful features
- Validate the cleaned dataset

## Workflow Diagram

Raw Dataset
      ▼
Data Quality Assessment
      ▼
Duplicate Removal
      ▼
Data Standardization
      ▼
NULL Handling
      ▼
Feature Engineering
      ▼
Validation
      ▼
Clean Dataset Ready for Analysis

---

## SQL Skills Demonstrated

- Window Functions
- Common Table Expressions (CTEs)
- Data Cleaning
- Data Standardization
- Data Validation
- Feature Engineering
- Data Type Conversion
- NULL Handling

---

## Files

| File | Description |
|------|-------------|
| 01_database_setup.sql | Database and table creation |
| 02_data_cleaning.sql | Complete cleaning process |
| 03_validation_queries.sql | Validation after cleaning |

---

## Dataset Cleaning Summary

✔ Removed duplicate records

✔ Standardized inconsistent company, industry, country and location values

✔ Converted the Date column to DATE datatype

✔ Handled missing values where possible

✔ Removed rows containing insufficient information

✔ Created an estimated employee count column

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Visual Studio Code | SQL development |
| MySQL Server | Database management |
| SQL | Data cleaning and transformation |
| Kaggle | Dataset source |
| Git & GitHub | Version control and project hosting |

---

## Results

The cleaning process produced a standardized dataset that is ready for exploratory data analysis and visualization.

Key improvements include:

- Duplicate records removed
- Missing values handled where possible
- Consistent categorical values
- Correct data types
- New analytical feature added
- Dataset validated for downstream analysis

---

## Future Improvements

- Migrate the project to PostgreSQL
- Exploratory Data Analysis (EDA)
- Power BI Dashboard
- Interactive Business Dashboard

---

## Project Environment

- Database: MySQL Server 8.x
- SQL Editor: Visual Studio Code
- Operating System: Windows 11

---

## Author

**Joel Chukwudi Okolie**

Aspiring Data Analyst

GitHub: https://github.com/joelokolie
