CREATE VIEW [CentrColectProdLapteVw] AS
SELECT 
CentrColectProdLapte.Centru_colectare,
Tip_lapte,
Producator,
Nr_ordine,
Nr_fisa,
Data_inscrierii,
ROW_NUMBER() OVER ( PARTITION by CentrColectProdLapte.Centru_colectare, Tip_lapte
	ORDER BY ProdLapte.Denumire, Nr_casa)  AS Nr_ord_alfabetica
FROM CentrColectProdLapte
	INNER JOIN ProdLapte ON CentrColectProdLapte.Producator= ProdLapte.Cod_producator