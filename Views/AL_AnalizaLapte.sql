--if not exists (select name from sysobjects where name = 'AL_LapteSubventionat' and type = 'V') 
CREATE
-- ALTER
VIEW [AL_AnalizaLapte] AS
SELECT
AnalizaLapte.Nr_inreg_inf_set AS AnalizaLapte_Nr_inreg_inf_set,
AnalizaLapte.Nr_inreg_sup_set AS AnalizaLapte_Nr_inreg_sup_set,
RTRIM(AnalizaLapte.Nr_inreg_inf_set)
+ISNULL('-'+LTRIM(NULLIF(AnalizaLapte.Nr_inreg_sup_set,AnalizaLapte.Nr_inreg_inf_set)),'') AS AnalizaLapte_Nr_inregistrare,
AnalizaLapte.Data AS AnalizaLapte_Data,
AnalizaLapte.Indicator AS AnalizaLapte_Indicator,
AnalizaLapte.Tip_analiza AS AnalizaLapte_Tip_analiza,
RTRIM(AnalizaLapte.Centru_colectare)+' '+LTRIM(ISNULL(CentrColectLapte.Denumire,'')) AS AnalizaLapte_Centru_colectare,
RTRIM(AnalizaLapte.Producator)+' '+LTRIM(ISNULL(ProdLapte.Denumire,'')) AS AnalizaLapte_Producator,
AnalizaLapte.Rezultat AS AnalizaLapte_Rezultat,
AnalizaLapte.Valoare AS AnalizaLapte_Valoare,
AnalizaLapte.Data_operarii AS AnalizaLapte_Data_operarii,
AnalizaLapte.Ora_operarii AS AnalizaLapte_Ora_operarii,
AnalizaLapte.Utilizator AS AnalizaLapte_Utilizator,

BuletineAnalizaLapte.Nr_inreg_inf_set AS BuletineAnalizaLapte_Nr_inreg_inf_set,
BuletineAnalizaLapte.Nr_inreg_sup_set AS BuletineAnalizaLapte_Nr_inreg_sup_set,
BuletineAnalizaLapte.Data AS BuletineAnalizaLapte_Data,
BuletineAnalizaLapte.Indicator AS BuletineAnalizaLapte_Indicator,
BuletineAnalizaLapte.Tip_colecta AS BuletineAnalizaLapte_Tip_colecta,
BuletineAnalizaLapte.Data_colecta AS BuletineAnalizaLapte_Data_colecta,
BuletineAnalizaLapte.Data_operarii AS BuletineAnalizaLapte_Data_operarii,
BuletineAnalizaLapte.Ora_operarii AS BuletineAnalizaLapte_Ora_operarii,
BuletineAnalizaLapte.Utilizator AS BuletineAnalizaLapte_Utilizator,

CalStd.Data AS CalStd_Data,
CalStd.Data_lunii AS CalStd_Data_lunii,
CalStd.An AS CalStd_An,
CalStd.Luna AS CalStd_Luna,
CalStd.LunaAlfa AS CalStd_LunaAlfa,
CalStd.Zi AS CalStd_Zi,
CalStd.Saptamana AS CalStd_Saptamana,
CalStd.Trimestru AS CalStd_Trimestru,
CalStd.Zi_alfa AS CalStd_Zi_alfa,
CalStd.Camp1 AS CalStd_Camp1,
CalStd.Camp2 AS CalStd_Camp2,
CalStd.Camp3 AS CalStd_Camp3,
CalStd.Fel_zi AS CalStd_Fel_zi,

ProdLapte.Cod_producator AS ProdLapte_Cod_producator,
ProdLapte.Denumire AS ProdLapte_Denumire,
ProdLapte.Initiala_tatalui AS ProdLapte_Initiala_tatalui,
ProdLapte.Serie_buletin AS ProdLapte_Serie_buletin,
ProdLapte.Nr_buletin AS ProdLapte_Nr_buletin,
ProdLapte.Eliberat AS ProdLapte_Eliberat,
ProdLapte.CNP_CUI AS ProdLapte_CNP_CUI,
RTRIM(ISNULL(ProdLapte.Judet,''))+' '+ISNULL(Judete.denumire,'') AS ProdLapte_Judet,
RTRIM(ISNULL(ProdLapte.Localitate,''))+' '+ISNULL(Localitati.oras,'') AS ProdLapte_Localitate,
ProdLapte.Comuna AS ProdLapte_Comuna,
ProdLapte.Sat AS ProdLapte_Sat,
ProdLapte.Strada AS ProdLapte_Strada,
ProdLapte.Nr_str AS ProdLapte_Nr_str,
ProdLapte.Nr_casa AS ProdLapte_Nr_casa,
ProdLapte.Bloc AS ProdLapte_Bloc,
ProdLapte.Scara AS ProdLapte_Scara,
ProdLapte.Etaj AS ProdLapte_Etaj,
ProdLapte.Ap AS ProdLapte_Ap,
ProdLapte.Cod_exploatatie AS ProdLapte_Cod_exploatatie,
ProdLapte.Cota_actuala AS ProdLapte_Cota_actuala,
ProdLapte.Grad_actual AS ProdLapte_Grad_actual,
ProdLapte.Vaci AS ProdLapte_Vaci,
ProdLapte.Tip_pers AS ProdLapte_Tip_pers,
ProdLapte.Tert AS ProdLapte_Tert,
ProdLapte.Reprezentant AS ProdLapte_Reprezentant,
ProdLapte.CNP_repr AS ProdLapte_CNP_repr,
ProdLapte.Centru_colectare AS ProdLapte_Centru_colectare,
ProdLapte.Loc_de_munca AS ProdLapte_Loc_de_munca,
ProdLapte.Data_operarii AS ProdLapte_Data_operarii,
ProdLapte.Ora_operarii AS ProdLapte_Ora_operarii,
ProdLapte.Utilizator AS ProdLapte_Utilizator,

CentrColectLapte.Cod_centru_colectare AS CentrColectLapte_Cod_centru_colectare,
CentrColectLapte.Denumire AS CentrColectLapte_Denumire,
CentrColectLapte.Cod_IBAN AS CentrColectLapte_Cod_IBAN,
CentrColectLapte.Banca AS CentrColectLapte_Banca,
CentrColectLapte.Sat AS CentrColectLapte_Sat,
CentrColectLapte.Comuna AS CentrColectLapte_Comuna,
CentrColectLapte.Localitate AS CentrColectLapte_Localitate,
CentrColectLapte.Judet AS CentrColectLapte_Judet,
CentrColectLapte.Responsabil AS CentrColectLapte_Responsabil,
RTRIM(CentrColectLapte.Loc_de_munca)+' '+RTRIM(ISNULL(lm.Denumire,'')) AS CentrColectLapte_Loc_de_munca,
CentrColectLapte.Tip_pers AS CentrColectLapte_Tip_pers,
CentrColectLapte.Tert AS CentrColectLapte_Tert,
CentrColectLapte.Data_operarii AS CentrColectLapte_Data_operarii,
CentrColectLapte.Ora_operarii AS CentrColectLapte_Ora_operarii,
CentrColectLapte.Utilizator AS CentrColectLapte_Utilizator,

Judete.cod_judet AS Judete_cod_judet,
Judete.denumire AS Judete_denumire,
Judete.prefix_telefonic AS Judete_prefix_telefonic,

JudRegDACLapte.Judet AS JudRegDACLapte_Judet,
JudRegDACLapte.Regiune AS JudRegDACLapte_Regiune,
JudRegDACLapte.Laborator_analize AS JudRegDACLapte_Laborator_analize,
JudRegDACLapte.Sediu_laborator AS JudRegDACLapte_Sediu_laborator,

Localitati.cod_oras AS Localitati_cod_oras,
Localitati.cod_judet AS Localitati_cod_judet,
Localitati.tip_oras AS Localitati_tip_oras,
Localitati.oras AS Localitati_oras,
Localitati.cod_postal AS Localitati_cod_postal,
Localitati.extern AS Localitati_extern,

lm.Nivel AS lm_Nivel,
lm.Cod AS lm_Cod,
lm.Cod_parinte AS lm_Cod_parinte,
lm.Denumire AS lm_Denumire

/*
select 
rtrim(t.name)
--'ReprProdLapte'
+'.'+rtrim(ltrim(c.name))+' AS '
+rtrim(t.name)
--+'ReprProdLapte'
+'_'+rtrim(ltrim(c.name))+','
from sysobjects t 
	inner join syscolumns c on t.id=c.id
where t.name='calstd'
*/
FROM AnalizaLapte
	LEFT JOIN BuletineAnalizaLapte ON BuletineAnalizaLapte.Nr_inreg_inf_set= AnalizaLapte.Nr_inreg_inf_set
		AND BuletineAnalizaLapte.Nr_inreg_sup_set= AnalizaLapte.Nr_inreg_sup_set AND BuletineAnalizaLapte.Data= AnalizaLapte.Data
	LEFT JOIN calstd ON calstd.data= BuletineAnalizaLapte.Data_colecta
	LEFT JOIN prodlapte ON prodlapte.cod_producator= AnalizaLapte.producator
	LEFT JOIN CentrColectLapte ON AnalizaLapte.Centru_colectare= CentrColectLapte.Cod_centru_colectare	
	LEFT JOIN judete ON judete.cod_judet=prodlapte.Judet
	LEFT JOIN localitati on localitati.cod_oras=prodlapte.localitate
	LEFT JOIN judRegDACLapte ON judRegDACLapte.judet=CentrColectLapte.Judet
	LEFT JOIN lm ON CentrColectLapte.Loc_de_munca= lm.cod	