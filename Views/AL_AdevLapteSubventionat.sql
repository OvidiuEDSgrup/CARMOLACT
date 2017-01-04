--if not exists (select name from sysobjects where name = 'AL_LapteSubventionat' and type = 'V') 
CREATE
-- ALTER
VIEW [AL_AdevLapteSubventionat] AS
SELECT
AdevLapteSubventionat.Nr_inregistrare AS AdevLapteSubventionat_Nr_inregistrare,
AdevLapteSubventionat.Data AS AdevLapteSubventionat_Data,
AdevLapteSubventionat.Producator AS AdevLapteSubventionat_Producator,
RTRIM(AdevLapteSubventionat.Centru_colectare)+' '+RTRIM(CentrColectLapte.Denumire) AS AdevLapteSubventionat_Centru_colectare,
AdevLapteSubventionat.Data_inf_livrare AS AdevLapteSubventionat_Data_inf_livrare,
AdevLapteSubventionat.Data_sup_livrare AS AdevLapteSubventionat_Data_sup_livrare,
AdevLapteSubventionat.Suma_cant_UM_livrata AS AdevLapteSubventionat_Suma_cant_UM_livrata,
AdevLapteSubventionat.Suma_cant_UM_cota_livrata AS AdevLapteSubventionat_Suma_cant_UM_cota_livrata,
AdevLapteSubventionat.Suma_cant_UM_subventionata AS AdevLapteSubventionat_Suma_cant_UM_subventionata,
AdevLapteSubventionat.Suma_cant_UM_cota_subventionata AS AdevLapteSubventionat_Suma_cant_UM_cota_subventionata,
AdevLapteSubventionat.Nr_luni_valide AS AdevLapteSubventionat_Nr_luni_valide,
AdevLapteSubventionat.Buletine_analiza AS AdevLapteSubventionat_Buletine_analiza,
AdevLapteSubventionat.Laboratoare_analize AS AdevLapteSubventionat_Laboratoare_analize,

AdevSubvenLapte.Nr_inregistrare AS AdevSubvenLapte_Nr_inregistrare,
AdevSubvenLapte.Data AS AdevSubvenLapte_Data,
RTRIM(ISNULL(AdevSubvenLapte.Producator,''))+' '+ISNULL(ProdLapte.Denumire,'') AS AdevSubvenLapte_Producator,
AdevSubvenLapte.Data_inf_perioada AS AdevSubvenLapte_Data_inf_perioada,
AdevSubvenLapte.Data_sup_perioada AS AdevSubvenLapte_Data_sup_perioada,
RTRIM(CONVERT(CHAR, AdevSubvenLapte.Data_inf_perioada, 102))+'-'
	+CONVERT(CHAR, AdevSubvenLapte.Data_sup_perioada, 102) AS Perioada_subventionata,
AdevSubvenLapte.Rezultat_trimestru AS AdevSubvenLapte_Rezultat_trimestru,
AdevSubvenLapte.Cantitate_livrata AS AdevSubvenLapte_Cantitate_livrata,
AdevSubvenLapte.Cantitate_subventionata AS AdevSubvenLapte_Cantitate_subventionata,
AdevSubvenLapte.Data_operarii AS AdevSubvenLapte_Data_operarii,
AdevSubvenLapte.Ora_operarii AS AdevSubvenLapte_Ora_operarii,
AdevSubvenLapte.Utilizator AS AdevSubvenLapte_Utilizator,

ProdLapte.Cod_producator AS ProdLapte_Cod_producator,
ProdLapte.Denumire AS ProdLapte_Denumire,
ProdLapte.Initiala_tatalui AS ProdLapte_Initiala_tatalui,
ProdLapte.Serie_buletin AS ProdLapte_Serie_buletin,
ProdLapte.Nr_buletin AS ProdLapte_Nr_buletin,
ProdLapte.Eliberat AS ProdLapte_Eliberat,
ProdLapte.CNP_CUI AS ProdLapte_CNP_CUI,
ISNULL(Judete.denumire,ProdLapte.Judet) AS ProdLapte_Judet,
ISNULL(Localitati.oras,ProdLapte.Localitate) AS ProdLapte_Localitate,
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
ISNULL(ReprProdLapte.Denumire, ProdLapte.Reprezentant) AS ProdLapte_Reprezentant,
ISNULL(ReprProdLapte.CNP_CUI, ProdLapte.CNP_repr) AS ProdLapte_CNP_repr,
ProdLapte.Centru_colectare AS ProdLapte_Centru_colectare,
ProdLapte.Loc_de_munca AS ProdLapte_Loc_de_munca,
ProdLapte.Data_operarii AS ProdLapte_Data_operarii,
ProdLapte.Ora_operarii AS ProdLapte_Ora_operarii,
ProdLapte.Utilizator AS ProdLapte_Utilizator,

ReprProdLapte.Cod_producator AS ReprProdLapte_Cod_producator,
ReprProdLapte.Denumire AS ReprProdLapte_Denumire,
ReprProdLapte.Initiala_tatalui AS ReprProdLapte_Initiala_tatalui,
ReprProdLapte.Serie_buletin AS ReprProdLapte_Serie_buletin,
ReprProdLapte.Nr_buletin AS ReprProdLapte_Nr_buletin,
ReprProdLapte.Eliberat AS ReprProdLapte_Eliberat,
ReprProdLapte.CNP_CUI AS ReprProdLapte_CNP_CUI,
ISNULL(JudRepr.denumire,ReprProdLapte.Judet) AS ReprProdLapte_Judet,
ISNULL(LocRepr.oras,ReprProdLapte.Localitate) AS ReprProdLapte_Localitate,
ReprProdLapte.Comuna AS ReprProdLapte_Comuna,
ReprProdLapte.Sat AS ReprProdLapte_Sat,
ReprProdLapte.Strada AS ReprProdLapte_Strada,
ReprProdLapte.Nr_str AS ReprProdLapte_Nr_str,
ReprProdLapte.Nr_casa AS ReprProdLapte_Nr_casa,
ReprProdLapte.Bloc AS ReprProdLapte_Bloc,
ReprProdLapte.Scara AS ReprProdLapte_Scara,
ReprProdLapte.Etaj AS ReprProdLapte_Etaj,
ReprProdLapte.Ap AS ReprProdLapte_Ap,
ReprProdLapte.Cod_exploatatie AS ReprProdLapte_Cod_exploatatie,

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
where t.name='AdevLapteSubventionat'
*/
FROM AdevLapteSubventionat
	LEFT JOIN AdevSubvenLapte ON AdevSubvenLapte.Nr_inregistrare=.AdevLapteSubventionat.Nr_inregistrare 
		and AdevSubvenLapte.Data=AdevLapteSubventionat.Data
--	LEFT JOIN calstd ON calstd.data= Data_inf_perioada Data_sup_perioada
	LEFT JOIN prodlapte ON prodlapte.cod_producator= AdevSubvenLapte.producator
	LEFT JOIN ProdLapte reprProdLapte ON reprProdLapte.cod_producator= ProdLapte.reprezentant
	LEFT JOIN CentrColectLapte ON AdevLapteSubventionat.Centru_colectare= CentrColectLapte.Cod_centru_colectare	
	LEFT JOIN judete ON judete.cod_judet=prodlapte.Judet
	LEFT JOIN judRegDACLapte ON judRegDACLapte.judet=CentrColectLapte.Judet
	LEFT JOIN localitati on localitati.cod_oras=prodlapte.localitate
	LEFT JOIN lm ON CentrColectLapte.Loc_de_munca= lm.cod	
	LEFT JOIN judete judRepr ON judRepr.cod_judet=prodlapte.Judet
	LEFT JOIN localitati locRepr on locRepr.cod_oras=prodlapte.localitate