
-- PEOPLE TEND TO CHOOSE WHICH TYPE OF JOBS?
SELECT 
	jobType,
	COUNT(id) AS total_jobs
FROM dbo.salary_data
GROUP BY jobType
ORDER BY total_jobs DESC;
-- OBSERVATION: 1.) PEOPLE CHOOSE JOBS WHICH ARE PERMANAT.
--				2.) CONTRACT AND TEMPORARY BASED JOBS ARE SAME.

-- WHICH CATEGORY HAVE JOBS PERMANENT AND CONTRACT BASED?
SELECT 
	category,
	jobType,
	COUNT(id) AS total_jobs
FROM dbo.salary_data
WHERE jobType IN ('Permanent', 'Contract')
GROUP BY category, jobType
ORDER BY jobType, total_jobs DESC;

-- CATEGORIES HAVE BOTH PERMANENT AND CONTRACT JOBS.
WITH category_job_type_cte AS (
	SELECT 
		category
	FROM dbo.salary_data
	WHERE jobType IN ('Permanent', 'Contract')
	GROUP BY category
	HAVING COUNT(DISTINCT jobType) = 2
)
SELECT 
	s.category, 
	s.jobType, 
	COUNT(s.id) AS total_jobs
FROM dbo.salary_data s
LEFT JOIN category_job_type_cte c ON s.category = c.category
WHERE jobType IN ('Permanent', 'Contract')
GROUP BY s.category, s.jobType
ORDER BY s.category, s.jobType;
-- OBSERVATION: IN ALMOST ALL CATEGORIES THAT OFFERS BOTH PERMANENT AND CONTRACT JOBS, PERMANENT JOBS TEND TO HAVE HIGHER HIKE.