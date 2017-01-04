CREATE VIEW [JudProdCentrColectLapte] AS 
SELECT DISTINCT Judet, ISNULL(Judete.Denumire,'') AS Denumire
FROM ProdLapte 
	LEFT JOIN Judete ON Judete.cod_judet=ProdLapte.judet
UNION
SELECT DISTINCT Judet, ISNULL(Judete.Denumire,'') AS Denumire
FROM CentrColectLapte 
	LEFT JOIN Judete ON Judete.cod_judet=CentrColectLapte.judet