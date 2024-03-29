CREATE SCHEMA Morawiec;

CREATE TABLE Morawiec.DIM_CUSTOMER (
	CustomerID INT NOT NULL, 
	firstName NVARCHAR(50), 
	LastName NVARCHAR(50), 
	TerritoryName NVARCHAR(50), 
	CountryRegionCode NVARCHAR(3), 
	[Group] NVARCHAR(50)
);

CREATE TABLE Morawiec.DIM_PRODUCT (
	ProductID INT NOT NULL,
	Name NVARCHAR(50),
	ListPrice MONEY, 
	Color NVARCHAR(15), 
	SubCategoryName NVARCHAR(50), 
	CategoryName NVARCHAR(50)
);

CREATE TABLE Morawiec.DIM_SALESPERSON (
	SalesPersonID INT NOT NULL, 
	FirstName NVARCHAR(50), 
	LastName NVARCHAR(50), 
	title NVARCHAR(50), 
	Gender NCHAR(1), 
	CountryRegionCode NVARCHAR(3), 
	[Group] NVARCHAR(50), 
	Age INT
);

CREATE TABLE Morawiec.FACT_SALES (
	ProductId INT,
	CustomerID INT, 
	SalesPersonID INT, 
	OrderDate INT, 
	ShipDate INT, 
	OrderQty SMALLINT, 
	UnitPrice MONEY, 
	UnitPricediscount MONEY, 
	LineTotal NUMERIC(38,6)
);

INSERT INTO Morawiec.DIM_CUSTOMER
SELECT C.CustomerID, P.FirstName, P.LastName, T.Name, T.CountryRegionCode, T.[Group]
FROM Sales.Customer C 
	JOIN Person.Person P ON C.PersonID = P.BusinessEntityID
	JOIN Sales.SalesTerritory T ON C.TerritoryID = T.TerritoryID;

INSERT INTO Morawiec.DIM_PRODUCT
SELECT P.ProductID, P.Name, P.ListPrice, P.Color, PS.Name, PC.Name
FROM Production.Product P 
	LEFT JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID 
	LEFT JOIN Production.ProductCategory PC ON PC.ProductCategoryID = PS.ProductCategoryID;

INSERT INTO Morawiec.DIM_SALESPERSON
SELECT S.BusinessEntityID, P.FirstName, P.LastName, E.JobTitle, E.Gender, T.CountryRegionCode, T.[Group], DATEDIFF(hour, E.BirthDate ,GETDATE())/8766
FROM Sales.SalesPerson S
	LEFT JOIN HumanResources.Employee E ON S.BusinessEntityID = E.BusinessEntityID
	LEFT JOIN Person.Person P ON P.BusinessEntityID = S.BusinessEntityID
	LEFT JOIN Sales.SalesTerritory T ON S.TerritoryID = T.TerritoryID;

INSERT INTO Morawiec.FACT_SALES
SELECT SD.ProductID, SH.CustomerID, SH.SalesPersonID, cast(format(SH.OrderDate,'yyyyMMdd') as int), cast(format(SH.ShipDate,'yyyyMMdd') as int), SD.OrderQty, SD.UnitPrice, SD.UnitPriceDiscount, SD.LineTotal
FROM Sales.SalesOrderHeader SH 
	JOIN Sales.SalesOrderDetail SD ON SH.SalesOrderID = SD.SalesOrderID;

ALTER TABLE Morawiec.DIM_PRODUCT
ADD CONSTRAINT dp_pk PRIMARY KEY(ProductID);

ALTER TABLE Morawiec.DIM_SALESPERSON
ADD CONSTRAINT ds_pk PRIMARY KEY(SalesPersonID);

ALTER TABLE Morawiec.DIM_CUSTOMER
ADD CONSTRAINT dc_pk PRIMARY KEY(CustomerID);

ALTER TABLE Morawiec.FACT_SALES
ADD SalesID INT IDENTITY(1,1) CONSTRAINT fs_pk PRIMARY KEY,
CONSTRAINT fs_fk_ci FOREIGN KEY(CustomerID) REFERENCES Morawiec.DIM_CUSTOMER(CustomerID),
CONSTRAINT fs_fk_sp FOREIGN KEY(SalesPersonID) REFERENCES Morawiec.DIM_SALESPERSON(SalesPersonID),
CONSTRAINT fs_fk_pr FOREIGN KEY(ProductID) REFERENCES Morawiec.DIM_PRODUCT(ProductID);

INSERT INTO Morawiec.DIM_CUSTOMER
VALUES(11000, 'Jon', 'Yang', 'Australia', 'AU', 'AU');
INSERT INTO Morawiec.DIM_CUSTOMER
VALUES(10000, 'Jon', 'Yang', 'Australia', 'AU', 'AU');

INSERT INTO Morawiec.DIM_PRODUCT
VALUES(999, 'Bike', '200.00', 'Black', 'Road Bikes', 'Bikes');
INSERT INTO Morawiec.DIM_PRODUCT
VALUES(1000, 'Bike', '200.00', 'Black', 'Road Bikes', 'Bikes');

INSERT INTO Morawiec.DIM_SALESPERSON
VALUES(290, 'Ranjit', 'Varkey Chudukatil', 'Sales Representative', 'M', 'FR', 'FR', 43);
INSERT INTO Morawiec.DIM_SALESPERSON
VALUES(291, 'Ranjit', 'Varkey Chudukatil', 'Sales Representative', 'M', 'FR', 'FR', 43);

INSERT INTO Morawiec.FACT_SALES
VALUES(999, 11000, 290, 20110531, 20110531, 1, 2.00, 0.1, 1.80);
INSERT INTO Morawiec.FACT_SALES
VALUES(1000, 1000, 1000, 20110531, 20110531, 1, 2.00, 0.1, 1.80);
BEGIN
	IF (EXISTS (SELECT * 
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_SCHEMA = 'Morawiec'
			AND TABLE_NAME = 'FACT_SALES'))	
	BEGIN
		DROP TABLE Morawiec.FACT_SALES;
	END
	IF (EXISTS (SELECT * 
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_SCHEMA = 'Morawiec'
			AND TABLE_NAME = 'DIM_CUSTOMER'))
	BEGIN
		DROP TABLE Morawiec.DIM_CUSTOMER;
	END

	IF (EXISTS (SELECT * 
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_SCHEMA = 'Morawiec'
			AND TABLE_NAME = 'DIM_SALESPERSON'))
	BEGIN
		DROP TABLE Morawiec.DIM_SALESPERSON;
	END

	IF (EXISTS (SELECT * 
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_SCHEMA = 'Morawiec'
			AND TABLE_NAME = 'DIM_PRODUCT'))
	BEGIN
		DROP TABLE Morawiec.DIM_PRODUCT;
	END

		IF (EXISTS (SELECT * 
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_SCHEMA = 'Morawiec'
			AND TABLE_NAME = 'DIM_TIME'))
	BEGIN
		DROP TABLE Morawiec.DIM_TIME;
	END

		IF (EXISTS (SELECT * 
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_SCHEMA = 'Morawiec'
			AND TABLE_NAME = 'MONTHS'))
	BEGIN
		DROP TABLE Morawiec.MONTHS;
	END

		IF (EXISTS (SELECT * 
			FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_SCHEMA = 'Morawiec'
			AND TABLE_NAME = 'DAYS_OF_WEEK'))
	BEGIN
		DROP TABLE Morawiec.DAYS_OF_WEEK;
	END
END

CREATE TABLE Morawiec.DAYS_OF_WEEK(
	DayID int IDENTITY(1, 1) CONSTRAINT dw_pk PRIMARY KEY,
	Name NVARCHAR(20)
);

CREATE TABLE Morawiec.MONTHS(
	MonthID int IDENTITY(1, 1) CONSTRAINT mn_pk PRIMARY KEY,
	Name NVARCHAR(20)
);

CREATE TABLE Morawiec.DIM_TIME(
	PK_TIME INT CONSTRAINT dt_pk PRIMARY KEY,
	dYear INT,
	dMonth INT CONSTRAINT dt_dm_fk REFERENCES Morawiec.MONTHS(MonthID),
	dDay INT,
	dDayOfWeek INT CONSTRAINT dt_dd_fk REFERENCES Morawiec.DAYS_OF_WEEK(DayID)
);

INSERT INTO Morawiec.DAYS_OF_WEEK
VALUES ('Niedziela'), ('Poniedzialek'), ('Wtorek'), ('Sroda'), ('Czwartek'), ('Piatek'), ('Sobota');

INSERT INTO Morawiec.MONTHS
VALUES ('Stycze�'), ('Luty'), ('Marzec'), ('Kwiecie�'), ('Maj'), ('Czerwiec'), ('Lipiec'), ('Sierpie�'), ('Wrzesien'), ('Pa�dziernik'), ('Listopad'), ('Grudzie�');

INSERT INTO Morawiec.DIM_TIME
SELECT DISTINCT OrderDate, LEFT(OrderDate, 4), RIGHT(LEFT(OrderDate, 6), 2), RIGHT(OrderDate, 2), DATEPART(dw, CONVERT (datetime,convert(char(8), OrderDate))) 
FROM Morawiec.FACT_SALES
UNION
SELECT DISTINCT ShipDate, LEFT(ShipDate, 4), RIGHT(LEFT(ShipDate, 6), 2), RIGHT(ShipDate, 2), DATEPART(dw, CONVERT (datetime,convert(char(8), ShipDate))) 
FROM Morawiec.FACT_SALES;

ALTER TABLE Morawiec.FACT_SALES
ADD CONSTRAINT fs_od_fk FOREIGN KEY(OrderDate) REFERENCES Morawiec.DIM_TIME(PK_TIME),
CONSTRAINT fs_sd_fk FOREIGN KEY(ShipDate) REFERENCES Morawiec.DIM_TIME(PK_TIME);

UPDATE Morawiec.DIM_PRODUCT
SET Color = 'Unknown'
WHERE Color IS NULL;

UPDATE Morawiec.DIM_PRODUCT
SET SubCategoryName = 'Unknown'
WHERE SubCategoryName IS NULL;

UPDATE Morawiec.DIM_SALESPERSON
SET CountryRegionCode = 000
WHERE CountryRegionCode IS NULL;

UPDATE Morawiec.DIM_SALESPERSON
SET [Group] = 'Unknown'
WHERE [Group] IS NULL;
