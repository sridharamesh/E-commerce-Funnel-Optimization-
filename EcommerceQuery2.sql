use Ecommerce;
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
), CohortData AS (
    SELECT 
        f.CohortMonth, 
        t.TransactionMonth, 
        COUNT(DISTINCT t.CustomerID) AS NumberOfCustomers, 
        SUM(t.Revenue) AS TotalRevenue
    FROM 
        FirstPurchase f
    JOIN 
        Transactions t ON f.CustomerID = t.CustomerID AND f.CohortMonth = t.TransactionMonth
    GROUP BY 
        f.CohortMonth, 
        t.TransactionMonth
)
SELECT 
    CohortMonth, 
    TransactionMonth, 
    NumberOfCustomers, 
    TotalRevenue,
    ROUND((NumberOfCustomers * 1.0 / 
        MAX(NumberOfCustomers) OVER (PARTITION BY CohortMonth)) * 100, 2) AS RetentionRate
FROM 
    CohortData
ORDER BY 
    CohortMonth, 
    TransactionMonth;
