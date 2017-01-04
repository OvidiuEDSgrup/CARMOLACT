
CREATE PROCEDURE [dbo].[wScriuPozRapProductieSP] @sesiune VARCHAR(50), @parXML XML
AS


DECLARE @eroare VARCHAR(2000)

SET @eroare = ''

BEGIN TRY
	DECLARE --antet  
		@resursa VARCHAR(20), @data DATETIME, @nrdoc VARCHAR(20), @update BIT, @idRealizare INT, @idTehnologie INT, @idPozRealizare 
		INT, --pozitie  
		@cod VARCHAR(20), @cantitate FLOAT, @cm BIT, @pp BIT, @observatii VARCHAR(200), @gestiuneMP VARCHAR(20), @gestiunePF VARCHAR(
			20), @fXML XML, @cons XML, @pred XML, @nrPP VARCHAR(20), @utilizator VARCHAR(20), @semif VARCHAR(20), @comanda VARCHAR(20)
		, @subunitate VARCHAR(20), @detalii XML,@cod_intrare varchar(20)

	SET @nrdoc = @parXML.value('(/row/@nrDoc)[1]', 'varchar(20)')
	SET @resursa = isnull(@parXML.value('(/row/@codRes)[1]', 'varchar(20)'), @parXML.value('(/row/@resursa)[1]', 'varchar(20)'
			))
	SET @data = isnull(@parXML.value('(/row/@data)[1]', 'datetime'), GETDATE())
	SET @idRealizare = @parXML.value('(/row/@idRealizare)[1]', 'int')
	SET @nrPP =(case when  isnull(@parXML.value('(/row/@nrPP)[1]', 'varchar(20)'),'')='' then @parXML.value('(/row/row/@nrPP)[1]', 'varchar(20)')
	else @parXML.value('(/row/@nrPP)[1]', 'varchar(20)') end)
	--set @nrPP=null
	SET @gestiuneMP = @parXML.value('(/row/@gestCM)[1]', 'varchar(20)')
	SET @gestiunePF = @parXML.value('(/row/@gestPP)[1]', 'varchar(20)')
	SET @cod = isnull(@parXML.value('(/row/row/@cod)[1]', 'varchar(20)'), '')
	SET @semif = isnull(@parXML.value('(/row/row/@semif)[1]', 'varchar(20)'), '')
	SET @cantitate = isnull(@parXML.value('(/row/row/@cantitate)[1]', 'float'), 0)
	SET @cod_intrare = @parXML.value('(/row/row/@codintrare)[1]', 'varchar(20)')
	SET @observatii = isnull(@parXML.value('(/row/row/@observatii)[1]', 'varchar(200)'), '')
	--SET @ob = isnull(@parXML.value('(/row/row/@observatii)[1]', 'varchar(200)'), '')
	SET @update = isnull(@parXML.value('(/row/row/@update)[1]', 'bit'), 0)
	SET @idPozRealizare = @parXML.value('(/row/row/@id)[1]', 'int')
	SET @cm = isnull(@parXML.value('(/row/row/@consum)[1]', 'bit'), '0')
	--SET @pp = isnull(@parXML.value('(/row/row/@predare)[1]', 'bit'), '0')
	SET @pp =1
	SET @comanda = @parXML.value('(/row/row/@comanda)[1]', 'varchar(20)')
	if @parXML.exist('(/*/detalii)[1]')=1
		SET @detalii = @parXML.query('(row/row/detalii/row)[1]')
		


	EXEC luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate OUTPUT

	IF ISNULL(@comanda, '') <> ''
	BEGIN
		-- Pe comanda
		SELECT @semif = pt.cod
		FROM pozTehnologii pt
		JOIN pozLansari pl ON pl.tip = 'L'
			AND pl.cod = @comanda
			AND pt.id = pl.idp
	END

	SELECT TOP 1 @idTehnologie = id
	FROM pozTehnologii
	WHERE tip = 'T'
		AND cod = @semif
		AND idp IS NULL

	IF (@idTehnologie IS NULL)
		RAISERROR ('(wScriuPozRapProductie)Nu s-a identificat tehnologia pentru codul ales!', 16, 1)
		
	IF (@nrPP IS NULL)
		RAISERROR ('(wScriuPozRapProductie)Introduceti numarul predatii!', 16, 1)

	EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

	/** adaugare */
	IF @update = 0
	BEGIN
		/** adaugare antet */
		IF (@idRealizare IS NULL)
		BEGIN
			--Adaugare antet si pozitie  
			IF @nrdoc IS NULL
				OR @nrdoc = ''
				SELECT @nrdoc = ISNULL((
							SELECT MAX(convert(INT, nrDoc))
							FROM realizari
							WHERE isnumeric(nrdoc) = 1
							), 0) + 1

			INSERT INTO realizari (codResursa, data, nrDoc, detalii)
			VALUES (
				@resursa, @data, @nrdoc, (
					SELECT 'T' AS tip
					FOR XML raw
					)
				)

			SELECT @idRealizare = IDENT_CURRENT('Realizari')
		END
		--nr din plaja
		/*
		IF isnull(@nrPP, '') = ''
					EXEC wIauNrDocFiscale @fXML, @nrPP OUTPUT
					*/
		/** adaugare pozitie */
		IF (@idPozRealizare IS NULL)
		BEGIN
			INSERT INTO pozRealizari (idRealizare, idLegatura,tip,  cantitate, observatii, detalii, CM, PP
				)
			VALUES (@idRealizare, @idTehnologie,'T', @cantitate, @observatii, @detalii, NULL, NULL)

			SELECT @idPozRealizare = IDENT_CURRENT('pozRealizari')
					

			if @pp=1
			BEGIN
				/*Trebuie generat o predare*/
				IF isnull(@gestiunePF, '') = ''
					SET @gestiunePF = (
							SELECT TOP 1 valoare
							FROM proprietati
							WHERE tip = 'utilizator'
								AND cod = @utilizator
								AND Cod_proprietate = 'GESTPF'
							)

				IF rtrim(isnull(@gestiunePF, '')) = ''
				BEGIN
					SET @eroare = '(wScriuPozRapProductie)Nu s-a gasit gestiune pentru produs finit!' + CHAR(10) + 
						'Se opereaza in antet sau trebuie sa fie configurata in proprietatile utilizatorului curent, cod proprietate="GESTPF"!'

					RAISERROR (@eroare, 16, 1)
				END
/*
				IF @nrPP = ''
					RAISERROR ('(wScriuPozRapProductie)Nu pot aloca plaja de numare. Verificati plajele de PP-uri! (wScriuPozRapProductie)', 16, 1
							)

           if(@nrPP like'10%')
                        begin 
	                             set @nrPP=(select cast(cast(SUBSTRING(@nrPP,2,7) as int)	 as varchar(7)))
	                   end	
	                   */
				SET @pred = (
						SELECT 'PP' AS '@tip', @data AS '@data', @nrPP AS '@numar', '1' AS '@subunitate', @idPozRealizare AS 
							'@idRealizare', (
								SELECT TOP 1 (select (case when ISNULL(gestiune,'')='' then @gestiunePF else Gestiune end) from nomencl where cod=@semif) AS '@gestiune'
									, pt.cod AS '@cod', convert(DECIMAL(16, 5), @cantitate) AS '@cantitate', /*coalesce(@comanda, cod)*/'GEN' AS '@comanda', @resursa AS '@lm'
									, dateadd(d,n.Categorie,@data) as '@dataexpirarii'
								FROM pozTehnologii pt
									join nomencl n on n.Cod=pt.cod
								WHERE pt.tip = 'T'
									AND pt.cod = @semif
								FOR XML path, type
								)
						FOR XML path, type
						)

				UPDATE pozRealizari
				SET PP = @nrPP
				WHERE id = @idPozRealizare
--select @pred
				BEGIN TRY
					EXEC wScriuPozdoc @sesiune, @pred
				END TRY

				BEGIN CATCH
					SET @eroare = ERROR_MESSAGE()

					RAISERROR (@eroare, 16, 1)
				END CATCH
			END
			
			
			--------------

			IF ISNULL(@comanda, '') <> ''
				UPDATE comenzi
				SET Starea_comenzii = 'I'
				WHERE Subunitate = @subunitate
					AND Comanda = @comanda
		END
	END
	ELSE
	BEGIN 
		--RAISERROR ('(wScriuPozRapProductie)Nu se poate modifica (s-a generat PP si CM)!', 16, 1)
		update pozdoc set Cantitate=@cantitate where tip='PP' and Numar=@nrPP and DATA=@data and cod=@semif
		update pozRealizari set cantitate=@cantitate where PP=@nrPP and idRealizare=@idRealizare and 
		id=@idPozRealizare
	END
	
	if(isnull(@cod_intrare,'')!='')
	update pozdoc set Cod_intrare=@cod_intrare
	 where tip='PP' and Numar=@nrPP and DATA=@data and cod=@semif
	and Cantitate=@cantitate 
		
	SET @parXML = '<row idRealizare="' + convert(VARCHAR(20), @idRealizare) + '"/>'

	EXEC wIaPozRapProductieSP @sesiune = @sesiune, @parXML = @parXML
	--EXEC wIaRapProductie @sesiune = @sesiune, @parXML ='<row/>'
	--EXEC wIaPozRapProductie @sesiune = @sesiune, @parXML = @parXML
END TRY

BEGIN CATCH
	SET @eroare = '(wScriuPozRapProductieSP)' + CHAR(10) + rtrim(ERROR_MESSAGE())
END CATCH

IF (@eroare <> '')
	RAISERROR (@eroare, 16, 1)
	
