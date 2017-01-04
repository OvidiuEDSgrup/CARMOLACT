--if not exists (select name from sysobjects where name = 'AL_BordAchizLapte' and type = 'V') 
CREATE
-- ALTER
VIEW [dbo].[AL_BordAchizLapte] AS
SELECT
BordAchizLapte.Data_lunii AS BordAchizLapte_Data_lunii,
CASE BordAchizLapte.Tip 
WHEN 'I' THEN 'Initiala' WHEN 'L' THEN 'Lunara' WHEN 'Z' THEN 'Zilnica' ELSE BordAchizLapte.Tip END
AS BordAchizLapte_Tip,

RTRIM(BordAchizLapte.Producator)+' '+RTRIM(ProdLapte.Denumire) AS BordAchizLapte_Producator,
--REPLICATE('0',3-LEN(RTRIM(BordAchizLapte.Centru_colectare)))
	+RTRIM(BordAchizLapte.Centru_colectare)+' '+RTRIM(CentrColectLapte.Denumire) AS BordAchizLapte_Centru_colectare,

RTRIM(BordAchizLapte.Tip_lapte)+' '+LTRIM(ISNULL(TipLapte.Denumire,'')) AS BordAchizLapte_Tip_lapte,
BordAchizLapte.Cant_UM AS BordAchizLapte_Cant_UM,
BordAchizLapte.Grasime_1 AS BordAchizLapte_Grasime_1,
BordAchizLapte.Grasime_2 AS BordAchizLapte_Grasime_2,
BordAchizLapteVw.Grasime AS BordAchizLapte_Grasime,
BordAchizLapteVw.Proteine AS BordAchizLapte_Proteine,
BordAchizLapteVw.Cant_UG AS BordAchizLapte_Cant_UG,
BordAchizLapteVw.Cant_UP AS BordAchizLapte_Cant_UP,
BordAchizLapteVw.Cant_STAS AS BordAchizLapte_Cant_STAS,
BordAchizLapteVw.Pret AS BordAchizLapte_Pret,
BordAchizLapteVw.Valoare AS BordAchizLapte_Valoare,
BordAchizLapteVw.Valoare_STAS AS BordAchizLapte_Valoare_STAS,
BordAchizLapteVw.Bonus AS BordAchizLapte_Bonus,
BordAchizLapte.Data_operarii AS BordAchizLapte_Data_operarii,
BordAchizLapte.Ora_operarii AS BordAchizLapte_Ora_operarii,
BordAchizLapte.Utilizator AS BordAchizLapte_Utilizator,
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
RTRIM(ProdLapte.Judet)+' '+RTRIM(ISNULL(Judete.denumire,'')) AS ProdLapte_Judet,
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
ISNULL(CentrColectProdLapte.Nr_ordine,0) AS CentrColectProdLapte_Nr_ordine,
CentrColectProdLapte.Data_inscrierii AS CentrColectProdLapte_Data_inscrierii,
CentrColectProdLapte.Nr_fisa AS CentrColectProdLapte_Nr_fisa,
CentrColectProdLapte.Data_operarii AS CentrColectProdLapte_Data_operarii,
CentrColectProdLapte.Ora_operarii AS CentrColectProdLapte_Ora_operarii,
CentrColectProdLapte.Utilizator AS CentrColectProdLapte_Utilizator,
TipLapte.Cod AS TipLapte_Cod,
TipLapte.Denumire AS TipLapte_Denumire,
TipLapte.Grasime_standard AS TipLapte_Grasime_standard,
CorectPretProdCantLapte.Producator AS CorectPretProdCantLapte_Producator,
CorectPretProdCantLapte.Data_lunii AS CorectPretProdCantLapte_Data_lunii,
CorectPretProdCantLapte.Tip_lapte AS CorectPretProdCantLapte_Tip_lapte,
ISNULL(CorectPretProdCantLapte.Bonus, 0) AS CorectPretProdCantLapte_Bonus,
ISNULL(CorectPretProdCantLapte.Penalizare, 0) AS CorectPretProdCantLapte_Penalizare,
GrilaPretCantLapte.Tip_lapte AS GrilaPretCantLapte_Tip_lapte,
ISNULL(GrilaPretCantLapte.Limita_inf, 0) AS GrilaPretCantLapte_Limita_inf,
ISNULL(GrilaPretCantLapte.Limita_sup, 0) AS GrilaPretCantLapte_Limita_sup,
GrilaPretCantLapte.Bonus AS GrilaPretCantLapte_Bonus,
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
Localitati.oras AS Localitati_oras
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
where t.name='BordAchizLapte'
*/
FROM BordAchizLapte
	LEFT JOIN BordAchizLapteVw ON BordAchizLapteVw.Data_lunii= BordAchizLapte.Data_lunii
		AND BordAchizLapteVw.Tip= BordAchizLapte.Tip AND BordAchizLapteVw.Producator= BordAchizLapte.Producator
		AND BordAchizLapteVw.Centru_colectare= BordAchizLapte.Centru_colectare AND BordAchizLapteVw.Tip_lapte= BordAchizLapte.Tip_lapte
	LEFT JOIN CalStd ON CalStd.Data= BordAchizLapte.Data_lunii
	LEFT JOIN ProdLapte ON BordAchizLapte.Producator= ProdLapte.Cod_producator
	LEFT JOIN CentrColectLapte ON BordAchizLapte.Centru_colectare= CentrColectLapte.Cod_centru_colectare	
	LEFT JOIN CentrColectProdLapte 
		ON CentrColectProdLapte.Producator= BordAchizLapte.Producator
			AND CentrColectProdLapte.Centru_colectare= BordAchizLapte.Centru_colectare
			and CentrColectProdLapte.Tip_lapte= BordAchizLapte.Tip_lapte
	LEFT JOIN TipLapte ON TipLapte.Cod= BordAchizLapte.Tip_lapte
	LEFT JOIN CorectPretProdCantLapte ON CorectPretProdCantLapte.Producator= BordAchizLapte.Producator 
		AND CorectPretProdCantLapte.Data_lunii= BordAchizLapte.Data_lunii AND CorectPretProdCantLapte.Tip_lapte= BordAchizLapte.Tip_lapte
	LEFT JOIN GrilaPretCantLapte ON GrilaPretCantLapte.Tip= ProdLapte.Grupa and GrilaPretCantLapte.Tip_lapte= BordAchizLapte.Tip_lapte 
		and GrilaPretCantLapte.Bonus= BordAchizLapteVw.Bonus
	LEFT JOIN terti ON ProdLapte.Tert= terti.tert
	LEFT JOIN lm ON CentrColectLapte.Loc_de_munca= lm.cod	
	LEFT JOIN judete ON judete.cod_judet= CentrColectLapte.Judet
	LEFT JOIN localitati ON localitati.cod_oras= CentrColectLapte.Localitate