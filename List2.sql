--1a--
SELECT YEAR(OrderDate)
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate);

--1b--
SELECT *
FROM Sales.SalesOrderHeader 
WHERE OrderDate < DATEADD(YEAR, 1, (SELECT MIN(OrderDate)
									FROM Sales.SalesOrderHeader)); 

--1c--
SELECT *
FROM Sales.SalesOrderHeader 
WHERE MONTH(OrderDate) = 5;

--2a--
SELECT S.CustomerID, P.FirstName + ', ' + P.LastName "Imie, nazwisko", COUNT(*) "Liczba zamowien"
FROM Sales.SalesOrderHeader S JOIN Sales.Customer C ON S.CustomerID = C.CustomerID JOIN Person.Person P ON C.PersonID = P.BusinessEntityID 
GROUP BY S.CustomerID, P.FirstName, P.LastName
HAVING COUNT(*) > 25
ORDER BY [Liczba zamowien] DESC; 

--optymlaniej
WITH liczbaZamowien AS(
	SELECT S.CustomerID AS id, COUNT(*) as liczba
	FROM Sales.SalesOrderHeader S
	GROUP BY S.CustomerID
	HAVING COUNT(*) > 25)
SELECT id, P.FirstName + ', ' + P.LastName "Imie, nazwisko", l.liczba
FROM liczbaZamowien l JOIN Sales.Customer C ON l.id = C.CustomerID JOIN Person.Person P ON P.BusinessEntityID = C.PersonID;


--2b--
SELECT CustomerID, YEAR(OrderDate) "Rok", Count(*)"Liczba zamowien"
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (SELECT CustomerID
					FROM Sales.SalesOrderHeader
					WHERE YEAR(OrderDate) = 2011
					GROUP BY CustomerID
					INTERSECT
					SELECT CustomerID
					FROM Sales.SalesOrderHeader
					WHERE YEAR(OrderDate) = 2014
					GROUP BY CustomerID
					EXCEPT
					SELECT CustomerID
					FROM Sales.SalesOrderHeader
					WHERE YEAR(OrderDate) IN (2012, 2013)
					GROUP BY CustomerID, YEAR(OrderDate))
GROUP BY CustomerID, YEAR(OrderDate)
ORDER BY CustomerID;

--3a--
DROP TABLE Sales.Sprzedaz;

SELECT S1.SalesPersonID "pracID", S2.ProductID "prodID", MIN(P1.Name) "Nazwa", YEAR(S1.OrderDate)"Rok", SUM(S2.OrderQty)"Ilosc"
INTO Sales.Sprzedaz
FROM Sales.SalesOrderHeader S1 JOIN Sales.SalesOrderDetail S2 ON S1.SalesOrderID = S2.SalesOrderID JOIN Production.Product P1 ON S2.ProductID = P1.ProductID
GROUP BY S1.SalesPersonID, S2.ProductID, YEAR(S1.OrderDate);

SELECT *
FROM Sales.Sprzedaz;

--3b--
SELECT pracID, prodID, [2011], [2012], [2013], [2014] FROM
(SELECT S1.SalesPersonID pracID, S2.ProductID prodID, P1.Name nazwa, YEAR(S1.OrderDate) rok, S2.OrderQty
FROM Sales.SalesOrderHeader S1 JOIN Sales.SalesOrderDetail S2 ON S1.SalesOrderID = S2.SalesOrderID JOIN Production.Product P1 ON S2.ProductID = P1.ProductID) AS src
PIVOT(
	SUM(OrderQty)
	FOR rok IN ([2011], [2012], [2013], [2014])
) AS piv;


--4a1--
SELECT YEAR(OrderDate) "Year", MONTH(OrderDate) "Month", COUNT(DISTINCT CustomerID) "Number of customers"
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month;

--inaczej
SELECT YEAR(OrderDate) "Year",
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=1 THEN CustomerID END) AS "1", 
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=2 THEN CustomerID END) AS "2",
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=3 THEN CustomerID END) AS "3",
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=4 THEN CustomerID END) AS "4",
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=5 THEN CustomerID END) AS "5",
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=6 THEN CustomerID END) AS "6",
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=7 THEN CustomerID END) AS "7",
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=8 THEN CustomerID END) AS "8",
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=9 THEN CustomerID END) AS "9",
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=10 THEN CustomerID END) AS "10",
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=11 THEN CustomerID END) AS "11",
	COUNT(DISTINCT CASE WHEN MONTH(OrderDate)=12 THEN CustomerID END) AS "12"
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY Year;

--4a2--
SELECT Year, [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12]
FROM (SELECT DISTINCT CustomerID, YEAR(OrderDate) "Year", MONTH(OrderDate) "Month"
	 FROM Sales.SalesOrderHeader) AS src
PIVOT(
	COUNT(CustomerID)
	FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS piv
ORDER BY Year;

--4b--
SELECT SUM(LineTotal) suma, COUNT(DISTINCT ProductID) id, CONVERT(varchar(10), YEAR(OrderDate)) dat
FROM Sales.SalesOrderHeader
	JOIN Sales.SalesOrderDetail ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
GROUP BY YEAR(OrderDate)
UNION
SELECT SUM(LineTotal) suma, COUNT(DISTINCT ProductID) id, CONVERT(varchar(10), YEAR(OrderDate)) + '-' + CONVERT(varchar(10), MONTH(OrderDate)) dat
FROM Sales.SalesOrderHeader
	JOIN Sales.SalesOrderDetail ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
UNION
SELECT SUM(LineTotal) suma, COUNT(DISTINCT ProductID) id, CONVERT(varchar(10), YEAR(OrderDate)) + '-' + CONVERT(varchar(10), MONTH(OrderDate)) + '-' +   CONVERT(varchar(10), DAY(OrderDate)) dat
FROM Sales.SalesOrderHeader
	JOIN Sales.SalesOrderDetail ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
GROUP BY OrderDate;


--optymalniej
SELECT SUM(LineTotal) suma, COUNT(DISTINCT ProductID) id, YEAR(OrderDate), MONTH(OrderDate), DAY(OrderDate)
FROM Sales.SalesOrderHeader JOIN Sales.SalesOrderDetail ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
GROUP BY ROLLUP(YEAR(OrderDate), MONTH(OrderDate), DAY(OrderDate))
ORDER BY MAX(OrderDate), id;

--6--
SELECT id, MIN(Fname), MIN(Lname), MIN(Number), MIN(Total), 
	CASE WHEN MIN(Color) = 1 THEN 'Platinum' WHEN MIN(Color) = 2 THEN 'Gold' ELSE 'Silver' END FROM(
SELECT id, MIN(fname) Fname, MIN(lname) Lname, SUM(num) Number, SUM(total) Total, 1 Color FROM
(SELECT S.CustomerID id, MIN(FirstName) fname, MIN(LastName) lname, COUNT(*) num, SUM(S.SubTotal) total, MIN(YEAR(OrderDate)) year
FROM Sales.SalesOrderHeader S JOIN Sales.Customer ON S.CustomerID = Customer.CustomerID JOIN Person.Person ON Person.BusinessEntityID = Customer.PersonID
WHERE S.SubTotal > 1.5 * (SELECT AVG(SubTotal)
					FROM Sales.SalesOrderHeader)
GROUP BY S.CustomerID, YEAR(S.OrderDate)
HAVING COUNT(*) >= 2) src
GROUP BY id
HAVING COUNT(*) = 4
UNION ALL
SELECT S.CustomerID, MIN(FirstName), MIN(LastName), COUNT(*), SUM(S.SubTotal), 2
FROM Sales.SalesOrderHeader S JOIN Sales.Customer ON S.CustomerID = Customer.CustomerID JOIN Person.Person ON Person.BusinessEntityID = Customer.PersonID
WHERE S.SubTotal > 1.5 * (SELECT AVG(SubTotal)
						  FROM Sales.SalesOrderHeader)
GROUP BY S.CustomerID
HAVING COUNT(*) >= 2
UNION ALL
SELECT S.CustomerID, MIN(FirstName), MIN(LastName), COUNT(*), SUM(S.SubTotal), 3
FROM Sales.SalesOrderHeader S JOIN Sales.Customer ON S.CustomerID = Customer.CustomerID JOIN Person.Person ON Person.BusinessEntityID = Customer.PersonID
GROUP BY S.CustomerID
HAVING COUNT(*) >= 5) AS result
GROUP BY id;