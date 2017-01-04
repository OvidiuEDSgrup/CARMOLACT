
CREATE PROCEDURE wOPInvalidareLocMunca_p @sesiune varchar(50), @parXML xml
AS
	DECLARE @lm varchar(20), @detalii xml, @invalid varchar(100)

	SELECT @lm = @parXML.value('(/row/@lm)[1]', 'varchar(20)')
	SELECT TOP 1 @invalid = ISNULL('Invalid ' + NULLIF(detalii.value('(/row/@invalid)[1]', 'varchar(100)'), ''), 'Locul de munca este valid')
	FROM lm WHERE Cod = @lm

	SELECT @invalid AS invalid
	FOR XML RAW, ROOT('Date')
