
DELIMITER $$

 PROCEDURE SearchCustomers(
    IN p_CustomerName VARCHAR(100),
    IN p_DateFrom DATE,
    IN p_DateTo DATE,
    IN p_MinAmount DECIMAL(12,2),
    IN p_MaxAmount DECIMAL(12,2),
    IN p_Status VARCHAR(30),
    IN p_Country VARCHAR(100),
    IN p_City VARCHAR(100),
    IN p_SortBy VARCHAR(30),
    IN p_SortDirection VARCHAR(4),
    IN p_Page INT,
    IN p_PageSize INT
)
BEGIN
    DECLARE v_SortBy VARCHAR(30);
    DECLARE v_SortDirection VARCHAR(4);
    DECLARE v_Offset INT;

    SET v_SortBy = CASE
        WHEN p_SortBy IN ('Id', 'CustomerName', 'CreatedAt', 'TotalAmount', 'Status')
        THEN p_SortBy
        ELSE 'Id'
    END;

    SET v_SortDirection = CASE
        WHEN UPPER(p_SortDirection) = 'ASC' THEN 'ASC'
        ELSE 'DESC'
    END;

    SET p_Page = GREATEST(COALESCE(p_Page, 1), 1);
    SET p_PageSize = LEAST(GREATEST(COALESCE(p_PageSize, 20), 1), 100);
    SET v_Offset = (p_Page - 1) * p_PageSize;

    SET @whereClause = '
        FROM Customers
        WHERE (? IS NULL OR CustomerName LIKE CONCAT(''%'', ?, ''%''))
          AND (? IS NULL OR CreatedAt >= ?)
          AND (? IS NULL OR CreatedAt < DATE_ADD(?, INTERVAL 1 DAY))
          AND (? IS NULL OR TotalAmount >= ?)
          AND (? IS NULL OR TotalAmount <= ?)
          AND (? IS NULL OR Status = ?)
          AND (? IS NULL OR Country = ?)
          AND (? IS NULL OR City = ?)';

    SET @customerName = p_CustomerName;
    SET @dateFrom = p_DateFrom;
    SET @dateTo = p_DateTo;
    SET @minAmount = p_MinAmount;
    SET @maxAmount = p_MaxAmount;
    SET @status = p_Status;
    SET @country = p_Country;
    SET @city = p_City;

    SET @countSql = CONCAT('SELECT COUNT(*) AS TotalCount ', @whereClause);

    PREPARE countStmt FROM @countSql;
    EXECUTE countStmt USING
        @customerName, @customerName,
        @dateFrom, @dateFrom,
        @dateTo, @dateTo,
        @minAmount, @minAmount,
        @maxAmount, @maxAmount,
        @status, @status,
        @country, @country,
        @city, @city;
    DEALLOCATE PREPARE countStmt;

    SET @dataSql = CONCAT(
        'SELECT Id, CustomerName, CreatedAt, TotalAmount, Status, Country, City ',
        @whereClause,
        ' ORDER BY ', v_SortBy, ' ', v_SortDirection,
        ', Id ASC LIMIT ? OFFSET ?'
    );

    SET @pageSize = p_PageSize;
    SET @offset = v_Offset;

    PREPARE dataStmt FROM @dataSql;
    EXECUTE dataStmt USING
        @customerName, @customerName,
        @dateFrom, @dateFrom,
        @dateTo, @dateTo,
        @minAmount, @minAmount,
        @maxAmount, @maxAmount,
        @status, @status,
        @country, @country,
        @city, @city,
        @pageSize, @offset;
    DEALLOCATE PREPARE dataStmt;
END$$

DELIMITER ;
