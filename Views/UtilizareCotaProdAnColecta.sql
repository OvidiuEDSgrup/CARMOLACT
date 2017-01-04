CREATE 
-- ALTER
VIEW UtilizareCotaProdAnColecta AS
SELECT 
p.Cod_producator Producator,
SUM(ISNULL( b.Cant_UM,0)) Cant_UM,
SUM(ISNULL( b.Cant_UM* b.Grasime, 0)) Cant_UG,
SUM(ISNULL( b.Cant_UM* b.Grasime/ NULLIF(p4.val_numerica,0),0)) Cant_STAS,
SUM(ISNULL( b.Cant_UM, 0)* ISNULL( p3.val_numerica, 1.03)) Cant_UM_cota,
SUM(ISNULL( b.Cant_UM* ISNULL( p3.val_numerica, 1.03)* b.Grasime, 0)) Cant_UG_cota,
SUM(ISNULL( b.Cant_UM, 0)* ISNULL( p3.val_numerica, 1.03)* ISNULL(b.Grasime/ NULLIF(p4.val_numerica,0),0)) Cant_STAS_UM_cota,
MAX( p.Grad_actual) Grad_actual,
MAX( p.Cota_actuala) Cota_actuala,
dbo.CotaUtilizata(SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)), 
					SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)* b.Grasime), 
					MAX( p.Grad_actual), MAX( p3.val_numerica)) AS Cota_utilizata,
ROUND( dbo.CotaUtilizata(SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)), 
					SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)* b.Grasime), 
					MAX( p.Grad_actual), MAX( p3.val_numerica))
		*ISNULL(100/NULLIF( MAX( p.Cota_actuala),0),0), 2) Proc_utiliz_cota,
ROUND( ISNULL( (MAX( p.Cota_actuala)
	-dbo.CotaUtilizata(SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)), 
					SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)* b.Grasime), 
					MAX( p.Grad_actual), MAX( p3.val_numerica)))
	/NULLIF(dbo.CotaUtilizata(AVG(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)), 
			AVG(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)* b.Grasime), 
			MAX(p.Grad_actual), MAX(p3.val_numerica)),0),0), 0) 
AS Nr_luni_cota_ramase,
DATEDIFF( mm, MAX(ISNULL( b.Data_lunii, '')), 
dbo.EOANCL( MAX(ISNULL( b.Data_lunii, '')), MAX(p1.val_numerica))) AS Nr_luni_an_cota_ramase,
dbo.CantUmRestCota(SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)), 
	SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)* b.Grasime), 
	MAX( p.Grad_actual), 
	MAX( p.Cota_actuala), 
	AVG(b.Grasime), 
	MAX(p3.val_numerica)) AS Cant_UM_rest_cota,
AVG(ISNULL(b.Grasime,0)) AS Gras_medie_rest_cota,
dbo.CantUmRestCota(SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)), 
	SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)* b.Grasime), 
	MAX( p.Grad_actual), 
	MAX( p.Cota_actuala), 
	AVG(b.Grasime), 
	MAX(p3.val_numerica))
*AVG(ISNULL(b.Grasime,0)) AS Cant_UG_rest_cota,
dbo.CantUmRestCota(SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)), 
	SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)* b.Grasime), 
	MAX( p.Grad_actual), 
	MAX( p.Cota_actuala), 
	AVG(b.Grasime), 
	MAX(p3.val_numerica))
*ISNULL(AVG(b.Grasime)/ NULLIF(MAX(p4.val_numerica),0),0) AS Cant_STAS_rest_cota,
dbo.CantUmRestCota(SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)), 
	SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)* b.Grasime), 
	MAX( p.Grad_actual), 
	MAX( p.Cota_actuala), 
	AVG(b.Grasime), 
	MAX(p3.val_numerica))
*ISNULL( MAX(p3.val_numerica), 1.03) Cant_UM_cota_rest_cota,
dbo.CantUmRestCota(SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)), 
	SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)* b.Grasime), 
	MAX( p.Grad_actual), 
	MAX( p.Cota_actuala), 
	AVG(b.Grasime), 
	MAX(p3.val_numerica))
*ISNULL( MAX(p3.val_numerica), 1.03)* AVG(ISNULL(b.Grasime,0)) Cant_UG_cota_rest_cota,
dbo.CantUmRestCota(SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)), 
	SUM(b.Cant_UM* ISNULL( p3.val_numerica, 1.03)* b.Grasime), 
	MAX( p.Grad_actual), 
	MAX( p.Cota_actuala), 
	AVG(b.Grasime), 
	MAX(p3.val_numerica))
*ISNULL( MAX(p3.val_numerica), 1.03)* ISNULL(AVG(b.Grasime)/ NULLIF(MAX(p4.val_numerica),0),0) 
AS Cant_STAS_UM_cota_rest_cota
FROM ProdLapte p
LEFT JOIN BordAchizLapte b on p.cod_producator= b.producator
LEFT JOIN par p1 on p1.tip_parametru= 'AL' and p1.parametru= 'LUNINCANC'
LEFT JOIN par p2 on p2.tip_parametru= 'AL' and p2.parametru= 'ANCOTACUR'
LEFT JOIN par p3 on p3.tip_parametru= 'AL' and p3.parametru= 'COEFCONVL'
LEFT JOIN par p4 ON p4.tip_parametru= 'AL' and p4.parametru= 'PROCGRASS'
WHERE b.data_lunii IS NULL 
	OR b.data_lunii BETWEEN dbo.BOANCC( p2.val_numerica, p1.val_numerica) 
	AND dbo.EOANCC( p2.val_numerica, p1.val_numerica) 
GROUP BY p.Cod_producator