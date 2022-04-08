USE bEJibun
GO

--SIMULASI 1
-- SALES TRANSACTION SIMULATION
BEGIN TRAN

INSERT INTO SalesTransactionHeader VALUES
('SA021', 'ST008', 'CU015', '2021-10-14')

INSERT INTO SalesTransactionDetail VALUES
('SA021', 'IT001', 2),
('SA021', 'IT002', 4),
('SA021', 'IT003', 3)

SELECT * FROM SalesTransactionHeader
SELECT * FROM SalesTransactionDetail

COMMIT

-- PURCHASE TRANSACTION SIMULATION
BEGIN TRAN

INSERT INTO PurchaseTransactionHeader VALUES
('PH021', 'ST006', 'VE007', '2021-09-14', '2021-09-20')

INSERT INTO PurchaseTransactionDetail VALUES
('PH021', 'IT003', 40),
('PH021', 'IT005', 25)

SELECT * FROM PurchaseTransactionHeader
SELECT * FROM PurchaseTransactionDetail

COMMIT


--SIMULASI 2
-- SALES TRANSACTION SIMULATION
BEGIN TRAN

INSERT INTO SalesTransactionHeader VALUES
('SA022', 'ST005', 'CU011', '2021-10-16')

INSERT INTO SalesTransactionDetail VALUES
('SA022', 'IT004', 1),
('SA022', 'IT005', 2),
('SA022', 'IT006', 2),
('SA022', 'IT003', 5)

ROLLBACK

BEGIN TRAN
INSERT INTO SalesTransactionHeader VALUES
('SA022', 'ST005', 'CU011', '2021-10-16')

INSERT INTO SalesTransactionDetail VALUES
('SA022', 'IT004', 1),
('SA022', 'IT005', 2),
('SA022', 'IT006', 2)

SELECT * FROM SalesTransactionHeader
SELECT * FROM SalesTransactionDetail
COMMIT


-- PURCHASE TRANSACTION SIMULATION
BEGIN TRAN

INSERT INTO PurchaseTransactionHeader VALUES
('PH022', 'ST003', 'VE004', '2021-09-16', '2021-09-20')

INSERT INTO PurchaseTransactionDetail VALUES
('PH022', 'IT003', 40),
('PH022', 'IT005', 25)

ROLLBACK

BEGIN TRAN
INSERT INTO PurchaseTransactionHeader VALUES
('PH022', 'ST003', 'VE004', '2021-09-16', '2021-09-20')

INSERT INTO PurchaseTransactionDetail VALUES
('PH022', 'IT003', 10),
('PH022', 'IT005', 20)

SELECT * FROM PurchaseTransactionHeader
SELECT * FROM PurchaseTransactionDetail

COMMIT

--SIMULASI 3
-- PURCHASE TRANSACTION SIMULATION
BEGIN TRAN

INSERT INTO PurchaseTransactionHeader(PurchaseID, StaffID, VendorID, PurchaseDate) VALUES
('PH023', 'ST006', 'VE002', GETDATE())

INSERT INTO PurchaseTransactionDetail VALUES
('PH023', 'IT006', 50),
('PH023', 'IT008', 50)

SELECT * FROM PurchaseTransactionHeader
SELECT * FROM PurchaseTransactionDetail

COMMIT

BEGIN TRAN
UPDATE PurchaseTransactionHeader
SET ArrivalDate = GETDATE()+1
WHERE PurchaseID = 'PH023'

SELECT * FROM PurchaseTransactionHeader
SELECT * FROM PurchaseTransactionDetail

COMMIT