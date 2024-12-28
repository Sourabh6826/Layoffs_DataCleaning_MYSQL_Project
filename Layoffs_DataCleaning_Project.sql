-- Data Cleaning Project
# 1. Removing duplicate data.
# 2. Standerdizing the data to usable format.
# 3. Replacing Null/Blank values if necessary.
# 4. Removing any rows/column if not needed.

CREATE DATABASE layoffs ;

# https://www.kaggle.com/datasets/swaptr/layoffs-2022 dataset link
# Imported layoffs.csv into table.

# Checking table data.
SELECT * FROM layoffs ;

# Creating a duplicate of layoffs table. We wiil be making changes in this duplicate, 
# while keeping raw data safe, incase we need to revert.

CREATE TABLE layoffs1 LIKE layoffs ;
INSERT INTO layoffs1 
SELECT * FROM layoffs;

# Checking duplicate table data.
SELECT * FROM layoffs1;

-- 1. Removing duplicate data. 
# Starting Data Cleaning by identifying duplicate data.
CREATE TABLE layoffs2 like layoffs1 ;
ALTER TABLE layoffs2 ADD row_num INT;
INSERT INTO layoffs2
SELECT *,
ROW_NUMBER() OVER( PARTITION BY company,location,industry, total_laid_off,  percentage_laid_off, 
`date`, stage,  country,  funds_raised ) AS row_num
FROM layoffs1 ;

SELECT * FROM layoffs2
WHERE row_num>1; # This is duplicate data.
DELETE FROM layoffs2 WHERE row_num > 1 ; # Deleting duplicate data.

-- 2. Standerdizing the data to usable format and  3. Replacing Null/Blank values if necessary.
# Removing any blank space at beggining or end from company collumn.
UPDATE layoffs2 
SET company = TRIM(company),
location = TRIM(location),
industry = TRIM(industry),
total_laid_off = TRIM(total_laid_off),
percentage_laid_off = TRIM(percentage_laid_off),
`date` = TRIM(`date`),
stage = TRIM(stage),
country = TRIM(country),
funds_raised = TRIM(funds_raised);

# Checking each indivisual collumns for any format discripency
# (excluding numerical collumns for now).
SELECT DISTINCT company FROM layoffs2 ORDER BY 1; # All good.
SELECT DISTINCT location FROM layoffs2 ORDER BY 1; # All good.
SELECT DISTINCT industry FROM layoffs2 ORDER BY 1; # All good.
SELECT DISTINCT stage FROM layoffs2 ORDER BY 1; # All good.
SELECT DISTINCT country FROM layoffs2 ORDER BY 1; # All good.

# Modifying data types of columns where necessary.(Currently all columns are 'Text' data type. 
ALTER TABLE layoffs2
MODIFY COLUMN `date` DATE; 

# Inserting  NULL to blank rows and then chamging the data type as directly changing it to INT
# will produce error due to  blank rows. 
UPDATE layoffs2
SET total_laid_off = NULL 
WHERE total_laid_off = '' ;
ALTER TABLE layoffs2
MODIFY COLUMN total_laid_off INT; 

UPDATE layoffs2
SET funds_raised = NULL
WHERE funds_raised = ''  ;
ALTER TABLE layoffs2
MODIFY COLUMN funds_raised INT; 

# Checking and replacing blank /null values in other columns 
SELECT *
FROM layoffs2 
where company  = '' or company IS NULL
order by company  ; # 0 rows returned thus company column does not contain any blank/null value.

SELECT *
FROM layoffs2 
where location  = '' or location IS NULL
order by location  ; # 1 rows returned. 
# Replacing blank with 'Unknown'
UPDATE layoffs2
SET location = 'Uknown' 
WHERE location  = '' or location IS NULL ;

SELECT *
FROM layoffs2 
where industry  = '' or industry IS NULL
order by industry;  # 1 rows returned. 
# Checking if there is multiple entry for this company if yes we can get industry value 
# from other row if not we will replace blank with 'Unknown'.
SELECT * FROM layoffs2 
WHERE company = 'Appsmith'; # Only 1 row, thus replacing blank with 'Uknown'.
UPDATE layoffs2
SET industry = 'Uknown' 
WHERE industry  = '' or industry IS NULL ;

SELECT *
FROM layoffs2 
where stage  = '' or stage IS NULL
order by stage ;# 7 rows returned.
UPDATE layoffs2
SET stage = 'Uknown' 
WHERE stage  = '' or stage IS NULL ;

SELECT *
FROM layoffs2 
WHERE country  = '' OR country IS NULL
ORDER BY country ;# 0 rows returned.

# Updating percentage_laid_off column to just 2 decimal place values.
# for those rows where percentage_laid_off column value is more than 2 decimal places
UPDATE layoffs2
SET percentage_laid_off = SUBSTRING(percentage_laid_off,1,4)
WHERE LENGTH(percentage_laid_off) > 4 ;

# for those rows where percentage_laid_off column value is less than 2 decimal places
UPDATE layoffs2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '' ;

UPDATE layoffs2
SET percentage_laid_off = CONCAT(percentage_laid_off,'0')
WHERE LENGTH(percentage_laid_off) < 4  ;

# Updating percentage_laid_off data type to INT and converting values in percentage
ALTER TABLE layoffs2
MODIFY COLUMN percentage_laid_off FLOAT(5,2);

UPDATE layoffs2
SET percentage_laid_off = percentage_laid_off * 100;

ALTER TABLE layoffs2
MODIFY COLUMN percentage_laid_off INT;

-- 4. Removing any collumn if not needed.
# Removing rows where total laid off column is null

DELETE FROM layoffs2 
WHERE total_laid_off IS NULL ;

# Removing row_num column
ALTER TABLE layoffs2 
DROP COLUMN row_num ;








































