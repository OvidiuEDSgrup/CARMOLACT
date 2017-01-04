
CREATE VIEW [dbo].[BordAchizLapteVw] as
SELECT 
b.Data_lunii,
b.Tip,
b.Producator,
b.Centru_colectare,
b.Tip_lapte,
p.Denumire AS Den_prod,
p.CNP_CUI,
p.Nr_casa,
p.Grupa,
b.Cant_UM,
ISNULL(cp.bonus-cp.penalizare, 
			ISNULL(p.Bonus*(SELECT TOP 1 Bonus FROM GrilaPretCantLapte gpc WHERE gpc.tip=p.grupa 
					and gpc.tip_lapte= b.Tip_lapte and CASE gpc.perioada WHEN 'Z' THEN CONVERT(DECIMAL(7,0),b.Cant_UM/DAY(b.Data_lunii)) ELSE b.Cant_UM END
BETWEEN gpc.limita_inf AND gpc.limita_sup), 0)) AS Bonus,

ISNULL(gpag.Corectie, 0)+ISNULL(gpap.Corectie, 0) AS Corectie,
ISNULL(NULLIF(p.Pret,0),gc.Pret)+ISNULL(cp.bonus-cp.penalizare,
			ISNULL(p.Bonus*(SELECT TOP 1 Bonus FROM GrilaPretCantLapte gpc WHERE gpc.tip=p.grupa 
					and gpc.tip_lapte= b.Tip_lapte and CASE gpc.perioada WHEN 'Z' THEN CONVERT(DECIMAL(7,0),b.Cant_UM/DAY(b.Data_lunii)) ELSE b.Cant_UM END
BETWEEN gpc.limita_inf AND gpc.limita_sup), 0))
		+ISNULL(gpag.Corectie, 0)+ISNULL(gpap.Corectie, 0) AS Pret,

b.Cant_UM*
(ISNULL(NULLIF(p.Pret,0),gc.Pret)+ISNULL(cp.bonus-cp.penalizare,
			ISNULL(p.Bonus*(SELECT TOP 1 Bonus FROM GrilaPretCantLapte gpc WHERE gpc.tip=p.grupa 
					and gpc.tip_lapte= b.Tip_lapte and CASE gpc.perioada WHEN 'Z' THEN CONVERT(DECIMAL(7,0),b.Cant_UM/DAY(b.Data_lunii)) ELSE b.Cant_UM END
BETWEEN gpc.limita_inf AND gpc.limita_sup), 0))
		+ISNULL(gpag.Corectie, 0)+ISNULL(gpap.Corectie, 0)) AS Valoare,
b.Grasime_1,
b.Grasime_2,
CONVERT(decimal(8,2),ISNULL(bang.Valoare, b.Grasime)) AS Grasime,
CONVERT(decimal(8,2),ISNULL(banp.Valoare, 0)) AS Proteine,
ISNULL(NULLIF(b.Cant_UG,0), b.Cant_UM*CONVERT(decimal(8,2),ISNULL(bang.Valoare, b.Grasime))) AS Cant_UG,
b.Cant_UM*CONVERT(decimal(8,2),ISNULL(banp.Valoare, 0)) AS Cant_UP,

ROUND(ISNULL(NULLIF(b.Cant_UG,0), b.Cant_UM*CONVERT(decimal(8,2),ISNULL(bang.Valoare, b.Grasime)))
/COALESCE(NULLIF(tp.Grasime_standard,0),NULLIF(gc.procent,0),t.Grasime_standard),0) AS Cant_STAS,

gc.Pret+ISNULL(cp.bonus-cp.penalizare,
	ISNULL(p.Bonus*(SELECT TOP 1 Bonus FROM GrilaPretCantLapte gpc WHERE gpc.tip=p.grupa 
					and gpc.tip_lapte= b.Tip_lapte and CASE gpc.perioada WHEN 'Z' THEN CONVERT(DECIMAL(7,0),b.Cant_UM/DAY(b.Data_lunii)) ELSE b.Cant_UM END
BETWEEN gpc.limita_inf AND gpc.limita_sup), 0)) AS Pret_STAS,

ROUND(ISNULL(NULLIF(b.Cant_UG,0), b.Cant_UM*CONVERT(decimal(8,2),ISNULL(bang.Valoare, b.Grasime)))
/COALESCE(NULLIF(tp.Grasime_standard,0),NULLIF(gc.procent,0),t.Grasime_standard),0)
*(gc.Pret+ISNULL(cp.bonus-cp.penalizare,
	ISNULL(p.Bonus*(SELECT TOP 1 Bonus FROM GrilaPretCantLapte gpc WHERE gpc.tip=p.grupa 
					and gpc.tip_lapte= b.Tip_lapte and CASE gpc.perioada WHEN 'Z' THEN CONVERT(DECIMAL(7,0),b.Cant_UM/DAY(b.Data_lunii)) ELSE b.Cant_UM END
BETWEEN gpc.limita_inf AND gpc.limita_sup), 0))) AS Valoare_STAS,
b.Data_doc as Data_doc,
b.Nr_doc as Nr_doc

FROM BordAchizLapte b
	INNER JOIN ProdLapte p on p.cod_producator= b.producator
	LEFT JOIN BordAnalizaLapteVw bang ON bang.Data_lunii=b.Data_lunii
		and bang.Tip=b.Tip and bang.Producator=b.Producator and bang.Centru_colectare=b.Centru_colectare
		and bang.Tip_lapte=b.Tip_lapte and bang.Indicator='G'
	LEFT JOIN BordAnalizaLapteVw banp ON banp.Data_lunii=b.Data_lunii
		and banp.Tip=b.Tip and banp.Producator=b.Producator and banp.Centru_colectare=b.Centru_colectare
		and banp.Tip_lapte=b.Tip_lapte and banp.Indicator='P'
	LEFT JOIN TipLapte t ON t.Cod= b.Tip_lapte
	LEFT JOIN TipLapteProd tp ON tp.producator=b.producator and tp.Tip_lapte= b.Tip_lapte
	LEFT JOIN CorectPretProdCantLapte cp ON cp.Producator= b.Producator 
		AND cp.Data_lunii= b.Data_lunii AND cp.Tip_lapte= b.Tip_lapte
	LEFT JOIN GrilaPretCentrColectLapte gc ON gc.Centru_colectare= b.Centru_colectare 
		AND gc.Data_lunii= b.Data_lunii AND gc.Tip_lapte= b.Tip_lapte
	LEFT JOIN GrilaPretAnalizaLapte gpag ON gpag.Tip= p.Grupa and gpag.Tip_lapte=b.tip_lapte and gpag.Indicator= bang.Indicator 
		and ROUND(gpag.Valoare,1)= ROUND(bang.Valoare, 1)
	LEFT JOIN GrilaPretAnalizaLapte gpap ON gpap.Tip= p.Grupa and gpap.Tip_lapte=b.tip_lapte and gpap.Indicator= banp.Indicator 
		and ROUND(gpap.Valoare,1)= ROUND(banp.Valoare, 1)
	LEFT JOIN par p1 on p1.tip_parametru= 'AL' and p1.parametru= 'LUNINCANC'
	LEFT JOIN par p2 on p2.tip_parametru= 'AL' and p2.parametru= 'COEFCONVL'
