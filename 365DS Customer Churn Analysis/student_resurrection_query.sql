SET sql_mode = '';
SELECT 
    s1.cancelled_date AS 'original canceled date',
    s2.cancelled_date AS 'resurrected canceled date',
    s1.created_date AS 'original created date',
    s2.created_date AS 'resurrected created date',
    s1.end_date AS 'original end date',
    s2.end_date AS 'resurrected end date',
    s1.next_charge_date AS 'original next charge date',
    s2.next_charge_date AS 'resurrected next charge date',
    CASE
		WHEN s1.subscription_type = 0 THEN 'monthly'
        WHEN s1.subscription_type = 2 THEN 'annually'
        WHEN s1.subscription_type = 3 THEN 'lifetime'
	END AS 'original plan',
    CASE
		WHEN s2.subscription_type = 0 THEN 'monthly'
        WHEN s2.subscription_type = 2 THEN 'annually'
        WHEN s2.subscription_type = 3 THEN 'lifetime'
	END AS 'resurrected plan',
    datediff(cast(s2.created_date AS date), cast(s1.end_date AS date)) AS 'days to resurrection',
    s1.student_id,
    s2.subscription_id AS 'original subscription ID',
    s2.subscription_id AS 'resurrected subscription ID'
FROM
    customer_churn.subscriptions AS s1
JOIN 
	customer_churn.subscriptions AS s2 ON (s1.student_id = s2.student_id AND s1.subscription_id != s2.subscription_id
										  AND s2.subscription_id > s1.subscription_id AND s2.created_date > s1.created_date)
WHERE 
	s1.state = 3
    AND datediff(cast(s2.created_date AS date), cast(s1.end_date AS date)) > 1
GROUP BY s1.student_id;