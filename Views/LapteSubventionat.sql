CREATE 
-- ALTER
VIEW [dbo].[LapteSubventionat] AS
SELECT a.Nr_inregistrare,
a.Data,
a.Producator,
a.Data_inf_perioada,
a.Data_sup_perioada,
b.Data_lunii,
b.Tip,
b.Centru_colectare,
c.Denumire Den_centru_colectare,
b.tip_lapte,
t.denumire Den_tip_lapte,
b.Cant_UM,
b.Grasime,
b.Cant_UG,
b.Cant_STAS,
b.Pret,
b.Valoare,
b.Cant_UM* ISNULL( p2.val_numerica, 1.03) Cant_UM_cota,
b.Cant_UM* ISNULL( p2.val_numerica, 1.03)* b.Grasime Cant_UG_cota,

CASE WHEN ISNULL( (SELECT COUNT(*) 
		FROM AnalizaLapte a 
			LEFT JOIN BuletineAnalizaLapte bl ON bl.Nr_inreg_inf_set= a.Nr_inreg_inf_set 
				AND bl.Nr_inreg_sup_set= a.Nr_inreg_sup_set AND bl.Data= a.Data
		WHERE Tip_colecta=b.tip and Data_colecta=b.Data_lunii and a.rezultat=1
			and (a.producator= b.producator or a.Centru_colectare= b.Centru_colectare)), 0)>=2 THEN 1 
ELSE 0 END AS Rezultat_analiza_lapte,

ISNULL(REPLACE((SELECT rtrim(ltrim(a.Nr_inreg_inf_set))+ISNULL('-'+rtrim(ltrim(NULLIF(a.Nr_inreg_sup_set,a.Nr_inreg_inf_set))),'')
					+'/'+rtrim(convert(char(10),a.Data,104)) AS [data()]
		FROM AnalizaLapte a 
			LEFT JOIN BuletineAnalizaLapte bl ON bl.Nr_inreg_inf_set= a.Nr_inreg_inf_set 
				AND bl.Nr_inreg_sup_set= a.Nr_inreg_sup_set AND bl.Data= a.Data
		WHERE Tip_colecta=b.tip and Data_colecta=b.Data_lunii and a.rezultat=1
			and (a.producator= b.producator or a.Centru_colectare= b.Centru_colectare)
		ORDER BY a.Data, a.Nr_inreg_inf_set, a.Nr_inreg_sup_set FOR XML PATH ('')),' ',','), '') AS Buletine_analiza

FROM BordAchizLapte b 
	INNER JOIN CentrColectLapte c ON b.Centru_colectare= c.Cod_centru_colectare
	INNER JOIN TipLapte t ON b.tip_lapte= t.cod
	INNER JOIN AdevSubvenLapte a ON b.Producator= a.Producator 
		and b.data_lunii BETWEEN a.data_inf_perioada AND a.data_sup_perioada
	LEFT JOIN par p2 on p2.tip_parametru= 'AL' and p2.parametru= 'COEFCONVL'
WHERE b.Cant_UM>0