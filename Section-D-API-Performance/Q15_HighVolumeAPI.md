
CREATE INDEX IX_Products_CreatedAt_Id
ON Products (CreatedAt DESC, Id DESC);

CREATE INDEX IX_Products_Category_CreatedAt_Id
ON Products (Category, CreatedAt DESC, Id DESC);

CREATE INDEX IX_Products_Price_Id
ON Products (Price, Id);

SELECT Id, Name, Category, Price, CreatedAt
FROM Products
WHERE Category = 'Electronics'
ORDER BY CreatedAt DESC, Id DESC
LIMIT 20;

SELECT Id, Name, Category, Price, CreatedAt
FROM Products
WHERE Category = 'Electronics'
  AND (
      CreatedAt < '2026-10-20 12:00:00'
      OR (
          CreatedAt = '2026-10-20 12:00:00'
          AND Id < 50000
      )
  )
ORDER BY CreatedAt DESC, Id DESC
LIMIT 20;

EXPLAIN ANALYZE
SELECT Id, Name, Category, Price, CreatedAt
FROM Products
WHERE Category = 'Electronics'
ORDER BY CreatedAt DESC, Id DESC
LIMIT 20;

CREATE FULLTEXT INDEX IX_Products_Name_FullText
ON Products (Name);

SELECT Id, Name, Category, Price, CreatedAt
FROM Products
WHERE MATCH(Name) AGAINST ('smartphone' IN NATURAL LANGUAGE MODE)
ORDER BY CreatedAt DESC, Id DESC
LIMIT 20;
  