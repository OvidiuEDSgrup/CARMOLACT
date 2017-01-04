
CREATE PROCEDURE wScriuPlanificareGantt @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @id INT, @dataStart DATETIME, @dataStop DATETIME, @oraStop VARCHAR(4), @oraStart VARCHAR(4), @mesaj VARCHAR(300)

BEGIN TRY
	SET @id = @parXML.value('(/*/@id)[1]', 'int')
	SET @dataStart = @parXML.value('(/*/@dataStart)[1]', 'datetime')
	SET @dataStop = @parXML.value('(/*/@dataStop)[1]', 'datetime')
	SET @oraStart = replace(@parXML.value('(/*/@oraStart)[1]', 'varchar(5)'), ':', '')
	SET @oraStop = replace(@parXML.value('(/*/@oraStop)[1]', 'varchar(5)'), ':', '')

	UPDATE planificare
	SET dataStart = @dataStart, dataStop = @dataStop, oraStart = @oraStart, oraStop = @oraStop
	WHERE id = @id
END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + 'wScriuPlanificareGantt'

	RAISERROR (@mesaj, 11, 1)
END CATCH

