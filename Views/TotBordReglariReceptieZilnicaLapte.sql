
CREATE VIEW [dbo].[TotBordReglariReceptieZilnicaLapte] AS
SELECT l.Subunitate,  l.Data AS Data, 
l.Loc_de_munca AS LM_sau_tert, --tl.cod ,
	MAX(CASE l.tip WHEN 'AI' THEN 'F' WHEN 'RM' THEN 'J' ELSE '' END) AS Tip_pers, 
	'' AS Centru_colectare,
	'' AS Den_centru,
	MAX(lm.Denumire) AS Den_LM_sau_tert,
	MAX(tl.Denumire) AS Den_cod_reglare,
	SUM( l.Cantitate) AS Cant_UM,
	SUM(l.Cantitate*l.Pret_de_stoc) AS Valoare
FROM pozdoc l
	INNER JOIN nomencl tl ON l.cod = tl.cod
	INNER JOIN lm ON lm.cod= l.Loc_de_munca
	LEFT JOIN terti t ON t.subunitate=l.subunitate and t.tert= l.Tert
WHERE l.Cod='1853' and l.Data BETWEEN dbo.BOANCC( NULL, NULL) and dbo.EOANCC( NULL, NULL)
GROUP BY l.Subunitate, l.data, l.Loc_de_munca--, tl.cod
