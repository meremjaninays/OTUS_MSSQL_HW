/*
Требуется написать запрос, который в результате своего выполнения формирует сводку по количеству покупок в разрезе клиентов и месяцев. 
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.
*/
SELECT [date], [Hue Ton],[Mauno Laurila],[Seo-yun Paik]
FROM (SELECT 
DATEFROMPARTS(YEAR(i.InvoiceDate), MONTH(i.InvoiceDAte), 1) as [date],
c.CustomerName,
i.invoiceid
FROM
[Sales].[Invoices] i
INNER JOIN
[Sales].[Customers] c
ON i.CustomerID = c.CustomerID) as sourcetable
PIVOT (COUNT(invoiceid) FOR CustomerName
	IN ([Hue Ton],[Mauno Laurila],[Seo-yun Paik])
	) AS PivotTable
ORDER BY [date]

/*
Для всех клиентов с именем, в котором есть "Tailspin Toys" вывести все адреса, 
которые есть в таблице, в одной колонке.
*/
SELECT *
FROM (
SELECT	c.CustomerName, 
		c.DeliveryAddressLine1, 
		c.DeliveryAddressLine2, 
		c.PostalAddressLine1, c.PostalAddressLine2 
FROM	[Sales].[Customers] c 
WHERE	c.CustomerName LIKE '%Tailspin Toys%') AS adresses
UNPIVOT (Adsress FOR Name IN (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)) AS unpt

/*
В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным. 
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.
*/

SELECT * 
FROM
(SELECT	c.CountryID, 
		c.CountryName, 
		CONVERT(NVARCHAR(5), c.IsoAlpha3Code) IsoAlpha3Code,	
		CONVERT(NVARCHAR(5), c.IsoNumericCode) IsoNumericCode 
FROM	Application.Countries c) as codes
UNPIVOT (code FOR Name IN (IsoAlpha3Code, IsoNumericCode)) as unpt
/*
Выберите по каждому клиенту два самых дорогих товара, которые он покупал. 
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
SELECT c.CustomerID, c.CustomerName, l.StockItemID, l.UnitPrice, l.InvoiceDate
FROM
[Sales].[Customers] c
CROSS APPLY
(SELECT TOP 2 i.CustomerID, il.StockItemID, il.UnitPrice, i.InvoiceDate
FROM
[Sales].[Invoices] i
INNER JOIN
[Sales].[InvoiceLines] il
ON i.invoiceid = il.invoiceid
WHERE c.CustomerID = i.CustomerID
ORDER BY il.UnitPrice DESC
) L