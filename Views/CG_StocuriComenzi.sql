CREATE 
-- ALTER
VIEW [dbo].[CG_StocuriComenzi] AS
SELECT
CalStd.An AS CalStd_An,
CalStd.Luna AS CalStd_Luna,
CalStd.Data_lunii AS CalStd_Data_lunii,
CalStd.LunaAlfa AS CalStd_LunaAlfa,
CalStd.Trimestru AS CalStd_Trimestru,
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
grcom.Denumire_grupa AS grcom_Denumire_grupa,
gestiuni.Subunitate AS gestiuni_Subunitate,
gestiuni.Tip_gestiune AS gestiuni_Tip_gestiune,
gestiuni.Cod_gestiune AS gestiuni_Cod_gestiune,
gestiuni.Denumire_gestiune AS gestiuni_Denumire_gestiune,
gestiuni.Cont_contabil_specific AS gestiuni_Cont_contabil_specific,
CASE WHEN gestiuni.Cod_gestiune IS NULL OR gestiuni.Cod_gestiune= ''
THEN 0 ELSE dbo.fStocuriCenGest(Data_lunii,Cod_gestiune) END AS Valoare_stoc_gestiune,
lm.Nivel AS lm_Nivel,
lm.Cod AS lm_Cod,
lm.Cod_parinte AS lm_Cod_parinte,
lm.Denumire AS lm_Denumire
FROM 
	(SELECT An,Luna,MAX(Data_lunii) AS Data_lunii, MAX(LunaAlfa) AS LunaAlfa,MAX(Trimestru) Trimestru FROM calstd GROUP BY An,Luna) calstd,comenzi
	LEFT JOIN gestiuni ON gestiuni.Subunitate= comenzi.Subunitate 
		AND gestiuni.Cod_gestiune= (SELECT MIN(pozcom.Cod_produs) FROM pozcom WHERE pozcom.Subunitate= 'GR' AND pozcom.Comanda= comenzi.Comanda)
	LEFT JOIN grcom ON grcom.Tip_comanda= comenzi.Tip_comanda 
			AND grcom.Grupa= (SELECT MIN(pozcom.Cod_produs) FROM pozcom WHERE pozcom.Subunitate= 'GR' AND pozcom.Comanda= comenzi.Comanda)
	LEFT JOIN lm ON lm.cod= comenzi.Loc_de_munca
