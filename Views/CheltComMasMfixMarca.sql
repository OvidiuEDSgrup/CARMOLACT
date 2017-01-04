CREATE
VIEW [dbo].[CheltComMasMfixMarca] AS
SELECT 
AS_pozincon.CalStd_Data AS Data,
AS_pozincon.pozincon_Loc_de_munca AS Loc_de_munca,
AS_pozincon.comenzi_Tip_comanda AS Tip_comanda,
AS_pozincon.CalStd_An AS An,
CASE 
WHEN AS_pozincon.pozincon_Cont_debitor LIKE '6024%' THEN 'Piese'
WHEN AS_pozincon.pozincon_Cont_debitor LIKE '6022.3%' THEN 'Alt combustibil'
WHEN AS_pozincon.pozincon_Cont_debitor LIKE '6022.[12]%' THEN 'Carburant'
WHEN AS_pozincon.pozincon_Cont_debitor LIKE '628.2%' 
	OR AS_pozincon.pozincon_Cont_debitor LIKE '624%'
	OR AS_pozincon.pozincon_Cont_debitor LIKE '611%' THEN 'Servicii' END 
AS Obiect_suma,
'Valoric' AS Tip_suma,
AS_pozincon.CalStd_Luna AS Luna,
AS_pozincon.pozincon_Comanda AS Comanda,
'' AS Tip_masina,
'' AS Masina,
'' AS Mijloc_fix,
'' AS Persoana,
AS_pozincon.pozincon_Suma AS Suma
FROM AS_pozincon
WHERE AS_pozincon.pozincon_Cont_debitor LIKE '6024%' 
	OR AS_pozincon.pozincon_Cont_debitor LIKE '6022.3%' 
	OR AS_pozincon.pozincon_Cont_debitor LIKE '6022.[12]%'
	OR AS_pozincon.pozincon_Cont_debitor LIKE '628.2%' 
	OR AS_pozincon.pozincon_Cont_debitor LIKE '624%'
	OR AS_pozincon.pozincon_Cont_debitor LIKE '611%'  
UNION ALL ---------------------------------------------------------
SELECT
CG_pozdoc.CalStd_Data,
CG_pozdoc.pozdoc_Loc_de_munca,
CG_pozdoc.comenzi_Tip_comanda,
CG_pozdoc.CalStd_An,
'Carburant',
'Cantitativ',
CG_pozdoc.CalStd_Luna,
CG_pozdoc.pozdoc_Comanda,
'',
'',
'',
'',
CG_pozdoc.pozdoc_cantitate
FROM CG_pozdoc
WHERE CG_pozdoc.nomencl_Cont LIKE '3022.[12]%' and CG_pozdoc.pozdoc_tip= 'CM'
UNION ALL ---------------------------------------------------------
SELECT
MF_fisamf.CalStd_Data,
MF_fisamf.fisaMF_Loc_de_munca,
MF_fisamf.comenzi_Tip_comanda,
MF_fisamf.CalStd_An,
'Amortizare',
'Valoric',
MF_fisamf.CalStd_Luna,
MF_fisamf.fisaMF_Comanda,
'',
'',
MF_fisamf.fisaMF_Numar_de_inventar,
'',
MF_fisamf.fisaMF_Amortizare_lunara
FROM MF_fisamf
UNION ALL ---------------------------------------------------------
SELECT
PS_realcom.CalStd_Data,
PS_realcom.realcom_Loc_de_munca,
PS_realcom.comenzi_Tip_comanda,
PS_realcom.CalStd_An,
'Salarii',
'Valoric',
PS_realcom.CalStd_Luna,
PS_realcom.realcom_Comanda,
'',
'',
'',
PS_realcom.realcom_Marca,
PS_realcom.realcom_Cantitate*PS_realcom.realcom_Tarif_unitar
FROM PS_realcom
UNION ALL ---------------------------------------------------------
SELECT
MM_elemactivitati.CalStd_Data,
MM_elemactivitati.activitati_Loc_de_munca,
MM_elemactivitati.comenzi_Tip_comanda,
MM_elemactivitati.CalStd_An,
'Productie',
'Valoric',
MM_elemactivitati.CalStd_Luna,
MM_elemactivitati.masini_Comanda,
MM_elemactivitati.masini_tip_masina,
MM_elemactivitati.activitati_Masina,
MM_elemactivitati.masini_nr_inventar,
MM_elemactivitati.activitati_Marca,
MM_elemactivitati.elemactivitati_Valoare*MM_elementemasini.coefmasini_Valoare
FROM MM_elemactivitati 
LEFT JOIN MM_elementemasini ON MM_elementemasini.coefmasini_Masina= MM_elemactivitati.masini_cod_masina
	AND MM_elementemasini.coefmasini_Coeficient= 'PRET'
WHERE MM_elemactivitati.elemactivitati_Element= 'TKM'
