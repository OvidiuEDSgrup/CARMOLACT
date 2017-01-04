
CREATE PROCEDURE wIaStocLimitaArticol @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	declare
		@cod varchar(20), @cautare varchar(200)

	select
		@cod = @parXML.value('(//@cod)[1]','varchar(20)'),
		@cautare = '%' + @parXML.value('(//@_cautare)[1]','varchar(200)')+'%'

	select
		rtrim(g.cod_gestiune) gestiune, rtrim(g.denumire_gestiune) dengestiune,
		convert(decimal(17,2), sl.stoc_min) stocmin, convert(decimal(17,2), sl.stoc_max) stocmax
	from StocLim sl
	JOIN Gestiuni g on g.cod_gestiune=sl.cod_gestiune
	where (@cautare is null or g.cod_gestiune like @cautare or g.denumire_gestiune like @cautare) and sl.cod=@cod
	for xml raw, root('Date')
		
	
END TRY
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH
