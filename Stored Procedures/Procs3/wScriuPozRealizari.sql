
CREATE PROCEDURE [dbo].[wScriuPozRealizari] @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @codResursa VARCHAR(20), @idOperatieLans INT, @nrdoc INT, @idOperatiePlanif INT, @idPozRealizari INT, @cComanda VARCHAR(20), 
	@dataOperatii DATETIME, @cantitateLansare FLOAT, @observatii VARCHAR(400), @cantitate FLOAT, @comanda VARCHAR(80), @update BIT, 
	@idRealizare INT, @cm BIT, @nrCM VARCHAR(13), @fXML XML, @cons XML, @pred XML, @gestiuneMP VARCHAR(20), @eroare VARCHAR(200), 
	@utilizator VARCHAR(20), @detalii XML

SET @codResursa = ISNULL(@parXML.value('(/row/@resursa)[1]', 'varchar(20)'), '')
SET @dataOperatii = ISNULL(@parXML.value('(/row/@dataOperarii)[1]', 'datetime'), '')
SET @nrdoc = @parXML.value('(/row/@nrDoc)[1]', 'int')
SET @idRealizare = @parXML.value('(/row/@id)[1]', 'int')
SET @comanda = ISNULL(@parXML.value('(/row/row/@comanda)[1]', 'varchar(80)'), '')
SET @idOperatiePlanif = ISNULL(@parXML.value('(/row/row/@codOp)[1]', 'varchar(80)'), '')
SET @cantitate = ISNULL(@parXML.value('(/row/row/@cantitate)[1]', 'float'), 0)
SET @observatii = ISNULL(@parXML.value('(/row/row/@observatii)[1]', 'varchar(400)'), '')
SET @cm = ISNULL(@parXML.value('(/row/row/@cm)[1]', 'bit'), 0)
SET @update = ISNULL(@parXML.value('(/row/row/@update)[1]', 'int'), 0)
SET @idPozRealizari = @parXML.value('(/row/row/@id)[1]', 'int')
if @parXML.exist('(/*/detalii)[1]')=1
		SET @detalii = @parXML.query('(row/row/detalii/row)[1]')

EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

SELECT @gestiuneMP = dbo.wfProprietateUtilizator('GESTMP', @utilizator)

SELECT @idOperatieLans = idOp
FROM planificare
WHERE id = @idOperatiePlanif

IF @update = 0
BEGIN
	/** adaugare antet */
	IF (@idRealizare IS NULL)
	BEGIN
		--Adaugare antet 
		IF @nrdoc IS NULL
			OR @nrdoc = ''
			SELECT @nrdoc = ISNULL((
						SELECT MAX(convert(INT, nrDoc))
						FROM realizari
						WHERE isnumeric(nrdoc) = 1
						), 0) + 1

		INSERT INTO realizari (codResursa, data, nrDoc, detalii)
		VALUES (
			@codResursa, @dataOperatii, @nrdoc, (
				SELECT 'O' AS tip
				FOR XML raw
				)
			)

		SELECT @idRealizare = IDENT_CURRENT('Realizari')
	END

	/** adaugare pozitie */
	IF (@idPozRealizari IS NULL)
	BEGIN
		INSERT INTO pozRealizari (idLegatura, tip, idRealizare, cantitate, observatii, detalii, CM, PP)
		VALUES (@idOperatiePlanif, 'P', @idRealizare, @cantitate, @observatii, @detalii, NULL, NULL)

		SELECT @idPozRealizari = IDENT_CURRENT('pozRealizari')
	END

	IF @cm = 1
		/*Trebuie generat un consum*/
	BEGIN
		SELECT TOP 1 @cantitateLansare = antetLans.cantitate, @cComanda = pt.cod
		FROM pozLansari antetLans
		INNER JOIN pozLansari pozitii ON pozitii.id = @idOperatieLans
			AND antetLans.id = pozitii.idp
			AND antetLans.tip = 'L'
		INNER JOIN pozTehnologii pt ON pt.tip = 'T'
			AND pt.idp IS NULL
			AND pt.id = antetLans.idp

		SET @fXML = '<row tip="CM"/>'
		SET @fXML.modify('insert attribute utilizator {sql:variable("@utilizator")} into (/row)[1]')

		EXEC wIauNrDocFiscale @parXML = @fXML, @Numar = @nrCM OUTPUT

		SET @cons = (
				SELECT 'CM' AS '@tip', @dataOperatii AS '@data', @nrCM AS '@numar', '1' AS '@subunitate', @idPozRealizari AS 
					'@idRealizare', (
						SELECT @gestiuneMP AS '@gestiune', rtrim(cod) AS '@cod', convert(DECIMAL(12, 2), cantitate * @cantitate / 
								@cantitateLansare) AS '@cantitate', @comanda AS '@comanda', @codResursa AS '@lm'
						FROM pozLansari
						WHERE tip = 'M'
							AND idp = @idOperatieLans
						FOR XML path, type
						)
				FOR XML path, type
				)

		UPDATE pozRealizari
		SET CM = @nrCM
		WHERE id = @idPozRealizari

		BEGIN TRY
			EXEC wScriuPozdoc @sesiune = @sesiune, @parXML = @cons
		END TRY

		BEGIN CATCH
			SET @eroare = ERROR_MESSAGE()

			RAISERROR (@eroare, 16, 1)
		END CATCH
	END
END
ELSE
	IF @update = 1
	BEGIN
		RAISERROR ('(wScriuPozRealizari)Nu se poate modifica (s-a generat CM)!', 16, 1)
	END

DECLARE @docXMLIaPozReal XML

SET @docXMLIaPozReal = '<row id="' + rtrim(@idRealizare) + '"/>'

EXEC wIaPozRealizari @sesiune = @sesiune, @parXML = @docXMLIaPozReal
