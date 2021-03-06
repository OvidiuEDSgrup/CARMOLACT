﻿CREATE
-- ALTER
VIEW [dbo].[PS_realcom] AS
SELECT 
RTRIM(realcom.Marca)+' '+RTRIM(ISNULL(personal.Nume,'')) AS realcom_Marca,
RTRIM(realcom.Loc_de_munca)+' '+RTRIM(ISNULL(lm.Denumire,'')) AS realcom_Loc_de_munca,
realcom.Numar_document AS realcom_Numar_document,
realcom.Data AS realcom_Data,
RTRIM(realcom.Comanda)+' '+RTRIM(ISNULL(comenzi.Descriere,'')) AS realcom_Comanda,
realcom.Cod_reper AS realcom_Cod_reper,
realcom.Cod AS realcom_Cod,
realcom.Cantitate AS realcom_Cantitate,
realcom.Categoria_salarizare AS realcom_Categoria_salarizare,
realcom.Norma_de_timp AS realcom_Norma_de_timp,
realcom.Tarif_unitar AS realcom_Tarif_unitar,
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
pontaj.Data AS pontaj_Data,
pontaj.Marca AS pontaj_Marca,
pontaj.Numar_curent AS pontaj_Numar_curent,
pontaj.Loc_de_munca AS pontaj_Loc_de_munca,
pontaj.Loc_munca_pentru_stat_de_plata AS pontaj_Loc_munca_pentru_stat_de_plata,
pontaj.Tip_salarizare AS pontaj_Tip_salarizare,
pontaj.Regim_de_lucru AS pontaj_Regim_de_lucru,
pontaj.Salar_orar AS pontaj_Salar_orar,
pontaj.Ore_lucrate AS pontaj_Ore_lucrate,
pontaj.Ore_regie AS pontaj_Ore_regie,
pontaj.Ore_acord AS pontaj_Ore_acord,
pontaj.Ore_suplimentare_1 AS pontaj_Ore_suplimentare_1,
pontaj.Ore_suplimentare_2 AS pontaj_Ore_suplimentare_2,
pontaj.Ore_suplimentare_3 AS pontaj_Ore_suplimentare_3,
pontaj.Ore_suplimentare_4 AS pontaj_Ore_suplimentare_4,
pontaj.Ore_spor_100 AS pontaj_Ore_spor_100,
pontaj.Ore_de_noapte AS pontaj_Ore_de_noapte,
pontaj.Ore_intrerupere_tehnologica AS pontaj_Ore_intrerupere_tehnologica,
pontaj.Ore_concediu_de_odihna AS pontaj_Ore_concediu_de_odihna,
pontaj.Ore_concediu_medical AS pontaj_Ore_concediu_medical,
pontaj.Ore_invoiri AS pontaj_Ore_invoiri,
pontaj.Ore_nemotivate AS pontaj_Ore_nemotivate,
pontaj.Ore_obligatii_cetatenesti AS pontaj_Ore_obligatii_cetatenesti,
pontaj.Ore_concediu_fara_salar AS pontaj_Ore_concediu_fara_salar,
pontaj.Ore_donare_sange AS pontaj_Ore_donare_sange,
pontaj.Salar_categoria_lucrarii AS pontaj_Salar_categoria_lucrarii,
pontaj.Coeficient_acord AS pontaj_Coeficient_acord,
pontaj.Realizat AS pontaj_Realizat,
pontaj.Coeficient_de_timp AS pontaj_Coeficient_de_timp,
pontaj.Ore_realizate_acord AS pontaj_Ore_realizate_acord,
pontaj.Sistematic_peste_program AS pontaj_Sistematic_peste_program,
pontaj.Ore_sistematic_peste_program AS pontaj_Ore_sistematic_peste_program,
pontaj.Spor_specific AS pontaj_Spor_specific,
pontaj.Spor_conditii_1 AS pontaj_Spor_conditii_1,
pontaj.Spor_conditii_2 AS pontaj_Spor_conditii_2,
pontaj.Spor_conditii_3 AS pontaj_Spor_conditii_3,
pontaj.Spor_conditii_4 AS pontaj_Spor_conditii_4,
pontaj.Spor_conditii_5 AS pontaj_Spor_conditii_5,
pontaj.Spor_conditii_6 AS pontaj_Spor_conditii_6,
pontaj.Ore__cond_1 AS pontaj_Ore__cond_1,
pontaj.Ore__cond_2 AS pontaj_Ore__cond_2,
pontaj.Ore__cond_3 AS pontaj_Ore__cond_3,
pontaj.Ore__cond_4 AS pontaj_Ore__cond_4,
pontaj.Ore__cond_5 AS pontaj_Ore__cond_5,
pontaj.Ore__cond_6 AS pontaj_Ore__cond_6,
pontaj.Grupa_de_munca AS pontaj_Grupa_de_munca,
pontaj.Ore AS pontaj_Ore,
pontaj.Spor_cond_7 AS pontaj_Spor_cond_7,
pontaj.Spor_cond_8 AS pontaj_Spor_cond_8,
pontaj.Spor_cond_9 AS pontaj_Spor_cond_9,
pontaj.Spor_cond_10 AS pontaj_Spor_cond_10,
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
infoPers.Marca AS infoPers_Marca,
infoPers.Permis_auto_categoria AS infoPers_Permis_auto_categoria,
infoPers.Limbi_straine AS infoPers_Limbi_straine,
infoPers.Nationalitatea AS infoPers_Nationalitatea,
infoPers.Cetatenia AS infoPers_Cetatenia,
infoPers.Starea_civila AS infoPers_Starea_civila,
infoPers.Marca_sot_sotie AS infoPers_Marca_sot_sotie,
infoPers.Nume_sot_sotie AS infoPers_Nume_sot_sotie,
infoPers.Religia AS infoPers_Religia,
infoPers.Evidenta_militara AS infoPers_Evidenta_militara,
infoPers.Telefon AS infoPers_Telefon,
infoPers.Email AS infoPers_Email,
infoPers.Observatii AS infoPers_Observatii,
infoPers.Actionar AS infoPers_Actionar,
infoPers.Centru_de_cost_exceptie AS infoPers_Centru_de_cost_exceptie,
infoPers.Vechime_studii AS infoPers_Vechime_studii,
infoPers.Poza AS infoPers_Poza,
infoPers.Loc_munca_precedent AS infoPers_Loc_munca_precedent,
infoPers.Loc_munca_nou AS infoPers_Loc_munca_nou,
infoPers.Vechime_la_intrare AS infoPers_Vechime_la_intrare,
infoPers.Vechime_in_meserie AS infoPers_Vechime_in_meserie,
infoPers.Nr_contract AS infoPers_Nr_contract,
infoPers.Spor_cond_7 AS infoPers_Spor_cond_7,
infoPers.Spor_cond_8 AS infoPers_Spor_cond_8,
infoPers.Spor_cond_9 AS infoPers_Spor_cond_9,
infoPers.Spor_cond_10 AS infoPers_Spor_cond_10,
functii.Cod_functie AS functii_Cod_functie,
functii.Denumire AS functii_Denumire,
functii.Nivel_de_studii AS functii_Nivel_de_studii,
lm.Nivel AS lm_Nivel,
lm.Cod AS lm_Cod,
lm.Cod_parinte AS lm_Cod_parinte,
lm.Denumire AS lm_Denumire,
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
(SELECT TOP 1 pozcom.Cantitate FROM pozcom WHERE pozcom.Subunitate= comenzi.Subunitate AND pozcom.Comanda= comenzi.Comanda ORDER BY pozcom.Cod_produs) AS pozcom_Cantitate,
(SELECT MIN(pozcom.Cod_produs) FROM pozcom WHERE pozcom.Subunitate= 'GR' AND pozcom.Comanda= comenzi.Comanda) AS pozcom_Cod_produs,
grcom.Tip_comanda AS grcom_Tip_comanda,
RTRIM((SELECT MIN(pozcom.Cod_produs) FROM pozcom WHERE pozcom.Subunitate= 'GR' AND pozcom.Comanda= comenzi.Comanda))+' '+
RTRIM(grcom.Grupa) AS grcom_Grupa,
grcom.Denumire_grupa AS grcom_Denumire_grupa
FROM realcom
	LEFT JOIN calstd ON realcom.Data= calstd.Data
	LEFT JOIN pontaj ON pontaj.Data= realcom.Data AND pontaj.marca= realcom.marca 
		AND 'PS'+ ltrim(rtrim(cast(pontaj.numar_curent as char(18))))= realcom.Numar_document
	LEFT JOIN personal ON personal.marca= realcom.marca
	LEFT JOIN infopers ON infopers.marca= realcom.marca
	LEFT JOIN functii ON functii.cod_functie= personal.cod_functie
	LEFT JOIN lm ON lm.cod= realcom.Loc_de_munca
	LEFT JOIN comenzi ON comenzi.Subunitate= '1' AND comenzi.comanda= realcom.comanda
	LEFT JOIN grcom ON grcom.Tip_comanda= comenzi.Tip_comanda 
		AND grcom.Grupa= (SELECT MIN(pozcom.Cod_produs) FROM pozcom WHERE pozcom.Subunitate= 'GR' AND pozcom.Comanda= comenzi.Comanda)
