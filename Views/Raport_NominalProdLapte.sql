CREATE VIEW [Raport_NominalProdLapte] AS
SELECT 
UtilizareCotaProdAnCurent_Producator AS Producator,
UtilizareCotaProdAnCurent_Centru_colectare AS Centru_colectare,
UtilizareCotaProdAnCurent_Data_lunii,
0 AS Cant_UM,
0 AS Cant_UG,
0 AS Cant_STAS,
0 AS Cant_UM_cota,
UtilizareCotaProdAnCurent_Proc_utiliz_cota AS Proc_utiliz_cota,

ProdLapte_Cod_producator AS Cod_producator,
ProdLapte_Denumire AS ProdLapte_Denumire,
ProdLapte_Initiala_tatalui AS Initiala_tatalui,
ProdLapte_Serie_buletin AS Serie_buletin,
ProdLapte_Nr_buletin AS Nr_buletin,
ProdLapte_Eliberat AS Eliberat,
ProdLapte_CNP_CUI AS CNP_CUI,
ProdLapte_Judet AS ProdLapte_Judet,
ProdLapte_Localitate AS ProdLapte_Localitate,
ProdLapte_Comuna AS ProdLapte_Comuna,
ProdLapte_Sat AS ProdLapte_Sat,
ProdLapte_Strada AS Strada,
ProdLapte_Nr_str AS Nr_str,
ProdLapte_Nr_casa AS Nr_casa,
ProdLapte_Bloc AS Bloc,
ProdLapte_Scara AS Scara,
ProdLapte_Etaj AS Etaj,
ProdLapte_Ap AS Ap,
ProdLapte_Cod_exploatatie AS Cod_exploatatie,
ProdLapte_Cota_actuala AS Cota_actuala,
ProdLapte_Grad_actual AS Grad_actual,
ProdLapte_Tip_pers AS ProdLapte_Tip_pers,
ProdLapte_Tert AS Tert,
ProdLapte_Reprezentant AS Reprezentant,
ProdLapte_CNP_repr AS CNP_repr,

CentrColectLapte_Cod_centru_colectare AS Cod_centru_colectare,
CentrColectLapte_Denumire,
CentrColectLapte_Localitate,
CentrColectLapte_Judet,
CentrColectLapte_Loc_de_munca AS Loc_de_munca,

CalStd_An AS An,
CalStd_Luna AS Luna,
CalStd_LunaAlfa AS LunaAlfa

FROM AL_UtilizareCotaProdAnCurent
UNION ALL
SELECT 
BordAchizLapte_Producator AS Producator,
BordAchizLapte_Centru_colectare AS Centru_colectare,
BordAchizLapte_Data_lunii AS BordAchizLapte_Data_lunii,
BordAchizLapte_Cant_UM AS Cant_UM,
BordAchizLapte_Cant_UG AS Cant_UG,
BordAchizLapte_Cant_STAS AS Cant_STAS,
BordAchizLapte_Cant_UM*ISNULL(NULLIF(p1.Val_numerica,0),1.03) AS Cant_UM_cota,
0 AS Proc_utiliz_cota,

ProdLapte_Cod_producator AS Cod_producator,
ProdLapte_Denumire AS ProdLapte_Denumire,
ProdLapte_Initiala_tatalui AS Initiala_tatalui,
ProdLapte_Serie_buletin AS Serie_buletin,
ProdLapte_Nr_buletin AS Nr_buletin,
ProdLapte_Eliberat AS Eliberat,
ProdLapte_CNP_CUI AS CNP_CUI,
ProdLapte_Judet AS ProdLapte_Judet,
ProdLapte_Localitate AS ProdLapte_Localitate,
ProdLapte_Comuna AS ProdLapte_Comuna,
ProdLapte_Sat AS ProdLapte_Sat,
ProdLapte_Strada AS Strada,
ProdLapte_Nr_str AS Nr_str,
ProdLapte_Nr_casa AS Nr_casa,
ProdLapte_Bloc AS Bloc,
ProdLapte_Scara AS Scara,
ProdLapte_Etaj AS Etaj,
ProdLapte_Ap AS Ap,
ProdLapte_Cod_exploatatie AS Cod_exploatatie,
ProdLapte_Cota_actuala AS Cota_actuala,
ProdLapte_Grad_actual AS Grad_actual,
ProdLapte_Tip_pers AS ProdLapte_Tip_pers,
ProdLapte_Tert AS Tert,
ProdLapte_Reprezentant AS Reprezentant,
ProdLapte_CNP_repr AS CNP_repr,

CentrColectLapte_Cod_centru_colectare AS Cod_centru_colectare,
CentrColectLapte_Denumire,
CentrColectLapte_Localitate,
CentrColectLapte_Judet,
CentrColectLapte_Loc_de_munca AS Loc_de_munca,

CalStd_An AS An,
CalStd_Luna AS Luna,
CalStd_LunaAlfa AS LunaAlfa
/*
select 
rtrim(t.name)
--'IntrariLapteCompartimente'
+'.'+rtrim(ltrim(c.name))+' AS '
--+rtrim(t.name)
--+'IntrariLapteCompartimente'
--+'_'
+rtrim(ltrim(c.name))+','
from sysobjects t 
	inner join syscolumns c on t.id=c.id
where t.name='AL_BordAchizLapte'
*/
FROM AL_BordAchizLapte
	LEFT JOIN par p1 on p1.tip_parametru= 'AL' and p1.parametru= 'COEFCONVL'
WHERE BordAchizLapte_Data_lunii BETWEEN dbo.BOANCC(null, null) and dbo.EOANCC(null, null)