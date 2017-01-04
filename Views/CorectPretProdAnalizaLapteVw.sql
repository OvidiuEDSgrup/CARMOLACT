CREATE VIEW [CorectPretProdAnalizaLapteVw] AS
SELECT
Data_lunii,
b.Tip,
Producator,
b.Centru_colectare,
b.Tip_lapte,
SUM(ISNULL(Corectie,0)) AS Corectie
FROM 
	(SELECT 
		Data_lunii,
		Tip,
		Producator,
		Centru_colectare,
		Tip_lapte,
		Indicator,
		CONVERT(decimal(15,5),AVG(Valoare)) as Valoare
	FROM BordAnalizaLapte
	WHERE Valoare<>0
	GROUP BY Data_lunii, Tip, Producator, Centru_colectare, Tip_lapte, Indicator) b
	LEFT JOIN ProdLapte p ON b.Producator= p.Cod_producator
	LEFT JOIN GrilaPretAnalizaLapte g ON g.Tip= p.Grupa and g.Tip_lapte=b.tip_lapte and g.Indicator= b.Indicator 
		and ROUND(b.Valoare,1)= ROUND(g.Valoare,1)
GROUP BY b.Data_lunii, b.Tip, b.Producator, b.Centru_colectare, b.Tip_lapte