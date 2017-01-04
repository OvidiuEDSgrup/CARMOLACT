
CREATE PROCEDURE [dbo].[wIaRealizari] @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @fltDescriere VARCHAR(80), @fltCod VARCHAR(20), @fltTip VARCHAR(20), @datajos DATETIME, @datasus DATETIME, @idRealizare INT

SET @fltCod = '%' + REPLACE(ISNULL(@parXML.value('(/row/@f_cod)[1]', 'varchar(20)'), ''), ' ', '%') + '%'
SET @fltDescriere = '%' + REPLACE(ISNULL(@parXML.value('(/row/@f_descriere)[1]', 'varchar(80)'), ''), ' ', '%') + '%'
SET @datajos = isnull(@parXML.value('(/row/@datajos)[1]', 'datetime'), '1901-1-1')
SET @datasus = isnull(@parXML.value('(/row/@datasus)[1]', 'datetime'), '2100-1-1')
SET @idRealizare = @parXML.value('(/row/@id)[1]', 'int')

SELECT max(r.nrDoc) AS nrDoc, max(rtrim(rs.descriere)) AS denresursa, max(CONVERT(VARCHAR(10), r.data, 101)) AS dataOperarii, max(
		RTRIM(r.codResursa)) AS resursa, max(RTRIM(r.codResursa)) AS cod, r.id AS id, max(rtrim(pr.CM)) AS nrCM, COUNT(pr.id) AS nrpoz
	, (
		CASE 
			WHEN COUNT(pr.id) = 0
				THEN '#FF0000'
			END
		) AS culoare
FROM Realizari r
LEFT JOIN pozRealizari pr ON r.id = pr.idRealizare
	AND pr.tip='P'
LEFT JOIN resurse rs ON rs.cod = r.codResursa
WHERE (
		(
			@idRealizare IS NOT NULL
			AND r.id = @idRealizare
			)
		OR (@idRealizare IS NULL)
		)
	and rs.cod like @fltCod
	and rs.descriere like @fltDescriere
	AND codResursa LIKE @fltCod
	AND r.data BETWEEN @datajos
		AND @datasus
	AND ISNULL(r.detalii.value('(/row/@tip)[1]', 'varchar(1)'), '') = 'O'
	and pr.PP is not null
GROUP BY r.id
FOR XML raw
