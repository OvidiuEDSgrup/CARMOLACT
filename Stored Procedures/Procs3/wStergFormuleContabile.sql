
CREATE PROCEDURE wStergFormuleContabile @sesiune varchar(50), @parXML xml
AS
BEGIN TRY
	
	DECLARE @tipdoc varchar(2), @cont_debit varchar(50), @cont_credit varchar(50)
	SELECT @tipdoc = ISNULL(@parXML.value('(/row/@tipdoc)[1]', 'varchar(2)'), ''),
		@cont_debit = ISNULL(@parXML.value('(/row/@cont_debit)[1]', 'varchar(50)'), ''),
		@cont_credit = ISNULL(@parXML.value('(/row/@cont_credit)[1]', 'varchar(50)'), '')

	IF @tipdoc = '' OR @cont_debit = '' OR @cont_credit = ''
		RAISERROR('Nu s-a putut identifica pozitia!', 16, 1)

	DELETE FROM FormuleContabile
	WHERE tip = @tipdoc AND cont_debit = @cont_debit AND cont_credit = @cont_credit

END TRY
BEGIN CATCH
	DECLARE @mesajEroare varchar(1000)
	SET @mesajEroare = ERROR_MESSAGE() + char(10) + '(' + OBJECT_NAME(@@PROCID) + ')'
	RAISERROR(@mesajEroare, 16, 1)
END CATCH
