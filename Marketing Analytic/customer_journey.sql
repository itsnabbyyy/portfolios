-- Create CTE to identify and tag duplicate records
-- Use row_num to assign a unique row number to each record within its partition

WITH DuplicateRecords AS (
	SELECT
		JourneyID,
		CustomerID,
		ProductID,
		VisitDate,
		Stage,
		Action,
		Duration,
		ROW_NUMBER() OVER (
			-- PARTITION BY groups the rows based on the specified columns that should be unique
			PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action
			-- ORDER BY defines how to order the rows within each partition (usually by unique identifier like JourneyID)
			ORDER BY JourneyID
		) AS row_num
	
	FROM dbo.customer_journey
)

-- Select all records from the CTE where row_num > 1 and the query shows there's a total of 79 duplicate entries 

SELECT *
FROM DuplicateRecords
WHERE row_num > 1 -- Filter out the first occurence (row_num = 1) and only shows the duplicates (row_num > 1)
ORDER BY JourneyID


-- Outer query selects the final cleaned and standardized data 

SELECT 
	JourneyID,
	CustomerID,
	ProductID,
	VisitDate,
	Stage,
	Action,
	COALESCE(Duration, avg_duration) AS Duration -- Replaces the null values in duration with the average duration for the corresponding dates

FROM 
	(
		-- Subquery to process and clean data
		SELECT
			JourneyID,
			CustomerID,
			ProductID, 
			VisitDate,
			UPPER(Stage) AS Stage, -- Converts Stage values to uppercase for consistency in data analysis
			Action,
			Duration,
			AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration, -- Calculates the average duration for each date using only numeric values
			ROW_NUMBER() OVER (
				PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action 
				ORDER BY JourneyID
			) AS row_num 
		FROM dbo.customer_journey
	) AS subquery 

WHERE row_num = 1;  -- Keeps only the first occurrence of each duplicate group identified in the subquery