
WITH LoginDates AS (
    SELECT DISTINCT
        UserId,
        DATE(LoginDate) AS LoginDay
    FROM UserLogin
),
DateGroups AS (
    SELECT
        UserId,
        LoginDay,
        DATE_SUB(
            LoginDay,
            INTERVAL ROW_NUMBER() OVER (
                PARTITION BY UserId
                ORDER BY LoginDay
            ) DAY
        ) AS GroupDate
    FROM LoginDates
),
Streaks AS (
    SELECT
        UserId,
        MIN(LoginDay) AS StartDate,
        MAX(LoginDay) AS EndDate
    FROM DateGroups
    GROUP BY UserId, GroupDate
    HAVING COUNT(*) >= 7
)
SELECT UserId, StartDate, EndDate
FROM Streaks
ORDER BY UserId, StartDate;
