
CREATE PROCEDURE wStergPozOrdineDePlataFacturi @sesiune VARCHAR(50), @parXML XML
AS
DECLARE 
	@idPozOP INT, @mesaj VARCHAR(500), @docJurnal XML, @idOP INT, @docPoz XML,@ultim_stare varchar(200), @tert varchar(20),@cautare varchar(8000)

BEGIN TRY
	SELECT
		@idPozOP = @parXML.value('(/*/*/@idPozOP)[1]', 'int'),
		@idOP = @parXML.value('(/*/@idOP)[1]', 'int'),
		@tert = @parXML.value('(/*/*/@tert)[1]', 'varchar(20)'),
		@cautare=@parXML.value('(/*/@_cautare)[1]', 'varchar(200)')

	SELECT TOP 1 @ultim_stare = stare
		FROM JurnalOrdineDePlata
		WHERE idOP = @idOP
		ORDER BY data DESC

	if @ultim_stare <> 'Operat'
		raiserror('Documentul este intr-o stare care nu mai permite modificarea!',16, 1) 
	
	IF OBJECT_ID('tempdb.dbo.#destersop') IS NOT NULL
		DROP TABLE #destersop

	select
		D.s.value('(@idPozOP)[1]', 'int') idPozOP,
		D.s.value('(@tert)[1]', 'varchar(20)') tert
	into #destersop
	from @parXML.nodes('row/row') D(s)


	DELETE p

	FROM PozOrdineDePlata p
	JOIN #destersop ds on (p.idPozOP = ds.idPozOP and ds.idPozOP is not null) OR (p.tert=ds.tert and ds.idPozOP is null)
	and p.idOP=@idOP

	SET @docJurnal = (
			SELECT @idOP idOP, 'Stergere pozitie' operatie
			FOR XML raw
			)

	EXEC wScriuJurnalOrdineDePlata @sesiune = @sesiune, @parXML = @docJurnal

	SET @docPoz = (
			SELECT @idOP idOP,
			@cautare _cautare
			FOR XML raw
			)

	EXEC wIaPozOrdineDeplataFacturi @sesiune = @sesiune, @parXML = @docPoz
END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (wStergPozOrdineDePlataFacturi)'

	RAISERROR (@mesaj, 11, 1)
END CATCH
 
