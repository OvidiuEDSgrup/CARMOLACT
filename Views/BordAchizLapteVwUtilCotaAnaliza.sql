--ALTER 
 CREATE
VIEW [dbo].[BordAchizLapteVwUtilCotaAnaliza] as
SELECT 
Data_lunii,
Tip,
Producator,
b.Centru_colectare,
dbo.BOANCL( b.Data_lunii, p1.val_numerica) Data_inc_an_cota,
dbo.EOANCL( b.Data_lunii, p1.val_numerica) Data_sf_an_cota,
YEAR( dbo.BOANCL( b.Data_lunii, p1.val_numerica)) An_cota,
Cota_actuala,
Grad_actual,
Cant_UM,
Grasime,
Cant_UG,
Cant_STAS,
B.Pret,
Valoare,
b.Cant_UM* ISNULL( p2.val_numerica, 1.03) Cant_UM_cota,
b.Cant_UM* ISNULL( p2.val_numerica, 1.03)* b.Grasime Cant_UG_cota,
dbo.CotaUtilizata(b.Cant_UM* ISNULL( p2.val_numerica, 1.03),
					b.Cant_UM* ISNULL( p2.val_numerica, 1.03)* b.Grasime,p.Grad_actual,p2.val_numerica) 
AS Cota_utilizata_colecta,
ROUND( dbo.CotaUtilizata(b.Cant_UM* ISNULL( p2.val_numerica, 1.03),
					b.Cant_UM* ISNULL( p2.val_numerica, 1.03)* b.Grasime,p.Grad_actual, p2.val_numerica)
	*ISNULL(100/NULLIF(p.Cota_actuala,0),0), 2) 
AS Proc_utiliz_cota,
CASE WHEN ISNULL( (SELECT COUNT(*) 
		FROM AnalizaLapte a 
			LEFT JOIN BuletineAnalizaLapte bl ON bl.Nr_inreg_inf_set= a.Nr_inreg_inf_set 
				AND bl.Nr_inreg_sup_set= a.Nr_inreg_sup_set AND bl.Data= a.Data
		WHERE Tip_colecta=b.tip and Data_colecta=b.Data_lunii and a.rezultat=1
			and ((a.producator= b.producator and (a.Centru_colectare='' or a.Centru_colectare= b.Centru_colectare))
				or (a.Centru_colectare= b.Centru_colectare and (a.producator= '' or a.producator= b.producator)))), 0)>=2 THEN 1 
ELSE 0 END AS Rezultat_analiza_lapte
FROM BordAchizLapte b
INNER JOIN ProdLapte p on p.cod_producator= b.producator
LEFT JOIN par p1 on p1.tip_parametru= 'AL' and p1.parametru= 'LUNINCANC'
LEFT JOIN par p2 on p2.tip_parametru= 'AL' and p2.parametru= 'COEFCONVL'