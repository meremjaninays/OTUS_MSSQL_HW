USE IntegrationDB

CREATE TABLE dbo.Tasks
(Id bigint identity primary key clustered,
SourceSystemId uniqueidentifier,
TargetSystemId bigint null, 
IntagrationDate datetime2,
CONSTRAINT UNQ_Tasks_SourceSystemId UNIQUE (SourceSystemId))

CREATE TABLE dbo.Files
(Id bigint identity primary key clustered,
SourceSystemId uniqueidentifier,
TargetSystemId bigint null, 
TaskId bigint REFERENCES dbo.Tasks(Id),
FileString varchar(max),
FileName varchar(250),
IntagrationDate datetime2,
CONSTRAINT UNQ_Files_SourceSystemId UNIQUE (SourceSystemId))

CREATE TABLE dbo.Errors
(Id bigint identity primary key clustered,
TaskId bigint REFERENCES dbo.Tasks(Id),
ErrorMessage varchar(500),
ErrorDate datetime2)

CREATE TABLE dbo.Quenue
(Id bigint identity primary key clustered,
SourceSystemId uniqueidentifier,
CONSTRAINT UNQ_Quenue_SourceSystemId UNIQUE (SourceSystemId))

CREATE INDEX IX_SourceSystemId ON dbo.Tasks
(SourceSystemId)
INCLUDE (TargetSystemId)

CREATE INDEX IX_SourceSystemId ON dbo.Files
(SourceSystemId)
INCLUDE (TargetSystemId)

CREATE INDEX IX_ErrorDate ON dbo.Errors
(ErrorDate)

CREATE INDEX IX_SourceSystemId ON dbo.Quenue
(SourceSystemId)

--добавила для ДЗ, но в проект я добавлять такое не стану, так как критична производительность, а эта проверка будет на стороне API
ALTER TABLE dbo.Files
   ADD CONSTRAINT CHK_Files_FileName   
   CHECK (FileName like '%.%')