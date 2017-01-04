CREATE 
--alter 
Procedure [dbo].[back_zilnic]
@cale varchar(100), @nume varchar(100)
As

Declare @dData DATETIME
Declare @cData varchar(20)
Declare @numefisier varchar(100)

Set @dData = GETDATE()
Set @cData = convert (varchar(100),@dData,126)
Set @cData = Replace( Replace( Replace(@cData,'-','_'), ' ','_'), ':', '')
Set @numefisier = rtrim(@nume)+'_'+rtrim(@cData)+'.bak'

if right(rtrim(@cale),1) <> '\' Set @cale = rtrim(@cale)+'\'
Set @cale = 'Backup Database '+rtrim(@nume)+' to Disk = '''+rtrim(@cale)+rtrim(@numefisier)+''' WITH INIT'

exec (@cale)
