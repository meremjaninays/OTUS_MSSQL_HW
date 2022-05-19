CREATE DATABASE IntegrationDB
ON PRIMARY
( NAME = IntegrationDB_dat,
    FILENAME = 'C:\OTUS_MSSQL_Repo\Data\IntegrationDB.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = IntegrationDB_log,
    FILENAME = 'C:\OTUS_MSSQL_Repo\Log\IntegrationDB.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB )
COLLATE cyrillic_general_ci_as;

ALTER DATABASE IntegrationDB SET RECOVERY SIMPLE;