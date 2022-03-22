/*
исходный запрос 
*/
SET STATISTICS IO, TIME ON
SELECT	Invoices.InvoiceID, 
		Invoices.InvoiceDate, 
		(SELECT People.FullName 
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID ) AS SalesPersonName, 
		SalesTotals.TotalSumm AS TotalSummByInvoice, 
		(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) FROM Sales.OrderLines 
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
									FROM Sales.Orders 
									WHERE Orders.PickingCompletedWhen IS NOT NULL 
									AND Orders.OrderId = Invoices.OrderId) 
		) AS TotalSummForPickedItems 
FROM	Sales.Invoices 
		JOIN (SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm 
			  FROM Sales.InvoiceLines 
			  GROUP BY InvoiceId 
			  HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals 
		ON Invoices.InvoiceID = SalesTotals.InvoiceID 
ORDER BY TotalSumm DESC

--совсем чуть чуть быстрее
SELECT	Invoices.invoiceid,
		Invoices.InvoiceDate,
		p.FullName,
		il.TotalSumm,
		t.TotalSummForPickedItems
FROM	Sales.Invoices		
		JOIN
		(SELECT SUM(Quantity*UnitPrice) AS TotalSumm, InvoiceLines.InvoiceID
		FROM Sales.InvoiceLines 
		GROUP BY InvoiceId 
		HAVING SUM(Quantity*UnitPrice) > 27000) AS il
		ON il.InvoiceID = Invoices.InvoiceID
		INNER JOIN
		Application.People p
		ON p.PersonID = Invoices.SalespersonPersonID
		LEFT JOIN
		Sales.Orders
		ON Orders.OrderID = Invoices.OrderID
		LEFT JOIN
		(SELECT OrderId, SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) as TotalSummForPickedItems 
		FROM Sales.OrderLines
		GROUP BY OrderId) as t
		ON Orders.OrderID = t.OrderID
WHERE	Orders.PickingCompletedWhen IS NOT NULL
ORDER BY TotalSumm DESC

--через CTE читаемей, но не быстрее
;WITH Orders
AS
(
SELECT SUM(ol.PickedQuantity*ol.UnitPrice) as totalsum, ol.OrderId
FROM Sales.OrderLines ol
INNER JOIN
Sales.Orders o
ON ol.OrderID = o.OrderID
WHERE o.PickingCompletedWhen IS NOT NULL
GROUP BY ol.OrderId),
Invoices
AS
(
SELECT SUM(il.Quantity*il.UnitPrice) TotalSummByInvoice, il.InvoiceID
FROM
Sales.InvoiceLines il
GROUP BY il.InvoiceID
HAVING SUM(il.Quantity*il.UnitPrice) > 27000
)

SELECT	Invoices.InvoiceID, 
		Invoices.InvoiceDate, 
		p.FullName, 
		il.TotalSummByInvoice AS TotalSummByInvoice, 
		o.totalsum
FROM	Sales.Invoices 
		JOIN 
		Invoices il
		ON Invoices.InvoiceID = il.InvoiceID
		JOIN
		Application.People p
		ON p.PersonID = Invoices.SalespersonPersonID
		INNER JOIN
		Orders o
		ON o.OrderID = Invoices.OrderID
ORDER BY totalsum DESC