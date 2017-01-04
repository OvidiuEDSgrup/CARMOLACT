

CREATE procedure [dbo].[wPOPNrConsum] @sesiune varchar(50) ,@parXML xml
as

declare @eroare varchar(1000)
begin try
	declare @nr varchar(50),@cantL float,@cod varchar(20),@cant float
	select	@nr=@parXML.value('(row/row/@nrPP)[1]','varchar(50)')
	select @cod=@parXML.value('(row/row/@cod)[1]','varchar(50)')
	set @cant=@parXML.value('(row/row/@cantitate)[1]','float')
	select @cantL=@cant*(select cantitate from poztehnologii where tip='M' and idp=( select id from pozTehnologii where tip='T' and cod=@cod)
	and cod='L')
	
	
	select  @nr as nr,cast(@cantL as varchar(10)) as cantL for xml raw
end try
begin catch
	set @eroare='wPOPNrConsum:'
		+char(10)+ERROR_MESSAGE()
	
end catch

if (@eroare is not null)
	raiserror(@eroare,16,1)
	
	