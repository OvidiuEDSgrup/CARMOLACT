CREATE
-- ALTER
VIEW [TipLaptePctAchizCentrColectLapte] AS
SELECT 
c.Loc_de_munca,
tl.Tip_lapte,
MAX( lm.Denumire) Den_loc_de_munca,
MAX( c.Cod_centru_colectare) Centru_colectare
FROM TipLapteCentrColect tl
	INNER JOIN CentrColectlapte c ON tl.Centru_colectare= c.cod_centru_colectare
	INNER JOIN lm ON c.Loc_de_munca= lm.cod			
GROUP BY c.Loc_de_munca, tl.Tip_lapte