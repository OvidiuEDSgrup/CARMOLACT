
CREATE PROCEDURE wOPGenerareAntecalculatii_p @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @fXML XML, @numarDoc VARCHAR(20), @utilizator VARCHAR(50)

EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

SET @fXML = '<row tip="LP"/>'
SET @fXML.modify('insert attribute utilizator {sql:variable("@utilizator")} into (/row)[1]')

EXEC wIauNrDocFiscale @parXML = @fXML, @Numar = @numarDoc OUTPUT

SELECT @numarDoc AS numarDoc, convert(CHAR(10), GETDATE(), 101) AS data
FOR XML raw, root('Date')
