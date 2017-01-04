
Create PROCEDURE wOPInlocuireComanda_p @sesiune VARCHAR(50), @parXML XML
AS
begin try
	select 
		@parXML.value('(/*/@comanda)[1]','varchar(20)') comanda_veche,
		@parXML.value('(/*/@dencomanda)[1]','varchar(20)') dencomanda_veche
	for xml raw, root('Date')
end try
begin catch

	declare @mesaj varchar(2000)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
end catch
