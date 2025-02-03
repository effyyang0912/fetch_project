
""" What are the top 5 brands by receipts scanned among users 21 and over? """

SELECT 
    p.BRAND, 
    COUNT(t.RECEIPT_ID) AS receipts_scanned
FROM Transactions t
JOIN Users u ON t.USER_ID = u.ID
JOIN Products p ON t.BARCODE = p.BARCODE
WHERE TIMESTAMPDIFF(YEAR, u.BIRTH_DATE, CURDATE()) >= 21
GROUP BY p.BRAND
ORDER BY receipts_scanned DESC
LIMIT 5

"""What are the top 5 brands by sales among users that have had their account for at least six months?"""

SELECT p.BRAND, SUM(t.FINAL_SAL)
FROM Transactions t
JOIN Users u ON t.USER_ID = u.ID
JOIN Products p ON t.BARCODE = p.BARCODE
WHERE TIMESTAMPDIFF(MONTH, u.CREATED_DATE, CURDATE()) >= 6
GROUP BY p.BRAND
ORDER BY total_sales DESC
LIMIT 5

"What is the percentage of sales in the Health & Wellness category by generation? Based on my research, 
I classified generations into five categories based on users birth years."

SELECT CASE WHEN Date_trunc(year, u.BIRTH_DATE) < 1946 THEN 'Traditionalists'
            WHEN Date_trunc(year, u.BIRTH_DATE) BETWEEN 1946 AND 1964 THEN 'Baby Boomers'
            WHEN Date_trunc(year, u.BIRTH_DATE) BETWEEN 1965 AND 1980 THEN 'Generation X'
            WHEN Date_trunc(year, u.BIRTH_DATE) BETWEEN 1981 AND 1996 THEN 'Millennials'
            ELSE 'Generation Z' END AS Generation,
        round((SUM(t.FINAL_SALE) * 100) / (SELECT SUM(FINAL_SALE) FROM Transactions),2) AS percentage_of_total_sales
FROM Transactions t
JOIN Users u ON t.USER_ID = u.ID
JOIN Products p ON t.BARCODE = p.BARCODE
WHERE p.CATEGORY_1 = 'Health & Wellness'
GROUP BY Generation

"Open ended question： Who are Fetch power users?
#According to the Pareto Principle, 20% of users typically generate 80% of the revenue.
#To identify power users, we filter for those whose total spending places them in the top 20%.
#Additionally, a power user should demonstrate consistent engagement.So I include users who have made transactions 
# on more than 1 day."

WITH Spending AS (
    SELECT t.USER_ID, SUM(t.FINAL_SALE) AS total_spent, COUNT(DISTINCT DATE(t.PURCHASE_DATE)) AS transaction_days
    FROM Transactions t
    GROUP BY t.USER_ID
),
Threshold AS (
    SELECT PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY total_spent) AS top_20_spending
    FROM UserSpending
)
SELECT u.ID AS User_ID, u.STATE, u.LANGUAGE, us.total_spent, us.transaction_days
FROM Spending us
JOIN Users u ON us.USER_ID = u.ID
WHERE us.total_spent >= (SELECT top_20_spending FROM Threshold)
AND us.transaction_days > 1
ORDER BY us.total_spent DESC
"""


