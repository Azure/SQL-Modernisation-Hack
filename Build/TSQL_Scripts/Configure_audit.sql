USE master;

CREATE CREDENTIAL [https://sqlhacksawdwzgxbjsu57o.blob.core.windows.net/auditlogs]
WITH IDENTITY='SHARED ACCESS SIGNATURE',
SECRET = 'sp=racwdl&st=2022-01-19T11:26:23Z&se=2022-03-01T19:26:23Z&spr=https&sv=2020-08-04&sr=c&sig=gNK6alS4NOwtp1s5z3iQn%2FyvXkYj7IqqB0MhZhw1MbE%3D'
GO

CREATE SERVER AUDIT [sqlmi_auditlog]
TO URL ( PATH ='https://sqlhacksawdwzgxbjsu57o.blob.core.windows.net/auditlogs' 
, RETENTION_DAYS =  30 )
GO

ALTER SERVER AUDIT [sqlmi_auditlog]
WITH (STATE = ON)
GO
