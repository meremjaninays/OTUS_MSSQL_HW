/*
Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, 
нарастать будет в течение времени выборки). 
Нарастающий итог должен быть без оконной функции.
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
Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции. 
Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
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
Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год 
(по 2 самых популярных продукта в каждом месяце).
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
Функции одним запросом Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
посчитайте общее количество товаров и выведете полем в этом же запросе
посчитайте общее количество товаров в зависимости от первой буквы названия товара
отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
предыдущий ид товара с тем же порядком отображения (по имени)
названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
сформируйте 30 групп товаров по полю вес товара на 1 шт Для этой задачи НЕ нужно писать аналог без аналитических функций.
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
По каждому сотруднику выведите последнего клиента, 
которому сотрудник что-то продал. 
В результатах должны быть ид и фамилия сотрудника, 
ид и название клиента, дата продажи, сумму сделки.
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
Выберите по каждому клиенту два самых дорогих товара, которые он покупал. 
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки. 
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