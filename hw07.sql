/*
Требуется написать запрос, который в результате своего выполнения
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.
Нужно написать запрос, который будет генерировать результаты для всех клиентов.
Имя клиента указывать полностью из поля CustomerName.
*/
DECLARE @customers NVARCHAR(max)
SET @customers=(SELECT QUOTENAME(c.CustomerName)+',' FROM
[Sales].[Customers] c
FOR XML PATH(''));

SET @customers = SUBSTRING(@customers, 1, LEN(@customers)-1)

DECLARE @sql NVARCHAR(max)
SET @sql = N'SELECT [date], '+@customers+'
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
	IN ('+@customers+')) AS PivotTable
ORDER BY [date]'

EXECUTE (@sql)
