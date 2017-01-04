
CREATE PROCEDURE wScriuProprietatiGestiune @sesiune varchar(50), @parXML xml
AS
BEGIN TRY
	DECLARE @gestiune varchar(20), @proprietateGestiune varchar(100),
		@valoare varchar(200), @valoare_tupla varchar(200), @update bit

	SELECT @gestiune = @parXML.value('(/*/@gestiune)[1]', 'varchar(20)'),
		@proprietateGestiune = ISNULL(@parXML.value('(/*/*/@codproprietate)[1]', 'varchar(100)'), ''),
		@valoare = ISNULL(@parXML.value('(/*/*/@valoare)[1]', 'varchar(200)'), ''),
		@valoare_tupla = ISNULL(@parXML.value('(/*/*/@valoare_tupla)[1]', 'varchar(200)'), ''),
		@update = ISNULL(@parXML.value('(/*/*/@update)[1]', 'bit'), 0)

	IF @update = 1
	BEGIN
		UPDATE proprietati
		SET Valoare = @valoare, Valoare_tupla = @valoare_tupla
		WHERE tip = 'GESTIUNE' AND cod = @gestiune AND cod_proprietate = @proprietateGestiune
	END
	ELSE
	BEGIN
		INSERT INTO proprietati (tip, cod, cod_proprietate, valoare, valoare_tupla)
		SELECT 'GESTIUNE', @gestiune, @proprietateGestiune, @valoare, @valoare_tupla
		WHERE NOT EXISTS (SELECT 1 FROM proprietati WHERE tip = 'GESTIUNE' and cod = @gestiune
			AND cod_proprietate = @proprietateGestiune AND valoare = @valoare)
	END

END TRY
BEGIN CATCH
	DECLARE @mesajEroare varchar(1000)
	SET @mesajEroare = ERROR_MESSAGE() + char(10) + '(' + OBJECT_NAME(@@PROCID) + ')'
	RAISERROR(@mesajEroare, 16, 1)
END CATCH
