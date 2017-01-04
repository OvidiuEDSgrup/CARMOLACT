CREATE FUNCTION [UtilizareCotaProdAnLuna]
(	
	@Anul NUMERIC(4)=NULL,
	@Luna NUMERIC(2)=NULL
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
p.Cod_producator Producator,
MAX(ISNULL(b.Centru_colectare,p.Centru_colectare)) Centru_colectare,
dbo.BOANCC(@Anul, @Luna) Data_inc_an_cota,
dbo.EOANCC(@Anul, @Luna) Data_sf_an_cota,
CONVERT(CHAR(4),YEAR(dbo.BOANCC(@Anul, @Luna)))+'/'+CONVERT(CHAR(4),YEAR(dbo.EOANCC(@Anul, @Luna))) An_cota,
SUM(ISNULL( (b.Cant_UM*t.cota),0)) Cant_UM,
SUM(ISNULL( (b.Cant_UM*t.cota)* CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime)), 0)) Cant_UG,
SUM(ISNULL( (b.Cant_UM*t.cota)* CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime))/ NULLIF(t.grasime_standard,0),0)) Cant_STAS,
SUM(ISNULL( (b.Cant_UM*t.cota), 0)* ISNULL( p3.val_numerica, 1.03)) Cant_UM_cota,
SUM(ISNULL( (b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)* CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime)), 0)) Cant_UG_cota,
SUM(ISNULL( (b.Cant_UM*t.cota), 0)* ISNULL( p3.val_numerica, 1.03)* ISNULL(CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime))/ NULLIF(t.grasime_standard,0),0)) Cant_STAS_UM_cota,
MAX( p.Grad_actual) Grad_actual,
MAX( p.Cota_actuala) Cota_actuala,

dbo.CotaUtilizata(SUM((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)), 
					SUM((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)* CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime))), 
					MAX( p.Grad_actual), MAX( p3.val_numerica)) AS Cota_utilizata,

ROUND( dbo.CotaUtilizata(SUM((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)), 
					SUM((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)* CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime))), 
					MAX( p.Grad_actual), MAX( p3.val_numerica))
		*ISNULL(100/NULLIF( MAX( p.Cota_actuala),0),0), 2) AS Proc_utiliz_cota,

ROUND( ISNULL( 
	CASE WHEN (MAX( p.Cota_actuala)
	-dbo.CotaUtilizata(SUM((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)), 
					SUM((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)* CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime))), 
					MAX( p.Grad_actual), MAX( p3.val_numerica)))>0
	THEN (MAX( p.Cota_actuala)
	-dbo.CotaUtilizata(SUM((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)), 
					SUM((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)* CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime))), 
					MAX( p.Grad_actual), MAX( p3.val_numerica)))
	ELSE 0 END
	/NULLIF(dbo.CotaUtilizata(AVG((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)), 
			AVG((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)* CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime))), 
			MAX(p.Grad_actual), MAX(p3.val_numerica)),0),0), 0) AS Nr_luni_colecta_ramase,

DATEDIFF( mm, MAX(ISNULL( b.Data_lunii, '')), 
dbo.EOANCC( YEAR(MAX(ISNULL( b.Data_lunii, ''))),MONTH(MAX(ISNULL( b.Data_lunii, ''))) )) AS Nr_luni_an_cota_ramase,

dbo.CantUmRestCota(SUM((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)), 
	SUM((b.Cant_UM*t.cota)* ISNULL( p3.val_numerica, 1.03)* CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime))), 
	MAX( p.Grad_actual), 
	MAX( p.Cota_actuala), 
	NULL, 
	MAX(p3.val_numerica)) AS Cant_UM_rest_cota,

--AVG(ISNULL(CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime)),0)) 
ROUND(ISNULL(SUM((b.Cant_UM*t.cota)* ISNULL(CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime)),0))/
NULLIF(SUM((b.Cant_UM*t.cota)),0),0),4) AS Gras_medie_rest_cota

FROM ProdLapte p
	LEFT JOIN BordAchizLapte b on p.cod_producator= b.producator
	LEFT JOIN (SELECT 
			Data_lunii,
			Tip,
			Producator,
			Centru_colectare,
			Tip_lapte,
			Indicator,
			CONVERT(decimal(8,2), AVG(Valoare)) as Valoare
		FROM BordAnalizaLapte
		WHERE Valoare<>0 and Indicator='G'
		GROUP BY Data_lunii, Tip, Producator, Centru_colectare, Tip_lapte, Indicator) ban 
		ON ban.Data_lunii=b.Data_lunii and ban.Tip=b.Tip and ban.Producator=b.Producator 
			and ban.Centru_colectare=b.Centru_colectare and ban.Tip_lapte=b.Tip_lapte
--	LEFT JOIN par p1 on p1.tip_parametru= 'AL' and p1.parametru= 'LUNINCANC'
--	LEFT JOIN par p2 on p2.tip_parametru= 'AL' and p2.parametru= 'ANCOTACUR'
	LEFT JOIN par p3 on p3.tip_parametru= 'AL' and p3.parametru= 'COEFCONVL'
	LEFT JOIN tiplapte t ON t.cod= b.tip_lapte 
WHERE (b.data_lunii IS NULL 
		OR b.data_lunii BETWEEN dbo.BOANCC(@Anul, @Luna) 
					AND ISNULL( dbo.EOM(CAST( CAST(@Anul AS CHAR(4))+ '-' + CAST(@Luna AS CHAR(2))+ '-'+ '1' AS DATETIME)),
								dbo.EOANCC(@Anul, @Luna)))
--	AND ((b.Cant_UM*t.cota)* ISNULL(ban.Valoare, b.Grasime) IS NULL OR (b.Cant_UM*t.cota)* ISNULL(ban.Valoare, b.Grasime) >0)
--	and (t.cota IS NULL OR t.cota=1)
GROUP BY p.Cod_producator
)