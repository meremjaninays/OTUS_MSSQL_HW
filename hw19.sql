--Create FileGroups for partitioning
ALTER DATABASE IntegrationDB
ADD FILEGROUP IntegrationDBArch
GO

ALTER DATABASE IntegrationDB
ADD FILE 
(
NAME = [IntegrationDBArch], 
FILENAME = 'C:\OTUS_MSSQL_Repo\Data\IntegrationDBArch.ndf', 
SIZE = 20 MB, 
MAXSIZE = UNLIMITED, 
FILEGROWTH = 20 MB
) TO FILEGROUP IntegrationDBArch
GO


ALTER DATABASE IntegrationDB
ADD FILEGROUP IntegrationDBCurrent
GO

ALTER DATABASE IntegrationDB
ADD FILE 
(
NAME = [IntegrationDBCurrent], 
FILENAME = 'C:\OTUS_MSSQL_Repo\Data\IntegrationDBCurrent.ndf', 
SIZE = 20 MB, 
MAXSIZE = UNLIMITED, 
FILEGROWTH = 20 MB
) TO FILEGROUP IntegrationDBCurrent
GO


CREATE PARTITION FUNCTION IntegrationLogPartitionFunction (Datetime2) 
AS RANGE LEFT FOR VALUES ('20220701'); 
GO


CREATE PARTITION SCHEME IntegrationLogPartitionScheme
AS PARTITION IntegrationLogPartitionFunction
TO (IntegrationDBArch,IntegrationDBCurrent);
GO

CREATE TABLE [dbo].[IntegrationLog](
	[IntegrationLogId] [bigint] IDENTITY(1,1) NOT NULL,
	[SourceObjectId] [uniqueidentifier] NULL,
	[ErrorMessage] [varchar](500) NULL,
	[IntegrationDate] [datetime2](7) NOT NULL,
	[IsSuccess] [bit] NULL
) 

ALTER TABLE [dbo].[IntegrationLog] ADD CONSTRAINT PK_IntegrationLog PRIMARY KEY Clustered (IntegrationLogId, IntegrationDate)
ON IntegrationLogPartitionScheme (IntegrationDate);
Go

CREATE TABLE [dbo].[IntegrationLogArch](
	[IntegrationLogId] [bigint] IDENTITY(1,1) NOT NULL,
	[SourceObjectId] [uniqueidentifier] NULL,
	[ErrorMessage] [varchar](500) NULL,
	[IntegrationDate] [datetime2](7) NOT NULL,
	[IsSuccess] [bit] NULL
) 
ALTER TABLE [dbo].[IntegrationLogArch] ADD CONSTRAINT PK_IntegrationLogArch PRIMARY KEY Clustered (IntegrationLogId, IntegrationDate)
ON IntegrationLogPartitionScheme (IntegrationDate);
Go

ALTER TABLE IntegrationLog SWITCH PARTITION 1 TO IntegrationLogArch PARTITION 1
Go


