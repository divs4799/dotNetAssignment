CREATE NONCLUSTERED INDEX EmailIndex
ON Customers (Email);

CREATE NONCLUSTERED INDEX ProductsIndex
ON Products (ProductName);

CREATE INDEX OrdersIndex
ON OrderDetails (OrderID, ProductID);

CREATE VIEW CustomerOrderSummary AS
SELECT c.CustomerID,c.FirstName,c.LastName,o.OrderID,o.OrderDate
FROM 
    Customers c
INNER JOIN 
    Orders o ON c.CustomerID = o.CustomerID;

CREATE VIEW ProductSalesSummary AS
SELECT Products.ProductID,
Products.ProductName,
OrderDetails.Quantity AS TotalQuantitySold,
(OrderDetails.Quantity*OrderDetails.UnitPrice) AS TotalRevenue
 FROM Products 
 LEFT JOIN OrderDetails on Products.ProductID = OrderDetails.ProductID; 


CREATE VIEW CustomerOrderDetails AS
SELECT Customers.CustomerID,
Customers.FirstName,
Customers.LastName,
Products.ProductName,
OrderDetails.OrderID,
OrderDetails.Quantity,
OrderDetails.UnitPrice
 FROM Customers
 JOIN Orders on Customers.CustomerID = Orders.OrderID
 JOIN OrderDetails on OrderDetails.OrderID = Orders.OrderID
 JOIN Products on OrderDetails.ProductID = Products.ProductID;

-- TAsk 4
SELECT 
    p.ProductName,
    p.Category, -- Assuming there's a Category column
    COUNT(od.OrderID) AS NumberOfOrders
FROM 
    Products p
LEFT JOIN 
    OrderDetails od ON p.ProductID = od.ProductID
GROUP BY 
    p.ProductName, p.Category;


SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    c.Phone,
    o.OrderID,
    o.OrderDate,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice) AS TotalPrice
FROM 
    Customers c
INNER JOIN 
    Orders o ON c.CustomerID = o.CustomerID
INNER JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN 
    Products p ON od.ProductID = p.ProductID;


SELECT 
    DISTINCT c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Email,
    c.Phone
FROM 
    Customers c
INNER JOIN 
    Orders o ON c.CustomerID = o.CustomerID
INNER JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN 
    Products p ON od.ProductID = p.ProductID
WHERE 
    od.UnitPrice > 100;
