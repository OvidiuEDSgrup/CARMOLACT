
CREATE PROCEDURE wOPLansareArticol @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	DECLARE @cod VARCHAR(20), @cantitate FLOAT, @contract VARCHAR(20), @idTehnologie INT, @comanda VARCHAR(20), @tert VARCHAR(20), 
		@doc XML, @termen DATETIME, @datalansarii DATETIME, @tipcontract VARCHAR(2), @mesaj VARCHAR(400)

	SET @cod = @parXML.value('(/*/@cod)[1]', 'varchar(20)')
	SET @contract = @parXML.value('(/*/@comanda)[1]', 'varchar(20)')
	SET @tert = @parXML.value('(/*/*/@codtert)[1]', 'varchar(20)')
	SET @tipcontract = @parXML.value('(/*/*/@tipcontract)[1]', 'varchar(2)')
	SET @cantitate = @parXML.value('(/*/@delansat)[1]', 'float')
	SET @termen = @parXML.value('(/*/*/@termen)[1]', 'datetime')
	SET @datalansarii = @parXML.value('(/*/*/@datalansarii)[1]', 'datetime')

	IF (
			SELECT @parXML.exist('(/*/*)')
			) <> 1
	BEGIN
		RAISERROR (
				'Nu este posibila generarea comenzii de productie din antet- selectati o pozitie din tabelul de pozitii!'
				, 11, 1
				)

		RETURN - 1
	END

	SET @doc = (
			SELECT @cod AS cod, @cantitate AS cantitate, @tert AS tert, @contract AS contract, @datalansarii AS data, @tipcontract 
				tipcontract
			FOR XML raw
			)

	EXEC wScriuPozLansari @sesiune = @sesiune, @parXML = @doc
END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (wOPLansareArticol)'

	RAISERROR (@mesaj, 11, 1)
END CATCH
