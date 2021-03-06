﻿
CREATE PROCEDURE [dbo].[wOPGenerareAntecalculatii] @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @docXML XML, @tip VARCHAR(2), @numarDoc VARCHAR(20), @data DATETIME, @cod VARCHAR(20), @scriuPret BIT, @mesaj VARCHAR(600), 
	@curs FLOAT, @valuta VARCHAR(10)

BEGIN TRY
	SET @tip = @parXML.value('(/*/@tip_antec)[1]', 'varchar(2)')
	SET @numarDoc = @parXML.value('(/*/@numarDoc)[1]', 'varchar(20)')
	SET @data = @parXML.value('(/*/@data)[1]', 'datetime')
	SET @cod = @parXML.value('(/*/@cod)[1]', 'varchar(20)')
	SET @scriuPret = isnull(@parXML.value('(/*/@scriuPret)[1]', 'bit'), 0)
	SET @valuta = @parXML.value('(/*/@valuta)[1]', 'varchar(10)')
	SET @curs = isnull(@parXML.value('(/*/@curs)[1]', 'float'), 1)

	IF @curs = 0
		SET @curs = 1

	IF @tip = 'C'
	BEGIN
		SET @docXML = (
				SELECT @numarDoc AS numarDoc, @data AS data, @cod AS cod, @scriuPret scriuPret, @curs curs, @valuta valuta
				FOR XML raw
				)
	END
	ELSE
		IF @tip = 'G'
			SET @docXML = (
					SELECT @numarDoc AS numarDoc, @data AS data, @cod AS grupa, @scriuPret scriuPret, @curs curs, @valuta valuta
					FOR XML raw
					)
		ELSE
			SET @docXML = (
					SELECT @numarDoc AS numarDoc, @data AS data, @scriuPret scriuPret, @curs curs, @valuta valuta
					FOR XML raw
					)

	EXEC GenerareAntecalculatii @sesiune = @sesiune, @parXML = @docXML
END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (wOPGenerareAntecalculatii)'

	RAISERROR (@mesaj, 11, 1)
END CATCH
