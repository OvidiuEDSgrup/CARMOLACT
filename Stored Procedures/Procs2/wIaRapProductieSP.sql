
CREATE PROCEDURE [dbo].[wIaRapProductieSP] @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @fltDescriere VARCHAR(80), @fltCod VARCHAR(20), @fltTip VARCHAR(20), @datajos DATETIME, @datasus DATETIME, @idRealizare INT

SET @fltCod = '%' + REPLACE(ISNULL(@parXML.value('(/row/@f_cod)[1]', 'varchar(20)'), ''), ' ', '%') + '%'
SET @fltDescriere = '%' + REPLACE(ISNULL(@parXML.value('(/row/@f_descriere)[1]', 'varchar(80)'), ''), ' ', '%') + '%'
SET @datajos = @parXML.value('(/row/@datajos)[1]', 'datetime')
SET @datasus = @parXML.value('(/row/@datasus)[1]', 'datetime')
SET @idRealizare = @parXML.value('(/row/@idRealizare)[1]', 'int')

SELECT max(r.nrDoc) AS nrDoc, max(rtrim(rs.descriere)) AS resursa, max(CONVERT(VARCHAR(10), r.data, 101)) AS data, max(RTRIM(r.
			codResursa)) AS codRes, r.id AS idRealizare, max(RTRIM(r.codResursa)) AS cod, max(rtrim(pr.CM)) AS nrCM, max(rtrim(pr.PP
		)) AS nrPP, COUNT(pr.id) AS nrpoz, max(rtrim(dp.Cod_gestiune)) gestPP, max(rtrim(gp.Denumire_gestiune)) denGestiunePP, max
	(rtrim(dc.Cod_gestiune)) gestCM, max(rtrim(gc.Denumire_gestiune)) denGestiuneCM, (CASE WHEN COUNT(pr.id) = 0 THEN '#FF0000' END
		) AS culoare
FROM Realizari r
LEFT JOIN pozRealizari pr ON r.id = pr.idRealizare
	AND pr.tip = 'T'
LEFT JOIN resurse rs ON rs.cod = r.codResursa
LEFT JOIN doc dp ON dp.Numar = pr.PP
	AND dp.Tip = 'PP'
LEFT JOIN gestiuni gp ON dp.Cod_gestiune = gp.Cod_gestiune
LEFT JOIN doc dc ON dc.Numar = pr.CM
	AND dc.Tip = 'CM'
LEFT JOIN gestiuni gc ON dc.Cod_gestiune = gc.Cod_gestiune
WHERE (
		(
			@idRealizare IS NOT NULL
			AND r.id = @idRealizare
			)
		OR (@idRealizare IS NULL)
		)
	--AND codResursa LIKE @fltCod
	AND r.data BETWEEN @datajos
		AND @datasus
	AND ISNULL(r.detalii.value('(/row/@tip)[1]', 'varchar(1)'), '') = 'T'
	--and pr.PP is not null
GROUP BY r.id
FOR XML raw
