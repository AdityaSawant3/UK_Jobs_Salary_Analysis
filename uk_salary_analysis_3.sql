-- WHICH JOB HAVE OPENING FROM MONTH OCTOBER TO NOVEMBER.
WITH job_trends_cte AS (
	SELECT 
		DATENAME(MONTH, postingDate) AS job_posting_month,
		title,
		MONTH(postingDate) AS month_number,
		COUNT(id) AS total_jobs
	FROM dbo.salary_data
	GROUP BY DATENAME(MONTH, postingDate), title, MONTH(postingDate)
	HAVING COUNT(id) > 50
)
SELECT job_posting_month, title, total_jobs
FROM job_trends_cte
ORDER BY month_number, total_jobs;

-- JOB OPPORTUNITIES IN WHICH CITY AND ACCORDING TO MONTHS.
WITH job_per_city_cte AS (
	SELECT
		DATENAME(MONTH, postingDate) AS month_name,
		MONTH(postingDate) AS month,
		city,
		COUNT(id) AS total_jobs
	FROM dbo.salary_data
	GROUP BY DATENAME(MONTH, postingDate), MONTH(postingDate), city
)
SELECT month_name, city, total_jobs
FROM job_per_city_cte
ORDER BY month;

-- TOTAL JOBS BETWEEN OPENING AND CLOSING DATE.
WITH jobs_between_opening_closing_cte AS (
	SELECT
		title,
		DATEDIFF(DAY, postingDate, closingDate) AS job_posted_days,
		COUNT(id) AS total_jobs
	FROM dbo.salary_data
	GROUP BY title, DATEDIFF(DAY, postingDate, closingDate)
	HAVING COUNT(id) > 50
)
SELECT title, job_posted_days, total_jobs
FROM jobs_between_opening_closing_cte
ORDER BY total_jobs;
