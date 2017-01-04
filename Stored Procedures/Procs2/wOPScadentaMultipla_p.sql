
CREATE PROCEDURE wOPScadentaMultipla_p @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	declare
		@tert varchar(20), @factura varchar(20)

	select 
		@tert = @parXML.value('(/*/@tert)[1]','varchar(20)'),
		@factura = @parXML.value('(/*/@factura)[1]','varchar(20)')

	set @parXML.modify('delete (/row/@tert)[1]')
	set @parXML.modify('delete (/row/@furnbenef)[1]')
	set @parXML.modify('delete (/row/@factura)[1]')
	set @parXML.modify('insert attribute furnizor {sql:variable("@tert")} into (/row)[1]')
	set @parXML.modify('insert attribute facturafurn {sql:variable("@factura")} into (/row)[1]')

	set @parXML.modify('insert attribute tert {("")} into (/row)[1]')
	set @parXML.modify('insert attribute factura {("")} into (/row)[1]')
	set @parXML.modify('insert attribute furnbenef {("B")} into (/row)[1]')

	select @parXML for xml path('Date')
END TRY
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH
