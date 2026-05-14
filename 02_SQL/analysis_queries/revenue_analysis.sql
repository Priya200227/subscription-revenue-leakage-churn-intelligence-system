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