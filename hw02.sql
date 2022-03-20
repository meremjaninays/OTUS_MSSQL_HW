USE [WideWorldImporters]
GO

SELECT	[StockItemID]
		,[StockItemName]
FROM	[Warehouse].[StockItems]
WHERE	StockItemName LIKE '%urgent%' OR StockItemName LIKE 'Animal%'

SELECT	s.SupplierID, s.SupplierName
FROM	[Purchasing].[Suppliers] s
		LEFT JOIN
		[Purchasing].[PurchaseOrders] p
		ON s.SupplierID = p.SupplierID
WHERE	p.SupplierID IS NULL

--«аказы (Orders) с ценой товара (UnitPrice) более 100$ 
--либо количеством единиц (Quantity) товара более 20 штуки 
--присутствующей датой комплектации всего заказа (PickingCompletedWhen).
SELECT	o.OrderID 
FROM	[Sales].[Orders] o
		INNER JOIN
		[Sales].[OrderLines] ol
		ON o.OrderID = ol.OrderID
		INNER JOIN
		[Warehouse].[StockItems] si
		ON ol.StockItemID = si.StockItemID
WHERE	si.UnitPrice > 100
		OR (ol.Quantity >20 AND ol.[PickingCompletedWhen] IS NOT NULL)

--«аказы поставщикам (Purchasing.Suppliers), 
--которые должны быть исполнены (ExpectedDeliveryDate) в €нваре 2013 года 
--с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName) 
--и которые исполнены (IsOrderFinalized)
SELECT	s.SupplierID, s.SupplierName
FROM	[Purchasing].[Suppliers] s
		INNER JOIN
		[Purchasing].[PurchaseOrders] po
		ON s.SupplierID = po.SupplierID
		INNER JOIN 
		[Application].[DeliveryMethods] dm
		ON s.DeliveryMethodID = dm.DeliveryMethodID
WHERE	ExpectedDeliveryDate > '20130101'
		AND ExpectedDeliveryDate < '20130201'
		AND (dm.DeliveryMethodName = 'Air Freight' OR dm.DeliveryMethodName = 'Refrigerated Air Freight')
		AND po.IsOrderFinalized = 1

--ƒес€ть последних продаж (по дате продажи) с именем клиента и именем сотрудника, 
--который оформил заказ (SalespersonPerson). —делать без подзапросов.
SELECT  TOP 10 o.OrderID, o.OrderDate, c.CustomerName, p.FullName 
FROM	[Sales].[Orders] o
		INNER JOIN
		[Sales].[Customers] c
		ON c.CustomerID = o.CustomerID
		INNER JOIN
		[Sales].[Invoices] i
		ON o.OrderID = i.InvoiceID
		INNER JOIN
		[Application].[People] p
		ON i.SalespersonPersonID = p.PersonID
ORDER BY OrderDate DESC

---¬се ид и имена клиентов и их контактные телефоны, которые покупали товар "Chocolate frogs 250g"
SELECT	DISTINCT c.CustomerID, c.CustomerName, c.PhoneNumber
FROM	[Sales].[Orders] o
		INNER JOIN
		[Sales].[Customers] c
		ON c.CustomerID = o.CustomerID
		INNER JOIN
		[Sales].[OrderLines] ol
		ON o.OrderID = ol.OrderID
		INNER JOIN
		[Warehouse].[StockItems] si
		ON ol.StockItemID = si.SupplierID
WHERE	si.StockItemName = 'Chocolate frogs 250g'

