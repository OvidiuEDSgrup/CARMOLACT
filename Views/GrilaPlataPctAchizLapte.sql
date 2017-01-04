CREATE
-- ALTER
VIEW [GrilaPlataPctAchizLapte] AS
SELECT 
b.Data_lunii,
c.Loc_de_munca,
b.Tip_lapte,
MAX( lm.Denumire) Den_loc_de_munca,
MAX( c.Tip_pers) Tip_pers,
MAX( b.Centru_colectare) Centru_colectare,
MAX( b.Pret) AS Pret

FROM GrilaPretCentrColectLapte b
	INNER JOIN TipLapte t on t.cod= b.tip_lapte
	INNER JOIN CentrColectlapte c on b.Centru_colectare= c.Cod_centru_colectare
	INNER JOIN lm ON c.Loc_de_munca= lm.cod		
WHERE b.data_lunii BETWEEN dbo.BOANCC( NULL, NULL) and dbo.EOANCC( NULL, NULL) 
GROUP BY b.Data_lunii, c.Loc_de_munca, b.Tip_Lapte