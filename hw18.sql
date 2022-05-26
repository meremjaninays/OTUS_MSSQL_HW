USE [WideWorldImporters]
GO
--Написать функцию возвращающую Клиента с наибольшей суммой покупки.
CREATE FUNCTION Sales.CustomerWithMaxOrder ()
RETURNS int
AS
BEGIN
	RETURN
	(
		SELECT top 1 c.[CustomerID]
		FROM [Sales].[Customers] c
		INNER JOIN
		[Sales].[Orders] o
		ON c.CustomerID = o.CustomerID
		INNER JOIN
		[Sales].[OrderLines] ol
		ON o.OrderID = ol.OrderID
		GROUP BY o.OrderID, c.[CustomerID]
		ORDER BY sum(ol.UnitPrice * ol.Quantity) desc)
END
--Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту. Использовать таблицы : Sales.Customers Sales.Invoices Sales.InvoiceLines
CREATE PROCEDURE Sales.InvoiceSumForCustomer 
@CustomerID int
AS
SELECT sum(il.UnitPrice * il.Quantity)
FROM [Sales].[Customers] c
INNER JOIN
[Sales].[Invoices] i
ON c.CustomerID = i.CustomerID
INNER JOIN
[Sales].[InvoiceLines] il
ON i.InvoiceID = il.InvoiceID
WHERE c.CustomerID = @CustomerID

--Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему. Разницы нет.
CREATE PROCEDURE TEST_proc
AS
SELECT c.CustomerID, sum(il.UnitPrice * il.Quantity)
FROM [Sales].[Customers] c
INNER JOIN
[Sales].[Invoices] i
ON c.CustomerID = i.CustomerID
INNER JOIN
[Sales].[InvoiceLines] il
ON i.InvoiceID = il.InvoiceID
GROUP BY c.CustomerID

CREATE FUNCTION TEST_func ()
RETURNS Table
AS
return
(
	SELECT c.CustomerID, sum(il.UnitPrice * il.Quantity) as [sum]
	FROM [Sales].[Customers] c
	INNER JOIN
	[Sales].[Invoices] i
	ON c.CustomerID = i.CustomerID
	INNER JOIN
	[Sales].[InvoiceLines] il
	ON i.InvoiceID = il.InvoiceID
	GROUP BY c.CustomerID);

SET STATISTICS IO ON;

EXEC TEST_proc

SELECT * FROM TEST_func ()

--Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.
CREATE FUNCTION func_with_table_result (@CustomerId int)
RETURNS Table
AS
return
(
	SELECT i.InvoiceID, sum(il.UnitPrice * il.Quantity) as [sum]
	FROM 
	[Sales].[Invoices] i
	INNER JOIN
	[Sales].[InvoiceLines] il
	ON i.InvoiceID = il.InvoiceID
	WHERE i.CustomerID = @CustomerId
	GROUP BY i.InvoiceID);

	SELECT c.CustomerID, c.CustomerName, d.InvoiceID, d.sum FROM
	[Sales].[Customers] c
	CROSS APPLY (SELECT * FROM func_with_table_result(c.CustomerID)) d
	ORDER BY c.CustomerID, d.InvoiceID

