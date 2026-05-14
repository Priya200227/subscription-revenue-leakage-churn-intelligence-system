-- =====================================================
-- LOADING THE DATASETS
-- =====================================================
SHOW PROCESSLIST;

SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL wait_timeout = 28800;
SET GLOBAL interactive_timeout = 28800;
SET GLOBAL max_allowed_packet = 1073741824;


-- LOAD MEMBERS DATA
CREATE TABLE raw_members (
    msno VARCHAR(100),
    city VARCHAR(20),
    bd VARCHAR(20),
    gender VARCHAR(20),
    registered_via VARCHAR(20),
    registration_init_time VARCHAR(20)
);

TRUNCATE TABLE raw_members;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/members_v3.csv'
INTO TABLE raw_members
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DROP TABLE raw_members;

SELECT COUNT(*) FROM raw_members;
SELECT * 
FROM raw_members
LIMIT 10;
SELECT COUNT(DISTINCT msno)
FROM raw_members;


-- LOAD TRAIN DATA
CREATE TABLE IF NOT EXISTS raw_train (
    msno VARCHAR(50),
    is_churn TINYINT
);

TRUNCATE TABLE raw_train;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/train.csv'
INTO TABLE raw_train
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM raw_train;


-- LOAD TRANSACTIONS DATA
CREATE TABLE IF NOT EXISTS raw_transactions (
    msno VARCHAR(50),
    payment_method_id INT,
    payment_plan_days INT,
    plan_list_price DECIMAL(10,2),
    actual_amount_paid DECIMAL(10,2),
    is_auto_renew TINYINT,
    transaction_date VARCHAR(20),
    membership_expire_date VARCHAR(20),
    is_cancel TINYINT
);
TRUNCATE TABLE raw_transactions;
SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET GLOBAL max_allowed_packet = 1073741824;

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE raw_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE raw_transactions;

SELECT COUNT(*)
FROM raw_transactions;

SELECT COUNT(DISTINCT msno)
FROM raw_transactions;
 
SELECT MIN(transaction_date),
       MAX(transaction_date)
FROM raw_transactions;


-- LOAD USER_LOGS DATA

CREATE TABLE user_behavior_features (
    msno VARCHAR(50),
    avg_total_secs DOUBLE,
    total_listening_secs DOUBLE,
    avg_num_unq DOUBLE,
    active_days INT,
    avg_completion_ratio DOUBLE,
    total_plays BIGINT
);

TRUNCATE TABLE user_behavior_features;

LOAD DATA LOCAL INFILE 'C:/kkbox_data/user_behavior_features.csv'
INTO TABLE user_behavior_features
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT *
FROM user_behavior_features
LIMIT 10;

SELECT
    MIN(avg_total_secs),
    MAX(avg_total_secs),
    AVG(avg_total_secs)
FROM user_behavior_features;

SELECT
    MIN(avg_completion_ratio),
    MAX(avg_completion_ratio)
FROM user_behavior_features;

DROP TABLE user_behavior_features;

SHOW WARNINGS;