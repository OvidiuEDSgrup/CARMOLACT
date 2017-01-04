--if not exists (select name from sysobjects where name = 'AL_BordAchizLapte' and type = 'V') 
CREATE
-- ALTER
VIEW [dbo].[Raport_BorderouAchizitieLapte] AS
SELECT 
AL_BordAchizLapte.BordAchizLapte_Data_lunii AS BordAchizLapte_Data_lunii,
AL_BordAchizLapte.BordAchizLapte_Tip AS Tip,
AL_BordAchizLapte.BordAchizLapte_Producator AS Producator,
AL_BordAchizLapte.BordAchizLapte_Centru_colectare AS Centru_colectare,
AL_BordAchizLapte.BordAchizLapte_Tip_lapte AS Tip_lapte,
AL_BordAchizLapte.BordAchizLapte_Cant_UM AS Cant_UM,
AL_BordAchizLapte.BordAchizLapte_Grasime_1 AS Grasime_1,
AL_BordAchizLapte.BordAchizLapte_Grasime_2 AS Grasime_2,
AL_BordAchizLapte.BordAchizLapte_Grasime AS Grasime,
AL_BordAchizLapte.BordAchizLapte_Proteine AS Proteine,
AL_BordAchizLapte.BordAchizLapte_Cant_UG AS Cant_UG,
AL_BordAchizLapte.BordAchizLapte_Cant_UP AS Cant_UP,
AL_BordAchizLapte.BordAchizLapte_Cant_STAS AS Cant_STAS,
AL_BordAchizLapte.BordAchizLapte_Pret AS Pret,
AL_BordAchizLapte.BordAchizLapte_Valoare AS Valoare,
AL_BordAchizLapte.BordAchizLapte_Valoare_STAS AS Valoare_STAS,
AL_BordAchizLapte.BordAchizLapte_Data_operarii AS Data_operarii,
AL_BordAchizLapte.BordAchizLapte_Ora_operarii AS Ora_operarii,
AL_BordAchizLapte.BordAchizLapte_Utilizator AS Utilizator,
AL_BordAchizLapte.CalStd_Data AS Data,
AL_BordAchizLapte.CalStd_Data_lunii AS CalStd_Data_lunii,
AL_BordAchizLapte.CalStd_An AS An,
AL_BordAchizLapte.CalStd_Luna AS Luna,
AL_BordAchizLapte.CalStd_LunaAlfa AS LunaAlfa,
AL_BordAchizLapte.CalStd_Zi AS Zi,

AL_BordAchizLapte.ProdLapte_Cod_producator AS Cod_producator,
AL_BordAchizLapte.ProdLapte_Denumire AS ProdLapte_Denumire,
AL_BordAchizLapte.ProdLapte_Initiala_tatalui AS Initiala_tatalui,
AL_BordAchizLapte.ProdLapte_Serie_buletin AS Serie_buletin,
AL_BordAchizLapte.ProdLapte_Nr_buletin AS Nr_buletin,
AL_BordAchizLapte.ProdLapte_Eliberat AS Eliberat,
AL_BordAchizLapte.ProdLapte_CNP_CUI AS CNP_CUI,
AL_BordAchizLapte.ProdLapte_Judet AS ProdLapte_Judet,
AL_BordAchizLapte.ProdLapte_Localitate AS ProdLapte_Localitate,
AL_BordAchizLapte.ProdLapte_Comuna AS ProdLapte_Comuna,
AL_BordAchizLapte.ProdLapte_Sat AS ProdLapte_Sat,
AL_BordAchizLapte.ProdLapte_Strada AS Strada,
AL_BordAchizLapte.ProdLapte_Nr_str AS Nr_str,
AL_BordAchizLapte.ProdLapte_Nr_casa AS Nr_casa,
AL_BordAchizLapte.ProdLapte_Bloc AS Bloc,
AL_BordAchizLapte.ProdLapte_Scara AS Scara,
AL_BordAchizLapte.ProdLapte_Etaj AS Etaj,
AL_BordAchizLapte.ProdLapte_Ap AS Ap,
AL_BordAchizLapte.ProdLapte_Cod_exploatatie AS Cod_exploatatie,
AL_BordAchizLapte.ProdLapte_Cota_actuala AS Cota_actuala,
AL_BordAchizLapte.ProdLapte_Grad_actual AS Grad_actual,
AL_BordAchizLapte.ProdLapte_Tip_pers AS ProdLapte_Tip_pers,
AL_BordAchizLapte.ProdLapte_Tert AS Tert,
AL_BordAchizLapte.ProdLapte_Reprezentant AS Reprezentant,
AL_BordAchizLapte.ProdLapte_CNP_repr AS CNP_repr,

AL_BordAchizLapte.CentrColectLapte_Cod_centru_colectare AS Cod_centru_colectare,
AL_BordAchizLapte.CentrColectLapte_Denumire AS CentrColectLapte_Denumire,
AL_BordAchizLapte.CentrColectLapte_Cod_IBAN AS Cod_IBAN,
AL_BordAchizLapte.CentrColectLapte_Banca AS Banca,
AL_BordAchizLapte.CentrColectLapte_Sat AS CentrColectLapte_Sat,
AL_BordAchizLapte.CentrColectLapte_Comuna AS CentrColectLapte_Comuna,
AL_BordAchizLapte.CentrColectLapte_Localitate AS CentrColectLapte_Localitate,
AL_BordAchizLapte.CentrColectLapte_Judet AS CentrColectLapte_Judet,
AL_BordAchizLapte.CentrColectLapte_Responsabil AS Responsabil,
AL_BordAchizLapte.CentrColectLapte_Loc_de_munca AS Loc_de_munca,
AL_BordAchizLapte.CentrColectLapte_Tip_pers AS CentrColectLapte_Tip_pers,

AL_BordAchizLapte.CentrColectProdLapte_Nr_ordine AS Nr_ordine,
AL_BordAchizLapte.CentrColectProdLapte_Data_inscrierii AS Data_inscrierii,
AL_BordAchizLapte.CentrColectProdLapte_Nr_fisa AS Nr_fisa,

AL_BordAchizLapte.TipLapte_Cod AS TipLapte_Cod,
AL_BordAchizLapte.TipLapte_Denumire AS TipLapte_Denumire,
AL_BordAchizLapte.TipLapte_Grasime_standard AS TipLapte_Grasime_standard,

AL_BordAchizLapte.BordAchizLapte_Bonus AS Bonus,
AL_BordAchizLapte.CorectPretProdCantLapte_Penalizare AS Penalizare,

AL_BordAchizLapte.GrilaPretCantLapte_Limita_inf AS Limita_inf,
AL_BordAchizLapte.GrilaPretCantLapte_Limita_sup AS Limita_sup,

AL_BordAchizLapte.lm_Cod AS lm_Cod,
AL_BordAchizLapte.lm_Denumire AS lm_Denumire,
AL_BordAchizLapte.terti_Tert AS terti_Tert,
AL_BordAchizLapte.terti_Denumire AS terti_Denumire,
AL_BordAchizLapte.terti_Cod_fiscal AS terti_Cod_fiscal,

AL_BordAchizLapte.Judete_cod_judet AS Judete_cod_judet,
AL_BordAchizLapte.Judete_denumire AS Judete_denumire,

AL_BordAchizLapte.Localitati_cod_oras AS Localitati_cod_oras,
AL_BordAchizLapte.Localitati_cod_judet AS Localitati_cod_judet,
AL_BordAchizLapte.Localitati_oras AS Localitati_oras
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