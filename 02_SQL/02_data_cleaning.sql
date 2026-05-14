-- =====================================================
-- 1. CLEAN MEMBERS TABLE
-- =====================================================

DROP TABLE IF EXISTS cleaned_members;

CREATE TABLE clean_members AS 
	SELECT 
			msno,
            city,
			-- =========================================
			-- HANDLE INVALID AGES
			-- =========================================
			CASE 
				WHEN bd BETWEEN 1 AND 100
                THEN bd
                ELSE NULL
			END AS age,
			-- =========================================
			-- HANDLE MISSING GENDER
			-- =========================================
            CASE 
				WHEN gender IS NULL OR TRIM(gender) = ''
                THEN 'unknown'
                ELSE LOWER(TRIM(gender))
			END AS gender,
             registered_via,
			-- =========================================
			-- CLEAN REGISTRATION DATE
			-- =========================================
            STR_TO_DATE(
             registration_init_time, '%Y%m%d') AS registration_date
FROM raw_members;



-- =====================================================
-- 2. CLEAN TRANSACTIONS TABLE
-- =====================================================
DROP TABLE IF EXISTS clean_transactions;

CREATE TABLE clean_transactions AS 
SELECT
    msno,
    payment_method_id,
    payment_plan_days,
    plan_list_price,
    actual_amount_paid,
	is_auto_renew,
    is_cancel,
    -- =========================================
    -- FIX TRANSACTION DATE FORMAT
    -- =========================================
    STR_TO_DATE(
        transaction_date,
        '%Y%m%d'
    ) AS transaction_date,
	-- =========================================
    -- FIX MEMBERSHIP EXPIRY DATE FORMAT
    -- =========================================
    CASE
        WHEN membership_expire_date = 19700101
        THEN NULL
		ELSE STR_TO_DATE(
            membership_expire_date,
            '%Y%m%d'
        )
    END AS membership_expire_date,
    -- =========================================
    -- SUSPICIOUS PAYMENT FLAG
    -- =========================================
    CASE
        WHEN actual_amount_paid > (plan_list_price * 2)
        THEN 1
        ELSE 0
    END AS suspicious_payment_flag
FROM raw_transactions;


-- =====================================================
-- 3. VALIDATE CLEANED TABLES
-- =====================================================

-- CLEAN MEMBERS CHECK
SELECT *
FROM clean_members
LIMIT 10;

-- CLEAN TRANSACTIONS CHECK
SELECT *
FROM clean_transactions
LIMIT 10;


-- =====================================================
-- 4. VALIDATE DATE CONVERSION
-- =====================================================
SELECT
    MIN(transaction_date) AS earliest_transaction,
    MAX(transaction_date) AS latest_transaction
FROM clean_transactions;


SELECT
    MIN(membership_expire_date) AS earliest_expiry,
    MAX(membership_expire_date) AS latest_expiry
FROM clean_transactions;


-- =====================================================
-- 5. VALIDATE GENDER CLEANING
-- =====================================================

SELECT
    gender,
    COUNT(*) AS customer_count
FROM clean_members
GROUP BY gender;


-- =====================================================
-- 6. VALIDATE AGE CLEANING
-- =====================================================

SELECT
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    AVG(age) AS avg_age
FROM clean_members;



-- =====================================================
-- 7. VALIDATE SUSPICIOUS PAYMENTS
-- =====================================================

SELECT
    suspicious_payment_flag,
    COUNT(*) AS transaction_count
FROM clean_transactions
GROUP BY suspicious_payment_flag;


-- =====================================================
-- END OF CLEANING
-- =====================================================