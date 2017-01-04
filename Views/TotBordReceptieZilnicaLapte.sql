CREATE VIEW [TotBordReceptieZilnicaLapte] AS
SELECT l.Subunitate,  g.Data_lunii AS Data, 
l.Loc_de_munca AS LM_sau_tert, tl.cod AS Tip_lapte,
	MAX(CASE l.tip WHEN 'AI' THEN 'F' WHEN 'RM' THEN 'J' ELSE '' END) AS Tip_pers, 
	'' AS Centru_colectare,
	'' AS Den_centru,
	MAX(lm.Denumire) AS Den_LM_sau_tert,
	MAX(tl.Denumire) AS Den_lapte,
	ROUND(SUM( l.Cantitate*l.Grasime / 
		ISNULL(NULLIF( tl.Grasime_standard, 0), 1)),0) AS Cant_STAS, 
	ROUND(SUM(l.Cantitate*l.Pret_de_stoc),0) AS Valoare_STAS,
	ROUND(SUM( l.Cantitate* l.Grasime),0) AS Cant_UG,
	SUM( l.Cantitate) AS Cant_UM,
	SUM(l.Cantitate*l.Pret_de_stoc) AS Valoare
FROM IntrariLapteCantitativScriptic l
	INNER JOIN GrilaPlataPctAchizLapte g ON g.Loc_de_munca= l.Loc_de_munca and g.Tip_lapte= l.cod 
		and l.Data<= g.Data_lunii 
		and l.Data> ISNULL((SELECT MAX(g1.Data_lunii) FROM GrilaPlataPctAchizLapte g1 
			WHERE g.Loc_de_munca= g1.Loc_de_munca and g.Tip_lapte= g1.Tip_lapte 
				and g1.Data_lunii<g.Data_lunii), dbo.BOM(g.Data_lunii)-1)
	INNER JOIN tiplapte tl ON l.cod = tl.cod
	INNER JOIN lm ON lm.cod= l.Loc_de_munca
	LEFT JOIN terti t ON t.subunitate=l.subunitate and t.tert= l.Tert
WHERE l.Data BETWEEN dbo.BOANCC( NULL, NULL) and dbo.EOANCC( NULL, NULL)
GROUP BY l.Subunitate, g.Data_lunii, l.Loc_de_munca, tl.cod