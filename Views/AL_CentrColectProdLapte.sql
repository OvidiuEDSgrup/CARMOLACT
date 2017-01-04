CREATE VIEW [dbo].[AL_CentrColectProdLapte] AS 
SELECT
RTRIM(CentrColectProdLapte.Centru_colectare)+' '+RTRIM(CentrColectLapte.Denumire) AS CentrColectProdLapte_Centru_colectare,
RTRIM(CentrColectProdLapte.Tip_lapte)+' '+RTRIM(TipLapte.Denumire) AS CentrColectProdLapte_Tip_lapte,
RTRIM(CentrColectProdLapte.Producator)+' '+RTRIM(ProdLapte.Denumire) AS CentrColectProdLapte_Producator,
CentrColectProdLapte.Nr_ordine AS CentrColectProdLapte_Nr_ordine,
CentrColectProdLapte.Nr_fisa AS CentrColectProdLapte_Nr_fisa,
CentrColectProdLapte.Data_inscrierii AS CentrColectProdLapte_Data_inscrierii,
CentrColectProdLapte.Data_operarii AS CentrColectProdLapte_Data_operarii,
CentrColectProdLapte.Ora_operarii AS CentrColectProdLapte_Ora_operarii,
CentrColectProdLapte.Utilizator AS CentrColectProdLapte_Utilizator,
CentrColectLapte.Cod_centru_colectare AS CentrColectLapte_Cod_centru_colectare,
CentrColectLapte.Denumire AS CentrColectLapte_Denumire,
CentrColectLapte.Cod_IBAN AS CentrColectLapte_Cod_IBAN,
CentrColectLapte.Banca AS CentrColectLapte_Banca,
CentrColectLapte.Sat AS CentrColectLapte_Sat,
CentrColectLapte.Comuna AS CentrColectLapte_Comuna,
CentrColectLapte.Localitate AS CentrColectLapte_Localitate,
RTRIM(CentrColectLapte.Judet)+' '+RTRIM(ISNULL(Judete.denumire,'')) AS CentrColectLapte_Judet,
CentrColectLapte.Responsabil AS CentrColectLapte_Responsabil,
RTRIM(CentrColectLapte.Loc_de_munca)+' '+RTRIM(ISNULL(lm.Denumire,'')) AS CentrColectLapte_Loc_de_munca,
CentrColectLapte.Tip_pers AS CentrColectLapte_Tip_pers,
CentrColectLapte.Tert AS CentrColectLapte_Tert,
CentrColectLapte.Data_operarii AS CentrColectLapte_Data_operarii,
CentrColectLapte.Ora_operarii AS CentrColectLapte_Ora_operarii,
CentrColectLapte.Utilizator AS CentrColectLapte_Utilizator,
TipLapte.Cod AS TipLapte_Cod,
TipLapte.Denumire AS TipLapte_Denumire,
TipLapte.Grasime_standard AS TipLapte_Grasime_standard,
TipLapte.Cota AS TipLapte_Cota,
ProdLapte.Cod_producator AS ProdLapte_Cod_producator,
ProdLapte.Denumire AS ProdLapte_Denumire,
ProdLapte.Initiala_tatalui AS ProdLapte_Initiala_tatalui,
ProdLapte.Serie_buletin AS ProdLapte_Serie_buletin,
ProdLapte.Nr_buletin AS ProdLapte_Nr_buletin,
ProdLapte.Eliberat AS ProdLapte_Eliberat,
ProdLapte.CNP_CUI AS ProdLapte_CNP_CUI,
ProdLapte.Judet AS ProdLapte_Judet,
RTRIM(ProdLapte.Localitate)+' '+RTRIM(ISNULL(Localitati.oras, '')) AS ProdLapte_Localitate,
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
RTRIM(ProdLapte.Tert)+' '+RTRIM(ISNULL(terti.Denumire,'')) AS ProdLapte_Tert,
ProdLapte.Reprezentant AS ProdLapte_Reprezentant,
ProdLapte.CNP_repr AS ProdLapte_CNP_repr,
ProdLapte.Centru_colectare AS ProdLapte_Centru_colectare,
ProdLapte.Loc_de_munca AS ProdLapte_Loc_de_munca,
ProdLapte.Data_operarii AS ProdLapte_Data_operarii,
ProdLapte.Ora_operarii AS ProdLapte_Ora_operarii,
ProdLapte.Utilizator AS ProdLapte_Utilizator,
lm.Cod AS lm_Cod,
lm.Denumire AS lm_Denumire,
terti.Tert AS terti_Tert,
terti.Denumire AS terti_Denumire,
terti.Cod_fiscal AS terti_Cod_fiscal,
terti.Localitate AS terti_Localitate,
terti.Judet AS terti_Judet,
terti.Adresa AS terti_Adresa,
terti.Telefon_fax AS terti_Telefon_fax,
terti.Banca AS terti_Banca,
terti.Cont_in_banca AS terti_Cont_in_banca,
terti.Tert_extern AS terti_Tert_extern,
terti.Grupa AS terti_Grupa,
terti.Cont_ca_furnizor AS terti_Cont_ca_furnizor,
terti.Cont_ca_beneficiar AS terti_Cont_ca_beneficiar,
terti.Sold_ca_furnizor AS terti_Sold_ca_furnizor,
terti.Sold_ca_beneficiar AS terti_Sold_ca_beneficiar,
terti.Sold_maxim_ca_beneficiar AS terti_Sold_maxim_ca_beneficiar,
terti.Disccount_acordat AS terti_Disccount_acordat,
Judete.cod_judet AS Judete_cod_judet,
Judete.denumire AS Judete_denumire,
Localitati.cod_oras AS Localitati_cod_oras,
Localitati.cod_judet AS Localitati_cod_judet,
Localitati.tip_oras AS Localitati_tip_oras,
Localitati.oras AS Localitati_oras,
Localitati.cod_postal AS Localitati_cod_postal,
Localitati.extern AS Localitati_extern
/*
select 
rtrim(t.name)
--'IntrariLapteCompartimente'
+'.'+rtrim(ltrim(c.name))+' AS '
+rtrim(t.name)
--+'IntrariLapteCompartimente'
+'_'+rtrim(ltrim(c.name))+','
from sysobjects t 
	inner join syscolumns c on t.id=c.id
where t.name='Localitati'
*/
FROM CentrColectProdLapte
	LEFT JOIN CentrColectLapte ON CentrColectProdLapte.Centru_colectare= CentrColectLapte.Cod_centru_colectare	
	LEFT JOIN TipLapte ON CentrColectProdLapte.Tip_lapte= TipLapte.Cod
	LEFT JOIN ProdLapte ON CentrColectProdLapte.Producator= ProdLapte.Cod_producator
	LEFT JOIN terti ON ProdLapte.Tert= terti.tert
	LEFT JOIN lm ON CentrColectLapte.Loc_de_munca= lm.cod	
	LEFT JOIN judete ON judete.cod_judet= CentrColectLapte.Judet
	LEFT JOIN localitati ON localitati.cod_oras= ProdLapte.Localitate