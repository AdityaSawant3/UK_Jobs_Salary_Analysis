USE uk_gov_salary_db;

SELECT TOP 10 * FROM dbo.salary_data;

-- TOTAL NO. OF UNIQUE JOBS IN UK.
SELECT DISTINCT hours FROM dbo.salary_data;
-- OBSERVATION: MORE THAN 50K+.

-- LET'S DROP SOME COLUMNS WHICH ARE NOT IMPORTANT FOR ANALYSIS.
ALTER TABLE dbo.salary_data
DROP COLUMN jobReference;

ALTER TABLE dbo.salary_data
DROP COLUMN additionalSalaryInf;

-- MEDIAN YEARLY SALARIES PER TITLE.
WITH title_median_cte AS (
	SELECT
		title, 
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ROUND(salary, 2)) 
		OVER(PARTITION BY title) AS median_yearly_salary
	FROM dbo.salary_data
)
SELECT title, median_yearly_salary
FROM title_median_cte
WHERE median_yearly_salary IS NOT NULL
GROUP BY title, median_yearly_salary
ORDER BY median_yearly_salary DESC;
-- OBSERVATION: DOCTORS TEND TO GET PAID MORE THAN ANY OTHER PROFESSION.

-- MEDIAN YEARLY SALARIES PER CATEGORY
WITH category_salary_cte AS (
	SELECT 
		category,
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ROUND(salary, 0)) 
		OVER (PARTITION BY category) AS median_yearly_salary
	FROM dbo.salary_data
)
SELECT
	category,
	median_yearly_salary
FROM category_salary_cte
WHERE median_yearly_salary IS NOT NULL
GROUP BY category, median_yearly_salary
ORDER BY median_yearly_salary DESC;
-- OBSERVATION: LEGEAL(GOVERNMENT), ENGINEERING, CONSULTANCY, HEALTHCARE, FINANCE, ETC CATEGORIES GETS PAID MORE.

-- WHICH TYPE MOST OF THE JOB ARE
WITH job_type_salary AS (
	SELECT 
		hours, 
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ROUND(salary ,0))
		OVER(PARTITION BY hours) AS percentile_25th_median_salary,
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY ROUND(salary ,0))
		OVER(PARTITION BY hours) AS percentile_50th_median_salary,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ROUND(salary ,0))
		OVER(PARTITION BY hours) AS percentile_75th_median_salary
	FROM dbo.salary_data
)
SELECT 
	hours,
	percentile_25th_median_salary,
	percentile_50th_median_salary,
	percentile_75th_median_salary
FROM job_type_salary
GROUP BY hours, percentile_25th_median_salary, percentile_50th_median_salary, percentile_75th_median_salary
ORDER BY percentile_25th_median_salary, percentile_50th_median_salary, percentile_75th_median_salary DESC;
-- OBSERVATION: 1.) THERE IS NOT MUCH DIFFERENCE BETWEEN PART TIME AND FULL TIME PAY.
--				2.) DON'T CONSIDER 25TH PERCENTILE IT IS OUTLIER.

-- THERE ARE SOME MISSPELLED STATE NAMES SO LET'S CLEAN IT.
UPDATE dbo.salary_data
SET state = 'South East England'
WHERE state = 'South East Englasd';

UPDATE dbo.salary_data
SET state = 'North West England'
WHERE state = 'North West Englasd';

-- WHICH STATES HAVE MORE JOB OPPORTUNITIES AND FOR WHICH PROFESSION?
WITH state_job_count_cte AS (
	SELECT 
		state,
		title,
		COUNT(id) AS total_jobs
	FROM dbo.salary_data
	GROUP BY state, title
)
SELECT
	state, title,
	total_jobs
FROM state_job_count_cte
WHERE total_jobs > 100
ORDER BY total_jobs DESC;
-- OBSERVATION: OBSERVE RESULTS.

-- DROP COLUMN LOCATION, NOT WORTH ANALYZING.
ALTER TABLE dbo.salary_data
DROP COLUMN location;

-- WHICH CITY HAVE MORE JOB OPPORTUNITIES?
SELECT 
	city,
	title,
	COUNT(id) AS total_jobs
FROM dbo.salary_data
GROUP BY city, title
HAVING COUNT(id) > 50 
	AND city IN (
		SELECT city 
		FROM dbo.salary_data
		GROUP BY city
)
ORDER BY total_jobs DESC
-- OBSERVATION: IN CITY LIKE KENT THERE ARE 400+ JOBS FOR PRIVATE TAXI DRIVERS & ASSISTANTS.