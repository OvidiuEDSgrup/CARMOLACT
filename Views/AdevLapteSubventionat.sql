CREATE VIEW AdevLapteSubventionat AS
SELECT Nr_inregistrare, Data,
MAX(Producator) AS Producator,
MAX(Centru_colectare) AS Centru_colectare,
dbo.BOM(MIN(Data_lunii)) AS Data_inf_livrare,
dbo.EOM(MAX(Data_lunii)) AS Data_sup_livrare,
SUM( ISNULL( Cant_UM, 0)) AS Suma_cant_UM_livrata,
SUM( ISNULL( Cant_UM_cota, 0)) AS Suma_cant_UM_cota_livrata,
SUM( CASE ISNULL( Rezultat_analiza_lapte, 0) WHEN 1 THEN Cant_UM ELSE 0 END) AS Suma_cant_UM_subventionata,
SUM( CASE ISNULL( Rezultat_analiza_lapte, 0) WHEN 1 THEN Cant_UM_cota ELSE 0 END) AS Suma_cant_UM_cota_subventionata,
COUNT(DISTINCT CASE WHEN Rezultat_analiza_lapte=0 OR Cant_UM=0 THEN NULL ELSE 
	CONVERT(CHAR(4),YEAR(Data_lunii))+'_'+CONVERT(CHAR(2),MONTH(Data_lunii)) END) AS Nr_luni_valide,

ISNULL(REPLACE(rtrim(ltrim((SELECT DISTINCT rtrim(ltrim(l.Buletine_analiza)) AS [data()]
		FROM LapteSubventionat l 			
		WHERE l.Nr_inregistrare= LapteSubventionat.Nr_inregistrare AND l.Data= LapteSubventionat.Data
		ORDER BY rtrim(ltrim(l.Buletine_analiza)) FOR XML PATH ('')))),' ',';'), '') AS Buletine_analiza,

ISNULL(REPLACE((SELECT DISTINCT rtrim(ltrim(bl.Laborator_analize))+ISNULL('-'+rtrim(ltrim(NULLIF(bl.Sediu_laborator,bl.Laborator_analize))),'') AS [data()]
		FROM AnalizaLapte a
			LEFT JOIN BuletineAnalizaLapte bl ON bl.Nr_inreg_inf_set= a.Nr_inreg_inf_set 
				AND bl.Nr_inreg_sup_set= a.Nr_inreg_sup_set AND bl.Data= a.Data
			LEFT JOIN BordAchizLapte b ON b.Data_lunii=Data_colecta and b.Tip=Tip_colecta 
				and (a.producator= b.producator or a.Centru_colectare= b.Centru_colectare)
			INNER JOIN AdevSubvenLapte adv ON b.Producator= adv.Producator 
				and b.data_lunii BETWEEN adv.data_inf_perioada AND adv.data_sup_perioada
		WHERE adv.Nr_inregistrare= LapteSubventionat.Nr_inregistrare AND adv.Data= LapteSubventionat.Data
			and a.rezultat=1 and bl.Laborator_analize<>''
		ORDER BY rtrim(ltrim(bl.Laborator_analize))+ISNULL('-'+rtrim(ltrim(NULLIF(bl.Sediu_laborator,bl.Laborator_analize))),'') 
			FOR XML PATH ('')),' ',','), '') AS Laboratoare_analize
FROM LapteSubventionat GROUP BY Nr_inregistrare, Data