--Zad 1.1 pivot
SELECT id, [2011], [2012], [2013], [2014] FROM (
SELECT SalesPersonID id, YEAR(OrderDate) AS rok, SubTotal
FROM Sales.SalesOrderHeader) AS src
PIVOT(
	SUM(SubTotal)
	FOR rok IN ([2011], [2012], [2013], [2014])
) AS piv;

--Zad 1.1 without pivot
SELECT SalesPersonID,
	SUM(CASE WHEN YEAR(OrderDate) = 2011 THEN SubTotal ELSE 0 END), 
	SUM(CASE WHEN YEAR(OrderDate) = 2012 THEN SubTotal ELSE 0 END), 
	SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN SubTotal ELSE 0 END), 
	SUM(CASE WHEN YEAR(OrderDate) = 2014 THEN SubTotal ELSE 0 END)
FROM Sales.SalesOrderHeader
GROUP BY SalesPersonID;

--Zad 1.2 pivot
SELECT id, [2012], [2013] FROM (
SELECT CustomerID id, YEAR(OrderDate) AS rok, SubTotal
FROM Sales.SalesOrderHeader) AS src
PIVOT(
	SUM(SubTotal)
	FOR rok IN ([2012], [2013])
) AS piv
ORDER BY id;

--Zad 1.2 without pivot
SELECT CustomerID,
	SUM(CASE WHEN YEAR(OrderDate) = 2012 THEN SubTotal ELSE 0 END), 
	SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN SubTotal ELSE 0 END)
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY CustomerID;

--Zad 1.3 pivot
SELECT idS, idC, [2011], [2012], [2013], [2014] FROM (
SELECT SalesPersonID idS, CustomerID idC, YEAR(OrderDate) AS rok, SubTotal
FROM Sales.SalesOrderHeader) AS src
PIVOT(
	SUM(SubTotal)
	FOR rok IN ([2011], [2012], [2013], [2014])
) AS piv
ORDER BY idS;

--Zad 1.3 without pivot
SELECT SalesPersonID, CustomerID,
	SUM(CASE WHEN YEAR(OrderDate) = 2011 THEN SubTotal ELSE 0 END), 
	SUM(CASE WHEN YEAR(OrderDate) = 2012 THEN SubTotal ELSE 0 END), 
	SUM(CASE WHEN YEAR(OrderDate) = 2013 THEN SubTotal ELSE 0 END), 
	SUM(CASE WHEN YEAR(OrderDate) = 2014 THEN SubTotal ELSE 0 END)
FROM Sales.SalesOrderHeader
GROUP BY SalesPersonID, CustomerID;

-- Zad 1.4 without pivot
SELECT MIN(PC.Name), MIN(P.Name), YEAR(SH.OrderDate), SUM(S.UnitPriceDiscount * S.OrderQty * S.UnitPrice)
FROM  Sales.SalesOrderHeader SH JOIN Sales.SalesOrderDetail S ON SH.SalesOrderID = S.SalesOrderID
	JOIN Production.Product P ON S.ProductID = P.ProductID 
	JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID 
	JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
GROUP BY PC.ProductCategoryID, P.ProductID, CUBE(YEAR(SH.OrderDate))
ORDER BY MIN(PC.Name), MIN(P.Name); 

--Zad 2
WITH Sprzedaz AS(
	SELECT SalesPersonID id, AVG(TotalDue) sr, MIN(P.LastName) + ', ' + MIN(P.FirstName) AS Fullname
	FROM Sales.SalesOrderHeader S JOIN Person.Person P ON S.SalesPersonID = P.BusinessEntityID
	WHERE SalesPersonID IS NOT NULL
	GROUP BY SalesPersonID)
SELECT id, fullname, sr, 
	RANK() OVER (ORDER BY sr DESC), 
	CASE NTILE(2) OVER(ORDER BY sr DESC)
		WHEN 1 THEN 'Wyrozniony'
		WHEN 2 THEN 'Do weryfikacji'
	END "Ocena"			 
FROM Sprzedaz;

--Zad 3
SELECT YEAR(OrderDate), MONTH(OrderDate), DAY(OrderDate), SUM(SubTotal) suma, COUNT(*) id
FROM Sales.SalesOrderHeader
GROUP BY ROLLUP(YEAR(OrderDate), MONTH(OrderDate), DAY(OrderDate))
ORDER BY MAX(OrderDate), id;

--Zad 4
SELECT SalesPersonID, CustomerID, SUM(SubTotal)
FROM Sales.SalesOrderHeader
GROUP BY CUBE(SalesPersonID, CustomerID);

--Zad 6a
SELECT DISTINCT PC.Name, P.Name, SUM(S.LineTotal) OVER(PARTITION BY S.ProductID) / SUM(S.LineTotal) OVER (PARTITION BY PC.ProductCategoryID) * 100 per
FROM Production.Product P JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID JOIN Sales.SalesOrderDetail S ON S.ProductID = P.ProductID
WHERE PC.Name = 'Accessories';

--Zad 6b
SELECT DISTINCT CustomerID, YEAR(OrderDate), COUNT(SubTotal) OVER (PARTITION BY CustomerID, YEAR(OrderDate)), COUNT(SubTotal) OVER (PARTITION BY CustomerID ORDER BY YEAR(OrderDate))
FROM Sales.SalesOrderHeader
ORDER BY CustomerID, YEAR(OrderDate);

--Zad 6c
SELECT DISTINCT SalesPersonID, YEAR(OrderDate), MONTH(OrderDate),
	COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate), MONTH(OrderDate)),
	COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate) ORDER BY MONTH(OrderDate)),
	COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate)),
	COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID ORDER BY YEAR(OrderDate)),
	COUNT(SalesOrderID) OVER (PARTITION BY SalesPersonID, YEAR(OrderDate), MONTH(OrderDate) ORDER BY SalesOrderID ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
FROM Sales.SalesOrderHeader
ORDER BY SalesPersonID, YEAR(OrderDate), MONTH(OrderDate);


--Zad 6d
SELECT s.Name, SUM(s.maximum)
FROM(
	SELECT DISTINCT PC.Name, MAX(P.ListPrice) OVER (PARTITION BY PS.ProductSubcategoryID) maximum
	FROM Production.Product P JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID) AS s
GROUP BY s.Name;


--Zad 6c v2
WITH help AS (
	SELECT SalesPersonID, YEAR(OrderDate) year , MONTH(OrderDate) month, COUNT(SalesOrderID) counter
	FROM Sales.SalesOrderHeader
	WHERE SalesPersonID IS NOT NULL
	GROUP BY SalesPersonID, YEAR(OrderDate), MONTH(OrderDate)
)
SELECT SalesPersonID "ID", year "Rok" , month "Miesiac", counter "Liczba zamowien w miesiacu",
	SUM(counter) OVER (PARTITION BY SalesPersonID ORDER BY year, month ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)"Liczba zamowien w miesiacu aktualnym i pop",
	SUM(counter) OVER (PARTITION BY SalesPersonID, year ORDER BY month) "Miesiecznie narastajaco",
	SUM(counter) OVER (PARTITION BY SalesPersonID, year) "Suma roczna",
	SUM(counter) OVER (PARTITION BY SalesPersonID ORDER BY year) "Rocznie narastajaco"
FROM help
ORDER BY SalesPersonID, year, month;


WITH help AS (
	SELECT BusinessEntityID, mon, yea, ISNULL(counter, 0) counter
	FROM (
		SELECT DISTINCT BusinessEntityID
		FROM Sales.SalesPerson
		GROUP BY BusinessEntityID
	) AS per
	CROSS JOIN (
		SELECT DISTINCT MONTH(OrderDate) mon, YEAR(OrderDate) yea
		FROM Sales.SalesOrderHeader
		GROUP BY MONTH(OrderDate), YEAR(OrderDate)
	) AS dat
	LEFT JOIN(
		SELECT SalesPersonID, YEAR(OrderDate) ye, MONTH(OrderDate) mo, COUNT(SalesOrderID) counter
		FROM Sales.SalesOrderHeader
		WHERE SalesPersonID IS NOT NULL
		GROUP BY SalesPersonID, YEAR(OrderDate), MONTH(OrderDate)) S ON S.SalesPersonID = per.BusinessEntityID AND S.ye = dat.yea AND S.mo = dat.mon
)
SELECT BusinessEntityID "ID", yea "Rok" , mon "Miesiac", counter "Liczba zamowien w miesiacu",
	SUM(counter) OVER (PARTITION BY BusinessEntityID ORDER BY yea, mon ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)"Liczba zamowien w miesiacu aktualnym i pop",
	SUM(counter) OVER (PARTITION BY BusinessEntityID, yea ORDER BY mon) "Miesiecznie narastajaco",
	SUM(counter) OVER (PARTITION BY BusinessEntityID, yea) "Suma roczna",
	SUM(counter) OVER (PARTITION BY BusinessEntityID ORDER BY yea) "Rocznie narastajaco"
FROM help
ORDER BY BusinessEntityID, yea, mon;