
CREATE PROCEDURE wACPlajaFacturiFiscale @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	declare
		@searchtext varchar(300)

	select
		@searchText = '%' + replace(ISNULL(@parXML.value('(/row/@searchText)[1]', 'varchar(100)'), ''), ' ', '%') + '%'
	
	select
		df.Id cod, 
		rtrim(ltrim(ISNULL(descriere, ''))) +'-Serie: ' + isnull(nullif(serie,''), '') + ' '+ convert(Varchar(20), numarinf) + ' - '+ convert(Varchar(20), numarsup) denumire,
		'Ultim nr: '+ convert(Varchar(100), df.UltimulNr) info
	from DocFiscale df
	where df.factura=1
	for xml raw, root('Date')

END TRY
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH
