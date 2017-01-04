CREATE VIEW [BordReceptieZilnicaLapte] AS
SELECT l.Subunitate,  dbo.EOM(l.Data) AS Data_lunii, CASE l.tip WHEN 'AI' THEN 'F' WHEN 'RM' THEN 'J' ELSE '' END AS Tip_pers, 
	l.Loc_de_munca AS LM_sau_tert, lm.denumire Den_LM_sau_tert, 
	tl.cod AS Tip_lapte, tl.Denumire AS Den_lapte, 
	l.Gestiune, l.Data, l.Numar, l.Cod, l.Numar_pozitie,
	l.Cantitate AS Cant_UM, 	
	l.Pret_de_stoc,
	l.Cantitate*l.Pret_de_stoc AS Valoare,
	l.Grasime AS Procent_grasime, 
	l.Cantitate* l.Grasime Cant_UG,
	ISNULL( l.Cantitate*l.Grasime / NULLIF( tl.Grasime_standard, 0), 0) Cant_STAS,
	l.Pret_de_stoc AS Pret_STAS, 
	l.Cantitate*l.Pret_de_stoc AS Valoare_STAS
FROM intrarilapte l
INNER JOIN tiplapte tl ON l.cod = tl.cod
INNER JOIN lm ON lm.cod= l.Loc_de_munca
LEFT JOIN terti t ON t.subunitate=l.subunitate and t.tert= l.Tert
WHERE l.Tip IN ('AI', 'RM')
	AND l.Data BETWEEN dbo.BOANCC( NULL, NULL) and dbo.EOANCC( NULL, NULL)