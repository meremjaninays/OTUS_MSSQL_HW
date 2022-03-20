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

--������ (Orders) � ����� ������ (UnitPrice) ����� 100$ 
--���� ����������� ������ (Quantity) ������ ����� 20 ����� 
--�������������� ����� ������������ ����� ������ (PickingCompletedWhen).
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

--������ ����������� (Purchasing.Suppliers), 
--������� ������ ���� ��������� (ExpectedDeliveryDate) � ������ 2013 ���� 
--� ��������� "Air Freight" ��� "Refrigerated Air Freight" (DeliveryMethodName) 
--� ������� ��������� (IsOrderFinalized)
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

--������ ��������� ������ (�� ���� �������) � ������ ������� � ������ ����������, 
--������� ������� ����� (SalespersonPerson). ������� ��� �����������.
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

---��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� "Chocolate frogs 250g"
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

