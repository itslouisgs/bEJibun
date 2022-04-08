USE bEJibun

--1
SELECT ItemName, ItemPrice, SUM(PurchaseQuantity) AS [Item Total]
FROM MsItem mi, PurchaseTransactionDetail ptd, PurchaseTransactionHeader pth
WHERE mi.ItemID = ptd.ItemID AND ptd.PurchaseID = pth.PurchaseID AND ArrivalDate > GETDATE()
GROUP BY ItemName, ItemPrice
HAVING SUM(PurchaseQuantity) > 100
ORDER BY [Item Total] DESC

--2
SELECT VendorName,
SUBSTRING(VendorEmail, CHARINDEX('@', VendorEmail) + 1, LEN(VendorEmail) - CHARINDEX('@', VendorEmail) + 1) AS 'Domain Name',
AVG(PurchaseQuantity) AS 'Average Purchased Item'
FROM PurchaseTransactionHeader ph
JOIN MsVendor v ON ph.VendorID = v.VendorID
JOIN PurchaseTransactionDetail pd ON ph.PurchaseID = pd.PurchaseID
WHERE VendorAddress LIKE '%Food Street' AND VendorEmail NOT LIKE '%gmail.com'
GROUP BY VendorName, VendorEmail

--3
SELECT DATENAME(month, SalesDate) AS Month,
MIN(SalesQuantity) AS 'Minimum Quantity Sold',
MAX(SalesQuantity) AS 'Maximum Quantity Sold'
FROM SalesTransactionHeader sh
JOIN SalesTransactionDetail sd ON sh.SalesID = sd.SalesID
JOIN MsItem i ON i.ItemID = sd.ItemID
JOIN MsItemType it ON it.ItemTypeID = i.ItemTypeID
WHERE YEAR(SalesDate) = 2019 AND ItemTypeName NOT IN ('Food', 'Drink')
GROUP BY DATENAME(month, SalesDate)

--4
SELECT STUFF(sf.StaffID, 1, 2, 'Staff ') AS 'Staff Number',
StaffName, 
'Rp. ' + CONVERT(VARCHAR, StaffSalary) AS Salary,
sCount AS 'Sales Count',
sQ AS 'Average Sales Quantity'
FROM MsStaff sf
JOIN (SELECT StaffID, COUNT(*) AS [sCount] FROM
 SalesTransactionHeader GROUP BY StaffID) x ON x.StaffID = sf.StaffID
JOIN SalesTransactionHeader sh ON sh.StaffID = sf.StaffID
JOIN (SELECT SalesID, AVG(SalesQuantity) AS [sQ] FROM SalesTransactionDetail GROUP BY SalesID) y ON y.SalesID = sh.SalesID
JOIN MsCustomer cs ON sh.CustomerID = cs.CustomerID
WHERE sf.StaffGender NOT LIKE cs.CustomerGender AND MONTH(sh.SalesDate) = 2

--5
SELECT LEFT(CustomerName, 1) + RIGHT(CustomerName, 1) AS 'Customer Initial',
CONVERT(VARCHAR, SalesDate, 107) AS 'Transaction Date',
SalesQuantity AS Quantity
FROM MsCustomer c
JOIN SalesTransactionHeader sh ON sh.CustomerID = c.CustomerID
JOIN SalesTransactionDetail sd ON sd.SalesID = sh.SalesID,
(
	SELECT AVG(SalesQuantity) AS Average
	FROM SalesTransactionDetail td
) AS x
WHERE CustomerGender = 'Female' AND SalesQuantity > x.Average

--6
SELECT LOWER(MsVendor.VendorID) AS 'Display ID', VendorName, STUFF(VendorPhone, 1, 1, '+62') AS 'Phone Number'  
FROM MsVendor
JOIN PurchaseTransactionHeader ON MsVendor.VendorID = PurchaseTransactionHeader.VendorID
JOIN PurchaseTransactionDetail ON PurchaseTransactionHeader.PurchaseID = PurchaseTransactionDetail.PurchaseID,
(
 SELECT MIN(PurchaseQuantity) AS minpq
 FROM PurchaseTransactionDetail
) AS A
WHERE PurchaseTransactionDetail.PurchaseQuantity > A.minpq AND CONVERT(INT, RIGHT(PurchaseTransactionDetail.ItemID, 3)) % 2 = 1

--7
SELECT s.StaffName,
v.VendorName,
ph.PurchaseID,
SUM(PurchaseQuantity) AS 'Total Purchased Quantity',
CONCAT(ABS(DATEDIFF(DAY, GETDATE(), ph.PurchaseDate)), ' Days ago') AS 'Ordered Day'
FROM PurchaseTransactionHeader ph
JOIN PurchaseTransactionDetail pd ON ph.PurchaseID = pd.PurchaseID
JOIN MsVendor v ON ph.VendorID = v.VendorID
JOIN MsStaff s ON ph.StaffID = s.StaffID
GROUP BY s.StaffName, v.VendorName, ph.PurchaseID, ph.PurchaseDate
HAVING SUM(PurchaseQuantity) >
(
 SELECT MAX(pd.PurchaseQuantity)
 FROM PurchaseTransactionHeader ph
 JOIN PurchaseTransactionDetail pd ON ph.PurchaseID = pd.PurchaseID
 WHERE ABS(DATEDIFF(DAY, ph.ArrivalDate, ph.PurchaseDate)) < 7
)

--8
SELECT TOP 2 DATENAME(dw, SalesDate) AS 'Day',
COUNT(i.ItemID) AS 'Item Sales Amount'
FROM SalesTransactionHeader sh
JOIN SalesTransactionDetail sd ON sd.SalesID = sh.SalesID
JOIN MsItem i ON i.ItemID = sd.ItemID,
(
	SELECT AVG(ItemPrice) AS Average
	FROM MsItem im
	JOIN MsItemType it ON im.ItemTypeID = it.ItemTypeID
	WHERE ItemTypeName IN ('Electronic', 'Gadgets')
) AS x
WHERE ItemPrice < x.Average
GROUP BY DATENAME(dw, SalesDate)
ORDER BY COUNT(sh.SalesID)

--9
GO
CREATE VIEW [Customer Statistic by Gender] AS
SELECT CustomerGender, MAX(maxi) AS
[Maximum Sales], MIN(mini) AS
[Minimum Sales]
FROM (SELECT SalesID, CustomerGender FROM
SalesTransactionHeader sth
JOIN MsCustomer mc ON mc.CustomerID =
sth.CustomerID WHERE YEAR(CustomerDOB) BETWEEN
1998 AND 1999) AS table1
JOIN (SELECT sth.SalesID, MAX(SalesQuantity) AS
[maxi], MIN(SalesQuantity) AS [mini]
FROM SalesTransactionDetail std
JOIN SalesTransactionHeader sth ON
sth.SalesID = std.SalesID
WHERE SalesQuantity BETWEEN 10 AND 50
GROUP BY sth.SalesID) table2
ON table1.SalesID = table2.SalesID
GROUP BY CustomerGender
GO

SELECT * FROM [Customer Statistic by Gender]

--10
GO
CREATE VIEW [Item Type Statistic] AS
SELECT UPPER(ItemTypeName) AS [Item Type],
AVG(ItemPrice) AS [Average Price], 
COUNT(*) AS [Number of Item Variety]
FROM MsItem mi 
JOIN MsItemType mit ON mi.ItemTypeID = mit.ItemTypeID,
(
 SELECT ItemID, MIN(PurchaseQuantity) AS [minPurchase]
 FROM PurchaseTransactionDetail
 GROUP BY ItemID
) AS x
WHERE LEFT(ItemTypeName, 1) LIKE 'F' AND x.minPurchase > 5
GROUP BY ItemTypeName
GO

SELECT * FROM [Item Type Statistic]