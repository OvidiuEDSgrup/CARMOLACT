
CREATE PROCEDURE wScriuAsociereFormulare @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	DECLARE @idAsoc INT, @meniu VARCHAR(20), @tip VARCHAR(20), @formular VARCHAR(60), @mesaj VARCHAR(500), @lm varchar(9)

	SELECT
		@meniu = @parXML.value('(/*/@meniu)[1]', 'varchar(20)'),
		@tip = @parXML.value('(/*/@tipDoc)[1]', 'varchar(20)'),
		@formular = @parXML.value('(/*/@formular)[1]', 'varchar(60)'),
		@idAsoc = @parXML.value('(/*/@idAsociere)[1]', 'int'),
		@lm = nullif(@parXML.value('(/*/@lm)[1]','varchar(9)'),'')

	if @meniu is null	--> s-ar putea sa fie apel din detalierea asocierilor din formulare
	select	@meniu = @parXML.value('(/*/*/@meniu)[1]', 'varchar(20)'),
			@tip = isnull(@tip,@parXML.value('(/*/*/@tipDoc)[1]', 'varchar(20)')),
			@idAsoc=isnull(@idAsoc,@parXML.value('(/*/*/@idAsociere)[1]', 'int')),
			@lm = nullif(@parXML.value('(/*/*/@lm)[1]','varchar(9)'),'')

	IF @idAsoc IS NULL
	BEGIN
		IF isnull(@meniu, '') = ''
			OR (not exists (select 1 from webconfigmeniu w where w.meniu=@meniu and tipmacheta iN ('C','M')) and ISNULL(@tip, '') = '')
			OR ISNULL(@formular, '') = ''
			RAISERROR ('Toate campurile trebuie completate pt. o asociere buna!', 11, 1)

		INSERT INTO webConfigFormulare (meniu, tip, cod_formular,loc_munca)
		SELECT @meniu, @tip, @formular, @lm
	END
	ELSE
	BEGIN
		UPDATE webConfigFormulare
		SET meniu = @meniu, tip = @tip, cod_formular = @formular, loc_munca=@lm
		WHERE idAsociere = @idAsoc
	END
END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (wScriuAsociereFormulare)'

	RAISERROR (@mesaj, 11, 1)
END CATCH
