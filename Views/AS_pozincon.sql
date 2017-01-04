﻿CREATE 
-- ALTER
VIEW [dbo].[AS_pozincon] AS
SELECT 
pozincon.Subunitate AS pozincon_Subunitate,
pozincon.Tip_document AS pozincon_Tip_document,
pozincon.Numar_document AS pozincon_Numar_document,
pozincon.Data AS pozincon_Data,
pozincon.Cont_debitor AS pozincon_Cont_debitor,
pozincon.Cont_creditor AS pozincon_Cont_creditor,
pozincon.Suma AS pozincon_Suma,
pozincon.Valuta AS pozincon_Valuta,
pozincon.Curs AS pozincon_Curs,
pozincon.Suma_valuta AS pozincon_Suma_valuta,
pozincon.Explicatii AS pozincon_Explicatii,
pozincon.Utilizator AS pozincon_Utilizator,
pozincon.Data_operarii AS pozincon_Data_operarii,
pozincon.Ora_operarii AS pozincon_Ora_operarii,
pozincon.Numar_pozitie AS pozincon_Numar_pozitie,
RTRIM(pozincon.Loc_de_munca)+' '+RTRIM(ISNULL(lm.Denumire,'')) AS pozincon_Loc_de_munca,
RTRIM(pozincon.Comanda)+' '+RTRIM(ISNULL(comenzi.Descriere,'')) AS pozincon_Comanda,
pozincon.Jurnal AS pozincon_Jurnal,
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
conturiDebit.Subunitate AS conturiDebit_Subunitate,
conturiDebit.Cont AS conturiDebit_Cont,
conturiDebit.Denumire_cont AS conturiDebit_Denumire_cont,
conturiDebit.Tip_cont AS conturiDebit_Tip_cont,
conturiDebit.Cont_parinte AS conturiDebit_Cont_parinte,
conturiDebit.Are_analitice AS conturiDebit_Are_analitice,
conturiDebit.Apare_in_balanta_sintetica AS conturiDebit_Apare_in_balanta_sintetica,
conturiDebit.Sold_debit AS conturiDebit_Sold_debit,
conturiDebit.Sold_credit AS conturiDebit_Sold_credit,
conturiDebit.Nivel AS conturiDebit_Nivel,
conturiDebit.Articol_de_calculatie AS conturiDebit_Articol_de_calculatie,
conturiDebit.Logic AS conturiDebit_Logic,
conturiCredit.Subunitate AS conturiCredit_Subunitate,
conturiCredit.Cont AS conturiCredit_Cont,
conturiCredit.Denumire_cont AS conturiCredit_Denumire_cont,
conturiCredit.Tip_cont AS conturiCredit_Tip_cont,
conturiCredit.Cont_parinte AS conturiCredit_Cont_parinte,
conturiCredit.Are_analitice AS conturiCredit_Are_analitice,
conturiCredit.Apare_in_balanta_sintetica AS conturiCredit_Apare_in_balanta_sintetica,
conturiCredit.Sold_debit AS conturiCredit_Sold_debit,
conturiCredit.Sold_credit AS conturiCredit_Sold_credit,
conturiCredit.Nivel AS conturiCredit_Nivel,
conturiCredit.Articol_de_calculatie AS conturiCredit_Articol_de_calculatie,
conturiCredit.Logic AS conturiCredit_Logic,
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
FROM pozincon pozincon
	LEFT JOIN CalStd on CalStd.Data= pozincon.Data
	LEFT JOIN conturi conturiDebit ON conturiDebit.Subunitate= pozincon.Subunitate 
		AND conturiDebit.Cont= pozincon.Cont_debitor
	LEFT JOIN conturi conturiCredit ON conturiCredit.Subunitate= pozincon.Subunitate
		AND conturiCredit.Cont= pozincon.Cont_creditor
	LEFT JOIN lm on lm.cod= pozincon.loc_de_munca
	LEFT JOIN comenzi ON comenzi.Subunitate= pozincon.Subunitate 
		AND comenzi.comanda= pozincon.comanda
	LEFT JOIN grcom ON grcom.Tip_comanda= comenzi.Tip_comanda 
		AND grcom.Grupa= (SELECT MIN(pozcom.Cod_produs) FROM pozcom WHERE pozcom.Subunitate= 'GR' AND pozcom.Comanda= comenzi.Comanda)
