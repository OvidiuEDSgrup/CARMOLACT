CREATE
--ALTER
VIEW [dbo].[BordAchizLapteVwCotaUtilAnaliz] as
SELECT 
b.Data_lunii,
b.Tip,
b.Producator,
b.Centru_colectare,
b.Tip_lapte,
b.Cant_UM,
b.Pret,
b.Valoare,
b.Grasime_1,
b.Grasime_2,
b.Grasime,
CONVERT(decimal(15,5),0) AS Proteine,
b.Cant_UG,
CONVERT(decimal(15,5),0) AS Cant_UP,
b.Cant_STAS,
CONVERT(decimal(15,5),0) AS Pret_STAS,
CONVERT(decimal(15,5),0) AS Valoare_STAS,

dbo.BOANCL( b.Data_lunii, p1.val_numerica) Data_inc_an_cota,
dbo.EOANCL( b.Data_lunii, p1.val_numerica) Data_sf_an_cota,
YEAR( dbo.BOANCL( b.Data_lunii, p1.val_numerica)) An_cota,
Cod_exploatatie,
Cota_actuala,
Grad_actual,
b.Cant_UM* ISNULL( p2.val_numerica, 1.03) Cant_UM_cota,
b.Cant_UM* ISNULL( p2.val_numerica, 1.03)*CONVERT(decimal(8,2),ISNULL(bang.Valoare, b.Grasime)) Cant_UG_cota,
dbo.CotaUtilizata(b.Cant_UM* ISNULL( p2.val_numerica, 1.03),
	b.Cant_UM* ISNULL( p2.val_numerica, 1.03)* CONVERT(decimal(8,2),ISNULL(bang.Valoare, b.Grasime)),p.Grad_actual,p2.val_numerica) AS Cota_utilizata_colecta,

ROUND( dbo.CotaUtilizata(b.Cant_UM* ISNULL( p2.val_numerica, 1.03),
					b.Cant_UM* ISNULL( p2.val_numerica, 1.03)* CONVERT(decimal(8,2),ISNULL(bang.Valoare, b.Grasime)),p.Grad_actual, p2.val_numerica)
	*ISNULL(100/NULLIF(p.Cota_actuala,0),0), 2) AS Proc_cota_utilizata_colecta,

CASE WHEN ISNULL( (SELECT COUNT(*) 
		FROM AnalizaLapte a 
			LEFT JOIN BuletineAnalizaLapte bl ON bl.Nr_inreg_inf_set= a.Nr_inreg_inf_set 
				AND bl.Nr_inreg_sup_set= a.Nr_inreg_sup_set AND bl.Data= a.Data
		WHERE Tip_colecta=b.tip and Data_colecta=b.Data_lunii and a.rezultat=1
			and (a.producator= b.producator or a.Centru_colectare= b.Centru_colectare)), 0)>=2 THEN 1 
ELSE 0 END AS Rezultat_analiza_lapte

FROM BordAchizLapte b
	INNER JOIN ProdLapte p on p.cod_producator= b.producator
	LEFT JOIN BordAnalizaLapteVw bang ON bang.Data_lunii=b.Data_lunii
		and bang.Tip=b.Tip and bang.Producator=b.Producator and bang.Centru_colectare=b.Centru_colectare
		and bang.Tip_lapte=b.Tip_lapte and bang.Indicator='G'
	LEFT JOIN TipLapte t ON t.Cod= b.Tip_lapte
	LEFT JOIN par p1 on p1.tip_parametru= 'AL' and p1.parametru= 'LUNINCANC'
	LEFT JOIN par p2 on p2.tip_parametru= 'AL' and p2.parametru= 'COEFCONVL'