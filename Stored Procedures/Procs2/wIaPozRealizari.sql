
CREATE PROCEDURE [dbo].[wIaPozRealizari] @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @idRealizare INT

SET @idRealizare = ISNULL(@parXML.value('(/row/@id)[1]', 'int'), 0)

SELECT CONVERT(DECIMAL(14, 4), pr.cantitate) AS cantitate, RTRIM(antet.cod) AS comanda, '(' + RTRIM(poz.cod) + ') ' + RTRIM(c.Denumire) 
	AS operatie, RTRIM(c.Denumire) AS codOp, CONVERT(DECIMAL(14, 4), poz.cantitate) AS cantLansat, RTRIM(pr.observatii) AS 
	observatii, RTRIM(pr.CM) AS numarCM, RTRIM(pr.PP) AS numarPP, 'AD' AS subtip, pr.id AS id, pr.detalii as detalii
FROM realizari r
INNER JOIN pozRealizari pr ON r.id = pr.idRealizare
INNER JOIN planificare pl ON pl.id = pr.idLegatura and pr.tip='P'
INNER JOIN pozLansari poz ON poz.id = pl.idOp
INNER JOIN pozLansari antet ON antet.id = poz.parinteTop
INNER JOIN catop c ON c.Cod = poz.cod
WHERE r.id = @idRealizare
FOR XML raw, root('Date')

select '1' as areDetaliiXml
for xml raw, root('Date')
