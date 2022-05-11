USE [WideWorldImporters]
GO

SELECT [StockItemID]
    ,[StockItemName]
	,JSON_VALUE(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture
	,JSON_VALUE(CustomFields, '$.Tags[0]') as FirstTag
FROM [Warehouse].[StockItems]

SELECT [StockItemID]
    ,[StockItemName]
	,STRING_AGG(tags2.value,',')
FROM [Warehouse].[StockItems]
CROSS APPLY OPENJSON(CustomFields, '$.Tags') tags
CROSS APPLY OPENJSON(CustomFields, '$.Tags') tags2
WHERE Tags.value = 'Vintage'
GROUP BY [StockItemID],[StockItemName]


