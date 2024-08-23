-- Query to clean and normalize the engagement_data table
-- Replaces "Socialmedia" with "Social Media" and then converts all ContentType values to uppercase
-- Extracts the Views part from the ViewsClicksCombined column by taking the substring before the '-' character
-- Extracts the Clicks part from the ViewsClicksCombined column by taking the substring after the '-' character
-- Converts and formats the date as dd.mm.yy

SELECT
	EngagementID,
	ContentID,
	CampaignID,
	ProductID,
	UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) AS ContentType,
	LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) - 1) AS Views,
	RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS Clicks,
	Likes,
	FORMAT(CONVERT(DATE, EngagementDate), 'dd.MM.yyyy') AS EngagementDate 

FROM dbo.engagement_data

-- Filter out Newsletter from Content Type as these are not relevant for analysis
WHERE 
	ContentType != 'Newsletter'; 
