/*
Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers
*/

DECLARE @LastCustomerID INT = NEXT VALUE FOR [Sequences].[CustomerCategoryID]

INSERT INTO [Sales].[Customers]
([CustomerID],
CustomerName, 
[BillToCustomerID],
CustomerCategoryID, 
PrimaryContactPersonID, 
DeliveryMethodID, 
DeliveryCityID, 
PostalCityID, 
AccountOpenedDate,
StandardDiscountPercentage,
IsStatementSent,
IsOnCreditHold,
PaymentDays,
PhoneNumber,
[FaxNumber],
[WebsiteURL],
[DeliveryAddressLine1],
[DeliveryPostalCode],
[PostalAddressLine1],
[PostalPostalCode], [LastEditedBy])
VALUES(NEXT VALUE For [Sequences].[CustomerID], 'Dixi2', NEXT VALUE For [Sequences].[CustomerID], 5, 3261, 3, 19881,  19881, GETDATE(), 0, 0,0, 7,'+79099900999',
'+79099900999', 'test','Gagarina 3','125000', 'Gagarina 3','125000',3261 ),
(NEXT VALUE For [Sequences].[CustomerID], 'DNS', NEXT VALUE For [Sequences].[CustomerID], 5, 3261, 3, 19881,  19881, GETDATE(), 0, 0,0, 7,'+79099900999',
'+79099900999', 'test','Gagarina 3','125000', 'Gagarina 3','125000',3261 ),
(NEXT VALUE For [Sequences].[CustomerID], 'STARBUCKS', NEXT VALUE For [Sequences].[CustomerID], 5, 3261, 3, 19881,  19881, GETDATE(), 0, 0,0, 7,'+79099900999',
'+79099900999', 'test','Gagarina 3','125000', 'Gagarina 3','125000',3261 ),
(NEXT VALUE For [Sequences].[CustomerID], 'COFFEEHOUSE', NEXT VALUE For [Sequences].[CustomerID], 5, 3261, 3, 19881,  19881, GETDATE(), 0, 0,0, 7,'+79099900999',
'+79099900999', 'test','Gagarina 3','125000', 'Gagarina 3','125000',3261 ),
(NEXT VALUE For [Sequences].[CustomerID], 'Billa', NEXT VALUE For [Sequences].[CustomerID], 5, 3261, 3, 19881,  19881, GETDATE(), 0, 0,0, 7,'+79099900999',
'+79099900999', 'test','Gagarina 3','125000', 'Gagarina 3','125000',3261 )

SELECT * FROM [Sales].[Customers]

/*
Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM sc
FROM [Sales].[Customers] sc
WHERE CustomerName = 'Dixi2'

/*
Изменить одну запись, из добавленных через UPDATE
*/
UPDATE [Sales].[Customers]
SET PaymentDays = 14
WHERE CustomerName = 'STARBUCKS'

/*
Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/
MERGE [Sales].[Customers] AS tgt  
    USING (SELECT 1078, 'MiraTorg') as src (CustomerID, CustomerName)
    ON (tgt.CustomerID = src.CustomerID)  
    WHEN MATCHED THEN
        UPDATE SET CustomerName = src.CustomerName  
    WHEN NOT MATCHED THEN  
        INSERT ([CustomerID],
																					CustomerName, 
																					[BillToCustomerID],
																					CustomerCategoryID, 
																					PrimaryContactPersonID, 
																					DeliveryMethodID, 
																					DeliveryCityID, 
																					PostalCityID, 
																					AccountOpenedDate,
																					StandardDiscountPercentage,
																					IsStatementSent,
																					IsOnCreditHold,
																					PaymentDays,
																					PhoneNumber,
																					[FaxNumber],
																					[WebsiteURL],
																					[DeliveryAddressLine1],
																					[DeliveryPostalCode],
																					[PostalAddressLine1],
																					[PostalPostalCode], [LastEditedBy])
        VALUES (src.CustomerId, src.CustomerName, src.CustomerId, 5, 3261, 3, 19881,  19881, GETDATE(), 0, 0,0, 7,'+79099900999',
'+79099900999', 'test','Gagarina 3','125000', 'Gagarina 3','125000',3261 );
    
/*
Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/
EXEC xp_cmdshell 'bcp WideWorldImporters.Sales.Customers out C:\BCP\StockItemTransactions_character.bcp -c -T';  

SELECT * into Sales.Customers_test
FROM  WideWorldImporters.Sales.Customers
WHERE 1=2

BULK INSERT Sales.Customers_test
FROM 'C:\BCP\StockItemTransactions_character.bcp';

SELECT * FROM Sales.Customers_test

DROP TABLE Sales.Customers_test