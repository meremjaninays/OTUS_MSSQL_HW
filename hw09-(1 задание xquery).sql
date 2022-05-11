DECLARE @x XML
SET @x = ( 
  SELECT * FROM OPENROWSET
  (BULK 'C:\OTUS_MSSQL_Repo\StockItems.xml',
   SINGLE_CLOB) as d)

MERGE [Warehouse].[StockItems] as si
USING (SELECT 
   t.StockItem.value('(@Name)[1]', 'nvarchar(100)') as [StockItemName],
   t.StockItem.value('(SupplierID)[1]', 'int') as [SupplierID],
   t.StockItem.value('(Package/UnitPackageID)[1]', 'int') as [UnitPackageID],
   t.StockItem.value('(Package/OuterPackageID)[1]', 'int') as [OuterPackageID],
   t.StockItem.value('(Package/QuantityPerOuter)[1]', 'int') as [QuantityPerOuter],
   t.StockItem.value('(Package/TypicalWeightPerUnit)[1]', 'decimal') as [TypicalWeightPerUnit],
   t.StockItem.value('(LeadTimeDays)[1]', 'int') as [LeadTimeDays],
   t.StockItem.value('(IsChillerStock)[1]', 'int') as [IsChillerStock],
   t.StockItem.value('(TaxRate)[1]', 'decimal') as [TaxRate],
   t.StockItem.value('(UnitPrice)[1]', 'decimal') as [UnitPrice]  
FROM @x.nodes('/StockItems/Item') as t(StockItem)) AS sd ON si.[StockItemName] = sd.StockItemName
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
