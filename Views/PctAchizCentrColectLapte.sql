CREATE
-- ALTER
VIEW [dbo].[PctAchizCentrColectLapte] AS
SELECT 
c.Loc_de_munca,
MAX( lm.Denumire) Den_loc_de_munca,
MAX( c.Tip_pers) AS Tip_pers,
MAX( c.Tert) AS Tert,
MAX( t.Denumire) AS Den_tert,
MAX( c.Cod_centru_colectare) Centru_colectare
FROM CentrColectlapte c 
	INNER JOIN lm ON c.Loc_de_munca= lm.cod			
	LEFT JOIN terti t ON t.tert= c.tert
GROUP BY c.Loc_de_munca