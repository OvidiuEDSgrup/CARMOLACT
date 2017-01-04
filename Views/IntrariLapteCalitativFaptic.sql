CREATE VIEW [dbo].[IntrariLapteCalitativFaptic] AS
SELECT 
p.Subunitate,
p.Tip, 
p.Numar,
p.Data,
p.Numar_pozitie,

p.Data AS Data_cursa,
Comanda AS Masina,
CONVERT(INT, CASE ISNUMERIC(LEFT(LTRIM(p.numar),1)) WHEN 1 THEN REPLACE(REPLACE(LEFT(LTRIM(p.numar),1),'.',''),',','') ELSE 0 END) AS Tura,
p.cod AS Tip_lapte,
CONVERT(INT, CASE ISNUMERIC(LEFT(RIGHT(RTRIM(p.cod_intrare),3),1)) 
			WHEN 1 THEN REPLACE(REPLACE(LEFT(RIGHT(RTRIM(p.cod_intrare),3),1),'.',''),',','') ELSE 0 END) AS Compartiment,
p.Gestiune,
p.Cod_intrare,

RTRIM(left(p.factura, 8)) AS Aviz,
Loc_de_munca AS Punct_achizitie, 

ISNULL(Numele_delegatului,'') AS Sofer,
Punct_livrare AS Ruta,
Tert AS Furnizor, 

p.Cod,
p.Cantitate,

dbo.iauPropStocGestCodIntr(identificator, 'G') AS gras_faptic,
dbo.iauPropStocGestCodIntr(identificator, 'G')*p.cantitate AS cant_UG_faptic,

dbo.iauPropStocGestCodIntr(identificator, 'S') AS subst_faptic,
dbo.iauPropStocGestCodIntr(identificator, 'S')*p.cantitate AS cant_US_faptic,

dbo.iauPropStocGestCodIntr(identificator, 'D') AS dens_faptic,
dbo.iauPropStocGestCodIntr(identificator, 'D')*p.cantitate AS cant_UD_faptic,

dbo.iauPropStocGestCodIntr(identificator, 'A') AS apa_faptic,
dbo.iauPropStocGestCodIntr(identificator, 'A')*p.cantitate AS cant_UA_faptic,

dbo.iauPropStocGestCodIntr(identificator, 'P') AS prot_faptic,
dbo.iauPropStocGestCodIntr(identificator, 'P')*p.cantitate AS cant_UP_faptic,

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
Cod_lapte AS Cod_lapte,
ISNULL(r.identificator,'') AS Identificator
/*
select 
'MAX('+
rtrim(t.name)
--'IntrariLapteCompartimente'
+'.'+rtrim(ltrim(c.name))
+') '
+' AS '
--+rtrim(t.name)
--+'IntrariLapteCompartimente'
--+'_'
+rtrim(ltrim(c.name))+','
from sysobjects t 
	inner join syscolumns c on t.id=c.id
where t.name='pozdoc'
*/
FROM  
		(SELECT 
			pd.Subunitate, pd.Data, pd.Numar, pd.Gestiune, pd.Cod, pd.Cod_intrare,			
			SUM(CASE pd.tip WHEN 'AE' THEN -1 ELSE 1 END *pd.Cantitate) AS Cantitate,
			MAX(pd.Tip) AS Tip,
			MAX(pd.Pret_valuta) AS Pret_valuta,
			MAX(pd.Pret_de_stoc) AS Pret_de_stoc,
			MAX(pd.Adaos) AS Adaos,
			MAX(pd.Pret_vanzare) AS Pret_vanzare,
			MAX(pd.Pret_cu_amanuntul) AS Pret_cu_amanuntul,
			MAX(pd.TVA_deductibil) AS TVA_deductibil,
			MAX(pd.Cota_TVA) AS Cota_TVA,
			MAX(pd.Utilizator) AS Utilizator,
			MAX(pd.Data_operarii) AS Data_operarii,
			MAX(pd.Ora_operarii) AS Ora_operarii,
			MAX(pd.Cont_de_stoc) AS Cont_de_stoc,
			MAX(pd.Cont_corespondent) AS Cont_corespondent,
			MAX(pd.TVA_neexigibil) AS TVA_neexigibil,
			MAX(pd.Pret_amanunt_predator) AS Pret_amanunt_predator,
			MAX(pd.Tip_miscare) AS Tip_miscare,
			MAX(pd.Locatie) AS Locatie,
			MAX(pd.Data_expirarii) AS Data_expirarii,
			MAX(pd.Numar_pozitie) AS Numar_pozitie,
			MAX(pd.Loc_de_munca) AS Loc_de_munca,
			MAX(pd.Comanda) AS Comanda,
			MAX(pd.Barcod) AS Barcod,
			MAX(pd.Cont_intermediar) AS Cont_intermediar,
			MAX(pd.Cont_venituri) AS Cont_venituri,
			MAX(pd.Discount) AS Discount,
			MAX(pd.Tert) AS Tert,
			MAX(pd.Factura) AS Factura,
			MAX(pd.Gestiune_primitoare) AS Gestiune_primitoare,
			MAX(pd.Numar_DVI) AS Numar_DVI,
			MAX(pd.Stare) AS Stare,
			MAX(pd.Grupa) AS Grupa,
			MAX(pd.Cont_factura) AS Cont_factura,
			MAX(pd.Valuta) AS Valuta,
			MAX(pd.Curs) AS Curs,
			MAX(pd.Data_facturii) AS Data_facturii,
			MAX(pd.Data_scadentei) AS Data_scadentei,
			MAX(pd.Procent_vama) AS Procent_vama,
			MAX(pd.Suprataxe_vama) AS Suprataxe_vama,
			MAX(pd.Accize_cumparare) AS Accize_cumparare,
			MAX(pd.Accize_datorate) AS Accize_datorate,
			MAX(pd.Contract) AS Contract,
			MAX(pd.Jurnal) AS Jurnal,
			MAX(tl.cod) AS Cod_lapte
		FROM pozdoc pd 
			INNER JOIN TipLapte tl ON pd.cod=tl.cod 
		WHERE pd.tip IN ('AI', 'RM', 'AE', 'PP')
		GROUP BY pd.Subunitate, pd.Data, pd.Numar, pd.Gestiune, pd.Cod, pd.Cod_intrare) p
	LEFT JOIN gestiuni g ON g.subunitate= p.subunitate and g.cod_gestiune= p.gestiune
	LEFT JOIN recodif r ON r.Tip='STOC' AND r.Alfa1=g.Tip_gestiune and r.Alfa2=p.gestiune 
		and r.Alfa3=RTRIM(p.cod)+'.' and r.Alfa4=LEFT(p.cod_intrare,LEN(p.cod_intrare)-2)+'00' 
		and r.Alfa5='' and r.Alfa6='' and r.Alfa7='' and r.Alfa8='' and r.Alfa9='' and r.Alfa10='' 
	LEFT JOIN anexadoc ad ON ad.subunitate= p.subunitate and ad.tip= p.tip and ad.numar= p.numar
		and ad.data= p.data and ad.tip_anexa=''