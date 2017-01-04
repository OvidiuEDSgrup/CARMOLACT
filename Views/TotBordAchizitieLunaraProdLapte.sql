CREATE
-- ALTER
VIEW [TotBordAchizitieLunaraProdLapte] AS
SELECT 
b.Data_lunii,
b.Producator,
b.Tip_Lapte,
MAX( p.Denumire) Den_producator,
MAX( b.Centru_colectare) Centru_colectare,
MAX( p.Tip_pers) Tip_pers,
MAX( c.Loc_de_munca) LM_sau_tert,
SUM(b.Cant_UM) Cant_UM,
SUM(b.Cant_UM* b.Grasime) AS Cant_UG,

SUM(ROUND(b.Cant_UM* b.Grasime/
	ISNULL( NULLIF(t.Grasime_standard, 0), 1),0)) AS Cant_STAS,

SUM(ROUND(b.Cant_UM* b.Grasime/ 
	ISNULL( NULLIF(t.Grasime_standard, 0), 1),0)* b.pret) AS Valoare_STAS,

SUM(ROUND(b.Cant_UM* b.Grasime/ 
	ISNULL( NULLIF(t.Grasime_standard, 0), 1),0)* b.pret)/
	ISNULL(NULLIF(SUM(ROUND(b.Cant_UM*b.Grasime/ 
	ISNULL( NULLIF(t.Grasime_standard, 0), 1),0)),0),1) AS Pret_mediu_STAS
FROM BordAchizLapteVw b
	INNER JOIN TipLapte t on t.cod= b.tip_lapte
	INNER JOIN ProdLapte p on p.cod_producator= b.producator
	INNER JOIN CentrColectlapte c on b.Centru_colectare= c.Cod_centru_colectare
WHERE b.data_lunii BETWEEN dbo.BOANCC( NULL, NULL) and dbo.EOANCC( NULL, NULL) 
GROUP BY b.Data_lunii, b.Producator, b.Tip_Lapte