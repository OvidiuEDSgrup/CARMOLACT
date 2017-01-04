
CREATE PROCEDURE wmModificScadenta @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @cod VARCHAR(20), @scadenta INT, @tert VARCHAR(20), @comanda VARCHAR(20), @subunitate VARCHAR(9)

SET @cod = @parXML.value('(/row/@cod)[1]', 'varchar(20)')
SET @scadenta = @parXML.value('(/row/@scadenta)[1]', 'varchar(20)')
SET @tert = @parXML.value('(/row/@tert)[1]', 'varchar(20)')
SET @comanda = @parXML.value('(/row/@comanda)[1]', 'varchar(20)')
SET @subunitate = '1'

--Se salveaza datele si se revine la meniul de comanda
IF @scadenta IS NOT NULL
BEGIN
	UPDATE con
	SET Scadenta = @scadenta
	WHERE Subunitate = @subunitate
		AND tip = 'BK'
		AND tert = @tert
		AND contract = @comanda

	SELECT 'back(2)' AS actiune
	FOR XML raw, Root('Mesaje')
END

--Primul apel pentru autoselect cu datele initiale
SELECT 'Scadenta: ' + @cod + ' zile' AS denumire, @cod AS cod, '@scadenta' AS _numeAtr, '' AS info, 'wmModificScadenta' AS procdetalii
FOR XML raw, root('Date')

SELECT 'Modificare scadenta' AS titlu, dbo.f_wmIaForm('MS') AS 'form', 'D' AS tipdetalii, 'wmModificScadenta' AS _procdetalii, 
	'autoSelect' AS actiune
FOR XML raw, Root('Mesaje')
