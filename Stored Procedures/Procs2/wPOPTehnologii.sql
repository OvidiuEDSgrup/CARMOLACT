


create procedure [dbo].[wPOPTehnologii] @sesiune varchar(50) ,@parXML xml
as

declare @eroare varchar(1000)
begin try
	declare @nr varchar(50)
	select	@nr=@parXML.value('(row/@nrPP)[1]','varchar(50)')
	--set @nr=(select id from pozLansari where cod=@nr)
	select  @nr as nr for xml raw
end try
begin catch
	set @eroare='wPOPNrConsum:'
		+char(10)+ERROR_MESSAGE()
	
end catch

if (@eroare is not null)
	raiserror(@eroare,16,1)
	
	