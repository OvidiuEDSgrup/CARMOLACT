
CREATE PROCEDURE wScriuPozRapProductie @sesiune VARCHAR(50), @parXML XML
AS
IF EXISTS (
		SELECT *
		FROM sysobjects
		WHERE NAME = 'wScriuPozRapProductieSP'
			AND type = 'P'
		)
BEGIN
	EXEC wScriuPozRapProductieSP @sesiune = @sesiune, @parXML = @parXML

	RETURN
END
BEGIN TRY
	DECLARE --antet  
		@data DATETIME, @nrdoc VARCHAR(20), @update BIT, @idRealizare INT, @idTehnologie INT, @idPozRealizare INT, 
		--pozitie  
		@cod VARCHAR(20), @cantitate FLOAT,@observatii VARCHAR(200), @gestiuneMP VARCHAR(20), @gestiunePF VARCHAR(20), @fXML XML,
		@utilizator VARCHAR(20), @semif VARCHAR(20), @comanda VARCHAR(20), @subunitate VARCHAR(20), @detalii XML, @eroare VARCHAR(2000), 
		@docPlajaRealiz xml, @detaliiPozDoc xml, @tip varchar(20), @resursa int

	SET @nrdoc = @parXML.value('(/row/@numar_doc)[1]', 'varchar(20)')
	SET @tip = @parXML.value('(/row/@tip)[1]', 'varchar(2)')
	SET @resursa = @parXML.value('(/row/@resursa)[1]', 'int')
	SET @data = isnull(@parXML.value('(/row/@data)[1]', 'datetime'), GETDATE())
	SET @idRealizare = @parXML.value('(/row/@idRealizare)[1]', 'int')
	SET @gestiuneMP = @parXML.value('(/row/@gestCM)[1]', 'varchar(20)')
	SET @gestiunePF = @parXML.value('(/row/@gestPP)[1]', 'varchar(20)')
	SET @cod = @parXML.value('(/row/row/@cod_tehnologie)[1]', 'varchar(20)')
	SET @cantitate = @parXML.value('(/row/row/@cantitate)[1]', 'float')
	SET @observatii = @parXML.value('(/row/row/@observatii)[1]', 'varchar(200)')
	SET @update = isnull(@parXML.value('(/row/row/@update)[1]', 'bit'), 0)
	SET @idPozRealizare = @parXML.value('(/row/row/@id)[1]', 'int')
	if @parXML.exist('(/*/*/detalii)[1]')=1
		SET @detalii = @parXML.query('(row/row/detalii/row)[1]')

	EXEC luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate OUTPUT

	
	SELECT TOP 1 @idTehnologie = id
	FROM pozTehnologii
	WHERE tip = 'T'
		AND cod = @cod
		AND idp IS NULL

	IF (@idTehnologie IS NULL)
		RAISERROR ('Nu s-a identificat tehnologia pentru codul ales!', 16, 1)

	EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

	/** Adaugare */
	IF @update = 0
	BEGIN
		/** Adaugare antet */
		IF (@idRealizare IS NULL)
		BEGIN
			/** Adaugare antet si pozitie  --*/
			
			/** Se ia numar din plaja de doc. de Realizari **/			
			SET @docPlajaRealiz = '<row tip="RP"/>'
			SET @docPlajaRealiz.modify('insert attribute utilizator {sql:variable("@utilizator")} into (/row)[1]')

			EXEC wIauNrDocFiscale @parXML=@docPlajaRealiz,@numar=@nrdoc OUTPUT

			IF isnull(@nrdoc, '') = ''
				RAISERROR ('Nu pot aloca numar pentru doc. de realizare. Verificati plajele pt tipul de document "RP"! ', 16, 1)

			INSERT INTO realizari (data, nrDoc,tip,idResursa)
			VALUES (@data, @nrdoc,@tip,@resursa )
			SELECT @idRealizare = IDENT_CURRENT('Realizari')

			set @detaliiPozDoc= (select @idRealizare as idRealizare for xml raw)
		END

		/** Adaugare pozitie */
		IF (@idPozRealizare IS NULL)
		BEGIN
			INSERT INTO pozRealizari (idRealizare,idResursa,idPozTehnologie, cantitate, observatii, detalii)
			VALUES (@idRealizare,@resursa, @idTehnologie, @cantitate, @observatii, @detalii)
			SELECT @idPozRealizare = IDENT_CURRENT('pozRealizari')			
		END
	END
	Else
	begin
		select @detalii
		update pozRealizari 
			set cantitate=@cantitate, observatii=@observatii, detalii=@detalii
		where id=@idPozRealizare
	end

	SET @parXML =( select @idRealizare as  idRealizare, @tip tip for xml raw)

	EXEC wIaPozRapProductie @sesiune = @sesiune, @parXML = @parXML
END TRY

BEGIN CATCH
	SET @eroare = ERROR_MESSAGE()+ ' (wScriuPozRapProductie)'
	raiserror(@eroare, 11, 1)
END CATCH