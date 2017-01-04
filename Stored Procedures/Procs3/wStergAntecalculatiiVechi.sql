
CREATE PROCEDURE wStergAntecalculatiiVechi @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @sterg INT, @mesaj VARCHAR(500)

BEGIN TRY
	SELECT @sterg = Val_logica
	FROM par
	WHERE parametru = 'ISTANTEC'

	IF @sterg = 1
	BEGIN
		SELECT idAntec AS id
		INTO #deSters
		FROM antecalculatii
		WHERE idantec NOT IN (
				SELECT MAX(idantec)
				FROM antecalculatii
				GROUP BY cod
				)

		DELETE
		FROM pozAntecalculatii
		WHERE parinteTop IN (
				SELECT a.idPoz
				FROM antecalculatii a
				INNER JOIN #deSters d ON d.id = a.idAntec
				)

		DROP TABLE #deSters
	END
END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (wStergAntecalculatiiVechi)'

	RAISERROR (@mesaj, 11, 1)
END CATCH
