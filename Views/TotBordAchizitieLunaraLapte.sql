CREATE 
-- ALTER
VIEW [TotBordAchizitieLunaraLapte] AS
SELECT 
b.Data_lunii,
b.Centru_colectare,
b.Tip_lapte,
MAX( c.Denumire) Den_centr_colectare,
MAX( c.Tip_pers) Tip_pers,
MAX( c.Loc_de_munca) LM_sau_tert,
SUM(b.Cant_UM) Cant_UM,
SUM(b.Cant_UG) AS Cant_UG,

SUM(ROUND(b.Cant_STAS,0)) AS Cant_STAS,

SUM(b.Valoare_STAS) AS Valoare_STAS,

ISNULL(SUM(b.Valoare_STAS)/
NULLIF(SUM(ROUND(b.Cant_STAS,0)),0),0) AS Pret_mediu_STAS

FROM BordAchizLapteVw b
	INNER JOIN TipLapte t on t.cod= b.tip_lapte
	INNER JOIN ProdLapte p on p.cod_producator= b.producator
	INNER JOIN CentrColectlapte c on b.Centru_colectare= c.Cod_centru_colectare
WHERE b.data_lunii BETWEEN dbo.BOANCC( NULL, NULL) and dbo.EOANCC( NULL, NULL) 
GROUP BY b.Data_lunii, b.Centru_colectare, b.Tip_Lapte