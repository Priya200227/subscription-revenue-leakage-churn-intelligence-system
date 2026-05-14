-- =====================================================
-- DROP EXISTING TABLE
-- =====================================================

DROP TABLE IF EXISTS transaction_features;

-- =====================================================
-- CREATE CUSTOMER-LEVEL TRANSACTION FEATURES
-- =====================================================

CREATE TABLE transaction_features AS
SELECT
	msno,
    -- =========================================
    -- TRANSACTION ACTIVITY
    -- =========================================
    
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT transaction_date)
        AS active_transaction_days,
        
	-- =========================================
    -- REVENUE FEATURES
    -- =========================================
    
    ROUND(SUM(actual_amount_paid),2) AS total_revenue,
    ROUND(AVG(actual_amount_paid),2) AS avg_payment_revenue,
    ROUND(MAX(actual_amount_paid),2) AS MAX_payment_revenue,
    ROUND(MIN(actual_amount_paid),2) AS MIN_payment_revenue,

    -- =========================================
    -- SUBSCRIPTION FEATURES
    -- =========================================
    
    ROUND(AVG(payment_plan_days),2) AS avg_plan_days,
    MIN(payment_plan_days) AS min_plan_days,
    MAX(payment_plan_days) AS max_plan_days,
    
	-- =========================================
    -- RENEWAL & CANCELLATION FEATURES
    -- =========================================
    
    SUM(is_cancel) AS cancellation_count,
    ROUND(AVG(is_cancel),4) AS cancellation_rate,
    SUM(is_auto_renew) AS auto_renew_count,
    ROUND(SUM(is_auto_renew),4) AS auto_renew_rate,
    
	-- =========================================
    -- DATE FEATURES
    -- =========================================
        
        MIN(transaction_date)
        AS first_transaction_date,

    MAX(transaction_date)
        AS last_transaction_date,

    MIN(membership_expire_date)
        AS first_expiry_date,

    MAX(membership_expire_date)
        AS last_expiry_date,
        
	-- =========================================
    -- MEMBERSHIP TENURE
    -- =========================================  
    
    GREATEST(
    DATEDIFF(
        MAX(membership_expire_date),
        MIN(transaction_date)
    ),
    0
) AS membership_tenure_days,
    
	-- =========================================
    -- RECENCY FEATURE
    -- =========================================
    
    DATEDIFF(
        '2017-03-31',
        MAX(membership_expire_date)
    ) AS expiry_recency_days,
    
    -- =========================================
    -- PAYMENT ANOMALY FEATURE
    -- =========================================
    
     SUM(suspicious_payment_flag)
        AS suspicious_payment_count,

    ROUND(AVG(suspicious_payment_flag), 4)
        AS suspicious_payment_rate
FROM clean_transactions  
WHERE membership_expire_date IS NOT NULL
GROUP BY msno;      
 

-- =====================================================
-- VALIDATION
-- =====================================================

SELECT *
FROM transaction_features
LIMIT 10;

-- =====================================================
-- FEATURE VALIDATION
-- =====================================================

SELECT
    MIN(total_transactions)
        AS min_transactions,
    MAX(total_transactions)
        AS max_transactions,
    AVG(total_transactions)
        AS avg_transactions,
    MIN(total_revenue)
        AS min_revenue,
    MAX(total_revenue)
        AS max_revenue,
    AVG(total_revenue)
        AS avg_revenue
FROM transaction_features;


-- =====================================================
-- CANCELLATION VALIDATION
-- =====================================================

SELECT
    MIN(cancellation_rate)
        AS min_cancel_rate,
    MAX(cancellation_rate)
        AS max_cancel_rate,
    AVG(cancellation_rate)
        AS avg_cancel_rate
FROM transaction_features;


-- =====================================================
-- AUTO RENEW VALIDATION
-- =====================================================

SELECT
    MIN(auto_renew_rate)
        AS min_renew_rate,
    MAX(auto_renew_rate)
        AS max_renew_rate,
    AVG(auto_renew_rate)
        AS avg_renew_rate
FROM transaction_features;


-- =====================================================
-- TENURE VALIDATION
-- =====================================================

SELECT
    MIN(membership_tenure_days)
        AS min_tenure,
    MAX(membership_tenure_days)
        AS max_tenure,
    AVG(membership_tenure_days)
        AS avg_tenure
FROM transaction_features;


-- =====================================================
-- END OF FILE
-- =====================================================
