
WITH RankedEmployees AS (
    SELECT
        Id,
        Name,
        DepartmentId,
        Salary,
        ROW_NUMBER() OVER (
            PARTITION BY DepartmentId
            ORDER BY Salary DESC, Id ASC
        ) AS RowNum
    FROM Employee
)
SELECT Id, Name, DepartmentId, Salary
FROM RankedEmployees
WHERE RowNum <= 3
ORDER BY DepartmentId, Salary DESC, Id ASC;
  