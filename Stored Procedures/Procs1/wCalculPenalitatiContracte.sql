--***
create procedure wCalculPenalitatiContracte @sesiune varchar(50), @parXML xml 
as     
-- apelare procedura specifica daca aceasta exista.
if exists (select 1 from sysobjects where [type]='P' and [name]='wCalculPenalitatiContracteSP')
begin 
	declare @returnValue int -- variabila salveaza return value de la procedura specifica
	exec @returnValue = wCalculPenalitatiContracteSP @sesiune, @parXML output
	return @returnValue
end

declare @dataj datetime,@subunitate varchar(9), @utilizator char(10),@datas datetime,
		@tip varchar(2),@subtip varchar(2),@mesaj varchar(200),@DATAPEN datetime
begin try 		
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate output
	exec luare_date_par 'GE', 'DATAPEN', 0, 0, @DATAPEN output
	
	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@Utilizator OUTPUT
	if @utilizator is null
		return -1
		
	declare @data_ucc datetime,@cod varchar(20), @cont_fact_penaliz varchar(20), @comanda varchar(20), @cont_de_stoc varchar(20),
		@indbug varchar(20)	,@zileDepasite int,@tert varchar(13)	
	select 
		@datas=ISNULL(@parXML.value('(/row/@datas)[1]', 'datetime'), ''),
		@dataj=ISNULL(@parXML.value('(/row/@dataj)[1]', 'datetime'), ''),
		@cod=ISNULL(@parXML.value('(/row/@cod)[1]', 'varchar(20)'), ''),
		@tert=ISNULL(@parXML.value('(/row/@tert)[1]', 'varchar(13)'), ''),
		@cont_fact_penaliz=ISNULL(@parXML.value('(/row/@cont_fact_penaliz)[1]', 'varchar(20)'), ''),
		@cont_de_stoc=ISNULL(@parXML.value('(/row/@cont_de_stoc)[1]', 'varchar(20)'), ''),
		@indbug=ISNULL(@parXML.value('(/row/@indbug)[1]', 'varchar(20)'), ''),
		@zileDepasite=ISNULL(@parXML.value('(/row/@zileDepasite)[1]', 'int'), '')
		
		
	set @comanda=space(20)+@indbug	
	if ISNULL(@zileDepasite,0)=0
		set @zileDepasite=120
	
	declare @tipuri_facturare varchar(100),@tipuri_incasare varchar(100) 
	set @tipuri_facturare='AP' set @tipuri_incasare='IB,C3,CO,CB,BX'
	set @data_ucc=@dataj

	if exists (select 1 from penalizarifact where tip_penalizare='P') -- dataUCC
	set @data_ucc = (select max(data_penalizare) from penalizarifact where tip_penalizare='P')
	--set @data_ucc--la nivel de tert =@DATAPEN
	
	--preluare documente necesare din ftert
	select ft.* into #documente 
	from fTert('B',null,@datas,(case when ISNULL(@tert,'')='' then null else @tert end),null,null,null,null,0, null) ft 
		inner join infotert t on ft.tert = t.tert and ft.subunitate=t.subunitate
	where dateadd(day,@zileDepasite,ft.data_scadentei)>=isnull((select max(data_penalizare) from penalizarifact where tip_penalizare='P' and tert=ft.tert),@dataj)
		and t.Observatii not in ('X','P')--nu sunt terti exceptati de la calculul penalitatilor 
		and ft.subunitate=@subunitate 
		and charindex(left(ft.tip,2),@tipuri_incasare+','+@tipuri_facturare)<>0--(si incasari si facturi)
		and ft.cod<>@cod --nu se calculeaza penalitati la penalitati
		--and not exists (select * from penalizarifact where penalizarifact.tip_penalizare='P' and penalizarifact.tip_doc_incasare='NE'and ft.numar =penalizarifact.factura_penalizata and ft.tert=penalizarifact.tert) 
		and valoare>=0 and tva>=0
		
	
	-- incasari din fTert
	select d2.tert,d2.factura,d2.tip,isnull(d3.data_document,d2.data) data,d2.numar,sum(d2.achitat) as achitat 
	into #incasari 
	from #documente d2 
		left join (select tip, numar, data, data_document, cont, cont_corespondent, numar_pozitie from extpozplin) d3
			on d3.tip=d2.tip and d3.numar=d2.numar and d3.data=d2.data and d3.cont=d2.cont_coresp and d3.cont_corespondent=d2.cont_de_tert 
			and d3.numar_pozitie=d2.numar_pozitie 
	where charindex(left(d2.tip,2),@tipuri_incasare)<>0 --numai incasarile
		and datediff(day,(select max(data_scadentei) from #documente where tip='AP' and tert=d2.tert and factura=d2.factura),isnull(d3.data_document,d2.data))>30
			--diferenta dintre data scadentei si data incasarii este mai mare de 30 de zile 
		and datediff(day,(select max(data_scadentei) from #documente where tip='AP' and tert=d2.tert and factura=d2.factura),isnull(d3.data_document,d2.data))<=90
			 --diferenta dintre data scadentei si data incasarii este mai mica de 90 de zile
		and isnull(d3.data_document,d2.data)<=@datas--incasarea s-a facut inainte de data actualului calcul de penalitati 
		and isnull(d3.data_document,d2.data)>isnull((select max(data_penalizare) from penalizarifact where tip_penalizare='P' and tert=d2.tert),@dataj)--incasarea s-a facut dupa ultimul calcul de penalitati 
	group by d2.tert,d2.factura,d2.tip,isnull(d3.data_document,d2.data),d2.numar

	-- sold pe facturi din fTert
	select max(isnull(p.contract,'')) as contract, 'AP' as tip,d2.tert,d2.factura, round(sum(d2.valoare+d2.tva),2)-max(round(isnull(i.achitat,0),2)) as sold, 
		max(d2.data_scadentei) as data_scadentei, max(p.loc_de_munca) as loc_de_munca,max(p.grupa) as grupa,max(p.gestiune) as gestiune 
	into #sold 
	from #documente d2 
		left join pozdoc p on d2.subunitate = p.subunitate and d2.tip = p.tip and d2.numar = p.numar and d2.data = p.data and d2.numar_pozitie = p.numar_pozitie
		left join (select d.tert,d.factura,sum(d.achitat) as achitat
			from #documente d 
				left join (select tip, numar, data, data_document, cont, cont_corespondent, numar_pozitie from extpozplin) e
					on e.tip=d.tip and e.numar=d.numar and e.data=d.data and e.cont=d.cont_coresp and e.cont_corespondent=d.cont_de_tert 
						and e.numar_pozitie=d.numar_pozitie 
					where charindex(left(d.tip,2),@tipuri_incasare)<>0 --incasari
						and datediff(day,(select max(data_scadentei) from #documente where tip='AP' and tert=d.tert and factura=d.factura),isnull(e.data_document,d.data))<=90 --(de ce??)
					group by d.tert,d.factura) i --ce s-a achitat pe factura
			on i.tert=d2.tert and i.factura=d2.factura
	where isnull(p.stare,0) not in (4,6) 
		and charindex(d2.tip,@tipuri_facturare)<>0 --numai facturi
		and datediff(day,d2.data_scadentei,@datas)>90--au trecut peste 90 de zile de la data scadentei
		and datediff(day,d2.data_scadentei,isnull((select max(data_penalizare) from penalizarifact where tip_penalizare='P' and tert=d2.tert),@dataj))<=90
			--nu trecusera 90 de zile de la data scadentei pana la data ultimului calcul de penalitati
	group by d2.tert,d2.factura 
	having round(sum(d2.valoare+d2.tva),2)-max(round(isnull(i.achitat,0),2))>0 --soldul ramas pt calculul penalitatilor este mai mare de 0
	order by d2.tert,d2.factura

	--calculare penalizare la incasari
	select d2.tert,d2.factura,d2.tip,d2.data,d2.numar,d2.achitat as sold_pen,
		datediff(day,(select max(data_scadentei) from #documente where tip='AP' and tert=d2.tert and factura=d2.factura),d2.data) as zile_pen 
	into #date_pen 
	from #incasari d2 
	group by d2.tert,d2.factura,d2.tip,d2.data,d2.numar,d2.achitat

	--calculare penalizare la sold
	insert into #date_pen 
	select s.tert,s.factura,'NE' as tip,@datas,'', max(s.sold) as sold_pen,91/*???? datediff(day,d2.data_scadentei,@datas)*/ as zile_pen 
	from #sold s 
	group by s.tert,s.factura 
	order by s.tert,s.factura

	--luare date din contract 
	select 'AP' as tip,d.tert,d.factura,max(d.tip) tipd,left(max(d.numar),8) numar,d.data,max(d.sold_pen)sold_pen,max(d.zile_pen)zile_pen,
		max(d.sold_pen*(case when d.tip='NE' then 15/*???*/ else 5/*???*/ end)/100) as s_p 
	into #p 
	from #date_pen d 
	where sold_pen>0 and zile_pen>0 and d.sold_pen*(case when d.tip='NE' then 15 /*???*/ else 5/*???*/ end)/100>1 
		and not exists (select 1 from penalizarifact pf where pf.factura_penalizata=d.factura and pf.tert=d.tert and pf.data_doc_incasare>=d.data and left(pf.factura,2) in ('P#','SP')) 
	group by d.tert,d.factura,d.numar,d.data 
	order by d.tert,d.factura,d.numar,d.data

	-- completare penalizari:
	insert into penalizarifact(Tip, Tert, Factura, Factura_penalizata, Tip_doc_incasare, Nr_doc_incasare, Data_doc_incasare, Sold_penalizare, 
		Data_penalizare, Zile_penalizare, Suma_penalizare, Valuta_penalizare,tip_penalizare)
	select tip, tert, '' as factura, factura as factura_penalizata, tipd, numar, data, sold_pen, @datas as data_incasare, zile_pen, s_p,'' as valuta,'P'
	from #p d 
	where not exists (select 1 from penalizarifact pf where pf.factura_penalizata=d.factura and pf.tert=d.tert and pf.tip=d.tip 
		and d.tipd=pf.tip_doc_incasare and pf.nr_doc_incasare=d.numar and pf.data_doc_incasare>=d.data and left(pf.factura,2) in ('P#','SP'))

	-- numar de factura temporar:
	declare @off_pdiez int
	select @off_pdiez=max(replace(numar,'P#','')) from pozdoc where left(numar,2)='P#'
	set @off_pdiez=isnull(@off_pdiez,0)
	update penalizarifact set factura='P#'+convert(varchar(6),p.numar) 
		from (select p.tert,s.loc_de_munca,@off_pdiez+row_number() over (order by p.tert) as numar 
			from penalizarifact p 
				inner join pozdoc s on p.factura_penalizata=s.factura and p.tert=s.tert
			where p.factura='' 
			group by p.tert,s.loc_de_munca)p 
		where p.tert=penalizarifact.tert and penalizarifact.factura='' 
			and	exists (select 1 from pozdoc s where s.tert=p.tert and s.loc_de_munca=p.loc_de_munca and s.factura=penalizarifact.factura_penalizata and s.tert=penalizarifact.tert)

	-- completare pozdoc:
	insert into pozdoc (Subunitate, Tip, Numar, Cod, Data, Gestiune, Cantitate, Pret_valuta, Pret_de_stoc, Adaos,
		Pret_vanzare, Pret_cu_amanuntul, TVA_deductibil, Cota_TVA, Utilizator, Data_operarii, Ora_operarii, 
		Cod_intrare, Cont_de_stoc, Cont_corespondent, TVA_neexigibil, Pret_amanunt_predator,Tip_miscare,Locatie, 
		Data_expirarii, Numar_pozitie, Loc_de_munca, Comanda, Barcod, Cont_intermediar, Cont_venituri, Discount, Tert, Factura, 
		Gestiune_primitoare, Numar_DVI, Stare, Grupa, Cont_factura, Valuta, Curs, Data_facturii, Data_scadentei, Procent_vama,
		Suprataxe_vama, Accize_cumparare, Accize_datorate, Contract, Jurnal)
	select @subunitate,'AS', max(p.factura),
		@cod,@datas,max(s.cod_gestiune),1, sum(suma_penalizare), 0,0,sum(suma_penalizare),sum(suma_penalizare),0,0, 'ASiS', 
		convert(datetime, convert(char(10), getdate(), 104), 104),replace(convert(char(8),getdate(), 108), ':', ''),
		'APBK',@cont_de_stoc,@cont_fact_penaliz,0,0,'V','',@datas,1,--p.Factura_penalizata,
		s.loc_munca,@comanda,'Penalitati','',@cont_de_stoc,0,p.tert,max(p.factura),'','',5,' '--max(pd.grupa)
		,@cont_fact_penaliz,'',0,@datas,@datas,2,0,0,0,max(s.contractul),''
	from penalizarifact p 
		inner join doc s on p.factura_penalizata=s.factura and p.tert=s.cod_tert
	where p.data_penalizare=@datas  and left(p.factura,2)='P#' and not exists (select 1 from pozdoc  where left(numar,2)='P#')
	group by p.tert,s.loc_munca
--sp_help pozdoc

	drop table #date_pen 
	drop table #documente 
	drop table #incasari 
	drop table #sold 
	drop table #p	
end try
begin catch
	set @mesaj=ERROR_MESSAGE()
end catch

if LEN(@mesaj)>0
	raiserror(@mesaj, 11, 1)
--select * from pozcon