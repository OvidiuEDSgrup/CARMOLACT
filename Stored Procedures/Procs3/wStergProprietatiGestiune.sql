
CREATE PROCEDURE wStergProprietatiGestiune @sesiune varchar(50), @parXML xml
AS
BEGIN TRY
	DECLARE @gestiune varchar(20), @proprietateGestiune varchar(100), @valoare varchar(200)

	SELECT @gestiune = ISNULL(@parXML.value('(/*/@gestiune)[1]', 'varchar(20)'), ''),
		@proprietateGestiune = ISNULL(@parXML.value('(/*/*/@codproprietate)[1]', 'varchar(100)'), ''),
		@valoare = ISNULL(@parXML.value('(/*/*/@valoare)[1]', 'varchar(200)'), '')

	IF @gestiune = ''
		RAISERROR('Gestiunea nu a putut fi identificata!', 16, 1)

	DELETE FROM proprietati
	WHERE Tip = 'GESTIUNE' and Cod = @gestiune
		and Cod_proprietate = @proprietateGestiune
		and Valoare = @valoare
		
END TRY
BEGIN CATCH
	DECLARE @mesajEroare varchar(1000)
	SET @mesajEroare = ERROR_MESSAGE() + char(10) + '(' + OBJECT_NAME(@@PROCID) + ')'
	RAISERROR(@mesajEroare, 16, 1)
END CATCH
