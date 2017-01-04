
CREATE PROCEDURE wOPInvalidareTert_p @sesiune varchar(50), @parXML xml
AS
BEGIN
	
	DECLARE @tert varchar(50), @invalid varchar(100), @detalii xml

	SELECT @tert = @parXML.value('(/row/@tert)[1]', 'varchar(50)')
	SELECT TOP 1 @invalid = ISNULL('Invalid ' + NULLIF(detalii.value('(/row/@invalid)[1]', 'varchar(100)'), ''), 'Tertul este valid')
	FROM terti WHERE Tert = @tert

	SELECT @invalid AS invalid
	FOR XML RAW, ROOT('Date')

END
