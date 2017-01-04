CREATE FUNCTION [UtilizareCotaExplProdRegAnLuna]  
(   
 @Regiune CHAR(30)=NULL,  
 @Anul NUMERIC(4)=NULL,  
 @Luna NUMERIC(2)=NULL,  
 @Grupare CHAR(1)='E'  
)  
RETURNS TABLE   
AS  
RETURN   
(  
SELECT   
MAX(p.Cod_exploatatie) AS Cod_exploatatie,  
MAX(p.CNP_CUI) AS CNP_CUI,  
MAX(p.Cod_producator) Producator,  
MAX(CASE p.DACL WHEN 1 THEN 1 ELSE 0 END) AS DACL,  
MAX(p.tip_furnizor) AS Tip_furnizor,  
MAX(ISNULL(b.Centru_colectare,p.Centru_colectare)) Centru_colectare,  
dbo.BOANCC(@Anul, @Luna) Data_inc_an_cota,  
dbo.EOANCC(@Anul, @Luna) Data_sf_an_cota,  
CONVERT(CHAR(4),YEAR(dbo.BOANCC(@Anul, @Luna)))+'/'+CONVERT(CHAR(4),YEAR(dbo.EOANCC(@Anul, @Luna))) An_cota, 
CASE YEAR(dbo.EOANCC(@Anul, @Luna))%4 WHEN 0 THEN 1 ELSE NULL END AS An_bisect, 
MAX(COALESCE(r.Regiune, NULLIF(p.judet,''), NULLIF(c.judet,''), @Regiune, '')) AS Regiune,  
  
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
NULLIF(SUM((b.Cant_UM*t.cota)),0),0),4) AS Gras_medie_rest_cota,

SUM(ISNULL((cs.Trimestru*b.Cant_UM*t.cota),0)*ISNULL(p3.val_numerica,1.03)) AS Cant_UM_cota_fm_an_bisect,

dbo.CotaUtilizata(SUM(ISNULL((cs.Trimestru*b.Cant_UM*t.cota),0)*ISNULL(p3.val_numerica,1.03)),   
     SUM(ISNULL((cs.Trimestru*b.Cant_UM*t.cota),0)*ISNULL(p3.val_numerica,1.03)* CONVERT(decimal(8,2),ISNULL(ban.Valoare, b.Grasime))),   
     MAX( p.Grad_actual), MAX( p3.val_numerica)) AS Cota_utilizata_fm_an_bisect, 

(SUM((ISNULL(b.Cant_UM*t.cota,0))* ISNULL( p3.val_numerica, 1.03))-(1/60.00*SUM(ISNULL((cs.Trimestru*b.Cant_UM*t.cota), 0)* ISNULL( p3.val_numerica, 1.03)))) AS Cant_UM_cota_red_an_bisect,

dbo.CotaUtilizata(SUM((ISNULL(b.Cant_UM*t.cota,0))* ISNULL( p3.val_numerica, 1.03))-(1/60.00*SUM(ISNULL(cs.Trimestru*b.Cant_UM*t.cota, 0)* ISNULL( p3.val_numerica, 1.03))),   
     SUM(ISNULL(b.Cant_UM*t.cota,0)* ISNULL( p3.val_numerica, 1.03)*CONVERT(decimal(8,2),ISNULL(ban.Valoare,b.Grasime)))
		-(1/60.00*SUM(ISNULL(cs.Trimestru*b.Cant_UM*t.cota, 0)* ISNULL( p3.val_numerica, 1.03)*CONVERT(decimal(8,2),ISNULL(ban.Valoare,b.Grasime)))),   
     MAX( p.Grad_actual), MAX( p3.val_numerica)) AS Cota_utilizata_an_bisect

FROM ProdLapte p  
 LEFT JOIN BordAchizLapte b on p.cod_producator= b.producator   
  AND b.data_lunii BETWEEN dbo.BOANCC(@Anul, @Luna)   
       AND ISNULL( dbo.EOM(CAST(CAST(@Anul AS CHAR(4))+ '-' + CAST(@Luna AS CHAR(2))+ '-'+ '1' AS DATETIME)),  
         dbo.EOANCC(@Anul, @Luna))  
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
-- LEFT JOIN par p1 on p1.tip_parametru= 'AL' and p1.parametru= 'LUNINCANC'  
-- LEFT JOIN par p2 on p2.tip_parametru= 'AL' and p2.parametru= 'ANCOTACUR'  
 LEFT JOIN par p3 on p3.tip_parametru= 'AL' and p3.parametru= 'COEFCONVL'  
 LEFT JOIN tiplapte t ON t.cod= b.tip_lapte   
 LEFT JOIN CentrColectLapte c ON c.cod_centru_colectare= ISNULL(b.Centru_colectare,p.Centru_colectare)  
 LEFT JOIN JudRegDACLapte r ON r.judet=ISNULL(NULLIF(p.judet,''),c.judet)  
 LEFT JOIN calStd cs on cs.data=b.data_lunii and cs.an%4=0 and cs.luna in (2,3)
WHERE (@Regiune IS NULL OR @Regiune=COALESCE(r.Regiune, NULLIF(p.judet,''), NULLIF(c.judet,''), @Regiune))  
-- AND ((b.Cant_UM*t.cota)* ISNULL(ban.Valoare, b.Grasime) IS NULL OR (b.Cant_UM*t.cota)* ISNULL(ban.Valoare, b.Grasime) >0)  
-- and (t.cota IS NULL OR t.cota=1)  
GROUP BY CASE @Grupare WHEN 'P' THEN p.Cod_producator ELSE p.Cod_exploatatie+p.CNP_CUI END  
)