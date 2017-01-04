
CREATE PROCEDURE wIaPozRapProductie @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @idRealizare INT, @cautare VARCHAR(20), @tip varchar(20)

SET @idRealizare = @parXML.value('(row/@idRealizare)[1]', 'int')
SET @cautare = '%' + replace(isnull(@parXML.value('(row/@_cautare)[1]', 'varchar(20)'), '%'), ' ', '%') + '%'
SET @tip= @parXML.value('(/row/@tip)[1]', 'varchar(2)')

SELECT 
	'AD' AS subtip, rtrim(n.cod) cod, rtrim(n.Denumire) denumire,  p.id, convert(DECIMAL(20, 2), p.cantitate) 	cantitate, 
	rtrim(p.observatii) observatii,  p.detalii detalii,	p.idRealizare as idRealizare, p.idPozLansare idPozLansare,p.idPozTehnologie idPozTehnologie,
	rtrim(t.cod) cod_tehnologie, p.id idPozRealizare, @tip tip
FROM pozRealizari p
	LEFT JOIN pozTehnologii pt ON p.idPozTehnologie = pt.id	AND pt.tip = 'T'
	LEFT JOIN tehnologii t ON t.cod = pt.cod
	LEFT JOIN nomencl n ON t.codNomencl = n.Cod
WHERE
	p.idRealizare = @idRealizare
	AND pt.cod LIKE @cautare
ORDER BY 
	id DESC
FOR XML raw, root('Date')

select '1' as areDetaliiXml
for xml raw, root('Mesaje')