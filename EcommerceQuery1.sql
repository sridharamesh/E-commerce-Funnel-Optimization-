use Ecommerce

select * from dbo.data;
--1. max Quantity sold by each country 
select max(Quantity) as Quantity , Country
from dbo.data 
group by Country

--2. Total Revenue
SELECT 
    Round(SUM(Quantity * UnitPrice),2) AS TotalRevenue
FROM 
    dbo.data;

--3 Revenue By country

SELECT 
    Country, 
    SUM(Quantity * UnitPrice) AS Revenue
FROM 
    dbo.data
GROUP BY 
    Country
ORDER BY 
    Revenue DESC;

-- 4. Top Selling Products

SELECT Top 10
    StockCode, 
    Description, 
    SUM(Quantity) AS TotalQuantitySold
FROM 
    dbo.data
GROUP BY 
    StockCode, 
    Description
ORDER BY 
    TotalQuantitySold DESC

--5 Average order value

SELECT 
    CustomerID, 
    ROUND(AVG(Quantity * UnitPrice),2) AS AverageOrderValue
FROM 
    dbo.data
GROUP BY 
    CustomerID
ORDER BY 
    AverageOrderValue DESC;

--6. Number of orders by customers
SELECT 
    CustomerID, 
    COUNT(DISTINCT InvoiceNo) AS NumberOfOrders
FROM 
    dbo.data
WHERE 
    CustomerID IS NOT NULL
GROUP BY 
    CustomerID
ORDER BY 
    NumberOfOrders DESC;


--7. Monthly Revenue
SELECT 
    FORMAT(InvoiceDate, 'MMMM yyyy') AS Month, 
    ROUND(SUM(Quantity * UnitPrice),2) AS Revenue
FROM 
    dbo.data
GROUP BY 
    FORMAT(InvoiceDate, 'MMMM yyyy')
ORDER BY 
    MIN(InvoiceDate);


--8.Customer Retention Analysis

WITH FirstPurchase AS (
    SELECT 
        CustomerID, 
        MIN(InvoiceDate) AS FirstPurchaseDate
    FROM 
        dbo.data
    GROUP BY 
        CustomerID
), LastPurchase AS (
    SELECT 
        CustomerID, 
        MAX(InvoiceDate) AS LastPurchaseDate
    FROM 
        dbo.data
    GROUP BY 
        CustomerID
)
SELECT 
    f.CustomerID, 
    f.FirstPurchaseDate, 
    l.LastPurchaseDate, 
    DATEDIFF(day, f.FirstPurchaseDate, l.LastPurchaseDate) AS RetentionDays
FROM 
    FirstPurchase f
JOIN 
    LastPurchase l ON f.CustomerID = l.CustomerID
ORDER BY 
    RetentionDays DESC;

--9. Top Customers By revenue

SELECT TOP 10
    CustomerID, 
    Round(SUM(Quantity * UnitPrice),2) AS TotalRevenue
FROM 
    dbo.data
WHERE 
    CustomerID IS NOT NULL
GROUP BY 
    CustomerID
ORDER BY 
    TotalRevenue DESC;

--10.Revenue Contribution by Product Category
SELECT 
    Description, 
    SUM(Quantity * UnitPrice) AS Revenue
FROM 
    dbo.data
GROUP BY 
    Description
ORDER BY 
    Revenue DESC;

--11. Daily Sales trend
SELECT
    CONVERT(date, InvoiceDate) AS Date,
    SUM(Quantity * UnitPrice) AS DailyRevenue
FROM
    dbo.data
GROUP BY
    CONVERT(date, InvoiceDate)
ORDER BY
    CONVERT(date, InvoiceDate);

--12. Cohorts Based on First Purchase Month:
WITH FirstPurchase AS (
    SELECT 
        CustomerID, 
        DATEADD(month, DATEDIFF(month, 0, MIN(InvoiceDate)), 0) AS CohortMonth
    FROM 
        dbo.data
    GROUP BY 
        CustomerID
)
SELECT 
    CustomerID, 
    CohortMonth

--13.Join Cohorts with Transactions
WITH FirstPurchase AS (
    SELECT 
        CustomerID, 
        DATEADD(month, DATEDIFF(month, 0, InvoiceDate), 0) AS CohortMonth
    FROM 
        dbo.data
    GROUP BY 
        CustomerID, 
        DATEADD(month, DATEDIFF(month, 0, InvoiceDate), 0)
), Transactions AS (
    SELECT 
        s.CustomerID, 
        DATEADD(month, DATEDIFF(month, 0, s.InvoiceDate), 0) AS TransactionMonth, 
        SUM(s.Quantity * s.UnitPrice) AS Revenue
    FROM 
        dbo.data s
    GROUP BY 
        s.CustomerID, 
        DATEADD(month, DATEDIFF(month, 0, s.InvoiceDate), 0)
)
SELECT 
    f.CohortMonth, 
    t.TransactionMonth, 
    COUNT(DISTINCT f.CustomerID) AS NumberOfCustomers, 
    SUM(t.Revenue) AS TotalRevenue
FROM 
    FirstPurchase f
JOIN 
    Transactions t ON f.CustomerID = t.CustomerID AND f.CohortMonth = t.TransactionMonth
GROUP BY 
    f.CohortMonth, 
    t.TransactionMonth
ORDER BY 
    f.CohortMonth, 
    t.TransactionMonth;














