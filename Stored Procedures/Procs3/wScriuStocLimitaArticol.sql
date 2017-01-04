
CREATE PROCEDURE wScriuStocLimitaArticol @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	declare
		@cod varchar(20), @gestiune varchar(20), @stocmin float, @stocmax float, @update bit

	select
		@cod = @parXML.value('(//@cod)[1]','varchar(20)'),
		@gestiune = @parXML.value('(/*/*/@gestiune)[1]','varchar(20)'),
		@stocmin = @parXML.value('(/*/*/@stocmin)[1]','float'),
		@stocmax = @parXML.value('(/*/*/@stocmax)[1]','float'),
		@update = ISNULL(@parXML.value('(//@update)[1]','bit'),0)

	IF @update = 1
		update StocLim set stoc_min = @stocmin, stoc_max=@stocmax, data=getdate() where cod_gestiune=@gestiune and cod=@cod
	else
		insert into StocLim (Subunitate, Tip_gestiune, Cod_gestiune, Cod, Data, Stoc_min, Stoc_max, Pret, Locatie)
		select '1', '', @gestiune, @cod, getdate(), @stocmin, @stocmax, 0, ''

	IF EXISTS (SELECT * FROM sysobjects WHERE NAME = 'wScriuStocLimitaArticolSP1')
		Exec wScriuStocLimitaArticolSP1 @sesiune = @sesiune, @parXML = @parXML
		
END TRY
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH
