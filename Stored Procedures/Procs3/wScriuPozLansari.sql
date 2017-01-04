
CREATE PROCEDURE [dbo].[wScriuPozLansari] @sesiune VARCHAR(50), @parXML XML
AS
IF EXISTS (
		SELECT *
		FROM sysobjects
		WHERE NAME = 'wScriuPozLansariSP'
			AND type = 'P'
		)
BEGIN
	EXEC wScriuPozLansariSP @sesiune = @sesiune, @parXML = @parXML

	RETURN
END

DECLARE @cod VARCHAR(20), @cuPlanificare BIT, @cantitate FLOAT, @idTehnologie INT, @tipLansare BIT, @comanda VARCHAR(20), @descriere 
	VARCHAR(80), @tipComanda VARCHAR(10), @dataLansarii DATETIME, @termen DATETIME, @stareComanda VARCHAR(10), @lm VARCHAR(20), 
	@tert VARCHAR(20), @contract VARCHAR(20), @doc XML, @mesaj VARCHAR(200), @update BIT, @id INT, @fXML XML, @utilizator VARCHAR(100), 
	@nrDoc INT, @idLansare INT, @resursa VARCHAR(20), @detalii XML, @tip VARCHAR(1), @comandaBenef VARCHAR(20), @tipContract VARCHAR(
		2)

SET @cod = @parXML.value('(/row/@cod)[1]', 'varchar(20)')
SET @cantitate = @parXML.value('(/row/@cantitate)[1]', 'float')
SET @tert = @parXML.value('(/row/@tert)[1]', 'varchar(20)')
SET @dataLansarii = isnull(@parXML.value('(/row/@data)[1]', 'datetime'), GETDATE())
SET @termen = @parXML.value('(/row/@termen)[1]', 'datetime')
SET @contract = @parXML.value('(/row/@contract)[1]', 'varchar(20)')
SET @resursa = @parXML.value('(/row/@resursa)[1]', 'varchar(20)')
SET @update = isnull(@parXML.value('(/row/row/@update)[1]', 'bit'), 0)
SET @idLansare = isnull(@parXML.value('(/row/@id)[1]', 'int'), 0)
SET @comandaBenef = @parXML.value('(/row/@comandaBenef)[1]', 'VARCHAR(20)')
SET @tipContract = @parXML.value('(/*/@tipcontract)[1]', 'VARCHAR(2)')
--SET @stareComanda = 'L'
SET @stareComanda = isnull(@parXML.value('(/row/@stareComanda)[1]', 'varchar(20)'), 'L')
--SET @tipComanda = 'P'
SET @tipComanda = isnull(@parXML.value('(/row/@tipComanda)[1]', 'varchar(20)'), 'P')
SET @comanda = @parXML.value('(/row/@comanda)[1]', 'VARCHAR(20)')

IF @parXML.exist('(/*/detalii/row)[1]') = 1
	SET @detalii = @parXML.query('(row/row/detalii/row)[1]')

IF @update = 0
BEGIN
	DECLARE @codPoz VARCHAR(20), @cantPoz FLOAT, @idLinie INT

	SET @codPoz = isnull(@parXML.value('(/row/row/@cod)[1]', 'varchar(20)'), '')
	SET @cantPoz = isnull(@parXML.value('(/row/row/@cantitate)[1]', 'float'), 0)
	SET @idLinie = @parXML.value('(/row/linie/@id)[1]', 'int')

	IF @idLansare <> 0
		AND @codPoz <> ''
		AND @cantPoz > 0
	BEGIN
		IF (
				SELECT tip
				FROM pozLansari
				WHERE id = @idLinie
				) NOT IN ('O', 'L', 'R')
		BEGIN
			RAISERROR (
					'Nu se pot adauga materiale/operatii decat subordonate unui reper, osau produsului!(wScriuPozLansari)'
					, 11, 1
					)

			RETURN
		END

		SELECT @tip = (CASE WHEN @parXML.value('(/row/row/@subtip)[1]', 'varchar(2)') = 'OP' THEN 'O' ELSE 'M' END)

		INSERT INTO pozLansari (tip, cod, cantitate, idp, parinteTop, detalii)
		VALUES (@tip, @codPoz, @cantPoz, @idLinie, @idLansare, @detalii)
	END

	IF @idLansare = 0
	BEGIN
		--Adaugare lansare (+)
		EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

		EXEC luare_date_par 'MP', 'TIPLANS', 0, @tipLansare OUTPUT, ''

		EXEC luare_date_par 'MP', 'CUPLANIF ', @cuPlanificare OUTPUT, 0, ''

		SET @fXML = '<row tip="UK"/>'
		SET @fXML.modify('insert attribute utilizator {sql:variable("@utilizator")} into (/row)[1]')

		EXEC wIauNrDocFiscale @parXML = @fXML, @Numar = @nrDoc OUTPUT

		SELECT @comanda = (CASE @tipComanda WHEN 'P' THEN 'L' WHEN 'X' THEN 'I' END) + CONVERT(VARCHAR(19), @nrDoc)

		SELECT TOP 1 @idTehnologie = pt.id, @descriere = coalesce(n.denumire, t.denumire, '')
		FROM pozTehnologii pt
		INNER JOIN tehnologii t
			ON t.cod = pt.cod
				AND pt.tip = 'T'
				AND pt.idp IS NULL
				AND pt.cod = @cod
		LEFT JOIN nomencl n
			ON n.Cod = pt.cod

		--Scriere in dependenteLans  
		INSERT INTO dependenteLans (comanda, cod, tert, contract, comandaleg, detalii, tip)
		VALUES (isnull(@contract, ''), @cod, @tert, @contract, @comanda, NULL, @tipContract)

		CREATE TABLE #id (id INT)

		IF @tipLansare = 0
			--Cu structura, scriete toata tehnologia  
		BEGIN
			INSERT INTO pozLansari (tip, cod, cantitate, idp, resursa, detalii)
			OUTPUT inserted.id
			INTO #id
			VALUES ('L', @comanda, @cantitate, @idTehnologie, @resursa, @detalii)

			SELECT TOP 1 @id = id
			FROM #id;

			WITH arbore (id, tip, cod, resursa, cantitate, idp, parinteTop, idNou, nivel)
			AS (
				SELECT id, tip, cod, resursa, @cantitate, idp, parinteTop, @id, 0
				FROM poztehnologii
				WHERE id = @idTehnologie
				
				UNION ALL
				
				SELECT pTehn.id, pTehn.tip, pTehn.cod, pTehn.resursa, pTehn.cantitate * arb.cantitate, pTehn.idp, pTehn.
					parinteTop, 0, arb.nivel + 1
				FROM pozTehnologii pTehn
				INNER JOIN arbore arb
					ON pTehn.tip IN ('M', 'O', 'R')
						AND arb.id = pTehn.idp
				)
			SELECT *
			INTO #tmpTehnologie
			FROM arbore

			DECLARE @nivel INT, @maiSuntRanduri INT

			SET @nivel = 1
			SET @maiSuntRanduri = 1

			CREATE TABLE #idNoi (id INT, cod VARCHAR(20), tip VARCHAR(20))

			WHILE @maiSuntRanduri > 0
			BEGIN
				INSERT INTO pozLansari (tip, cod, resursa, cantitate, idp, parinteTop)
				OUTPUT inserted.ID, inserted.cod, inserted.tip
				INTO #idNoi(id, cod, tip)
				SELECT tp.tip, tp.cod, tp.resursa, tp.cantitate, tp2.idNou, @id
				FROM #tmpTehnologie tp
				LEFT JOIN #tmpTehnologie tp2
					ON tp.idp = tp2.id
				WHERE tp.nivel = @nivel

				SET @maiSuntRanduri = @@ROWCOUNT

				UPDATE #tmpTehnologie
				SET idNou = #idNoi.id
				FROM #idNoi
				WHERE #idNoi.tip = #tmpTehnologie.tip
					AND #idNoi.cod = #tmpTehnologie.cod
					AND #tmpTehnologie.nivel = @nivel

				SELECT @nivel = @nivel + 1
			END

			DROP TABLE #idNoi

			DROP TABLE #tmpTehnologie
		END
		ELSE
			IF @tipLansare = 1
				--Fara structura, doar scriere  
			BEGIN
				--Scriere in (pozTehnologii   ) POZLANSARI
				INSERT INTO pozLansari (tip, cod, cantitate, idp, resursa, detalii)
				VALUES ('L', @comanda, @cantitate, @idTehnologie, @resursa, @detalii)
			END

		--Scriere in tabelul de planificari daca se lucreaza cu planificari
		IF @cuPlanificare = 1
		BEGIN
			INSERT INTO planificare (idOp, comanda, resursa, dataStart, dataStop, cantitate)
			SELECT lansari.id, antetLansari.cod, COALESCE(lansari.resursa, res.cod, ''), convert(DATE, GETDATE()), convert(DATE, 
					GETDATE()), lansari.cantitate
			FROM #id idLansari
			INNER JOIN pozLansari antetLansari
				ON antetLansari.id = idLansari.id
					AND antetLansari.tip = 'L'
			INNER JOIN pozLansari lansari
				ON lansari.parinteTop = antetLansari.id
					AND lansari.tip = 'O'
			OUTER APPLY (
				SELECT TOP 1 rs.cod
				FROM resurse rs
				INNER JOIN OpResurse op
					ON rs.id = op.idRes
				WHERE op.cod = lansari.Cod
				) res
		END

		-- Scriere in comenzi  
		SET @doc = (
				SELECT @comanda AS comanda, @tipComanda AS tipcomanda, @dataLansarii AS datalansarii, @lm AS lm, @termen AS termen, 
					@tert AS beneficiar, @contract AS contract, @cantitate AS cantitate, @stareComanda AS stareacomenzii, @descriere 
					AS dencomanda, @cod AS tehnologie, @comandaBenef AS comandabenef
				FOR XML raw
				)

		BEGIN TRY
			EXEC wScriuComenzi @sesiune = @sesiune, @parXML = @doc
		END TRY

		BEGIN CATCH
			SET @mesaj = ERROR_MESSAGE()

			RAISERROR (@mesaj, 11, 1)
		END CATCH
	END
END
ELSE
	IF @update = 1
	BEGIN
		DECLARE @cantitatePozitie FLOAT, @idPozitie INT

		SET @idPozitie = @parXML.value('(/row/linie/@id)[1]', 'int')
		SET @cantitatePozitie = @parXML.value('(/row/row/@cantitate)[1]', 'float')

		UPDATE pozLansari
		SET cantitate = @cantitatePozitie, detalii = @detalii
		WHERE id = @idPozitie
			AND tip IN ('M', 'O')
	END

DECLARE @docXMLIaPozLans XML

SET @docXMLIaPozLans = '<row comanda="' + rtrim(@comanda) + '"/>'

EXEC wIaPozLansari @sesiune = @sesiune, @parXML = @docXMLIaPozLans
