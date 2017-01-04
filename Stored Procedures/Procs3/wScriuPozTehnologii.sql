
CREATE PROCEDURE [dbo].[wScriuPozTehnologii] @sesiune VARCHAR(50), @parXML XML
AS
begin try
DECLARE --Date antet
	@codTehnologie VARCHAR(20), @denumireTehnologie VARCHAR(80), @tipTehnologie VARCHAR(1), @idTehnologie INT, @codNomencl 
	VARCHAR(20), --Date pozitie
	@cod VARCHAR(20), @cantitate FLOAT, @pret FLOAT, @ordineOperatie FLOAT, @id INT, @tip VARCHAR(1), @cant_i FLOAT, @resursa VARCHAR(
		20), --Altele
	@subtip VARCHAR(2), @update BIT, @idReal INT, @eroare VARCHAR(200), --Parinte (modificari/adaugari pozitii
	@codLinie VARCHAR(20), @parinteTopLinie INT, @codTehnologieParinteTopLinie VARCHAR(20), @tipLinie VARCHAR(2), @idLinie INT, 
	@grupareLinie VARCHAR(20), @selectat BIT, @detalii XML, @mesaj varchar(500)

IF EXISTS (
		SELECT 1
		FROM sysobjects
		WHERE [type] = 'P'
			AND [name] = 'wScriuPozTehnologiiSP'
		)
	EXEC wScriuPozTehnologiiSP @sesiune = @sesiune, @parXML = @parXML OUTPUT

--Antet
SET @codTehnologie = ISNULL(@parXML.value('(/row/@cod_tehn)[1]', 'varchar(20)'), '')
SET @denumireTehnologie = ISNULL(@parXML.value('(/row/@denumire)[1]', 'varchar(80)'), '')
SET @tipTehnologie = ISNULL(@parXML.value('(/row/@tip_tehn)[1]', 'varchar(1)'), 'P')
SET @idTehnologie = ISNULL(@parXML.value('(/row/@id)[1]', 'int'), 0)
SET @codNomencl = ISNULL(@parXML.value('(/row/@codNomencl)[1]', 'varchar(20)'), 'Serviciu')
SET @detalii = @parXML.query('(row/row/detalii/row)[1]')
--Pozitie
SET @cod = ISNULL(@parXML.value('(/row/row/@cod)[1]', 'varchar(20)'), '')
SET @cantitate = ISNULL(@parXML.value('(/row/row/@cantitate)[1]', 'float'), 0)
SET @resursa = @parXML.value('(/row/row/@resursa)[1]', 'varchar(20)')
SET @pret = ISNULL(@parXML.value('(/row/row/@pret)[1]', 'float'), 0)
SET @cant_i = ISNULL(@parXML.value('(/row/row/@cant_i)[1]', 'float'), 0)
SET @ordineOperatie = ISNULL(@parXML.value('(/row/row/@ordine)[1]', 'float'), 0)
--Linie
SET @codLinie = ISNULL(@parXML.value('(/row/linie/@cod)[1]', 'varchar(20)'), '')
SET @id = ISNULL(@parXML.value('(/row/linie/@idReal)[1]', 'int'), 0)
SET @parinteTopLinie = ISNULL(@parXML.value('(/row/linie/@parinteTop)[1]', 'int'), 0)
SET @tipLinie = ISNULL(@parXML.value('(/row/linie/@tip)[1]', 'varchar(2)'), '')
SET @idLinie = ISNULL(@parXML.value('(/row/linie/@id)[1]', 'int'), 0)
SET @grupareLinie = ISNULL(@parXML.value('(/row/linie/@_grupare)[1]', 'varchar(20)'), '')
SET @selectat = @parXML.exist('/row/linie')

IF @detalii.exist('/row') = 0
	SET @detalii = NULL

IF @selectat <> '1'
	AND @idTehnologie <> 0
BEGIN
	RAISERROR ('Selectati un parinte din grid pentru a adauga o componenta tehnologiei!', 11, 1
			)


END

SELECT @codTehnologieParinteTopLinie = cod
FROM pozTehnologii
WHERE id = @parinteTopLinie

--Altele
SET @update = ISNULL(@parXML.value('(/row/row/@update)[1]', 'bit'), 0)
SET @subtip = ISNULL(@parXML.value('(/row/row/@subtip)[1]', 'varchar(2)'), '')

--Determinare tip pozitie
IF @subtip IN ('MT', 'SA')
	SET @tip = 'M'

IF @subtip = 'OP'
	SET @tip = 'O'

IF @subtip = 'RS'
	SET @tip = 'R'

IF @subtip = 'RZ'
	SET @tip = 'Z'

IF @tipTehnologie NOT IN ('R', 'M')
	SET @codTehnologie = @codNomencl

IF @denumireTehnologie = ''
	SELECT @denumireTehnologie = denumire
	FROM nomencl
	WHERE cod = @codNomencl

IF @update = 0
	--Adaugare date (nu modificare)
BEGIN
	IF @idTehnologie = 0
		--Adaugare tehnologie
	BEGIN
		--Validari date introduse in antet
		IF (
				SELECT count(*)
				FROM tehnologii
				WHERE cod = @codTehnologie
				) > 0
		BEGIN
			RAISERROR ('Codul introdus este asociat deja unei tehnologii!', 11, 1)


		END

		IF @codTehnologie = ''
			OR @tipTehnologie = ''
			OR @denumireTehnologie = ''
			OR (
				@codNomencl = ''
				AND @tipTehnologie <> 'S'
				)
		BEGIN
			RAISERROR ('Nu sunt permise campuri cu valori necompletate in antet!', 11, 1
					)

		END

		IF @subtip IN ('OP', 'MT', 'RS', 'SA')
			--Adaugare tehnologie cu pozitie
		BEGIN
			--Validate date introduse in pozitie
			IF @cod = ''
				OR (
					@pret < 0
					AND @subtip <> 'RS'
					)
				OR (
					@ordineOperatie <= 0
					AND @subtip = 'OP'
					)
			BEGIN
				RAISERROR (
						'Nu sunt permise: valori negative pentru Pret si OrdineOperatie, cod necompletat'
						, 11, 1
						)


			END

			--Insert
			INSERT INTO tehnologii (cod, Denumire, tip, Data_operarii, detalii, codNomencl)
			VALUES (@codTehnologie, @denumireTehnologie, @tipTehnologie, GETDATE(), NULL, @codNomencl)

			CREATE TABLE #id (id INT)

			INSERT INTO pozTehnologii (tip, cod, cantitate, pret)
			OUTPUT inserted.id
			INTO #id
			VALUES ('T', @codTehnologie, 0, 0)

			--Obtinem id-ul tehnologiei tocmai introduse pentru a putea salva pozitia
			SELECT @idTehnologie = id
			FROM #id

			INSERT INTO pozTehnologii (tip, cod, cantitate, pret, idp, cantitate_i, ordine_o, parinteTop, resursa, detalii
				)
			VALUES (@tip, @cod, @cantitate, @pret, @idTehnologie, @cant_i, @ordineOperatie, @idTehnologie, @resursa, @detalii
				)
		END
	END
	ELSE
		--Adaugare pozitie in tehnologie existenta
	BEGIN
		IF @cod = ''
			OR (
				@pret < 0
				AND @subtip <> 'RS'
				)
			OR (
				@ordineOperatie <= 0
				AND @subtip = 'OP'
				)
		BEGIN
			RAISERROR (
					'Nu sunt permise: valori negative pentru Pret si OrdineOperatie, cod necompletat'
					, 11, 1
					)


		END

		BEGIN
			IF EXISTS (
					SELECT cod
					FROM poztehnologii
					WHERE tip = @tip
						AND parinteTop = @idTehnologie
						AND cod = @cod
					)
			BEGIN
				SET @eroare = 'Elementul: ' + isnull(@cod,'.') + ' exista deja pe nivelul selectat al tehnologie'

				RAISERROR (@eroare, 11, 1)

			END

			IF (
					@parinteTopLinie <> @idTehnologie
					AND @grupareLinie NOT IN ('Produs','Serviciu','Interventie')
					)
			BEGIN
				SET @eroare = 'Pentru a adauga elementul: ' + isnull(@cod,'.') + ' mergeti pe tehnologia: ' + rtrim(
						isnull(@codTehnologieParinteTopLinie,'.')) + ' !'

				RAISERROR (@eroare, 11, 1)

			END

			IF @tipLinie NOT IN ('M', 'Z')
				INSERT INTO pozTehnologii (tip, cod, cantitate, pret, idp, cantitate_i, ordine_o, parinteTop, resursa, detalii
					)
				VALUES (@tip, @cod, @cantitate, @pret, @idLinie, @cant_i, @ordineOperatie, @idTehnologie, @resursa, @detalii
					)
			ELSE
			BEGIN
				SET @eroare = 'Elementului ' + isnull(@codLinie,'.') + 
					' nu i se pot adauga elemente in structura! Daca este Semifabricat editati tehnologia acestuia'

				RAISERROR (@eroare, 11, 1)
			END
		END
	END
END --Gata adaugari
ELSE
BEGIN
	IF @idTehnologie = @parinteTopLinie
	BEGIN
		IF @subtip = 'OP'
		BEGIN
			UPDATE pozTehnologii
			SET cantitate = @cantitate, pret = @pret, cantitate_i = @cant_i, ordine_o = @ordineOperatie, resursa = @resursa, detalii = 
				@detalii
			WHERE id = @id
		END
		ELSE
			IF @subtip = 'MT'
			BEGIN
				UPDATE pozTehnologii
				SET cantitate = @cantitate, cantitate_i = @cant_i, pret = @pret, detalii = @detalii
				WHERE id = @id
			END
			ELSE
				IF @subtip = 'RS'
				BEGIN
					UPDATE pozTehnologii
					SET cantitate = @cantitate, detalii = @detalii
					WHERE id = @id
				END
				ELSE
					IF @subtip = 'RZ'
					BEGIN
						UPDATE pozTehnologii
						SET cantitate = @cantitate, detalii = @detalii
						WHERE id = @id
					END
	END
	ELSE
	BEGIN
		SET @eroare = 'Pentru a modifica ' + isnull(@codLinie,'.') + ' mergeti pe tehnologia ' + 
			isnull(@codTehnologieParinteTopLinie,'.')

		RAISERROR (@eroare, 11, 1)
	END
END

DECLARE @docXMLIaPozTehn XML

SET @docXMLIaPozTehn = '<row cod_tehn="' + rtrim(@codTehnologie) + '"/>'

EXEC wIaPozTehnologii @sesiune = @sesiune, @parXML = @docXMLIaPozTehn

end try
begin catch
	set @mesaj=ERROR_MESSAGE()+ ' (wScriuPozTehnologii)'
	raiserror(@mesaj, 11, 1)
end catch