CREATE 
-- ALTER
VIEW [TotBordLunarPctAchizLapte] AS
SELECT 
b.Data_lunii,
c.Loc_de_munca,
b.Tip_lapte,
MAX( lm.Denumire) Den_loc_de_munca,
MAX( c.Tip_pers) Tip_pers,
MAX( b.Centru_colectare) Centru_colectare,
SUM(b.Cant_UM) Cant_UM,
SUM(b.Valoare) AS Valoare,
ISNULL(SUM(b.Valoare)/NULLIF(SUM(b.Cant_UM),0),1) AS Pret_mediu,

SUM(b.Cant_UG) AS Cant_UG,
SUM(ROUND(b.Cant_STAS,0)) AS Cant_STAS,

SUM(b.Valoare_STAS) AS Valoare_STAS,

ISNULL(SUM(b.Valoare_STAS)/
NULLIF(SUM(ROUND(b.Cant_STAS,0)),0),0) AS Pret_mediu_STAS
FROM BordAchizLapteVw b
	INNER JOIN TipLapte t on t.cod= b.tip_lapte
	INNER JOIN ProdLapte p on p.cod_producator= b.producator
	INNER JOIN CentrColectlapte c on b.Centru_colectare= c.Cod_centru_colectare
	INNER JOIN lm ON c.Loc_de_munca= lm.cod		
WHERE b.data_lunii BETWEEN dbo.BOANCC( NULL, NULL) and dbo.EOANCC( NULL, NULL) 
GROUP BY b.Data_lunii, c.Loc_de_munca, b.Tip_Lapte