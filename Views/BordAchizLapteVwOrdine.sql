CREATE VIEW [BordAchizLapteVwOrdine] AS
SELECT 
Data_lunii,
Tip,
BordAchizLapte.Producator,
BordAchizLapte.Centru_colectare,
BordAchizLapte.Tip_lapte,
Cant_UM,
Grasime_1,
Grasime_2,
Grasime,
Cant_UG,
Cant_STAS,
BordAchizLapte.Pret,
Valoare,
ROW_NUMBER() OVER ( PARTITION by  Data_lunii, BordAchizLapte.Tip, 
						BordAchizLapte.Centru_colectare, BordAchizLapte.Tip_lapte
					ORDER BY ProdLapte.Denumire, Nr_casa)  AS Nr_ord_alfabetica
FROM BordAchizLapte
	INNER JOIN ProdLapte ON BordAchizLapte.Producator= ProdLapte.Cod_producator