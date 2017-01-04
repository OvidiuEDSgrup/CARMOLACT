
CREATE PROCEDURE wScriuFormuleContabile @sesiune varchar(50), @parXML xml
AS
BEGIN TRY

	DECLARE @utilizator varchar(50), @cont_debit varchar(50), @cont_credit varchar(50), @update bit,
		@tipdoc varchar(2), @o_cont_debit varchar(50), @o_cont_credit varchar(50), @o_tipdoc varchar(2)
	SELECT @cont_debit = ISNULL(@parXML.value('(/row/@cont_debit)[1]', 'varchar(50)'), ''),
		@cont_credit = ISNULL(@parXML.value('(/row/@cont_credit)[1]', 'varchar(50)'), ''),
		@tipdoc = ISNULL(@parXML.value('(/row/@tipdoc)[1]', 'varchar(2)'), ''),
		@update = ISNULL(@parXML.value('(/row/@update)[1]', 'bit'), 0),

		@o_cont_debit = @parXML.value('(/row/@o_cont_debit)[1]', 'varchar(50)'),
		@o_cont_credit = @parXML.value('(/row/@o_cont_credit)[1]', 'varchar(50)'),
		@o_tipdoc = @parXML.value('(/row/@o_tipdoc)[1]', 'varchar(2)')

	EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

	IF @tipdoc = '' OR @cont_credit = '' OR @cont_debit = ''
		RAISERROR('Completati tipul de document, contul de debit si contul de credit', 16, 1)

	
	IF (@update = 0 OR (@update = 1 AND @tipdoc <> @o_tipdoc) OR (@update = 1 AND @cont_debit <> @o_cont_debit) OR (@update = 1 AND @cont_credit <> @o_cont_credit))
		AND EXISTS (SELECT 1 FROM FormuleContabile WHERE tip = @tipdoc AND cont_debit = @cont_debit AND cont_credit = @cont_credit)
			RAISERROR('Exista deja o pozitie cu datele introduse!', 16, 1)

	IF @update = 0
		INSERT INTO FormuleContabile (tip, cont_debit, cont_credit, utilizator, data_operarii)
		SELECT @tipdoc, @cont_debit, @cont_credit, @utilizator, GETDATE()
	ELSE
		UPDATE FormuleContabile
		SET tip = @tipdoc, cont_debit = @cont_debit, cont_credit = @cont_credit,
			utilizator = @utilizator, data_operarii = GETDATE()
		WHERE tip = @o_tipdoc AND cont_debit = @o_cont_debit AND cont_credit = @o_cont_credit


END TRY
BEGIN CATCH
	DECLARE @mesajEroare varchar(1000)
	SET @mesajEroare = ERROR_MESSAGE() + char(10) + '(' + OBJECT_NAME(@@PROCID) + ')'
	RAISERROR(@mesajEroare, 16, 1)
END CATCH
