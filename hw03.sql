/*
Посчитать среднюю цену товара, общую сумму продажи по месяцам.
*/
SELECT	si.StockItemName,
		year(o.OrderDate),
		month(o.OrderDate), 
		AVG(ol.UnitPrice),
		SUM(ol.UnitPrice * ol.Quantity)
FROM	[Sales].[Orders] o
		INNER JOIN
		[Sales].[OrderLines] ol
		ON o.OrderID = ol.OrderID
		INNER JOIN
		[Warehouse].[StockItems] si
		ON ol.StockItemID = si.StockItemID
GROUP BY  si.StockItemName, year(o.OrderDate), month(o.OrderDate)
ORDER BY 1,2,3

/*
Отобразить все месяцы, где общая сумма продаж превысила 10 000.
*/
SELECT	si.StockItemName,
		year(o.OrderDate),
		month(o.OrderDate), 	
		SUM(ol.UnitPrice * ol.Quantity)
FROM	[Sales].[Orders] o
		INNER JOIN
		[Sales].[OrderLines] ol
		ON o.OrderID = ol.OrderID
		INNER JOIN
		[Warehouse].[StockItems] si
		ON ol.StockItemID = si.StockItemID
GROUP BY year(o.OrderDate), month(o.OrderDate), si.StockItemName
HAVING	SUM(ol.UnitPrice * ol.Quantity) > 10000
ORDER BY 1,2,3

/*
Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, 
по товарам, продажи которых менее 50 ед в месяц. 
Группировка должна быть по году, месяцу, товару. 
Опционально: Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж, 
то этот месяц также отображался бы в результатах, но там были нули.
*/
SELECT	year(o.OrderDate),
		month(o.OrderDate), 
		si.StockItemName,
		SUM(ol.UnitPrice * ol.Quantity),
		min(o.OrderDate),
		SUM(ol.Quantity)
FROM	[Sales].[Orders] o
		INNER JOIN
		[Sales].[OrderLines] ol
		ON o.OrderID = ol.OrderID
		INNER JOIN
		[Warehouse].[StockItems] si
		ON ol.StockItemID = si.StockItemID
GROUP BY year(o.OrderDate), month(o.OrderDate), si.StockItemName
HAVING	SUM(ol.Quantity) < 50
ORDER BY 1,2,3