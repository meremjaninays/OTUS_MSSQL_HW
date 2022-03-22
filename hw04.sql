/*
Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/
SELECT p.PersonID, p.FullName FROM
[Application].[People] p
WHERE p.IsSalesperson = 1
AND p.PersonID NOT IN (SELECT i.SalespersonPersonID FROM [Sales].[Invoices] i
						WHERE i.InvoiceDate = '20140704')

;WITH invoices
AS
(SELECT i.SalespersonPersonID FROM [Sales].[Invoices] i
WHERE i.InvoiceDate = '20140704')

SELECT p.PersonID, p.FullName FROM
[Application].[People] p
WHERE p.IsSalesperson = 1
AND p.PersonID NOT IN (SELECT SalespersonPersonID FROM invoices)

/*
Выберите товары с минимальной ценой (подзапросом). 
Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/
SELECT  si.StockItemID,
		si.StockItemName,
		(SELECT MIN(ol.UnitPrice)
		FROM
		[Sales].[OrderLines] ol
		WHERE ol.StockItemID = si.StockItemID) 
FROM	[Warehouse].[StockItems] si
ORDER BY 1

;WITH prices
AS
(SELECT ol.StockItemID, MIN(ol.UnitPrice) as minPrice FROM [Sales].[OrderLines] ol
GROUP BY ol.StockItemID)

SELECT  si.StockItemID,
		si.StockItemName,
		(SELECT minPrice
		FROM
		prices p
		WHERE p.StockItemID = si.StockItemID) 
FROM	[Warehouse].[StockItems] si
ORDER BY 1

/*
Выберите информацию по клиентам, 
которые перевели компании пять максимальных платежей из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE).
*/
SELECT	TOP 5 CustomerID
FROM	Sales.CustomerTransactions
ORDER	BY TransactionAmount

SELECT	DISTINCT c.CustomerID, c.CustomerName
FROM	[Sales].[Customers] c 
WHERE	c.CustomerID in (SELECT	TOP 5 CustomerID
						FROM	Sales.CustomerTransactions
						ORDER	BY TransactionAmount DESC)

;WITH top_customers
AS
(SELECT	TOP 5 CustomerID
FROM	Sales.CustomerTransactions
ORDER	BY TransactionAmount DESC)

SELECT	DISTINCT c.CustomerID, c.CustomerName
FROM	[Sales].[Customers] c 
WHERE	c.CustomerID in (SELECT CustomerID
						FROM	top_customers)

/*
Выберите города (ид и название), 
в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, 
а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/
SELECT	TOP 3 il.StockItemID 
FROM	[Sales].[InvoiceLines] il
ORDER BY il.UnitPrice DESC

SELECT	cit.CityID, 
		cit.CityName, 
		p.FullName
FROM	[Sales].[Invoices] i
		INNER JOIN
		[Sales].[InvoiceLines] il
		ON i.InvoiceID = il.InvoiceID
		INNER JOIN
		[Sales].[Customers] c
		ON i.CustomerID = c.CustomerID
		INNER JOIN
		[Application].[Cities] cit
		ON c.DeliveryCityID = cit.CityID
		INNER JOIN
		[Application].[People] p
		ON p.PersonID = i.PackedByPersonID
WHERE	il.StockItemID IN (SELECT	TOP 3 il.StockItemID 
							FROM	[Sales].[InvoiceLines] il
							ORDER BY il.UnitPrice DESC)

;WITH top_stockitems
AS
(SELECT	TOP 3 il.StockItemID 
FROM	[Sales].[InvoiceLines] il
ORDER BY il.UnitPrice DESC)

SELECT	cit.CityID, 
		cit.CityName, 
		p.FullName
FROM	[Sales].[Invoices] i
		INNER JOIN
		[Sales].[InvoiceLines] il
		ON i.InvoiceID = il.InvoiceID
		INNER JOIN
		[Sales].[Customers] c
		ON i.CustomerID = c.CustomerID
		INNER JOIN
		[Application].[Cities] cit
		ON c.DeliveryCityID = cit.CityID
		INNER JOIN
		[Application].[People] p
		ON p.PersonID = i.PackedByPersonID
WHERE	il.StockItemID IN (SELECT	StockItemID 
							FROM	top_stockitems)