-- =====================================================
-- 1. ROW COUNT VALIDATION
-- =====================================================
SELECT 'raw_members' as table_name,
	count(*) AS total_rows
FROM raw_members

UNION ALL

SELECT 'raw_train',
       COUNT(*)
FROM raw_train

UNION ALL

SELECT 'raw_transactions',
       COUNT(*)
FROM raw_transactions

UNION ALL

SELECT 'user_behavior_features',
       COUNT(*)
FROM user_behavior_features;


-- ===================================================== 
-- 2. BASIC NULL + EMPTY VALUE VALIDATION 
-- =====================================================
-- MEMBERS TABLE 
SELECT SUM(CASE WHEN msno IS NULL OR msno = '' THEN 1 ELSE 0 END) AS null_msno, 
	SUM(CASE WHEN city IS NULL OR city = '' THEN 1 ELSE 0 END) AS null_city, 
    SUM(CASE WHEN bd IS NULL OR bd = '' THEN 1 ELSE 0 END) AS null_bd, 
    SUM(CASE WHEN gender IS NULL OR gender = '' THEN 1 ELSE 0 END) AS null_gender, 
    SUM(CASE WHEN registered_via IS NULL OR registered_via = '' THEN 1 ELSE 0 END) AS null_registered_via 
FROM raw_members;

-- TRAIN TABLE 
SELECT SUM(CASE WHEN msno IS NULL OR msno = '' THEN 1 ELSE 0 END) AS null_msno, 
	SUM(CASE WHEN is_churn IS NULL OR is_churn = '' THEN 1 ELSE 0 END) AS null_is_churn 
FROM raw_train; 

-- TRANSACTIONS TABLE 
SELECT SUM(CASE WHEN msno IS NULL OR msno = '' THEN 1 ELSE 0 END) AS null_msno, 
	SUM(CASE WHEN payment_method_id IS NULL OR payment_method_id = '' THEN 1 ELSE 0 END) AS null_payment_method, 
    SUM(CASE WHEN payment_plan_days IS NULL OR payment_plan_days = '' THEN 1 ELSE 0 END) AS null_plan_days, 
    SUM(CASE WHEN actual_amount_paid IS NULL OR actual_amount_paid = '' THEN 1 ELSE 0 END) AS null_actual_amount 
FROM raw_transactions;

-- USER LOGS TABLE 
SELECT SUM(CASE WHEN msno IS NULL OR msno = '' THEN 1 ELSE 0 END) AS null_msno, 
	SUM(CASE WHEN avg_total_secs IS NULL THEN 1 ELSE 0 END) AS null_avg_total_secs, 
	SUM(CASE WHEN active_days IS NULL THEN 1 ELSE 0 END) AS null_active_days, 
	SUM(CASE WHEN avg_completion_ratio IS NULL THEN 1 ELSE 0 END) AS null_completion_ratio 
FROM user_behavior_features;


-- ===================================================== 
-- 3. CHURN DISTRIBUTION VALIDATION 
-- =====================================================
SELECT 
	is_churn, 
	COUNT(*) AS customer_count, 
    ROUND( 
		COUNT(*) * 100.0 / 
        SUM(COUNT(*)) OVER(), 2 ) AS churn_percentage 
FROM raw_train 
GROUP BY is_churn;


-- ===================================================== 
-- 4. GENDER DISTRIBUTION
-- =====================================================
SELECT gender, 
	COUNT(*) AS customer_count 
FROM raw_members 
GROUP BY gender;


-- ===================================================== 
-- 5. AGE VALIDATION 
-- =====================================================
SELECT
    COUNT(CASE WHEN bd < 0 OR bd > 100 THEN 1 END) AS invalid_age_count,
    MIN(CASE WHEN bd BETWEEN 1 AND 100 THEN bd END) AS min_age,
    MAX(CASE WHEN bd BETWEEN 1 AND 100 THEN bd END) AS max_age,
    ROUND(AVG(CASE WHEN bd BETWEEN 1 AND 100 THEN bd END), 2) AS avg_age
FROM raw_members;


-- ===================================================== 
-- 6. TRANSACTION DATE VALIDATION 
-- =====================================================
SELECT MIN(transaction_date) AS earliest_transaction_date, 
	MAX(transaction_date) AS latest_transaction_date 
FROM raw_transactions;

SELECT MIN(membership_expire_date) AS earliest_expiry_date, 
	MAX(membership_expire_date) AS latest_expiry_date 
FROM raw_transactions;


-- ===================================================== 
-- 7. PAYMENT VALIDATION
-- =====================================================
SELECT COUNT(CASE WHEN actual_amount_paid < 0 THEN 1 END) AS negative_payment_count, 
	COUNT( CASE WHEN actual_amount_paid > (plan_list_price * 2) 
				THEN 1 END ) AS suspicious_payment_count 
FROM raw_transactions;

-- SAMPLE INVALID PAYMENTS 
SELECT * FROM raw_transactions 
WHERE actual_amount_paid < 0 
	OR actual_amount_paid > (plan_list_price * 2) 
LIMIT 20;


-- ===================================================== 
-- 8. AUTO-RENEW VS CANCEL VALIDATION
-- =====================================================
SELECT is_auto_renew, 
	   is_cancel, 
	   COUNT(*) AS transaction_count 
FROM raw_transactions 
GROUP BY is_auto_renew, is_cancel;


-- ===================================================== 
-- 9. USER BEHAVIOR FEATURE VALIDATION 
-- =====================================================
SELECT MIN(avg_total_secs) AS min_avg_secs, 
	   MAX(avg_total_secs) AS max_avg_secs, 
       ROUND(AVG(avg_total_secs), 2) AS avg_avg_secs, 
       
       MIN(active_days) AS min_active_days, 
       MAX(active_days) AS max_active_days, 
       ROUND(AVG(active_days), 2) AS avg_active_days, 
       
       MIN(avg_completion_ratio) AS min_completion_ratio, 
       MAX(avg_completion_ratio) AS max_completion_ratio, 
       
       MIN(total_plays) AS min_total_plays, 
       MAX(total_plays) AS max_total_plays 
FROM user_behavior_features;


-- ===================================================== 
-- 10. REFERENTIAL INTEGRITY VALIDATION 
-- =====================================================
-- TRAIN USERS MISSING IN MEMBERS 
SELECT COUNT(*) AS missing_users_in_members 
FROM raw_train t 
LEFT JOIN raw_members m 
	ON t.msno = m.msno 
WHERE m.msno IS NULL; 

-- TRAIN USERS MISSING IN USER BEHAVIOR FEATURES 
SELECT COUNT(*) AS missing_users_in_behavior_features 
FROM raw_train t 
LEFT JOIN user_behavior_features ubf 
	ON t.msno = ubf.msno 
WHERE ubf.msno IS NULL;


-- ===================================================== 
-- 11. DUPLICATE VALIDATION 
-- ===================================================== 
-- DUPLICATE MEMBERS CHECK
SELECT
    COUNT(*) - COUNT(DISTINCT msno)
    AS duplicate_member_count
FROM raw_members;
    
-- DUPLICATE TRAIN CHECK
SELECT
    COUNT(*) - COUNT(DISTINCT msno)
    AS duplicate_train_count
FROM raw_train;


-- ===================================================== 
-- 12. SAMPLE DATA INSPECTION 
-- ===================================================== 
SELECT * FROM raw_members LIMIT 10; 
SELECT * FROM raw_train LIMIT 10; 
SELECT * FROM raw_transactions LIMIT 10; 
SELECT * FROM user_behavior_features LIMIT 10; 

-- ===================================================== 
-- END OF VALIDATION 
-- =====================================================