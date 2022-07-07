set statistics io, time on;
--������������ ������
Select	ord.CustomerID, 
		det.StockItemID, 
		SUM(det.UnitPrice), 
		SUM(det.Quantity), 
		COUNT(ord.OrderID)
FROM	Sales.Orders AS ord
		JOIN Sales.OrderLines AS det
		ON det.OrderID = ord.OrderID
		JOIN Sales.Invoices AS Inv
		ON Inv.OrderID = ord.OrderID
		JOIN Sales.CustomerTransactions AS Trans
		ON Trans.InvoiceID = Inv.InvoiceID
		JOIN Warehouse.StockItemTransactions AS ItemTrans --����� ���� ��� ������ �������, � ����� ���� ��� ����� � ������� ��� ���� ����� �������� ������ �� ��������, �� ������� ���� ����������
		ON ItemTrans.StockItemID = det.StockItemID
WHERE	Inv.BillToCustomerID != ord.CustomerID
		AND (Select SupplierId
			FROM Warehouse.StockItems AS It
			Where It.StockItemID = det.StockItemID) = 12 -- ���������� �� ����� � ��������� ���������� ������ �������, �� 
		AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
			FROM Sales.OrderLines AS Total
			Join Sales.Orders AS ordTotal
			On ordTotal.OrderID = Total.OrderID
			WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
		AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
--����� ������
;with totals as
(SELECT ordTotal.CustomerID
			FROM Sales.OrderLines AS Total
			Join Sales.Orders AS ordTotal
			On ordTotal.OrderID = Total.OrderID
			group by ordTotal.CustomerID 
			having SUM(Total.UnitPrice*Total.Quantity)>250000)

Select	ord.CustomerID, 
		det.StockItemID, 
		SUM(det.UnitPrice), 
		SUM(det.Quantity), 
		COUNT(ord.OrderID)
FROM	Sales.Orders AS ord
		JOIN Sales.OrderLines AS det
		ON det.OrderID = ord.OrderID
		inner JOIN Sales.Invoices AS Inv
		ON Inv.OrderID = ord.OrderID
		JOIN Warehouse.StockItems AS It
		ON It.StockItemID = det.StockItemID
		JOIN totals
		ON totals.CustomerID = inv.CustomerID
WHERE	Inv.BillToCustomerID != ord.CustomerID
		AND It.SupplierId = 12
		AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
