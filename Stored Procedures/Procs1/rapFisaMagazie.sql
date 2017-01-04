--***
create procedure rapFisaMagazie (@sesiune varchar(50) = null,	-->	parametrul sesiune nu va avea efect pana ce nu-l vom trimite catre ftert
	@dDataJos datetime, @dDataSus datetime, @cCod varchar(20) = null,
	@cGestiune varchar(20) = null,
	@grupGestiuni varchar(20) = null,
	@cCodi varchar(20) = null,
	@cCont varchar(40) = null,
	@tip_pret varchar(1) = 0,		-->	0=stoc, 1=amanuntul, 2=pe tip gestiune, 3=vanzare
	@ordonare varchar(20) = 0,	--> @ordonare=1 ordonare alfabetica pe nume produs, =0 ordonare pe cod produs
	@grupare_pret int = 0,		--> 0=grupare pe cod intrare, 1=grupare pe pret, 2=grupare pe lot, 3=fara grupare
	@gr_cod varchar(20) = null
	/*
	,
	@TipStocuri varchar(20), @den varchar(20) = null, @gr_cod varchar(20) = null, 
	@tip_pret varchar(1)=0,	-->	0=stoc, 1=amanuntul, 2=pe tip gestiune, 3=vanzare
	@tiprap varchar(20), @ordonare varchar(20)=0,	--> @ordonare=1 ordonare alfabetica pe nume produs, =0 ordonare pe cod produs
	@grupare4 bit=0,							--> grupare pe pret (0=nu, 1=da)
	@comanda varchar(200)=null,
	@centralizare int=3,	--> 0=grupare1, 1=grupare2, 2=cod, 3=fara centralizare
	@grupare int=0,	-->	0=Gestiuni si grupe, 1=Gestiuni si conturi, 3=Conturi si gestiuni, 4=Gestiuni si locatii, 5=Grupe (si nimic)
			--> daca @tiprap='F' atunci @grupare=2 -> 7=Marci si lm,
			-->							@grupare=4 -> 8=lm si marci
	@categpret smallint=null,
	@locatie varchar(30)=null,
	@furnizor_nomenclator varchar(20)=null,
	@furnizor varchar(50)='',
	@locm varchar(50)='',	--> loc de munca folosinta
	@locmg varchar(200)=null,	--> loc de munca asociat gestiunii
	@lot varchar(200) = null	--> filtru lot
	*/
	)
as
set transaction isolation level read uncommitted
declare @eroare varchar(max)
select @eroare=''
begin try

	declare @q_dDataJos datetime, @q_dDataSus datetime,@q_cCod varchar(20), @q_cGestiune varchar(20), @q_cCodi varchar(20), @q_cCont varchar(40)
		,@q_tip_pret varchar(1), @q_gr_cod varchar(20)
	select @q_dDataJos=@dDataJos, @q_dDataSus=@dDataSus, @q_cCod=@cCod, @q_cGestiune=@cGestiune, @q_cCodi=@cCodi, @q_cCont=@cCont
		,@q_tip_pret=@tip_pret,
		@q_gr_cod=@gr_cod+'%'

	declare @parXML xml
	select @parXML=(select @sesiune as sesiune for xml raw)
	
	if isnull(@cGestiune, '') = ''
		raiserror('Fisa de magazie necesita filtrare pe o gestiune!', 16, 1)

	if object_id('tempdb.dbo.#stocuri') is not null drop table #stocuri
	if object_id('tempdb.dbo.#de_cumulatstoc') is not null drop table #de_cumulatstoc
	if object_id('tempdb.dbo.#docstoc') is not null drop table #docstoc
	if object_id('tempdb.dbo.#final') is not null drop table #final
		
	declare @p xml
	select @p =
	(
		select @q_dDataJos dDataJos, @q_dDataSus dDataSus, @q_cCod cCod, @q_cGestiune cGestiune, @q_cCodi cCodi,
			@q_gr_cod cGrupa, 'D' TipStoc, @q_cCont cCont, 0 Corelatii, @grupGestiuni grupGestiuni ,@sesiune sesiune
		for xml raw
	)

	if object_id('tempdb..#docstoc') is not null drop table #docstoc
		create table #docstoc(subunitate varchar(9))
		exec pStocuri_tabela
			 
	exec pstoc @sesiune='', @parxml=@p

	select r.subunitate, r.cont, r.cod, r.cod_intrare, r.gestiune,
		(case when data<@q_dDataJos then '' else r.tert end) as tert, 
		(case when data<@q_dDataJos then 'SI' else r.tip_document end) as tip_document,
		(case when data<@q_dDataJos then '' else r.numar_document end) as numar_document,
		(case when data<@q_dDataJos then @q_dDataJos else r.data end) as data,
									sum((case when in_out=1 then 1
									when (in_out=2 and data<@q_dDataJos) then 1
									when (in_out=3 and data<@q_dDataJos) then -1
									else 0 end)*r.cantitate) as stoci,
		sum((case when in_out=2 and data between @q_dDataJos and @q_dDataSus then r.cantitate else 0 end)) as intrari,
		sum((case when in_out=3 and r.data between @q_dDataJos and @q_dDataSus then cantitate else 0 end)) as iesiri,
		g.denumire_gestiune as DenGest, '' as loc_de_munca,
		convert(decimal(17,5), max(case when @q_tip_pret='0' or @q_tip_pret='2' and g.Tip_gestiune<>'A' then r.pret
				when @q_tip_pret='1' or @q_tip_pret='2' and g.Tip_gestiune='A' then r.pret_cu_amanuntul else 0 end)) as pretRaport,
		max(rtrim(r.comanda)) comanda, r.locatie, max(g.tip_gestiune) tip_gestiune,
		space(200) denumire_locatie, max(r.lot) as lot,
		max(rtrim(case when r.tip_document in ('TE','TI','DF','CM') then r.predator 
			when data < @q_dDataJos then 'Stoc initial' else r.tert end)) as predator,
		max(r.tip_miscare) AS tip_miscare
	into #stocuri
	from #docstoc r
	left outer join gestiuni g on r.subunitate=g.subunitate and r.gestiune=g.cod_gestiune
	group by r.subunitate,
		r.cont,r.cod,r.cod_intrare,r.gestiune,r.pret,r.pret_cu_amanuntul,
		(case when data<@q_dDataJos then 'SI' else r.tip_document end),
		(case when data<@q_dDataJos then '' else r.numar_document end),
		(case when data<@q_dDataJos then @q_dDataJos else r.data end),
		(case when data<@q_dDataJos then '' else r.tert end),
		g.denumire_gestiune, r.locatie
	having
		(
			abs(sum((case when in_out=1 then 1
			when (in_out=2 and data<@q_dDataJos) then 1
			when (in_out=3 and data<@q_dDataJos) then -1
			else 0 end)*r.cantitate))>0.0009
		or
			abs(sum((case when in_out=2 and data between @q_dDataJos and @q_dDataSus then r.cantitate else 0 end)))>0.0009
		or
			abs(sum((case when in_out=3 and r.data between @q_dDataJos and @q_dDataSus then cantitate else 0 end)))>0.0009
		)

	declare @parsp xml
	select @parsp = 
	(
		select @dDataJos dDataJos, @dDataSus dDataSus, @cCod cCod, @cGestiune cGestiune, @grupGestiuni grupGestiuni, @cCodi cCodi, @cCont cCont
		for xml raw
	)

	if exists (select 1 from sys.objects where name='rapFisaMagazie_completareSP')
		exec rapFisaMagazie_completareSP @sesiune=@sesiune, @parxml=@parsp

	select
		rtrim(r.cont) cont, rtrim(r.cod) cod, rtrim(cod_intrare) cod_intrare, rtrim(r.gestiune) gestiune
		,convert(decimal(17,5), r.pretRaport) as pret, tip_document
		,rtrim(numar_document) numar_document, data, stoci, intrari, iesiri, rtrim(DenGest) DenGest
		,rtrim(n.denumire)+' ('+rtrim(n.um)+')' as DenProd
		,n.um, rtrim(n.grupa) grupa, rtrim(gr.denumire) as nume_grupa
		,rtrim(c.denumire_cont) as nume_cont, rtrim(r.loc_de_munca) loc_de_munca
		,rtrim(p.nume) as den_marca, rtrim(l.denumire) as den_lm, 
		convert(float,0) as stocCumulat, convert(float,0) as valStocCumulat,
		rtrim(r.predator) as predator, rtrim(r.comanda) as comanda,
		--> camp ajutator pentru ordinea calculului cumulat stoc cu update si pentru ordonare
		isnull(rtrim(r.gestiune),'')+'|'+isnull(rtrim(case when @ordonare=1 then n.Denumire else r.cod end),'')+'|' as ordonareGrupare,
		(case when tip_document='SI' then 1 when intrari<>0 then 2 else 3 end) as ordineNivDoc
		,rtrim(case @grupare_pret when 2 then rtrim(r.lot) when 1 then rtrim(r.pretRaport) when 0 then rtrim(cod_intrare) else '' end) as grupare,
		r.tip_miscare, rtrim(r.lot) as lot
	into #de_cumulatstoc
	from #stocuri r
		left join nomencl n on n.cod=r.cod
		left join grupe gr on gr.grupa=n.grupa
		left join conturi c on c.cont=r.cont and c.Subunitate=r.subunitate
		left join personal p on r.gestiune = p.marca
		left join lm l on l.cod=r.loc_de_munca
		left join terti t on r.tert=t.tert and r.subunitate=t.Subunitate
	where (abs((select sum(stoci) from #stocuri si where si.cod_intrare=r.cod_intrare and si.cod=r.cod
				and si.gestiune=r.gestiune and si.tip_document='SI' and si.tip_document=r.tip_document))>0.001
			or r.data between @q_dDataJos and @q_dDataSus --and r.tip_document<>'SI'
		)
	order by r.gestiune,
			(case when @ordonare=1 then n.Denumire else r.cod end),
			--data, tip_miscare desc
			data, (case when stoci<>0 then 0 when intrari<>0 then 1 else 2 end)

	--> select final
	select --row_number() over (order by d.data, max(tip_miscare) desc, d.cod) as nrcrt,
		row_number() over (order by d.cod, d.data, (case when max(tip_document)='SI' then 0 when sum(stoci)<>0 then 1 when sum(intrari)<>0 then 2 else 3 end) ) as nrcrt,
		max(d.ordineNivDoc) ordineNivDoc, max(cont) cont, max(cod) cod, max(cod_intrare) cod_intrare,
		max(gestiune) gestiune, grupare, max(d.lot) as lot,
		convert(decimal(17,5), (case when sum(abs(d.stoci)+abs(d.intrari)+abs(d.iesiri))=0 then 0
			--else sum((abs(d.stoci)+abs(d.intrari)+abs(d.iesiri))*pret)/sum(abs(d.stoci)+abs(d.intrari)+abs(d.iesiri)) end)) pret
			else sum(((d.stoci)+(d.intrari)+(d.iesiri))*pret)/sum((d.stoci)+(d.intrari)+(d.iesiri)) end)) pret
		,tip_document, numar_document, data, convert(decimal(20,5), sum(stoci)) stoci, 
		convert(decimal(20,5), sum(intrari)) intrari, convert(decimal(20,5), sum(iesiri)) iesiri, max(DenGest) DenGest, max(DenProd) DenProd, max(um) um,
		max(d.grupa) grupa, max(nume_grupa) nume_grupa, max(nume_cont) nume_cont, max(predator) predator, max(d.den_marca) as den_marca, max(ordonareGrupare) AS ordonareGrupare,
		max(rtrim(coalesce(t.Denumire, g.Denumire_gestiune, pers.Nume, com.Descriere, d.predator))) as denpredator
	into #final
	from #de_cumulatstoc d
	left join terti t on t.Tert = d.predator and d.tip_document IN ('RM', 'RS', 'AP', 'AS')
	left join gestiuni g on g.Cod_gestiune = d.predator and (d.tip_miscare = 'E' OR d.tip_miscare = 'I' AND d.tip_document = 'TI')
	left join personal pers on pers.Marca = d.predator and d.tip_document IN ('DF', 'PF')
	left join comenzi com ON com.Comanda = d.comanda and d.tip_document = 'CM'
	group by tip_document, numar_document, data, cod, gestiune, grupare
	--order by max(ordonareGrupare), data, max(tip_miscare) desc, tip_document
	order by max(ordonareGrupare), data, (case when max(tip_document)='SI' then 0 when sum(stoci)<>0 then 1 when sum(intrari)<>0 then 2 else 3 end)
	
	--> scriere stoc initial cu stocul rezultat de la documentul din urma (altfel, ramane SI)
	UPDATE d
	SET d.stoci = ISNULL(dp.stoci, d.stoci)
	FROM #final d
	OUTER APPLY (
		SELECT SUM(ISNULL(dp.stoci, 0)) + SUM(ISNULL(dp.intrari, 0) - ISNULL(dp.iesiri, 0)) AS stoci
		FROM #final dp
		WHERE dp.nrcrt < d.nrcrt AND d.cod = dp.cod AND dp.grupare = d.grupare
	) AS dp

	select * from #final
	order by ordonareGrupare, data, (case when tip_document='SI' then 0 when stoci<>0 then 1 when intrari<>0 then 2 else 3 end)

end try
begin catch
	select @eroare=error_message()+' (' + OBJECT_NAME(@@PROCID) + ')'
end catch

if object_id('tempdb.dbo.#stocuri') is not null drop table #stocuri
if object_id('tempdb.dbo.#de_cumulatstoc') is not null drop table #de_cumulatstoc
if object_id('tempdb.dbo.#docstoc') is not null drop table #docstoc
if object_id('tempdb.dbo.#final') is not null drop table #final

if len(@eroare) > 0
	select '<EROARE>' as gestiune, @eroare as DenGest
