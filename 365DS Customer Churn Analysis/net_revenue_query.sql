SET sql_mode = '';
SELECT 
	p.purchase_id, 
	p.student_id,
    CASE
		WHEN p.subscription_type = 0 THEN 'monthly'
        WHEN p.subscription_type = 2 THEN 'annual'
        WHEN p.subscription_type = 3 THEN 'lifetime'
    END as subscription_type,
    p.refund_id,
    p.refunded_date,
    min(p.purchase_date) AS 'first_purchase_date',
    p2.purchase_date AS 'current_purchase_date',
    p.price,
    CASE
		WHEN min(p.purchase_date) = p2.purchase_date THEN 'new'
        ELSE 'recurring'
    END as 'revenue_type',
    CASE 
		WHEN p.refunded_date IS NULL THEN 'revenue'
        ELSE 'refund'
	END as refunds,
    s.student_country 
FROM purchases AS p
INNER JOIN 
	purchases AS p2
USING (student_id)
INNER JOIN 
	students AS s
USING (student_id)
GROUP BY p.purchase_id
ORDER BY p.purchase_date