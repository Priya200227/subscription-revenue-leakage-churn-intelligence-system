SELECT
    CASE
        WHEN auto_renew_rate >= 0.8
        THEN 'High Auto Renew'
        WHEN auto_renew_rate >= 0.4
        THEN 'Medium Auto Renew'
        ELSE 'Low Auto Renew'
    END AS renew_segment,
    COUNT(*) AS customers,
    ROUND(AVG(is_churn) * 100,2) AS churn_rate
FROM churn_base
GROUP BY renew_segment;