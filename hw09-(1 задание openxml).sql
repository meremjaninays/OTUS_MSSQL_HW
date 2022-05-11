-- Переменная, в которую считаем XML-файл
DECLARE @xmlDocument  xml

-- Считываем XML-файл в переменную
SELECT @xmlDocument = BulkColumn
FROM OPENROWSET
(BULK 'C:\OTUS_MSSQL_Repo\StockItems.xml', 
 SINGLE_CLOB)
as data 

-- Проверяем, что в @xmlDocument
SELECT @xmlDocument as [@xmlDocument]

DECLARE @docHandle int
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument

-- docHandle - это просто число
SELECT @docHandle as docHandle


MERGE [Warehouse].[StockItems] as si
USING	(SELECT *
		FROM OPENXML(@docHandle, N'/StockItems/Item')
		WITH ( 
		StockItemName nvarchar(100) '@Name',
		SupplierID int 'SupplierID',
		UnitPackageID int 'Package/UnitPackageID',
		OuterPackageID int 'Package/OuterPackageID',
		QuantityPerOuter int 'Package/QuantityPerOuter',
		TypicalWeightPerUnit decimal 'Package/TypicalWeightPerUnit',
		LeadTimeDays int 'LeadTimeDays',
		IsChillerStock bit 'IsChillerStock',
		TaxRate decimal 'TaxRate',
		UnitPrice decimal 'UnitPrice'
		)) AS sd ON si.[StockItemName] = sd.StockItemName
		WHEN MATCHED THEN UPDATE SET	si.SupplierID = sd.SupplierID, 
										si.UnitPackageID = sd.UnitPackageID,
										si.OuterPackageID = sd.OuterPackageID,
										si.QuantityPerOuter = sd.QuantityPerOuter,
										si.TypicalWeightPerUnit = sd.TypicalWeightPerUnit,
										si.LeadTimeDays = sd.LeadTimeDays,
										si.IsChillerStock = sd.IsChillerStock,
										si.TaxRate = sd.TaxRate,
										si.UnitPrice = sd.UnitPrice
		WHEN NOT MATCHED THEN
			INSERT(StockItemName, SupplierID, UnitPackageID,OuterPackageID,QuantityPerOuter,TypicalWeightPerUnit,LeadTimeDays,IsChillerStock,TaxRate,UnitPrice, LastEditedBy)
			VALUES(sd.StockItemName, sd.SupplierID, sd.UnitPackageID,sd.OuterPackageID,sd.QuantityPerOuter,sd.TypicalWeightPerUnit,sd.LeadTimeDays,sd.IsChillerStock,sd.TaxRate,sd.UnitPrice, 1);

