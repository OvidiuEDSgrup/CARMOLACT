
CREATE PROCEDURE [dbo].[wStergPozRapProductieSP] @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @nrCM VARCHAR(20), @nrPP VARCHAR(20), @idPozRealizari INT, @idRealizare INT, @eroare VARCHAR(256), @comanda VARCHAR(20),
@cod varchar(20),@cantitate float,@data datetime,@id int

SET @nrCM = ISNULL(@parXML.value('(/row/row/@nrCM)[1]', 'varchar(20)'), '')
SET @nrPP = ISNULL(@parXML.value('(/row/row/@nrPP)[1]', 'varchar(20)'), '')
SET @data = @parXML.value('(/row/@data)[1]', 'datetime')
SET @idPozRealizari = ISNULL(@parXML.value('(/row/row/@id)[1]', 'int'), 0)
SET @idRealizare = @parXML.value('(/row/@idRealizare)[1]', 'int')
SET @comanda = @parXML.value('(/row/row/@comanda)[1]', 'varchar(20)')
SET @cod = @parXML.value('(/row/row/@cod)[1]', 'varchar(20)')
SET @cantitate = @parXML.value('(/row/row/@cantitate)[1]', 'float')
SET @id = @parXML.value('(/row/row/@id)[1]', 'int')
BEGIN TRY


if(@nrCM!='')
raiserror('wStergPozRapProductieSP: Documentul are generat consum!',11,1)
	DELETE 
	FROM pozdoc
	WHERE Subunitate = '1'
		AND tip = 'PP'
		AND Numar = @nrPP
		and cod=@cod
		and DATA=@data
		

	--and Comanda=@comanda
	/*
	DELETE
	FROM pozdoc
	WHERE Subunitate = '1'
		AND tip = 'CM'
		AND Numar = @nrCM
		AND detalii.value('(/row/@idRealizare)[1]', 'int') = @idPozRealizari
		*/

	--and comanda =@comanda
	DELETE
	FROM pozRealizari
	WHERE id = @id
END TRY

BEGIN CATCH
	SET @eroare = '(wStergPozRapProductieSP):' + CHAR(10) + rtrim(ERROR_MESSAGE())
END CATCH

IF (@eroare <> '')
	RAISERROR (@eroare, 16, 1)

	SET @parXML = '<row idRealizare="' + convert(VARCHAR(20), @idRealizare) + '"/>'

	EXEC wIaPozRapProductieSP @sesiune = @sesiune, @parXML = @parXML
