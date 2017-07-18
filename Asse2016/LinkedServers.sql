print '#####################################################'
--Nombre del servidor
print @@servername
print 'Fecha de ejecución; ' + ((CONVERT( VARCHAR(24), GETDATE(), 121)))+ char(10)
print '#####################################################'
print ' ' 
print '----------------------LINKED SERVERS------------------------'+ CHAR(10)
print ''

PRINT'**DATOS GENERALES DE LINKED SERVERS'+ CHAR(20)
Go
cREATE TABLE #GeneralTem(
ID int not null,
SrvName varchar (20),
LocaloginID INT,
LocalLogin varchar (20),
RemotUser varchar (20),
ModifyDate date
)
Go
Insert into #GeneralTem
SELECT A.[server_id], B.[name], A.[local_principal_id], C.[name], A.[remote_name], A.[modify_date]
FROM 
	[master].[sys].[linked_logins] A 
	RIGHT JOIN 
	[master].[sys].[servers] B 
 ON 
	A.[server_id] = B.server_id  

	LEFT JOIN [master].[sys].[server_principals] AS C
	ON A.[local_principal_id]  = C.[principal_id]

Go
select * from #GeneralTem
drop table #GeneralTem

PRINT '**DATOS ESPECIFICOS DE LINKED SERVERS'+ CHAR(20)
GO
 Create table #especificTem
 (
 [name] nvarchar (15) null,
 product nvarchar (15) null,
 [provider] nvarchar (15) null,
 EsLinked bit null, 
 CollationComp bit null,
 DataAccess bit not null,
 RCP bit not null,
 UseRemote bit not null,
 [provider_string] nvarchar (4000) null
 )
 GO
 Insert into #especificTem
 SELECT [name],[product],[provider], [is_linked] as EsLinked, [is_collation_compatible] as CollationComp,[is_data_access_enabled] as DataAccess,[is_rpc_out_enabled] as RPC,[is_remote_login_enabled] as UseRemote,[provider_string]
FROM [master].[sys].[linked_logins] A RIGHT JOIN [master].[sys].[servers] B
 ON A.[server_id] = B.[server_id]
 go
 
 select * from #especificTem
 drop table #especificTem