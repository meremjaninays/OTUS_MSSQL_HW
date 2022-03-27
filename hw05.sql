/*
������� ������ ����� ������ ����������� ������ �� ������� � 2015 ���� 
(� ������ ������ ������ �� ����� ����������, 
��������� ����� � ������� ������� �������). 
����������� ���� ������ ���� ��� ������� �������.
*/
SET STATISTICS IO, TIME ON;
SELECT	DISTINCT YEAR(i.InvoiceDate) as [year], 
		MONTH(i.InvoiceDate) as [month], 
		(SELECT SUM(il2.UnitPrice * il2.Quantity)
		FROM	[Sales].[Invoices] i2
				INNER JOIN
				[Sales].[InvoiceLines] il2
				ON i2.InvoiceID = il2.InvoiceID
		WHERE i2.InvoiceDate > '20150101'
		AND year(i.InvoiceDate) >= year(i2.InvoiceDate) AND MONTH(i.InvoiceDate) >= MONTH(i2.InvoiceDate)
		)
FROM	[Sales].[Invoices] i
		WHERE i.InvoiceDate > '20150101'
ORDER BY [year], [month]

/*
�������� ������ ����� ����������� ������ � ���������� ������� � ������� ������� �������. 
�������� ������������������ �������� 1 � 2 � ������� set statistics time, io on
*/
SELECT	DISTINCT YEAR(i.InvoiceDate) as [year], 
		MONTH(i.InvoiceDate) as [month], 
		SUM(il.UnitPrice * il.Quantity) OVER (ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
		)
FROM	[Sales].[Invoices] i
		INNER JOIN
		[Sales].[InvoiceLines] il
		ON i.InvoiceID = il.InvoiceID
		WHERE i.InvoiceDate > '20150101'
ORDER BY [year], [month]

/*
������� ������ 2� ����� ���������� ��������� (�� ���������� ���������) 
� ������ ������ �� 2016 ��� 
(�� 2 ����� ���������� �������� � ������ ������).
*/

SELECT [month], si.StockItemName FROM
(
SELECT	MONTH(i.InvoiceDate) [month],
			il.StockItemID,
			ROW_NUMBER() OVER (PARTITION BY MONTH(i.InvoiceDate) ORDER BY SUM(il.Quantity) DESC) as quan
	FROM	[Sales].[Invoices] i
			INNER JOIN
			[Sales].[InvoiceLines] il
			ON i.InvoiceID = il.InvoiceID
	WHERE	i.InvoiceDate BETWEEN '20160101' AND '20170101'
	GROUP BY il.StockItemID, MONTH(i.InvoiceDate)
	) quantable
INNER JOIN
[Warehouse].[StockItems] si
ON quantable.StockItemID = si.StockItemID
WHERE quantable.quan<3
ORDER BY [month]

/*
������� ����� �������� ���������� �� ������� ������� (� ����� ����� ������ ������� �� ������, ��������, ����� � ����):
������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
���������� ����� ���������� ������� � �������� ����� � ���� �� �������
���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� �����
���������� �� ������ � ��� �� �������� ����������� (�� �����)
�������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
����������� 30 ����� ������� �� ���� ��� ������ �� 1 �� ��� ���� ������ �� ����� ������ ������ ��� ������������� �������.
*/
SELECT	si.StockItemID,		
		si.StockItemName, 
		si.Brand, 
		si.UnitPrice, 
		ROW_NUMBER() OVER (ORDER BY si.StockItemName),
		SUM(si.QuantityPerOuter) OVER(),
		LEAD(si.StockItemID) OVER (ORDER BY si.StockItemName) AS leadv,
		LAG(si.StockItemID) OVER (ORDER BY si.StockItemName) AS lagv,
		LAG(si.StockItemName, 2, 'No items') OVER (ORDER BY si.StockItemName) AS lagv,
		NTILE(30) OVER (ORDER BY si.[TypicalWeightPerUnit])
FROM	[Warehouse].[StockItems] si

/*
�� ������� ���������� �������� ���������� �������, 
�������� ��������� ���-�� ������. 
� ����������� ������ ���� �� � ������� ����������, 
�� � �������� �������, ���� �������, ����� ������.
*/
SELECT	top 1 WITH TIES p.PersonID, 
		p.FullName,
		pc.PersonID,
		pc.FullName,
		i.invoicedate,
		(SELECT SUM(ct.TransactionAmount)
		FROM [Sales].[CustomerTransactions] ct
		WHERE ct.InvoiceID = i.InvoiceID)
FROM	[Sales].[Invoices] i
		INNER JOIN
		[Application].[People] p
		ON i.SalespersonPersonID = p.PersonID
		INNER JOIN
		[Application].[People] pc
		ON i.CustomerID = pc.PersonID
ORDER BY ROW_NUMBER() OVER (PARTITION BY p.PersonID ORDER BY i.invoicedate DESC)

/*
�������� �� ������� ������� ��� ����� ������� ������, ������� �� �������. 
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������. 
*/
SELECT * FROM
(
	SELECT	TOP 2 WITH TIES
			pc.PersonID,
			pc.FullName,
			il.StockItemID,
			il.UnitPrice,
			i.InvoiceID,
			RANK() OVER (PARTITION BY pc.PersonID ORDER BY il.UnitPrice DESC) rnk
	FROM	[Sales].[Invoices] i
			INNER JOIN
			[Application].[People] pc
			ON i.CustomerID = pc.PersonID
			INNER JOIN
			[Sales].[InvoiceLines] il
			ON i.Invoiceid = il.InvoiceID
	ORDER BY rnk) tbl
ORDER BY PersonID