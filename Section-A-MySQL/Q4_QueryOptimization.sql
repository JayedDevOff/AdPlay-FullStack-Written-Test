
SELECT
    o.*,
    c.*,
    p.*
FROM Orders o
JOIN Customers c ON c.Id = o.CustomerId
JOIN Products p ON p.Id = o.ProductId
WHERE o.OrderDate >= '2026-06-01'
  AND o.OrderDate < '2026-07-01'
  AND c.Country = 'BD'
ORDER BY o.OrderDate DESC;




CREATE INDEX idx_orders_orderdate_customer
ON Orders (OrderDate, CustomerId);

CREATE INDEX idx_customers_country_id
ON Customers (Country, Id);

CREATE INDEX idx_orders_product
ON Orders (ProductId);
