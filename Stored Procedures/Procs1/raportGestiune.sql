--***
create procedure raportGestiune (@sesiune varchar(50)=null, @datajos datetime,@datasus datetime, @gestiunea varchar(20),@tip_gestiune nvarchar(1), @soldc int=0,
			@numairulaje bit=0,@numaiMarfuri bit=0)
as

/**
exec raportGestiune '','02/08/2016','02/08/2016','1','E'
*/
set transaction isolation level read uncommitted
declare @eroare varchar(2000), @nivelmesaj int
select @eroare='', @nivelmesaj=1	--> prima aplicare a noii metode de semnalizare probleme: mesaj de avertizare + nivel (nivel: 0=avertizare in subtitlu cu rosu, 1=eroare, apare in titlu, cu rosu, fara alte date)
			--> daca apare vreo eroare de obicei e de-aia grava, de nivel 1, de asta nivelmesaj e 1 implicit
begin try
------------------------ stergere eventuale tabele temporare
if object_id('tempdb..#soldi') is not null drop table #soldi
if object_id('tempdb..#rapg_Fgrupat') is not null drop table #rapg_Fgrupat
if object_id('tempdb..#rapg_grupat') is not null drop table #rapg_grupat
if object_id('tempdb..#rapg') is not null drop table #rapg
	
/**	Pregatire filtrare pe proprietati utilizatori*/
declare @fltGstUt int
declare @GestUtiliz table(valoare varchar(200), cod varchar(20), analitic371 varchar(40), analitic707 varchar(40))
insert into @GestUtiliz (valoare,cod, analitic371, analitic707)
select valoare, cod_proprietate,
		'371'+'.'+rtrim(cod_proprietate)+'%' analitic371, '707'+'.'+rtrim(cod_proprietate)+'%' analitic707 from fPropUtiliz(null) where cod_proprietate='GESTIUNE' and valoare<>''
set	@fltGstUt=isnull((select count(1) from @GestUtiliz),0)
		
declare @q_datasus datetime,@q_datajos datetime,@q_gestiune_jos varchar(20),@q_gestiune_sus varchar(20),@q_tip_gestiune varchar(1)
select @q_datasus=@datasus,@q_datajos=@datajos,@q_gestiune_jos=isnull(@gestiunea,''),@q_gestiune_sus=isnull(@gestiunea,'')+'zzzzzzzzz'
		,@q_tip_gestiune=@tip_gestiune

declare @q_sub varchar(9), @q_data_inchisa datetime,
		@analitic371 varchar(40), @analitic707 varchar(40)--, @q_pret_am_fara_tva int, @q_totaluri_pe_corespondente int
select @q_sub='1', @q_data_inchisa=dateadd(d,-1,dateadd(M,1,
		convert(datetime,convert(varchar(4),(select val_numerica from par where Tip_parametru='GE' and Parametru='anulinc'))+'-'+
					convert(varchar(2),(select val_numerica from par where Tip_parametru='GE' and Parametru='lunainc'))+'-1')
						))
select @analitic371='371'+'.'+rtrim(@q_gestiune_jos)+'%', @analitic707='707'+'.'+rtrim(@q_gestiune_jos)+'%'

declare @incLuna datetime
set @incLuna=dateadd(d,1-day(@q_datajos),@q_datajos)

select p.Subunitate,p.Tip,p.Numar,p.Cod,p.Data,p.Gestiune,p.Cantitate,p.Pret_valuta,p.Pret_de_stoc,p.Adaos,p.Pret_vanzare,p.Pret_cu_amanuntul,p.TVA_deductibil,p.Cota_TVA,p.Utilizator,p.Data_operarii,p.Ora_operarii,p.Cod_intrare,p.Cont_de_stoc,p.Cont_corespondent,p.TVA_neexigibil,p.Pret_amanunt_predator,p.Tip_miscare,p.Locatie,p.Data_expirarii,p.Numar_pozitie,p.Loc_de_munca,p.Comanda,p.Barcod,p.Cont_intermediar,p.Cont_venituri,p.Discount,p.Tert,p.Factura,p.Gestiune_primitoare,p.Numar_DVI,p.Stare,p.Grupa,p.Cont_factura,p.Valuta,p.Curs,p.Data_facturii,p.Data_scadentei,p.Procent_vama,p.Suprataxe_vama,p.Accize_cumparare,p.Accize_datorate,p.Contract,p.Jurnal,p.detalii,p.idPozDoc,p.subtip,p.idIntrare,p.idIntrareTI,p.colet,p.lot,p.idIntrareFirma
into #pozdocRapGestiune
from pozdoc p
left join gestiuni g on g.subunitate=@q_sub and p.gestiune=g.cod_gestiune
where @q_tip_gestiune<>'V' and p.subunitate=@q_sub 
		and data between (case when g.pret_am=1 then @q_datajos else @incLuna end) and @q_datasus 
		and gestiune between @q_gestiune_jos and @q_gestiune_sus 
		and ((@numaimarfuri=0 and tip_miscare in ('I','E','V')) -- V pentru taxa verde --or left(cont_de_stoc,4)='4428') 
			or (@numaiMarfuri=1 and tip_miscare in ('I','E')))
		and (@q_tip_gestiune='E' and g.pret_am=1 or g.tip_gestiune=@q_tip_gestiune)
		and (@fltGstUt=0 or exists(select 1 from @GestUtiliz pr where pr.valoare=p.gestiune))
union all
-- AC-uri din gestiune tip C, cu gestiune primitoare completata, validata in catalogul de gestiuni si de tip A. Am tratat separat pt. a nu complica selectul de mai sus; cele cu cantitate negativa = stornari bonuri 
select p.Subunitate,p.Tip,p.Numar,p.Cod,p.Data,p.Gestiune,p.Cantitate,p.Pret_valuta,p.Pret_de_stoc,p.Adaos,p.Pret_vanzare,p.Pret_cu_amanuntul,p.TVA_deductibil,p.Cota_TVA,p.Utilizator,p.Data_operarii,p.Ora_operarii,p.Cod_intrare,p.Cont_de_stoc,p.Cont_corespondent,p.TVA_neexigibil,p.Pret_amanunt_predator,p.Tip_miscare,p.Locatie,p.Data_expirarii,p.Numar_pozitie,p.Loc_de_munca,p.Comanda,p.Barcod,p.Cont_intermediar,p.Cont_venituri,
cantitate*convert(decimal(17,5),(p.pret_valuta-p.pret_vanzare)*(1+cota_tva/100.00)) as Discount,
p.Tert,p.Factura,p.Gestiune_primitoare,p.Numar_DVI,p.Stare,p.Grupa,p.Cont_factura,p.Valuta,p.Curs,p.Data_facturii,p.Data_scadentei,p.Procent_vama,p.Suprataxe_vama,p.Accize_cumparare,p.Accize_datorate,p.Contract,p.Jurnal,p.detalii,p.idPozDoc,p.subtip,p.idIntrare,p.idIntrareTI,p.colet,p.lot,p.idIntrareFirma
from pozdoc p
left join terti t on p.Tert=t.Tert and p.Subunitate=t.Subunitate
where @q_tip_gestiune='A' and p.subunitate=@q_sub 
		and (tip='AC' or tip='AP' and p.cantitate<0) 
		and data between @incLuna and @q_datasus 
		and gestiune_primitoare between @q_gestiune_jos and @q_gestiune_sus 
		and tip_miscare='E' 
		and exists (select 1 from gestiuni where subunitate=@q_sub and tip_gestiune='C' and gestiune=cod_gestiune)
		and exists (select 1 from gestiuni where subunitate=@q_sub and tip_gestiune=@q_tip_gestiune and Gestiune_primitoare=cod_gestiune)
		and (@fltGstUt=0 or exists (select 1 from @GestUtiliz pr where pr.valoare=p.Gestiune_primitoare))
union all 
-- TI-uri (din TE si din AP/AC din gestiune tip C cu gestiune primitoare)
select p.Subunitate,'TI',p.Numar,p.Cod,p.Data,p.Gestiune_primitoare,p.Cantitate,p.Pret_valuta,p.Pret_de_stoc,p.Adaos,p.Pret_vanzare,
(case when p.tip='TE' then p.Pret_cu_amanuntul else convert(decimal(12,2),p.Pret_valuta*(1+p.Cota_tva/100.00)) end) as pret_cu_amanuntul,
p.TVA_deductibil,p.Cota_TVA,p.Utilizator,p.Data_operarii,p.Ora_operarii,p.Cod_intrare,p.Cont_de_stoc,p.Cont_corespondent,p.TVA_neexigibil,p.Pret_amanunt_predator,'I',p.Locatie,p.Data_expirarii,p.Numar_pozitie,p.Loc_de_munca,p.Comanda,p.Barcod,p.Cont_intermediar,p.Cont_venituri,p.Discount,p.Tert,p.Factura,p.Gestiune,p.Numar_DVI,p.Stare,p.Grupa,p.Cont_factura,p.Valuta,p.Curs,p.Data_facturii,p.Data_scadentei,p.Procent_vama,p.Suprataxe_vama,p.Accize_cumparare,p.Accize_datorate,p.Contract,p.Jurnal,p.detalii,p.idPozDoc,p.subtip,p.idIntrare,p.idIntrareTI,p.colet,p.lot,p.idIntrareFirma
from pozdoc p
left join gestiuni gp on gp.subunitate=@q_sub and p.gestiune_primitoare=gp.cod_gestiune
where @q_tip_gestiune<>'V' and p.subunitate=@q_sub 
		and data between (case when gp.pret_am=1 then @q_datajos else @incLuna end) and @q_datasus 
		and (p.tip='TE' or (p.tip='AC' or p.tip='AP' and p.cantitate<0) and exists(select 1 from gestiuni where subunitate=@q_sub and tip_gestiune='C' and cod_gestiune=gestiune)) 
		and p.tip_miscare='E' 
		and p.gestiune_primitoare between @q_gestiune_jos and @q_gestiune_sus 
		and exists (select 1 from gestiuni where subunitate=@q_sub and (@q_tip_gestiune='E' and pret_am=1 or tip_gestiune=@q_tip_gestiune) 
		and (tip='TE' or @q_tip_gestiune in ('A','E')) and cod_gestiune=p.gestiune_primitoare)
		and (@fltGstUt=0 or exists (select 1 from @GestUtiliz pr where pr.valoare=p.Gestiune_primitoare))

if @q_tip_gestiune='E'
begin
	select p.idpozdoc,p.cod,tip,p.gestiune as gestiune
	into #preturiam
	from #pozdocRapGestiune p
	left join gestiuni g on p.Gestiune=g.cod_gestiune 
	left join gestiuni gp on p.Gestiune_primitoare=gp.cod_gestiune 
	where not (p.tip='TE' and p.Gestiune=p.Gestiune_primitoare)
	and (g.pret_am=1 or gp.pret_am=1)

	exec CreazaDiezPreturiAmanunt
	exec wIaPreturiAmanunt @sesiune,'<row/>'
		
	update p set pret_cu_amanuntul=(case when p.tip_miscare='I' then pa.pret_amanunt else p.pret_cu_amanuntul end),
		tva_neexigibil=pa.cota_tva,
		pret_amanunt_predator=(case when p.tip_miscare='E' then pa.pret_amanunt when p.tip_miscare='V' then 0 else p.pret_amanunt_predator end)
	from #pozdocRapGestiune p
	inner join #preturiam pa on pa.idpozdoc=p.idpozdoc and p.tip=pa.tip
end
-----------------	rulaj valorice (V):
select substring(cont_debitor,5,9) as gestiune, tip_document, numar_document, data, sum(suma) suma, 0 as sumaE, 
	max(explicatii) explicatii, 'V' as tip, 0 as val_cu_amanuntul, 0 as discount, 0 as discpoz
	--, 0 as servicii,space(13) as coresp
into #rapg 
from pozincon  
where @q_tip_gestiune='V' and subunitate=@q_sub and data between @incLuna and @q_datasus and cont_debitor like @analitic371 
	and tip_document<>'IC' 
	and exists(select 1 from gestiuni where subunitate=@q_sub and tip_gestiune='V' and substring(cont_debitor,5,9)=cod_gestiune)
	and (@fltGstUt=0 or exists(select 1 from @GestUtiliz pr where cont_debitor like pr.analitic371))
	group by substring(cont_debitor,5,9), tip_document, numar_document, data
union all 
select substring(cont_creditor,5,9), tip_document, numar_document, data, 0, sum(suma) suma, max(explicatii) explicatii, 'V', 0, 0, 0 
		--,/*(case when totaluri_pe_corespondente=0 then '' else cont_debitor end)*/ '', 0, 0
from pozincon  
where @q_tip_gestiune='V' and subunitate=@q_sub and data between @incLuna and @q_datasus and cont_creditor like @analitic371 and tip_document<>'IC' 
	and exists(select 1 from gestiuni where subunitate=@q_sub and tip_gestiune='V' and cod_gestiune=substring(cont_creditor,5,9))
	and (@fltGstUt=0 or exists(select 1 from @GestUtiliz pr where Cont_creditor like pr.analitic371))
	group by substring(Cont_creditor,5,9), tip_document, numar_document, data
union all
select substring(cont_corespondent,5,9), 'IN', numar, data, 0, 
		sum(suma) suma, max(explicatii) explicatii, 'V', 0, 0, 0
		--,'', 0, 0
from pozplin 
where @q_tip_gestiune='V' and subunitate=@q_sub and data between @incLuna and @q_datasus and cont_corespondent like @analitic707 
	and exists(select 1 from gestiuni where subunitate=@q_sub and tip_gestiune='V' and substring(cont_corespondent,5,9)=cod_gestiune)
	and plata_incasare<>'ID'
	and (@fltGstUt=0 or exists(select 1 from @GestUtiliz pr where Cont_corespondent like pr.analitic707))
	group by substring(cont_corespondent,5,9), numar, data
union all
select substring(cont_cred,5,9), 'FB', numar_document, data, 0, 
		sum(suma) suma, max(explicatii) explicatii,'V', 0, 0, 0
		--,'', 0,  0
from pozadoc 
where @q_tip_gestiune='V' and subunitate=@q_sub and data between @incLuna and @q_datasus and cont_cred like @analitic707 
	and exists(select 1 from gestiuni where subunitate=@q_sub and tip_gestiune='V' and substring(cont_cred,5,9)=cod_gestiune)
	and (@fltGstUt=0 or exists(select 1 from @GestUtiliz pr where Cont_cred like pr.analitic707))
	group by substring(cont_cred,5,9), numar_document, data
union all
select (case when p.tip='AP' then p.gestiune else substring(cont_venituri,5,9) end), p.tip, numar, data, 0, 
	sum(round(convert(decimal(17,5), cantitate*p.pret_vanzare*(1+0)), 2)+TVA_deductibil) suma, max(n.denumire) explicatii,
	'V', 0, 0, 0	--,'', 0, 0
from pozdoc p left join nomencl n on p.cod=n.cod
where @q_tip_gestiune='V' and p.subunitate=@q_sub and p.data between @incLuna and @q_datasus and p.cont_venituri like @analitic707 
	and (p.tip='AP' and exists(select 1 from gestiuni where subunitate=@q_sub and tip_gestiune='V' and p.gestiune=cod_gestiune) 
		or p.tip='AS' and exists(select 1 from gestiuni where subunitate=@q_sub and tip_gestiune='V' and cod_gestiune=substring(cont_venituri,5,9)))
	and (@fltGstUt=0 or exists(select 1 from @GestUtiliz pr where Cont_venituri like pr.analitic707))
	group by (case when p.tip='AP' then p.gestiune else substring(p.cont_venituri,5,9) end), p.tip, p.numar, p.data
----------------------------- rulaj cantitative/amanunt (C sau A):
union all
select gestiune, tip as tip_document, numar as numar_document, data, 
sum(case when tip_miscare='I' then round(convert(decimal(17,5), cantitate*
		(case when @q_tip_gestiune in ('A','E') then pret_cu_amanuntul else Pret_de_stoc end)),2) else 0 end) as suma, 
sum(case when tip_miscare in ('E','V') then round(convert(decimal(17,5), cantitate*
		(case when @q_tip_gestiune in ('A','E') then pret_amanunt_predator else Pret_de_stoc end)),2) else 0 end) as sumaE, 
(case when tip='TI' then 'Gest. predatoare '+max(rtrim(p.Gestiune_primitoare)) else max(isnull(rtrim(t.denumire),'')) end) as explicatii, @q_tip_gestiune as tip, 
	sum(round(convert(decimal(17,5), cantitate*(case when @q_tip_gestiune in ('A','E') and pret_cu_amanuntul>0 then pret_cu_amanuntul when @q_tip_gestiune in ('A','E') then round(pret_vanzare*(1+cota_tva/100.00),2) else Pret_de_stoc end)),2)) as val_cu_amanuntul, 
	0 as Discount, 
	-- pozitiile valorice se aduna in "discpoz" si se vor evidentia in explicatii 
	sum(round(convert(decimal(17,5), cantitate*(case when @q_tip_gestiune in ('A','E') then pret_cu_amanuntul when @q_tip_gestiune in ('A','E') then round(pret_vanzare*(1+cota_tva/100.00),2) else Pret_de_stoc end)),2)*(case when tip_miscare='V' then -1 else 0 end)) as discpoz
from #pozdocRapGestiune p
left join terti t on p.Tert=t.Tert and p.Subunitate=t.Subunitate
where @q_tip_gestiune<>'V' and p.subunitate=@q_sub 
		and data between @incLuna and @q_datasus 
		and gestiune between @q_gestiune_jos and @q_gestiune_sus 
		and (tip_miscare in ('I','E','V') /*V pentru taxa verde*/ or left(cont_de_stoc,4)='4428') 
		and exists (select 1 from gestiuni where subunitate=@q_sub and (@q_tip_gestiune='E' and pret_am=1 or tip_gestiune=@q_tip_gestiune) and gestiune=cod_gestiune)
		and (@fltGstUt=0 or exists(select 1 from @GestUtiliz pr where pr.valoare=p.gestiune))
group by tip, gestiune, numar, data
union all -- AP/AC din gestiune tip C cu gestiune primitoare
select Gestiune_primitoare, tip as tip_document, numar as numar_document, data, 0 as suma, 
sum(round(convert(decimal(17,5), cantitate*pret_cu_amanuntul),2)) as sumaE, 
'' as explicatii, @q_tip_gestiune as tip, 
	sum(round(convert(decimal(17,5), cantitate*pret_cu_amanuntul),2)) as val_cu_amanuntul, 
round(sum(case when abs(p.discount)<=0.01 then 0 else p.Discount end),2) as Discount, 0
from #pozdocRapGestiune p
left join terti t on p.Tert=t.Tert and p.Subunitate=t.Subunitate
where @q_tip_gestiune in ('A','E') and p.subunitate=@q_sub 
		and (tip='AC' or tip='AP' and p.cantitate<0) 
		and data between @incLuna and @q_datasus 
		and gestiune_primitoare between @q_gestiune_jos and @q_gestiune_sus 
		and tip_miscare='E' 
		and exists (select 1 from gestiuni where subunitate=@q_sub and tip_gestiune='C' and gestiune=cod_gestiune)
		and exists (select 1 from gestiuni where subunitate=@q_sub and (@q_tip_gestiune='E' and pret_am=1 or tip_gestiune=@q_tip_gestiune) and Gestiune_primitoare=cod_gestiune)
		and (@fltGstUt=0 or exists (select 1 from @GestUtiliz pr where pr.valoare=p.Gestiune_primitoare))
	group by tip, Gestiune_primitoare, numar, data


/* corectez discounturi cu diferentele ce provin din rotunjiri in raport cu valoare intrare/iesire/discount */
update a set a.discount=a.discount+ti.suma-(a.sumaE+a.discount)
	from #rapg a
	inner join #rapg ti on ti.gestiune=a.gestiune and ti.numar_document=a.numar_document and ti.data=a.data and ti.Tip_document='TI' 
	where a.Tip_document in ('AC','AP')

---------------- procedura specifica 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'raportGestiuneSP') AND type in (N'P'))
	exec raportGestiuneSP @sesiune, @datajos, @datasus, @gestiunea, @tip_gestiune, @soldc,	@numairulaje 

---------------- grupez aici rulajul, pentru viteza mai mare in continuare:

select rtrim(r.gestiune) as gestiune, r.data, tip_document, numar_document, 
sum(suma) suma, sum(sumaE) sumaE,
0 rulaj, @q_tip_gestiune tip_gestiune,
(case when tip='A' and tip_document in ('AP','AC','AS') then 'Valoare v.'+rtrim(convert(char(15),convert(decimal(12,2),sum(val_cu_amanuntul))))+
		(case when Tip_document='AC' and abs((case when sum(discount)<>0 then sum(discount) else sum(val_cu_amanuntul)-sum(sumaE) end))>0.01 
				then ' disc. '+rtrim(convert(char(15),convert(decimal(12,2),(case when sum(discount)<>0 then sum(discount) else sum(sumaE+discpoz)-sum(val_cu_amanuntul) end))))
				else '' end)
		else max(explicatii) end) as explicatii, --coresp, 
		(case when 0=1 then '01/01/2999' else r.data end) as data_ord, sum(val_cu_amanuntul) val_cu_amanuntul, sum(discount) discount
into #rapg_grupat
from #rapg r
group by tip, r.gestiune, tip_document, numar_document, r.data--, coresp

--------------------- solduri initiale (din pozdoc de la ult. data inchisa pana ieri, din istoricstocuri pentru ult. data inchisa):

select dateadd(d,2,@q_data_inchisa) as data, rtrim(substring(cont, 5,20)) as gestiune, f.suma_debit as si, 0 as apare	
		--> campul apare determina care solduri initiale se transmit in raport (apare=1) si care sunt doar pentru calcul (apare=0)
	into #soldi from fRulajeConturi(1, '371.%', null, @incLuna, null, null,'1901-1-1', null) f
	where exists(
	select 1 from gestiuni g where g.Cod_gestiune=rtrim(substring(f.cont, 5,20)) and (g.Tip_gestiune='V' or @soldc=1)
				)

if (@soldc=0)
	if @q_tip_gestiune='E'
	begin
		/*Pentru sold INCEPUT PERIOADA*/
		declare @p xml
		select @p=(select dateadd(day,-1,@datajos) dDataSus, @gestiunea cGestiune, 1 GrCod, 1 GrGest, 1 GrCodi,'D' TipStoc for xml raw)

		if object_id('tempdb..#docstoc') is not null 
			drop table #docstoc
			
		create table #docstoc(subunitate varchar(9))
		exec pStocuri_tabela
		 
		exec pstoc @sesiune='', @parxml=@p

		delete from #preturiam
		insert into #preturiam(idpozdoc,cod,tip,gestiune)
		select 0,p.cod,'SI',p.gestiune
		from #docstoc p
		group by gestiune,cod

		declare @p1 xml
		set @p1=(select convert(char(10),dateadd(day,-1,@datajos),101) data for xml raw) 
		exec wIaPreturiAmanunt @sesiune,@p1

		update p set pret_cu_amanuntul=pa.pret_amanunt,
			tva_neexigibil=pa.cota_tva
		from #docstoc p
		inner join #preturiam pa on pa.cod=p.cod and pa.gestiune=p.gestiune

		insert into #soldi(data,gestiune,si, apare)
		select dateadd(day,-1,@datajos),gestiune,isnull(sum(stoc*pret_cu_amanuntul),0),0
			from #docstoc 
		group by gestiune


		/*Pentru FINAL DE PERIOADA*/
		select @p=(select @datasus dDataSus, @gestiunea cGestiune, 1 GrCod, 1 GrGest, 1 GrCodi,'D' TipStoc for xml raw)
		delete from #docstoc
		exec pstoc @sesiune='', @parxml=@p	

		/*Evaluam stocul de final in pret cu amanuntul*/
		delete from #preturiam
		insert into #preturiam(idpozdoc,cod,tip,gestiune)
		select 0,p.cod,'SI',p.gestiune
		from #docstoc p
		group by gestiune,cod
			
		set @p1=(select convert(char(10),@datasus,101) data for xml raw) 
		exec wIaPreturiAmanunt @sesiune,@p1
		update p set pret_cu_amanuntul=pa.pret_amanunt,
			tva_neexigibil=pa.cota_tva
		from #docstoc p
		inner join #preturiam pa on pa.cod=p.cod and pa.gestiune=p.gestiune

		/*Verificam daca avem nevoie de modificari automate de pret*/
		select gestiune,isnull(sum(stoc*pret_cu_amanuntul),0) as sf
			into #soldf
			from #docstoc 
		group by gestiune

		/*
		select doc.gestiune,min(isnull(si.si,0)),sum(suma),sum(sumaE),sum(discount),min(isnull(sf.sf,0))
		from #rapg_grupat doc
		left join #soldi si on doc.gestiune=si.gestiune
		left join #soldf sf on doc.gestiune=sf.gestiune
		group by doc.gestiune
		having abs(min(isnull(si.si,0))+sum(suma)-sum(sumaE)-sum(discount)-min(isnull(sf.sf,0)))>1 --Nu bate Sold Initial+Intrari-Iesiri <> Sold Final (calculat). Trebuie data o modificare automata de preturi
		*/
		select doc.gestiune
		into #deTrimisLaModificarePret
		from #rapg_grupat doc
		left join #soldi si on doc.gestiune=si.gestiune
		left join #soldf sf on doc.gestiune=sf.gestiune
		group by doc.gestiune
		having abs(min(isnull(si.si,0))+sum(suma)-sum(sumaE)-sum(discount)-min(isnull(sf.sf,0)))>1 --Nu bate Sold Initial+Intrari-Iesiri <> Sold Final (calculat). Trebuie data o modificare automata de preturi

		if exists (select 1 from #deTrimisLaModificarePret)
		select top 1 @eroare='S-au gasit necorelatii pe gestiunea '+gestiune+'! Rulati operatia de modificare preturi!'
			,@nivelmesaj=0
			from #deTrimisLaModificarePret
	end	
else
begin
	insert into #soldi(data,gestiune,si, apare)
	select dateadd(d,1,@q_data_inchisa) as data, gestiune,sum(suma-sumae) as si, 0 as apare
	from
	(
	select gestiune,
		sum(case when tip_miscare='I' then round(convert(decimal(17,5), cantitate*(case when @q_tip_gestiune in ('A','E') then pret_cu_amanuntul else pret_de_stoc end)),2) else 0 end) as suma, 
		sum(case when tip_miscare='E' then round(convert(decimal(17,5), cantitate*(case when @q_tip_gestiune in ('A','E') then pret_amanunt_predator else pret_de_stoc end)),2) else 0 end) as sumaE
	from pozdoc p
	where subunitate=@q_sub and data between dateadd(d,1,@q_data_inchisa) and dateadd(d,-1,@incLuna) 
		and gestiune between @q_gestiune_jos and @q_gestiune_sus and (tip_miscare in ('I','E') or left(cont_de_stoc,4)='4428') 
		and exists (select cod_gestiune from gestiuni where subunitate=@q_sub and tip_gestiune=(case when @q_tip_gestiune in ('A','E') then 'A' else 'C' end)
					and cod_gestiune=gestiune)
		and (@fltGstUt=0 or exists(select 1 from @GestUtiliz pr where pr.valoare=p.Gestiune))
		/*and (:9=0 or :9=1 and TVA_neexigibil<>0 or :9=2 and TVA_neexigibil=0)*/
		group by gestiune
	union all
	select gestiune_primitoare, 
		sum(round(convert(decimal(17,5), cantitate*(case when @q_tip_gestiune in ('A','E') then pret_cu_amanuntul else pret_de_stoc end)),2)), 0
	from pozdoc p
	where subunitate=@q_sub and tip='TE' and data between dateadd(d,1,@q_data_inchisa) and dateadd(d,-1,@incLuna) 
		and gestiune_primitoare between @q_gestiune_jos and @q_gestiune_sus
		and exists (select 1 from gestiuni where subunitate=@q_sub and tip_gestiune=(case when @q_tip_gestiune='A' then 'A' else 'C' end)
				and cod_gestiune=gestiune_primitoare) 
		and (@fltGstUt=0 or exists(select 1 from @GestUtiliz pr where pr.valoare=p.Gestiune_primitoare))
		/*and (:9=0 or :9=1 and TVA_neexigibil<>0 or :9=2 and TVA_neexigibil=0)*/
		group by Gestiune_primitoare
	union all
	select cod_gestiune,
		sum(round(convert(decimal(17,5), stoc*(case when @q_tip_gestiune in ('A','E') then Pret_cu_amanuntul else pret end)),2)), 0
	from istoricstocuri i
	where subunitate=@q_sub and data_lunii=@q_data_inchisa 
		and cod_gestiune between @q_gestiune_jos and @q_gestiune_sus
		and exists(select 1 from gestiuni where subunitate=@q_sub and tip_gestiune=(case when @q_tip_gestiune='A' then 'A' else 'C' end)
			and i.cod_gestiune=gestiuni.cod_gestiune) and stoc <> 0 
		and (@fltGstUt=0 or exists(select 1 from @GestUtiliz pr where pr.valoare=i.Cod_gestiune))
		group by Cod_gestiune
	) x
	group by gestiune
end
	
select sum(r.suma-r.sumaE-r.discount) as suma, r.Data, r.gestiune
into #rapg_Fgrupat 
from #rapg_grupat r group by r.data, r.gestiune

insert into #rapg_Fgrupat
select 0,@datajos,si.gestiune
from #soldi si
	left join (select distinct gestiune from #rapg_Fgrupat) rg on si.gestiune=rg.gestiune
where rg.gestiune is null -- Nu exista date pe gestiunea respectiva in perioada
	
--------- inserez linie de sold final pe zi si gestiune, in functie de soldul initial al perioadei si rulajul precedent
insert into #soldi (data,Gestiune,si, apare)
select r.data,r.gestiune,isnull(max(s.si),0)+sum(rr.suma) as si, 1 as apare
from (select r.data,r.gestiune from #rapg_Fgrupat r group by r.data,r.gestiune) r 
	left join #soldi s on r.gestiune=s.Gestiune
	inner join #rapg_Fgrupat rr on r.gestiune=rr.gestiune and r.Data>=rr.Data 
group by r.data, r.gestiune
	
------------------------ select-ul final:
-- la suma_iesire am tratat diminuarea valorii cu valoarea discountului (compatibilitate in urma pentru AC-uri cu TE in pozdoc). Aceeasi idee si pentru AP.
select @q_sub subunitate, rtrim(x.gestiune)+space(9-len(x.gestiune)) as gestiune,
	--isnull(r.data,'1901-1-1') 
	r.data, tip_document, numar_document, 
	suma as suma_intrare, sumaE-(case when r.tip_document in ('AC','AP') and discount=0 and sumaE-val_cu_amanuntul<>0 then sumaE-val_cu_amanuntul else 0 end) as suma_iesire,
	isnull(si.si,0) sold_final_zi, @q_tip_gestiune tip_gestiune,
	explicatii, --coresp, 
		(case when 0=1 then '01/01/2999' else r.data end) as data_ord, 
	rtrim(g.Denumire_gestiune) Denumire_gestiune, (case when Tip_document in ('AC','AP') then (case when discount<>0 then discount else sumaE-val_cu_amanuntul end) else 0 end) as discount
	,@eroare mesaj, @nivelmesaj nivelmesaj 
from #rapg_grupat r
	full join #soldi si on r.gestiune=si.Gestiune and r.Data=si.data and apare=1
	left join gestiuni g on isnull(r.gestiune,si.gestiune)=g.Cod_gestiune
	cross apply (select isnull(r.gestiune,si.gestiune) as gestiune) x
where (abs(suma)+abs(sumae)>0 or si.si!=0) and (r.data is null and @numairulaje<>1 or r.data>=@q_datajos)
	and x.gestiune between @q_gestiune_jos and @q_gestiune_sus
	--and r.data is not null
order by x.gestiune, data_ord, numar_document, (case when tip_document in ('RM','TI') then 1 else 2 end) 

end try
begin catch
	if @nivelmesaj=1
		set @eroare='raportGestiune:'+char(13)+ERROR_MESSAGE()
end catch

------------------------ stergere tabele temporare
if object_id('tempdb..#soldi') is not null drop table #soldi
if object_id('tempdb..#rapg_Fgrupat') is not null drop table #rapg_Fgrupat
if object_id('tempdb..#rapg_grupat') is not null drop table #rapg_grupat
if object_id('tempdb..#rapg') is not null drop table #rapg
	
if len(@eroare)>0 and @nivelmesaj=1
begin
	select @eroare as mesaj, @nivelmesaj as nivelmesaj	--> ma asigur ca raportul primeste mesajul, ca daca e eroare grava nu ajunge pana la ultimul select
	raiserror(@eroare,16,1)
end
