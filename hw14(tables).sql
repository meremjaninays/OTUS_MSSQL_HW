USE IntegrationDB

CREATE TABLE dbo.Tasks
(SourceSystemId uniqueidentifier primary key clustered,
TargetSystemId bigint null, 
IntegrationDate datetime2)

CREATE TABLE dbo.Files
(SourceSystemId uniqueidentifier primary key clustered,
TargetSystemId bigint null, 
TaskId uniqueidentifier REFERENCES dbo.Tasks(SourceSystemId),
FileBase64String varchar(max),
FileName varchar(250),
IntegrationDate datetime2)

CREATE TABLE dbo.IntegrationLog
(Id bigint identity primary key clustered,
TaskId uniqueidentifier REFERENCES dbo.Tasks(SourceSystemId),
ErrorMessage varchar(500),
IntegrationDate datetime2,
IsSuccess bit)

CREATE TABLE dbo.[Queue]
(SourceSystemId uniqueidentifier primary key clustered)

CREATE INDEX IX_SourceSystemId ON dbo.Tasks
(SourceSystemId)
INCLUDE (TargetSystemId)

CREATE INDEX IX_SourceSystemId ON dbo.Files
(SourceSystemId)
INCLUDE (TargetSystemId)

CREATE INDEX IX_ErrorDate ON dbo.IntegrationLog
(IntegrationDate)

--добавила для ДЗ, но в проект я добавлять такое не стану, так как критична производительность, а эта проверка будет на стороне API
ALTER TABLE dbo.Files
   ADD CONSTRAINT CHK_Files_FileName   
   CHECK (FileName like '%.%')