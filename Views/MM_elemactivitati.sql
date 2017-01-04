﻿CREATE 
-- ALTER
VIEW [dbo].[MM_elemactivitati] AS
SELECT
elemactivitati.Tip AS elemactivitati_Tip,
elemactivitati.Fisa AS elemactivitati_Fisa,
elemactivitati.Data AS elemactivitati_Data,
elemactivitati.Numar_pozitie AS elemactivitati_Numar_pozitie,
elemactivitati.Element AS elemactivitati_Element,
elemactivitati.Valoare AS elemactivitati_Valoare,
elemactivitati.Tip_document AS elemactivitati_Tip_document,
elemactivitati.Numar_document AS elemactivitati_Numar_document,
elemactivitati.Data_document AS elemactivitati_Data_document,
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
elemente.Cod AS elemente_Cod,
elemente.Denumire AS elemente_Denumire,
elemente.Tip AS elemente_Tip,
elemente.UM AS elemente_UM,
elemente.UM2 AS elemente_UM2,
elemente.Interval AS elemente_Interval,
pozactivitati.Tip AS pozactivitati_Tip,
pozactivitati.Fisa AS pozactivitati_Fisa,
pozactivitati.Data AS pozactivitati_Data,
pozactivitati.Numar_pozitie AS pozactivitati_Numar_pozitie,
pozactivitati.Traseu AS pozactivitati_Traseu,
pozactivitati.Plecare AS pozactivitati_Plecare,
pozactivitati.Data_plecarii AS pozactivitati_Data_plecarii,
pozactivitati.Ora_plecarii AS pozactivitati_Ora_plecarii,
pozactivitati.Sosire AS pozactivitati_Sosire,
pozactivitati.Data_sosirii AS pozactivitati_Data_sosirii,
pozactivitati.Ora_sosirii AS pozactivitati_Ora_sosirii,
pozactivitati.Explicatii AS pozactivitati_Explicatii,
pozactivitati.Comanda_benef AS pozactivitati_Comanda_benef,
pozactivitati.Lm_beneficiar AS pozactivitati_Lm_beneficiar,
pozactivitati.Tert AS pozactivitati_Tert,
pozactivitati.Marca AS pozactivitati_Marca,
pozactivitati.Utilizator AS pozactivitati_Utilizator,
pozactivitati.Data_operarii AS pozactivitati_Data_operarii,
pozactivitati.Ora_operarii AS pozactivitati_Ora_operarii,
pozactivitati.Alfa1 AS pozactivitati_Alfa1,
pozactivitati.Alfa2 AS pozactivitati_Alfa2,
pozactivitati.Val1 AS pozactivitati_Val1,
pozactivitati.Val2 AS pozactivitati_Val2,
pozactivitati.Data1 AS pozactivitati_Data1,
trasee.Cod AS trasee_Cod,
trasee.Plecare AS trasee_Plecare,
trasee.Sosire AS trasee_Sosire,
trasee.Via AS trasee_Via,
activitati.Tip AS activitati_Tip,
activitati.Fisa AS activitati_Fisa,
activitati.Data AS activitati_Data,
RTRIM(ISNULL(activitati.Masina,''))+' '+ RTRIM(ISNULL(masini.denumire,'')) AS activitati_Masina,
activitati.Comanda AS activitati_Comanda,
activitati.Loc_de_munca AS activitati_Loc_de_munca,
activitati.Comanda_benef AS activitati_Comanda_benef,
activitati.lm_benef AS activitati_lm_benef,
activitati.Tert AS activitati_Tert,
RTRIM(ISNULL(activitati.Marca,''))+' '+ RTRIM(ISNULL(personal.Nume,'')) AS activitati_Marca,
activitati.Marca_ajutor AS activitati_Marca_ajutor,
activitati.Jurnal AS activitati_Jurnal,
masini.cod_masina AS masini_cod_masina,
RTRIM(ISNULL(masini.tip_masina,'')) +' '+ RTRIM(ISNULL(tipmasini.Denumire,'')) AS masini_tip_masina,
masini.nr_inmatriculare AS masini_nr_inmatriculare,
masini.denumire AS masini_denumire,
RTRIM(ISNULL(masini.nr_inventar,''))+' '+ RTRIM(ISNULL(MFix.Denumire,'')) AS masini_nr_inventar,
masini.capacitate_metri_cubi AS masini_capacitate_metri_cubi,
masini.consum_normat_100km AS masini_consum_normat_100km,
masini.consum_pe_ora AS masini_consum_pe_ora,
masini.grupa AS masini_grupa,
masini.loc_de_munca AS masini_loc_de_munca,
masini.coeficient AS masini_coeficient,
masini.tonaj AS masini_tonaj,
masini.benzina_sau_motorina AS masini_benzina_sau_motorina,
masini.capacitate_rezervor AS masini_capacitate_rezervor,
masini.capacitate_baie_de_ulei AS masini_capacitate_baie_de_ulei,
masini.norma_de_ulei AS masini_norma_de_ulei,
masini.consum_vara AS masini_consum_vara,
masini.consum_iarna AS masini_consum_iarna,
masini.consum_usor AS masini_consum_usor,
masini.consum_mediu AS masini_consum_mediu,
masini.consum_greu AS masini_consum_greu,
masini.km_la_bord_efectivi AS masini_km_la_bord_efectivi,
masini.km_la_bord_echivalenti AS masini_km_la_bord_echivalenti,
masini.km_SU AS masini_km_SU,
masini.km_RK AS masini_km_RK,
masini.km_RT1 AS masini_km_RT1,
masini.km_RT2 AS masini_km_RT2,
masini.ultim_SU AS masini_ultim_SU,
masini.ultim_RK AS masini_ultim_RK,
masini.ultim_RT1 AS masini_ultim_RT1,
masini.ultim_RT2 AS masini_ultim_RT2,
masini.de_care_masina AS masini_de_care_masina,
masini.de_putere_mare AS masini_de_putere_mare,
RTRIM(ISNULL(masini.Comanda,'')) +' '+ RTRIM(ISNULL(comenzi.Descriere,'')) AS masini_Comanda,
masini.data_expirarii_ITP AS masini_data_expirarii_ITP,
masini.Firma_CASCO AS masini_Firma_CASCO,
masini.Serie_caroserie AS masini_Serie_caroserie,
tipmasini.Cod AS tipmasini_Cod,
tipmasini.Denumire AS tipmasini_Denumire,
tipmasini.Tip_activitate AS tipmasini_Tip_activitate,
grmasini.Grupa AS grmasini_Grupa,
grmasini.Denumire AS grmasini_Denumire,
lmm.Nivel AS lmMasini_Nivel,
lmm.Cod AS lmMasini_Cod,
lmm.Cod_parinte AS lmMasini_Cod_parinte,
lmm.Denumire AS lmMasini_Denumire,
comenzi.Subunitate AS comenzi_Subunitate,
comenzi.Comanda AS comenzi_Comanda,
comenzi.Tip_comanda AS comenzi_Tip_comanda,
comenzi.Descriere AS comenzi_Descriere,
comenzi.Data_lansarii AS comenzi_Data_lansarii,
comenzi.Data_inchiderii AS comenzi_Data_inchiderii,
comenzi.Starea_comenzii AS comenzi_Starea_comenzii,
comenzi.Grup_de_comenzi AS comenzi_Grup_de_comenzi,
comenzi.Loc_de_munca AS comenzi_Loc_de_munca,
comenzi.Numar_de_inventar AS comenzi_Numar_de_inventar,
comenzi.Beneficiar AS comenzi_Beneficiar,
comenzi.Loc_de_munca_beneficiar AS comenzi_Loc_de_munca_beneficiar,
comenzi.Comanda_beneficiar AS comenzi_Comanda_beneficiar,
comenzi.Art_calc_benef AS comenzi_Art_calc_benef,
lmc.Nivel AS lmComenzi_Nivel,
lmc.Cod AS lmComenzi_Cod,
lmc.Cod_parinte AS lmComenzi_Cod_parinte,
lmc.Denumire AS lmComenzi_Denumire,
MFix.Subunitate AS MFix_Subunitate,
MFix.Numar_de_inventar AS MFix_Numar_de_inventar,
MFix.Denumire AS MFix_Denumire,
MFix.Serie AS MFix_Serie,
MFix.Tip_amortizare AS MFix_Tip_amortizare,
MFix.Cod_de_clasificare AS MFix_Cod_de_clasificare,
MFix.Data_punerii_in_functiune AS MFix_Data_punerii_in_functiune,
personal.Marca AS personal_Marca,
personal.Nume AS personal_Nume,
personal.Cod_functie AS personal_Cod_functie,
personal.Loc_de_munca AS personal_Loc_de_munca,
personal.Loc_de_munca_din_pontaj AS personal_Loc_de_munca_din_pontaj,
personal.Categoria_salarizare AS personal_Categoria_salarizare,
personal.Grupa_de_munca AS personal_Grupa_de_munca,
personal.Salar_de_incadrare AS personal_Salar_de_incadrare,
personal.Salar_de_baza AS personal_Salar_de_baza,
personal.Salar_orar AS personal_Salar_orar,
personal.Tip_salarizare AS personal_Tip_salarizare,
personal.Tip_impozitare AS personal_Tip_impozitare,
personal.Pensie_suplimentara AS personal_Pensie_suplimentara,
personal.Somaj_1 AS personal_Somaj_1,
personal.As_sanatate AS personal_As_sanatate,
personal.Indemnizatia_de_conducere AS personal_Indemnizatia_de_conducere,
personal.Spor_vechime AS personal_Spor_vechime,
personal.Spor_de_noapte AS personal_Spor_de_noapte,
personal.Spor_sistematic_peste_program AS personal_Spor_sistematic_peste_program,
personal.Spor_de_functie_suplimentara AS personal_Spor_de_functie_suplimentara,
personal.Spor_specific AS personal_Spor_specific,
personal.Spor_conditii_1 AS personal_Spor_conditii_1,
personal.Spor_conditii_2 AS personal_Spor_conditii_2,
personal.Spor_conditii_3 AS personal_Spor_conditii_3,
personal.Spor_conditii_4 AS personal_Spor_conditii_4,
personal.Spor_conditii_5 AS personal_Spor_conditii_5,
personal.Spor_conditii_6 AS personal_Spor_conditii_6,
personal.Sindicalist AS personal_Sindicalist,
personal.Salar_lunar_de_baza AS personal_Salar_lunar_de_baza,
personal.Zile_concediu_de_odihna_an AS personal_Zile_concediu_de_odihna_an,
personal.Zile_concediu_efectuat_an AS personal_Zile_concediu_efectuat_an,
personal.Zile_absente_an AS personal_Zile_absente_an,
personal.Vechime_totala AS personal_Vechime_totala,
personal.Data_angajarii_in_unitate AS personal_Data_angajarii_in_unitate,
personal.Banca AS personal_Banca,
personal.Cont_in_banca AS personal_Cont_in_banca,
personal.Poza AS personal_Poza,
personal.Sex AS personal_Sex,
personal.Data_nasterii AS personal_Data_nasterii,
personal.Cod_numeric_personal AS personal_Cod_numeric_personal,
personal.Studii AS personal_Studii,
personal.Profesia AS personal_Profesia,
personal.Adresa AS personal_Adresa,
personal.Copii AS personal_Copii,
personal.Loc_ramas_vacant AS personal_Loc_ramas_vacant,
personal.Localitate AS personal_Localitate,
personal.Judet AS personal_Judet,
personal.Strada AS personal_Strada,
personal.Numar AS personal_Numar,
personal.Cod_postal AS personal_Cod_postal,
personal.Bloc AS personal_Bloc,
personal.Scara AS personal_Scara,
personal.Etaj AS personal_Etaj,
personal.Apartament AS personal_Apartament,
personal.Sector AS personal_Sector,
personal.Mod_angajare AS personal_Mod_angajare,
personal.Data_plec AS personal_Data_plec,
personal.Tip_colab AS personal_Tip_colab,
personal.grad_invalid AS personal_grad_invalid,
personal.coef_invalid AS personal_coef_invalid,
personal.alte_surse AS personal_alte_surse,
(SELECT TOP 1 pozcom.Cantitate FROM pozcom WHERE pozcom.Subunitate= comenzi.Subunitate AND pozcom.Comanda= comenzi.Comanda ORDER BY pozcom.Cod_produs) AS pozcom_Cantitate,
(SELECT MIN(pozcom.Cod_produs) FROM pozcom WHERE pozcom.Subunitate= 'GR' AND pozcom.Comanda= comenzi.Comanda) AS pozcom_Cod_produs,
grcom.Tip_comanda AS grcom_Tip_comanda,
RTRIM((SELECT MIN(pozcom.Cod_produs) FROM pozcom WHERE pozcom.Subunitate= 'GR' AND pozcom.Comanda= comenzi.Comanda))+' '+
RTRIM(grcom.Grupa) AS grcom_Grupa,
grcom.Denumire_grupa AS grcom_Denumire_grupa
FROM elemactivitati
	LEFT JOIN elemente ON elemente.cod= elemactivitati.element
	LEFT JOIN pozactivitati ON elemactivitati.Tip= pozactivitati.Tip AND elemactivitati.Fisa= pozactivitati.Fisa 
		AND elemactivitati.Data= pozactivitati.Data AND elemactivitati.Numar_pozitie= pozactivitati.Numar_pozitie
	LEFT JOIN trasee ON pozactivitati.traseu= trasee.cod
	LEFT JOIN activitati ON elemactivitati.Tip= activitati.Tip AND elemactivitati.Fisa= activitati.Fisa 
		AND elemactivitati.Data= activitati.Data 
	LEFT JOIN CalStd ON elemactivitati.data= CalStd.Data
	LEFT JOIN masini ON activitati.masina= masini.cod_masina
	LEFT JOIN tipmasini ON masini.tip_masina= tipmasini.cod
	LEFT JOIN grmasini ON masini.grupa= grmasini.grupa
	LEFT JOIN lm lmM ON masini.loc_de_munca= lmM.cod
	LEFT JOIN personal ON personal.marca= activitati.marca
	LEFT JOIN comenzi ON masini.comanda= comenzi.comanda AND comenzi.subunitate='1'
	LEFT JOIN mfix ON masini.nr_inventar= mfix.Numar_de_inventar AND mfix.subunitate='1'
	LEFT JOIN lm lmC ON comenzi.Loc_de_munca= lmC.cod
	LEFT JOIN grcom ON grcom.Tip_comanda= comenzi.Tip_comanda 
		AND grcom.Grupa= (SELECT MIN(pozcom.Cod_produs) FROM pozcom WHERE pozcom.Subunitate= 'GR' AND pozcom.Comanda= comenzi.Comanda)