
CREATE PROCEDURE [dbo].[wIaPozRapProductieSP] @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @idRealizare INT, @cautare VARCHAR(20)

SET @idRealizare = @parXML.value('(row/@idRealizare)[1]', 'int')
SET @cautare = '%' + replace(isnull(@parXML.value('(row/@_cautare)[1]', 'varchar(20)'), '%'), ' ', '%') + '%'

SELECT 
	'AD' AS subtip, rtrim(pt.cod) cod, rtrim(n.Denumire) denumire, rtrim(pt.cod) semif, p.id, convert(DECIMAL(20, 2), p.cantitate) 
	cantitate, /*rtrim(p.observatii) observatii,*/ rtrim(p.CM) AS nrCM, rtrim(p.PP) AS nrPP, @idRealizare AS idRealizare, p.detalii detalii,
	(select max(cod_intrare) from pozdoc where tip='PP' and Numar=p.PP and cod=pt.cod and data=rz.data ) as observatii
FROM pozRealizari p
left join realizari rz on rz.id=p.idRealizare
LEFT JOIN pozTehnologii pt ON p.idLegatura = pt.id
	AND pt.tip = 'T'
LEFT JOIN tehnologii t ON t.cod = pt.cod
LEFT JOIN nomencl n ON t.codNomencl = n.Cod
WHERE p.idRealizare = @idRealizare
	AND pt.cod LIKE @cautare
	
ORDER BY  (select max(cod_intrare) from pozdoc where tip='PP' and Numar=p.PP and cod=pt.cod and data=rz.data )
FOR XML raw, root('Date')

select '1' as areDetaliiXml
for xml raw, root('Mesaje')