
CREATE PROCEDURE wOPInvalidareNomenclatorSpecific @sesiune varchar(50), @parXML xml
AS
BEGIN TRY
	
	DECLARE @utilizator varchar(50), @tert varchar(50), @cod_invalidare varchar(1),
		@data datetime, @anulare bit, @xml xml, @cod varchar(50), @codSpecific varchar(50)

	EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT
	
	SELECT @tert = ISNULL(@parXML.value('(/row/@tert)[1]', 'varchar(50)'), ''),
		@cod_invalidare = ISNULL(@parXML.value('(/row/@cod_invalidare)[1]', 'varchar(1)'), ''),
		@data = @parXML.value('(/row/@data)[1]', 'datetime'),
		@anulare = ISNULL(@parXML.value('(/row/@anulare)[1]', 'bit'), 0),
		@cod = @parXML.value('(/row/@cod)[1]', 'varchar(50)'),
		@codSpecific = @parXML.value('(/row/@cod_specific)[1]', 'varchar(50)')
	
	/** Validari */
	IF @tert = ''
		RAISERROR('Tert inexistent!', 16, 1)

	IF @cod_invalidare = ''
		RAISERROR('Tipul de invalidare nu este completat!', 16, 1)
	

	IF OBJECT_ID('tempdb.dbo.#tempCatalog') IS NOT NULL
		DROP TABLE #tempCatalog
	
	SELECT *, ISNULL(detalii.value('(/row/@invalid)[1]', 'varchar(100)'), '') AS invalid
	INTO #tempCatalog FROM nomspec
	WHERE Tert = @tert AND Cod = @cod AND Cod_special = @codSpecific


	/** Trimitem parametrii la procedura de invalidare, care va scrie in detalii */
	SET @xml = (SELECT @cod_invalidare AS cod_invalidare, @data AS data, @anulare AS anulare FOR XML RAW)
	EXEC invalideazaObiectCatalog @sesiune = @sesiune, @parXML = @xml


	/** In final, facem update la tabela reala "nomspec" */
	UPDATE t
		SET t.detalii = l.detalii
	FROM nomspec t
	INNER JOIN #tempCatalog l ON l.Tert = t.Tert AND l.Cod = t.Cod AND l.Cod_special = t.Cod_special

END TRY
BEGIN CATCH
	DECLARE @mesajEroare varchar(1000)
	SET @mesajEroare = ERROR_MESSAGE() + char(10) + '(' + OBJECT_NAME(@@PROCID) + ')'
	RAISERROR(@mesajEroare, 16, 1)
END CATCH
