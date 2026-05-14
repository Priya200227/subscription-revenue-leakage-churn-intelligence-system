SELECT
    is_churn,
    COUNT(*) AS customers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),2 ) AS churn_rate
FROM churn_base
GROUP BY is_churn;