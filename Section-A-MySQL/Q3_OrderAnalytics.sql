
WITH OrderAnalytics AS (
    SELECT
        Id,
        CustomerId,
        OrderDate,
        Amount,
        LAG(Amount) OVER (
            PARTITION BY CustomerId
            ORDER BY OrderDate, Id
        ) AS PreviousOrderAmount,
        SUM(Amount) OVER (
            PARTITION BY CustomerId
            ORDER BY OrderDate, Id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningTotal
    FROM Orders
)
SELECT
    Id,
    CustomerId,
    OrderDate,
    Amount AS CurrentOrderAmount,
    PreviousOrderAmount,
    Amount - PreviousOrderAmount AS AmountDifference,
    RunningTotal
FROM OrderAnalytics
ORDER BY CustomerId, OrderDate, Id;
