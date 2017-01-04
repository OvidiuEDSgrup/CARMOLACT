CREATE VIEW [dbo].[IntrariLapte] AS
SELECT 
CASE WHEN p.Tip IN ('AI', 'RM') THEN 1 ELSE -1 END AS semn_tip_miscare,
CASE WHEN p.tip IN ('AI','RM') and Alfa2='0' THEN p.cantitate ELSE 0 END AS cant_teren,
CASE WHEN p.tip IN ('AE') THEN p.cantitate ELSE 0 END AS cant_corectie,
CASE WHEN p.tip IN ('AI','RM') and p.cod=rtrim(tl.cod)+'.' THEN p.cantitate ELSE 0 END AS cant_fabrica,

ISNULL(Numele_delegatului,'') AS Sofer,
ISNULL(Punct_livrare, '') AS Ruta,
ISNULL(rl.Denumire,'') AS Denumire_ruta,
CONVERT(INT, CASE ISNUMERIC(LEFT(LTRIM(p.numar),1)) WHEN 1 THEN REPLACE(REPLACE(LEFT(LTRIM(p.numar),1),'.',''),',','') ELSE 0 END) AS Tura,
RTRIM(left(p.factura, 8)) AS Aviz,
CONVERT(INT, CASE ISNUMERIC(LEFT(RIGHT(RTRIM(p.cod_intrare),3),1)) 
			WHEN 1 THEN REPLACE(REPLACE(LEFT(RIGHT(RTRIM(p.cod_intrare),3),1),'.',''),',','') ELSE 0 END) AS Compartiment,

p.Subunitate, p.Tip, p.Numar, p.Cod, p.Data, p.Gestiune, p.cantitate, 
Pret_valuta, 
Pret_de_stoc, 
Adaos, 
Pret_vanzare, Pret_cu_amanuntul, 
TVA_deductibil, Cota_TVA, 
Utilizator, Data_operarii, 
Ora_operarii, 
Cod_intrare, Cont_de_stoc, Cont_corespondent, TVA_neexigibil, Pret_amanunt_predator, Tip_miscare, Locatie, 
Data_expirarii, Numar_pozitie, 
Loc_de_munca, Comanda, Barcod, Cont_intermediar, Cont_venituri, Discount, 
Tert, 
Factura, 
Gestiune_primitoare, 
Numar_DVI, Stare, Grupa, Cont_factura, Valuta, Curs, 
Data_facturii, Data_scadentei, Procent_vama, Suprataxe_vama, Accize_cumparare, Accize_datorate, 
Contract, Jurnal,
tl.cod as cod_lapte,
ISNULL(r.identificator,'') AS identificator,

dbo.iauPropStocGestCodIntr(identificator, 'G') AS Grasime,
CASE WHEN p.tip IN ('AI','RM') and p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'G')
ELSE 0 END AS gras_teren,
CASE WHEN p.tip IN ('AI','RM') and p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'G')
*p.cantitate ELSE 0 END AS cant_UG_teren,
CASE WHEN p.tip IN ('AE') THEN dbo.iauPropStocGestCodIntr(identificator, 'G')
ELSE 0 END AS gras_corectie,
CASE WHEN p.tip IN ('AE') THEN dbo.iauPropStocGestCodIntr(identificator, 'G')
*p.cantitate ELSE 0 END AS cant_UG_corectie,
CASE WHEN p.tip IN ('AI','RM') and p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'G')
ELSE 0 END AS gras_fabrica,
CASE WHEN p.tip IN ('AI','RM') and p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'G')
*p.cantitate ELSE 0 END AS cant_UG_fabrica,

dbo.iauPropStocGestCodIntr(identificator, 'S') AS Substanta_uscata,
CASE WHEN p.tip IN ('AI','RM') and p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'S')
ELSE 0 END AS subst_teren,
CASE WHEN p.tip IN ('AI','RM') and p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'S')
*p.cantitate ELSE 0 END AS cant_US_teren,
CASE WHEN p.tip IN ('AE') THEN dbo.iauPropStocGestCodIntr(identificator, 'S')
ELSE 0 END AS subst_corectie,
CASE WHEN p.tip IN ('AE') THEN dbo.iauPropStocGestCodIntr(identificator, 'S')
*p.cantitate ELSE 0 END AS cant_US_corectie,
CASE WHEN p.tip IN ('AI','RM') and p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'S')
ELSE 0 END AS subst_fabrica,
CASE WHEN p.tip IN ('AI','RM') and p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'S')
*p.cantitate ELSE 0 END AS cant_US_fabrica,

dbo.iauPropStocGestCodIntr(identificator, 'D') AS Densitate,
CASE WHEN p.tip IN ('AI','RM') and p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'D')
ELSE 0 END AS dens_teren,
CASE WHEN p.tip IN ('AI','RM') and p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'D')
*p.cantitate ELSE 0 END AS cant_UD_teren,
CASE WHEN p.tip IN ('AE') THEN dbo.iauPropStocGestCodIntr(identificator, 'D')
ELSE 0 END AS dens_corectie,
CASE WHEN p.tip IN ('AE') THEN dbo.iauPropStocGestCodIntr(identificator, 'D')
*p.cantitate ELSE 0 END AS cant_UD_corectie,
CASE WHEN p.tip IN ('AI','RM') and p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'D')
ELSE 0 END AS dens_fabrica,
CASE WHEN p.tip IN ('AI','RM') and p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'D')
*p.cantitate ELSE 0 END AS cant_UD_fabrica,

dbo.iauPropStocGestCodIntr(identificator, 'A') AS Apa_adaugata,
CASE WHEN p.tip IN ('AI','RM') and p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'A')
ELSE 0 END AS apa_teren,
CASE WHEN p.tip IN ('AI','RM') and p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'A')
*p.cantitate ELSE 0 END AS cant_UA_teren,
CASE WHEN p.tip IN ('AE') THEN dbo.iauPropStocGestCodIntr(identificator, 'A')
ELSE 0 END AS apa_corectie,
CASE WHEN p.tip IN ('AE') THEN dbo.iauPropStocGestCodIntr(identificator, 'A')
*p.cantitate ELSE 0 END AS cant_UA_corectie,
CASE WHEN p.tip IN ('AI','RM') and p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'A')
ELSE 0 END AS apa_fabrica,
CASE WHEN p.tip IN ('AI','RM') and p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'A')
*p.cantitate ELSE 0 END AS cant_UA_fabrica,

dbo.iauPropStocGestCodIntr(identificator, 'P') AS Proteine,
CASE WHEN p.tip IN ('AI','RM') and p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'P')
ELSE 0 END AS prot_teren,
CASE WHEN p.tip IN ('AI','RM') and p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'P')
*p.cantitate ELSE 0 END AS cant_UP_teren,
CASE WHEN p.tip IN ('AE') THEN dbo.iauPropStocGestCodIntr(identificator, 'P')
ELSE 0 END AS prot_corectie,
CASE WHEN p.tip IN ('AE') THEN dbo.iauPropStocGestCodIntr(identificator, 'P')
*p.cantitate ELSE 0 END AS cant_UP_corectie,
CASE WHEN p.tip IN ('AI','RM') and p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'P')
ELSE 0 END AS prot_fabrica,
CASE WHEN p.tip IN ('AI','RM') and p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'P')
*p.cantitate ELSE 0 END AS cant_UP_fabrica

FROM pozdoc p 
	INNER JOIN TipLapte tl ON p.cod=tl.cod OR p.cod=RTRIM(tl.cod)+'.'
	LEFT JOIN gestiuni g ON g.subunitate= p.subunitate and g.cod_gestiune= p.gestiune
	LEFT JOIN recodif r ON r.Tip='STOC' AND r.Alfa1=g.Tip_gestiune and r.Alfa2=p.gestiune and 
		r.Alfa3=p.cod and r.Alfa4=p.cod_intrare and r.Alfa5='' and r.Alfa6='' 
		and r.Alfa7='' and r.Alfa8='' and r.Alfa9='' and r.Alfa10='' 
	LEFT JOIN anexadoc ad ON ad.subunitate= p.subunitate and ad.tip= p.tip and ad.numar= p.numar
		and ad.data= p.data and ad.tip_anexa=''
	LEFT JOIN ruteliv rl ON rl.cod=ad.Punct_livrare
	WHERE p.tip IN ('AI', 'AE', 'RM', 'PP')