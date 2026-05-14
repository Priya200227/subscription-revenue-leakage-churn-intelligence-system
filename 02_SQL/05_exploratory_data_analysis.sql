-- =====================================================
-- 1. OVERALL CHURN RATE
-- =====================================================
SELECT
    is_churn,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 /
		  SUM(COUNT(*)) OVER(),2) AS churn_percentage
FROM churn_base
GROUP BY is_churn;


-- =====================================================
-- 2. CHURN BY GENDER
-- =====================================================
SELECT
    gender,
    COUNT(*) AS total_customers,
    SUM(is_churn) AS churned_customers,
    ROUND(AVG(is_churn) * 100,2) AS churn_rate
FROM churn_base
GROUP BY gender
ORDER BY churn_rate DESC;


-- =====================================================
-- 3. CHURN BY AGE GROUP
-- =====================================================

SELECT
    CASE
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS total_customers,
	SUM(is_churn) AS churned_customers,
	ROUND(AVG(is_churn) * 100,2) AS churn_rate
FROM churn_base
WHERE age IS NOT NULL
GROUP BY age_group
ORDER BY churn_rate DESC;


-- =====================================================
-- 4. CHURN BY REGISTRATION CHANNEL
-- =====================================================

SELECT
    registration_via,
    COUNT(*) AS total_customers,
    ROUND(AVG(is_churn) * 100,2) AS churn_rate
FROM churn_base
GROUP BY registration_via
ORDER BY churn_rate DESC;


-- =====================================================
-- 5. REVENUE VS CHURN
-- =====================================================

SELECT
    is_churn,
    ROUND(AVG(total_revenue), 2)
        AS avg_revenue,
    ROUND(AVG(avg_payment_revenue), 2)
        AS avg_payment,
    ROUND(AVG(total_transactions), 2)
        AS avg_transactions
FROM churn_base
GROUP BY is_churn;


-- =====================================================
-- 6. ENGAGEMENT VS CHURN
-- =====================================================

SELECT
    is_churn,
    ROUND(AVG(avg_total_secs), 2)
        AS avg_listening_time,
    ROUND(AVG(active_days), 2)
        AS avg_active_days,
    ROUND(AVG(total_plays), 2)
        AS avg_total_plays,
    ROUND(AVG(avg_completion_ratio), 4)
        AS avg_completion_ratio
FROM churn_base
GROUP BY is_churn;


-- =====================================================
-- 7. AUTO RENEW ANALYSIS
-- =====================================================

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
GROUP BY renew_segment
ORDER BY churn_rate DESC;


-- =====================================================
-- 8. CANCELLATION ANALYSIS
-- =====================================================

SELECT
    CASE
        WHEN cancellation_rate = 0
        THEN 'No Cancellation'
        WHEN cancellation_rate <= 0.3
        THEN 'Low Cancellation'
        ELSE 'High Cancellation'
    END AS cancellation_segment,
    COUNT(*) AS customers,
    ROUND(AVG(is_churn) * 100,2) AS churn_rate
FROM churn_base
GROUP BY cancellation_segment
ORDER BY churn_rate DESC;


-- =====================================================
-- 9. MEMBERSHIP TENURE ANALYSIS
-- =====================================================

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
GROUP BY tenure_segment
ORDER BY churn_rate DESC;


-- =====================================================
-- 10. HIGH VALUE CUSTOMER ANALYSIS
-- =====================================================

SELECT
    CASE
        WHEN total_revenue >= 5000
        THEN 'High Value'
        WHEN total_revenue >= 1000
        THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_value_segment,
    COUNT(*) AS customers,
    ROUND(AVG(is_churn) * 100,2) AS churn_rate,
    ROUND(AVG(total_revenue),2) AS avg_revenue
FROM churn_base
GROUP BY customer_value_segment
ORDER BY avg_revenue DESC;


-- =====================================================
-- 11. SUSPICIOUS PAYMENT ANALYSIS
-- =====================================================

SELECT
    CASE
        WHEN suspicious_payment_count > 0
        THEN 'Suspicious Payments'
        ELSE 'Normal Payments'
    END AS payment_behavior,
    COUNT(*) AS customers,
    ROUND(AVG(is_churn) * 100,2) AS churn_rate
FROM churn_base
GROUP BY payment_behavior;


-- =====================================================
-- 12. TOP CHURN RISK SEGMENTS
-- =====================================================

SELECT
    gender,
    registration_via,
    ROUND(AVG(is_churn) * 100, 2)AS churn_rate,
    COUNT(*) AS customers
FROM churn_base
GROUP BY gender, registration_via
HAVING COUNT(*) > 1000
ORDER BY churn_rate DESC
LIMIT 20;


-- =====================================================
-- END OF FILE
-- =====================================================
