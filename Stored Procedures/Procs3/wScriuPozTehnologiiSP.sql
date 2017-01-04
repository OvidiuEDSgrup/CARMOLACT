
CREATE PROCEDURE [dbo].[wScriuPozTehnologiiSP] @sesiune VARCHAR(50), @parXML XML OUTPUT
AS

begin try
set transaction isolation level read uncommitted
DECLARE --Date antet
	@codTehnologie VARCHAR(20), @denumireTehnologie VARCHAR(80), @tipTehnologie VARCHAR(1), @idTehnologie INT, @codNomencl 
	VARCHAR(20), --Date pozitie
	@cod VARCHAR(20), @cantitate FLOAT, @pret FLOAT, @ordineOperatie FLOAT, @id INT, @tip VARCHAR(1), @cant_i FLOAT, @resursa VARCHAR(
		20), --Altele
	@subtip VARCHAR(2), @update BIT, @idReal INT, @eroare VARCHAR(200), --Parinte (modificari/adaugari pozitii
	@codLinie VARCHAR(20), @parinteTopLinie INT, @codTehnologieParinteTopLinie VARCHAR(20), @tipLinie VARCHAR(2), @idLinie INT, 
	@grupareLinie VARCHAR(20), @selectat BIT, @detalii XML, @mesaj varchar(500)
	
/*sp
IF EXISTS (
		SELECT 1
		FROM sysobjects
		WHERE [type] = 'P'
			AND [name] = 'wScriuPozTehnologiiSP'
		)
	EXEC wScriuPozTehnologiiSP @sesiune = @sesiune, @parXML = @parXML OUTPUT
sp*/

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
		print 'nimic in plus de validat in antet'
	END
	ELSE
		--Adaugare pozitie in tehnologie existenta
	BEGIN

		BEGIN
--/*sp
			IF (
					(SELECT cod
					FROM pozTehnologii
					WHERE id = @idTehnologie) = @cod
					)
			BEGIN
				SET @eroare = 'Nu puteti adauga elementul: ' + isnull(@cod,'.') + ' pe tehnologia: ' + rtrim(
						isnull(@codTehnologieParinteTopLinie,'.')) + ' !'

				RAISERROR (@eroare, 11, 1)

			END		
--sp*/
		END
	END
END --Gata adaugari
ELSE
BEGIN
	print 'nimic in plus de actualizat'
END
/*sp
DECLARE @docXMLIaPozTehn XML

SET @docXMLIaPozTehn = '<row cod_tehn="' + rtrim(@codTehnologie) + '"/>'

EXEC wIaPozTehnologii @sesiune = @sesiune, @parXML = @docXMLIaPozTehn
--sp*/
end try
begin catch
	set @mesaj=ERROR_MESSAGE()+ ' (wScriuPozTehnologiiSP)'
	raiserror(@mesaj, 11, 1)
end catch