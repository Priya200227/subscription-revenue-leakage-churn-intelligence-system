SELECT
    CASE
        WHEN membership_tenure_days < 30
        THEN 'New Users'
        WHEN membership_tenure_days < 180
        THEN 'Growing Users'
        WHEN membership_tenure_days < 365
        THEN 'Established Users'
        ELSE 'Long-Term Users'
    END AS tenure_segment,
    COUNT(*) AS customers,
    ROUND(AVG(is_churn) * 100,2) AS churn_rate
FROM churn_base
GROUP BY tenure_segment;