DROP TABLE IF EXISTS churn_base;

-- =====================================================
-- CREATE MASTER CHURN TABLE
-- =====================================================

CREATE TABLE churn_base AS
SELECT
    -- =========================================
    -- CUSTOMER ID
    -- =========================================

    t.msno,

    -- =========================================
    -- TARGET VARIABLE
    -- =========================================

    t.is_churn,

    -- =========================================
    -- DEMOGRAPHIC FEATURES
    -- =========================================

    COALESCE(m.city, -1) AS city,
    m.age,
    COALESCE(m.gender, 'unknown') AS gender,
    COALESCE(m.registered_via, -1) AS registration_via,
    m.registration_date,
    
    -- =========================================
    -- BEHAVIORAL FEATURES
    -- =========================================

    ubf.avg_total_secs,
    ubf.total_listening_secs,
    ubf.avg_num_unq,
    ubf.active_days,
    ubf.avg_completion_ratio,
    ubf.total_plays,

    -- =========================================
    -- TRANSACTION FEATURES
    -- =========================================

    tf.total_transactions,
    tf.active_transaction_days,
    tf.total_revenue,
    tf.avg_payment_revenue,
    tf.max_payment_revenue,
    tf.min_payment_revenue,
    tf.avg_plan_days,
    tf.max_plan_days,
    tf.min_plan_days,
    tf.cancellation_count,
    tf.cancellation_rate,
    tf.auto_renew_count,
    tf.auto_renew_rate,
    tf.first_transaction_date,
    tf.last_transaction_date,
    tf.first_expiry_date,
    tf.last_expiry_date,
    tf.membership_tenure_days,
    tf.expiry_recency_days,
    tf.suspicious_payment_count,
    tf.suspicious_payment_rate
FROM raw_train t
LEFT JOIN clean_members m
       ON t.msno = m.msno
LEFT JOIN user_behavior_features ubf
       ON t.msno = ubf.msno
LEFT JOIN transaction_features tf
       ON t.msno = tf.msno;
    
   
-- =====================================================
-- VALIDATION
-- =====================================================
SELECT *
FROM churn_base
LIMIT 10;


-- =====================================================
-- ROW COUNT VALIDATION
-- =====================================================
SELECT COUNT(*) AS total_rows
FROM churn_base;


-- =====================================================
-- CHURN DISTRIBUTION VALIDATION
-- =====================================================
SELECT
    is_churn,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),2
    ) AS churn_percentage
FROM churn_base
GROUP BY is_churn;


-- =====================================================
-- NULL ANALYSIS
-- =====================================================
SELECT
    SUM(age IS NULL) AS null_age,
    SUM(gender IS NULL) AS null_gender,
    SUM(avg_total_secs IS NULL)
        AS null_behavior_features,
    SUM(total_transactions IS NULL)
        AS null_transaction_features
FROM churn_base;


-- =====================================================
-- FEATURE RANGE VALIDATION
-- =====================================================
SELECT
    MIN(total_revenue) AS min_revenue,
    MAX(total_revenue) AS max_revenue,
    MIN(active_days) AS min_active_days,
    MAX(active_days) AS max_active_days,
    MIN(membership_tenure_days)
        AS min_tenure,
    MAX(membership_tenure_days)
        AS max_tenure
FROM churn_base;


-- =====================================================
-- END OF FILE
-- =====================================================