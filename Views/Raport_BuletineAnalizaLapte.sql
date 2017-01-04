CREATE VIEW Raport_BuletineAnalizaLapte AS 
SELECT
AnalizaLapte_Nr_inreg_inf_set AS Nr_inreg_inf_set,
AnalizaLapte_Nr_inreg_sup_set AS Nr_inreg_sup_set,
AnalizaLapte_Nr_inregistrare AS Nr_inregistrare,
AnalizaLapte_Data AS Data,
AnalizaLapte_Indicator AS Indicator,
AnalizaLapte_Tip_analiza AS Tip_analiza,
AnalizaLapte_Centru_colectare AS Centru_colectare,
AnalizaLapte_Producator AS Producator,
AnalizaLapte_Rezultat AS Rezultat,
AnalizaLapte_Valoare AS Valoare,

BuletineAnalizaLapte_Tip_colecta AS Tip_colecta,
BuletineAnalizaLapte_Data_colecta AS Data_colecta,

CalStd_Data AS CalStd_Data,
CalStd_Data_lunii AS Data_lunii,
CalStd_An AS An,
CalStd_Luna AS Luna,
CalStd_LunaAlfa AS LunaAlfa,
CONVERT(CHAR, CalStd_Data, 112) AS LunaAn,
CalStd_Zi AS Zi,
CONVERT(CHAR(4),YEAR(dbo.BOANCC(CalStd_An,CalStd_Luna)))
+'/'+CONVERT(CHAR(4),YEAR(dbo.EOANCC(CalStd_An,CalStd_Luna))) AS An_cota,

ProdLapte_Cod_producator AS Cod_producator,
ProdLapte_Denumire AS ProdLapte_Denumire,
ProdLapte_Initiala_tatalui AS Initiala_tatalui,
ProdLapte_Serie_buletin AS Serie_buletin,
ProdLapte_Nr_buletin AS Nr_buletin,
ProdLapte_Eliberat AS Eliberat,
ProdLapte_CNP_CUI AS CNP_CUI,
ProdLapte_Judet AS Judet,
ProdLapte_Localitate AS Localitate,
ProdLapte_Comuna AS Comuna,
ProdLapte_Sat AS Sat,
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
ProdLapte_Vaci AS Vaci,
ProdLapte_Tip_pers AS Tip_pers,
ProdLapte_Tert AS Tert,
ProdLapte_Reprezentant AS Reprezentant,
ProdLapte_CNP_repr AS CNP_repr,

CentrColectLapte_Cod_centru_colectare AS Cod_centru_colectare,
CentrColectLapte_Denumire AS CentrColectLapte_Denumire,
CentrColectLapte_Cod_IBAN AS Cod_IBAN,
CentrColectLapte_Banca AS Banca,
CentrColectLapte_Sat AS CentrColectLapte_Sat,
CentrColectLapte_Comuna AS CentrColectLapte_Comuna,
CentrColectLapte_Localitate AS CentrColectLapte_Localitate,
CentrColectLapte_Judet AS CentrColectLapte_Judet,
CentrColectLapte_Responsabil AS Responsabil,
CentrColectLapte_Loc_de_munca AS Loc_de_munca,
CentrColectLapte_Tip_pers AS CentrColectLapte_Tip_pers,
CentrColectLapte_Tert AS CentrColectLapte_Tert,

Judete_cod_judet AS cod_judet,
Judete_denumire AS Judete_denumire,

JudRegDACLapte_Regiune AS Regiune,
JudRegDACLapte_Laborator_analize AS Laborator_analize,
JudRegDACLapte_Sediu_laborator AS Sediu_laborator,

Localitati_cod_oras AS cod_oras,
Localitati_oras AS oras,

lm_Cod AS Cod,
lm_Denumire AS lm_Denumire
/*
select 
--rtrim(t.name)
--'ReprProdLapte'
--+'.'
+rtrim(ltrim(c.name))+' AS '
--+rtrim(t.name)
--+'ReprProdLapte'
--+'_'
+rtrim(ltrim(SUBSTRING(c.name,CHARINDEX('_',c.name)+1,256)))+','
from sysobjects t 
	inner join syscolumns c on t.id=c.id
where t.name='AL_AnalizaLapte'
*/
FROM AL_AnalizaLapte