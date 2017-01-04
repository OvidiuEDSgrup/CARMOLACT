
CREATE PROCEDURE wOPPreluareFacturiInOrdineDePlata @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	DECLARE 
		@idOP INT, @docPozitii XML, @data DATETIME, @cont VARCHAR(20), @conturiFiltru VARCHAR(max), @datascadentei datetime, 
		@tert VARCHAR(20), @mesaj VARCHAR(500), @explicatii varchar(500), @tip_sume int, @adaug_in_existent bit

	SELECT
		@cont = @parXML.value('(/*/@cont)[1]', 'varchar(20)'),
		@data = @parXML.value('(/*/@data)[1]', 'datetime'),
		@datascadentei = isnull(@parXML.value('(/*/@datascadentei)[1]', 'datetime'),getdate()), 
		@tert= @parXML.value('(/*/@tert)[1]', 'varchar(20)'),
		@explicatii= @parXML.value('(/*/@explicatii)[1]', 'varchar(500)'),
		@tip_sume= isnull(@parXML.value('(/*/@tip_sume)[1]', 'int'),1),
		@idOP = @parXML.value('(/*/@idOP)[1]', 'int')

	IF OBJECT_ID('tempdb..#pozitiiPreluare') IS NOT NULL
		DROP TABLE #pozitiiPreluare
	
	IF @parXML.exist('(/parametri/row)[1]')=0
		select @idOP = null


	CREATE TABLE #pozitiiPreluare (tert VARCHAR(20), factura VARCHAR(20), sold decimal(19,2),data_scadentei datetime,soldscadent float)

	declare 
		@parXMLFact xml

	if OBJECT_ID('tempdb..#pfacturi') IS NOT NULL
		DROP TABLE #pfacturi
	CREATE TABLE #pfacturi (subunitate varchar(9))

	exec CreazaDiezFacturi @numeTabela='#pfacturi'

	set @parXMLFact=(select 'F' as furnbenef, GETDATE() as datasus, 1 as cen, 1 as grtert, 1 as grfactura, 0.01 as soldmin, 0 as semnsold, 0 inclfacturine, nullif(@tert,'') tert for xml raw)
	exec pFacturi @sesiune=@sesiune, @parXML=@parXMLFact

	IF EXISTS (SELECT * FROM sysobjects WHERE NAME = 'CalculScadenteMultiple')
	begin
		exec CalculScadenteMultiple 'wOPPreluareFacturiInOrdineDePlata'
	end

	INSERT INTO #pozitiiPreluare (tert, factura, sold,data_scadentei,soldscadent)
	SELECT rtrim(tert) tert, rtrim(Factura) factura, (case @tip_sume WHEN 1 then convert(decimal(19,2),sold) else 0.0 end),data_scadentei,convert(decimal(19,2),sold)
	from #pfacturi
	WHERE Data_scadentei <= @datascadentei


	SET @docPozitii = (
			select
				'1' AS preluare, @data data, @cont cont, 'F' sursa,'1' fara_luare_date,'FA' tip,'FA' tipOP,@explicatii explicatii, @idOP idOP,
				(
					select
						@idOP idOP,rtrim(p.tert) tert, rtrim(p.factura) factura, rtrim(t.banca) banca, rtrim(t.cont_in_banca) iban, 'FA' tip, p.sold suma,
						'0' stare,	'Factura '+rtrim(p.factura) explicatii,data_scadentei,soldscadent
					from #pozitiiPreluare p
					LEFT JOIN terti t ON t.Tert = p.tert
					for xml raw, type
				)
			for xml raw)
	EXEC wScriuPozOrdineDePlata @sesiune = @sesiune, @parXML = @docPozitii
END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (wOPPreluareFacturiInOrdineDePlata)'

	RAISERROR (@mesaj, 11, 1)
END CATCH
