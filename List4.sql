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


	ProductId INT,
	CustomerID INT, 
	SalesPersonID INT,
 
 
 
 
 
 




 
	JOIN Sales.SalesTerritory T ON C.TerritoryID = T.TerritoryID;


SELECT P.ProductID, P.Name, P.ListPrice, P.Color, PS.Name, PC.Name
FROM Production.Product P 
	LEFT JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
 








INSERT INTO Morawiec.FACT_SALES
SELECT SD.ProductID, SH.CustomerID, SH.SalesPersonID, cast(format(SH.OrderDate,'yyyyMMdd') as int), cast(format(SH.ShipDate,'yyyyMMdd') as int), SD.OrderQty, SD.UnitPrice, SD.UnitPriceDiscount, SD.LineTotal
FROM Sales.SalesOrderHeader SH 
	JOIN Sales.SalesOrderDetail SD ON SH.SalesOrderID = SD.SalesOrderID;

ALTER TABLE Morawiec.DIM_PRODUCT
ADD CONSTRAINT dp_pk PRIMARY KEY(ProductID);

ALTER TABLE Morawiec.DIM_SALESPERSON
ADD CONSTRAINT ds_pk PRIMARY KEY(SalesPersonID);





ADD SalesID INT IDENTITY(1,1) CONSTRAINT fs_pk PRIMARY KEY,
	CONSTRAINT fs_fk_ci FOREIGN KEY(CustomerID) REFERENCES Morawiec.DIM_CUSTOMER(CustomerID),
	CONSTRAINT fs_fk_sp FOREIGN KEY(SalesPersonID) REFERENCES Morawiec.DIM_SALESPERSON(SalesPersonID),
	

INSERT INTO Morawiec.DIM_CUSTOMER
VALUES(11000, 'Jon', 'Yang', 'Australia', 'AU', 'AU');

INSERT INTO Morawiec.DIM_CUSTOMER


INSERT INTO Morawiec.DIM_PRODUCT
VALUES(999, 'Bike', '200.00', 'Black', 'Road Bikes', 'Bikes');

INSERT INTO Morawiec.DIM_PRODUCT


INSERT INTO Morawiec.DIM_SALESPERSON
VALUES(290, 'Ranjit', 'Varkey Chudukatil', 'Sales Representative', 'M', 'FR', 'FR', 43);

INSERT INTO Morawiec.DIM_SALESPERSON
VALUES(291, 'Ranjit', 'Varkey Chudukatil', 'Sales Representative', 'M', 'FR', 'FR', 43);




INSERT INTO Morawiec.FACT_SALES


BEGIN
	IF (EXISTS (SELECT *
 

	

		END
	IF (EXISTS (SELECT *
 

		BEGIN
			DROP TABLE Morawiec.DIM_CUSTOMER;


 

	
			DROP TABLE Morawiec.DIM_SALESPERSON;
	
	IF (EXISTS (SELECT *
 

	
	
	
	IF (EXISTS (SELECT *
 

		BEGIN
	
	
	IF (EXISTS (SELECT *
 

	
			DROP TABLE Morawiec.MONTHS;
	

 

	
			DROP TABLE Morawiec.DAYS_OF_WEEK;
		END
END


	DayID int IDENTITY(1, 1) CONSTRAINT dw_pk PRIMARY KEY,
	Name NVARCHAR(20)


	MonthID int IDENTITY(1, 1) CONSTRAINT mn_pk PRIMARY KEY,



	PK_TIME INT CONSTRAINT dt_pk PRIMARY KEY,






VALUES ('Niedziela'), ('Poniedzialek'), ('Wtorek'), ('Sroda'), ('Czwartek'), ('Piatek'), ('Sobota');


VALUES ('Stycze�'), ('Luty'), ('Marzec'), ('Kwiecie�'), ('Maj'), ('Czerwiec'), ('Lipiec'), ('Sierpie�'), ('Wrzesien'), ('Pa�dziernik'), ('Listopad'), ('Grudzie�');

INSERT INTO Morawiec.DIM_TIME

FROM Morawiec.FACT_SALES
UNION
SELECT DISTINCT ShipDate, LEFT(ShipDate, 4), RIGHT(LEFT(ShipDate, 6), 2), RIGHT(ShipDate, 2), DATEPART(dw, CONVERT (datetime,convert(char(8), ShipDate))) 
FROM Morawiec.FACT_SALES;



	

UPDATE Morawiec.DIM_PRODUCT
SET Color = 'Unknown'
WHERE Color IS NULL;


SET SubCategoryName = 'Unknown'
WHERE SubCategoryName IS NULL;

UPDATE Morawiec.DIM_SALESPERSON

WHERE CountryRegionCode IS NULL;


SET [Group] = 'Unknown'
