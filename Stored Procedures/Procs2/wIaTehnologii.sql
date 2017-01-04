
CREATE PROCEDURE [dbo].[wIaTehnologii] @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @codt VARCHAR(16), @fltcod VARCHAR(20), @fltdenumire VARCHAR(20), @flttip VARCHAR(20), @cod VARCHAR(20), @fltcodN VARCHAR(20
	), @id VARCHAR(20)

SET @fltdenumire = isnull(@parXML.value('(/row/@f_denumire)[1]', 'varchar(20)'), ' ')
SET @flttip = isnull(@parXML.value('(/row/@f_tip)[1]', 'varchar(20)'), ' ')
SET @fltcod = isnull(@parXML.value('(/row/@f_cod)[1]', 'varchar(20)'), ' ')
SET @fltcodN = isnull(@parXML.value('(/row/@f_codN)[1]', 'varchar(20)'), ' ')
SET @id = isnull(@parXML.value('(/row/@id)[1]', 'varchar(20)'), '%')
SET @cod = isnull(@parXML.value('(/row/@cod_tehn)[1]', 'varchar(20)'), ' ')
SET @fltdenumire = '%' + replace(@fltdenumire, ' ', '%') + '%'
SET @fltcod = '%' + replace(@fltcod, ' ', '%') + '%'
SET @flttip = '%' + replace(@flttip, ' ', '%') + '%'
SET @fltcodN = '%' + replace(@fltcodN, ' ', '%') + '%'
SET @cod = '%' + replace(@cod, ' ', '%') + '%'

SELECT RTRIM(t.Cod) AS cod_tehn, RTRIM(t.denumire) AS denumire, (CASE WHEN t.tip = 'P' THEN 'Produs' WHEN t.tip = 'R' THEN 'Reper' WHEN t.tip = 'S' THEN 'Serviciu' WHEN t.tip = 'I' THEN 'Inteventie' END
		) AS tip_tehn, RTRIM(t.codNomencl) AS codNomencl, '' AS tip, convert(VARCHAR(30), getdate(), 101) AS data, t.cod AS numar, pt.id 
	AS id, pt.id AS idTehn
FROM tehnologii t
LEFT JOIN nomencl n ON n.Cod = t.codNomencl
INNER JOIN pozTehnologii pt ON pt.cod = t.cod
	AND pt.tip = 'T'
	AND idp IS NULL
WHERE t.Cod LIKE @fltcod
	AND t.cod LIKE @cod
	AND t.denumire LIKE @fltdenumire
	AND t.tip LIKE @flttip
	AND isnull(n.Denumire, '%') LIKE @fltcodN
	AND t.cod LIKE isnull(convert(VARCHAR(20), pt.cod), '%')
	AND convert(VARCHAR(20), pt.id) LIKE @id
	--and pt.resursa is null
FOR XML raw, root('Date')

