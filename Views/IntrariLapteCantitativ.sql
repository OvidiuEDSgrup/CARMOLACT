CREATE VIEW [dbo].[IntrariLapteCantitativ] AS
SELECT 
p.Subunitate,
p.Tip, 
p.Numar,
p.Data,
Numar_pozitie,

p.Data AS Data_cursa,
Comanda AS Masina,
CONVERT(INT, CASE ISNUMERIC(LEFT(LTRIM(p.numar),1)) WHEN 1 THEN REPLACE(REPLACE(LEFT(LTRIM(p.numar),1),'.',''),',','') ELSE 0 END) AS Tura,
p.cod AS Tip_lapte,
CONVERT(INT, CASE ISNUMERIC(LEFT(RIGHT(RTRIM(p.cod_intrare),3),1)) 
			WHEN 1 THEN REPLACE(REPLACE(LEFT(RIGHT(RTRIM(p.cod_intrare),3),1),'.',''),',','') ELSE 0 END) AS Compartiment,
ISNULL(Numele_delegatului,'') AS Sofer,
RTRIM(ISNULL(Punct_livrare, ''))+' '+LTRIM(ISNULL(rl.Denumire,'')) AS Ruta,
Loc_de_munca AS Punct_achizitie, 
RTRIM(left(p.factura, 8)) AS Aviz,
Tert AS Furnizor, 

p.Cod,
p.Gestiune,
p.Cantitate,

CASE WHEN p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'G') ELSE 0 END AS gras_teren,
CASE WHEN p.cod=tl.cod THEN dbo.iauPropStocGestCodIntr(identificator, 'G')*p.cantitate ELSE 0 END AS cant_UG_teren,
CASE WHEN p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'G') ELSE 0 END AS gras_fabrica,
CASE WHEN p.cod=rtrim(tl.cod)+'.' THEN dbo.iauPropStocGestCodIntr(identificator, 'G')*p.cantitate ELSE 0 END AS cant_UG_fabrica,

Pret_valuta,
Pret_de_stoc,
Adaos,
Pret_vanzare,
Pret_cu_amanuntul,
TVA_deductibil,
Cota_TVA,
Utilizator,
Data_operarii,
Ora_operarii,
Cod_intrare,
Cont_de_stoc,
Cont_corespondent,
TVA_neexigibil,
Pret_amanunt_predator,
Tip_miscare,
Locatie,
Data_expirarii,
Loc_de_munca,
Comanda,
Barcod,
Cont_intermediar,
Cont_venituri,
Discount,
Tert,
Factura,
Gestiune_primitoare,
Numar_DVI,
Stare,
Grupa,
Cont_factura,
Valuta,
Curs,
Data_facturii,
Data_scadentei,
Procent_vama,
Suprataxe_vama,
Accize_cumparare,
Accize_datorate,
Contract,
Jurnal,
tl.cod AS Cod_lapte,
ISNULL(r.identificator,'') AS Identificator

FROM pozdoc p 
	INNER JOIN TipLapte tl ON p.cod=tl.cod OR p.cod=RTRIM(tl.cod)+'.'
	LEFT JOIN gestiuni g ON g.subunitate= p.subunitate and g.cod_gestiune= p.gestiune
	LEFT JOIN recodif r ON r.Tip='STOC' AND r.Alfa1=g.Tip_gestiune and r.Alfa2=p.gestiune and 
		r.Alfa3=p.cod and r.Alfa4=p.cod_intrare and r.Alfa5='' and r.Alfa6='' 
		and r.Alfa7='' and r.Alfa8='' and r.Alfa9='' and r.Alfa10='' 
	LEFT JOIN anexadoc ad ON ad.subunitate= p.subunitate and ad.tip= p.tip and ad.numar= p.numar
		and ad.data= p.data and ad.tip_anexa=''
	LEFT JOIN ruteliv rl ON rl.cod=ad.Punct_livrare
	WHERE p.tip IN ('AI', 'RM', 'PP')