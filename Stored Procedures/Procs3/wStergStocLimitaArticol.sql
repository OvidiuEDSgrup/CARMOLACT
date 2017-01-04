
CREATE PROCEDURE wStergStocLimitaArticol @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	declare
		@cod varchar(20), @gestiune varchar(20), @stocmin float, @stocmax float, @update bit

	select
		@cod = @parXML.value('(//@cod)[1]','varchar(20)'),
		@gestiune = @parXML.value('(/*/*/@gestiune)[1]','varchar(20)')
		
	delete StocLim where cod_gestiune=@gestiune and cod=@cod

	
END TRY
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH
