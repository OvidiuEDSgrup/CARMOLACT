--***
create procedure yso_rapBalantaStocuri(@dDataJos datetime, @dDataSus datetime,@cCod varchar(20), @cGestiune varchar(20), @cCodi varchar(20), @cCont varchar(20),
	@TipStocuri varchar(20), @den varchar(20), @gr_cod varchar(20), 
	@tip_pret varchar(1)=0,	-->	0=stoc, 1=amanuntul, 2=pe tip gestiune
	@tiprap varchar(20), @ordArticole varchar(20)=0,	--> @ordArticole=1 ordonare alfabetica pe nume produs, =0 ordonare pe cod produs
	@grupare4 bit=0,							--> grupare pe pret (0=nu, 1=da)
	@comanda varchar(200)=null
	,@tipDoc varchar(200)=null)
as --*/
	/*	test
	declare @dDataJos datetime, @dDataSus datetime,@cCod varchar(20), @cGestiune varchar(20), @cCodi varchar(20), @cCont varchar(20),
		@TipStocuri varchar(20), @den varchar(20), @gr_cod varchar(20), @tip_pret varchar(1), @tiprap varchar(20), @comanda varchar(20), @tipdoc varchar(100)
		,@ordArticole int, @grupare4 bit
	select @dDataJos='2013-02-11', @dDataSus='2013-02-11',@cCod=null, @cGestiune='04', @cCodi=null, --@cCont='371', 
			@TipStocuri=''
		--@den='%', @gr_cod=null, 
		,@tip_pret='0', @comanda='', @tipdoc='TI', @ordArticole=0, @grupare4=0
		/*select * from tmpRefreshLuci where
	(@dDataJos='2008-1-1' and  @dDataSus='2009-10-1' and @cCod=null and  @cGestiune=null and  @cCodi=null and  @cCont=null and  @TipStocuri='M' and 
		@den='%' and  @gr_cod=null) or 1=1
		*/ -- select pentru refresh fields in Reporting, ca sa nu se incurce in tabela #stocuri
	--*/
set transaction isolation level read uncommitted
declare @q_dDataJos datetime, @q_dDataSus datetime,@q_cCod varchar(20), @q_cGestiune varchar(20), @q_cCodi varchar(20), @q_cCont varchar(20),
	@q_TipStocuri varchar(20), @q_den varchar(20), @q_gr_cod varchar(20), @q_tip_pret varchar(1), @q_tiprap varchar(1)
select @q_dDataJos=@dDataJos, @q_dDataSus=@dDataSus,@q_cCod=@cCod, @q_cGestiune=@cGestiune, @q_cCodi=@cCodi, @q_cCont=@cCont,
	@q_TipStocuri=@TipStocuri, @q_den=@den, @q_gr_cod=@gr_cod, @q_tip_pret=@tip_pret, @q_tiprap=@tiprap,
	@comanda=isnull(@comanda,'')

--select * from dbo.fStocuri(@q_dDataJos,@q_dDataSus,@q_cCod,@q_cGestiune,@q_cCodi,null,'',null,@q_cCont, 0,'','','','','') r
	if object_id('tempdb.dbo.#stocuri') is not null drop table #stocuri
	if object_id('tempdb.dbo.#de_cumulatstoc') is not null drop table #de_cumulatstoc

if OBJECT_ID('tempdb..#docstoc') is not null
	drop table #docstoc

if OBJECT_ID('tempdb..#docstocuri') is not null
	drop table #docstocuri

create table #docstocuri 
(
subunitate char(9), gestiune char(20), cont char(20), cod char(20), data datetime, data_stoc datetime, cod_intrare char(20), pret float, 
tip_document char(2), numar_document char(9), cantitate float, cantitate_UM2 float, tip_miscare char(1), in_out char(1), 
predator char(20), jurnal char(3), tert char(13),serie char(20), pret_cu_amanuntul float, tip_gestiune char(1), locatie char(30), 
data_expirarii datetime, TVA_neexigibil int, pret_vanzare float, accize_cump float, loc_de_munca char(9), comanda char(40), 
[contract] char(20), furnizor char(13), lot char(20), numar_pozitie int, cont_corespondent char(13), schimb int
)
if @q_dDataJos is not null or @q_dDataSus is not null
	insert #docstocuri
	exec yso_pStocuri @q_dDataJos,@q_dDataSus,@q_cCod,@q_cGestiune,@q_cCodi,@q_gr_cod,@q_tiprap,@q_cCont, 0, '', '', @comanda, '', '', ''

select r.subunitate, r.cont,r.cod,r.cod_intrare,r.gestiune,
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
	g.denumire_gestiune as DenGest,(case when @q_tiprap='F' then r.loc_de_munca else '' end) as loc_de_munca
	, max(r.predator) predator,
	max(case when @q_tip_pret='0' or @q_tip_pret='2' and g.Tip_gestiune<>'A' then r.pret
			when @q_tip_pret='1' or @q_tip_pret='2' and g.Tip_gestiune='A' then r.pret_cu_amanuntul else 0 end) as pretRaport,
	max(rtrim(r.comanda)) comanda
into #stocuri
from #docstocuri r
	left outer join gestiuni g on  r.subunitate=g.subunitate and r.gestiune=g.cod_gestiune
--left outer join nomencl n on n.cod=r.cod
where (@q_TipStocuri='' or @q_TipStocuri='M' and left(r.cont,3) not in ('345','354','371','357') 
	or @q_TipStocuri='P' and left(r.cont,3) in ('345','354') or @q_TipStocuri='A' and left(r.cont,3) in ('371','357'))
--	and  (isnull(@q_gr_cod,'')='' or n.Grupa like @q_gr_cod+'%')
group by r.subunitate,
	r.cont,r.cod,r.cod_intrare,r.gestiune,r.pret,r.pret_cu_amanuntul,
	(case when data<@q_dDataJos then 'SI' else r.tip_document end),
	(case when data<@q_dDataJos then '' else r.numar_document end),
	(case when data<@q_dDataJos then @q_dDataJos else r.data end),
	(case when data<@q_dDataJos then '' else r.tert end),
	g.denumire_gestiune,(case when @q_tiprap='F' then r.loc_de_munca else '' end)
having
	(
								sum((case when in_out=1 then 1
								when (in_out=2 and data<@q_dDataJos) then 1
								when (in_out=3 and data<@q_dDataJos) then -1
								else 0 end)*r.cantitate)<>0
	or
	 sum((case when in_out=2 and data between @q_dDataJos and @q_dDataSus then r.cantitate else 0 end))<>0
	or
	sum((case when in_out=3 and r.data between @q_dDataJos and @q_dDataSus then cantitate else 0 end))<>0
	)


select
	rtrim(r.cont) cont, rtrim(r.cod) cod, rtrim(cod_intrare) cod_intrare, rtrim(r.gestiune) gestiune
	,r.pretRaport as pret, tip_document
	,rtrim(numar_document) numar_document, data, stoci, intrari, iesiri, rtrim(DenGest) DenGest
	,rtrim(n.denumire)+' ('+rtrim(n.um)+')' as DenProd
	,n.um, rtrim(n.grupa) grupa, rtrim(gr.denumire) as nume_grupa
	,rtrim(c.denumire_cont) as nume_cont, rtrim(r.loc_de_munca) loc_de_munca
	,rtrim(p.nume) as den_marca, rtrim(l.denumire) as den_lm, 
	rtrim(case when r.tip_document in('TE','TI') then r.predator 
		when r.tip_document in('SI') then '' 
		else ISNULL(t.denumire,r.tert) end) predator,
	--row_number() over (partition by cod order by (case when @ordArticole=1 then n.Denumire else r.cod end),data) as nrrand,
	convert(float,0) as stocCumulat, convert(float,0) as valStocCumulat,
	rtrim(r.gestiune)+'|'+rtrim(case when @ordArticole=1 then n.Denumire else r.cod end)+'|'+
		rtrim(cod_intrare)+'|'+(case when @grupare4=0 then '' else convert(varchar(40),r.pretRaport) end)
	as ordonareGrupare,	--> camp ajutator pentru ordinea calculului cumulat stoc cu update
	(case when tip_document='SI' then 1 when intrari<>0 then 2 else 3 end) ordineNivDoc,
	r.comanda
	into #de_cumulatstoc
from #stocuri r
	left outer join nomencl n on n.cod=r.cod
	left join grupe gr on gr.grupa=n.grupa
	left join conturi c on c.cont=r.cont and c.Subunitate=r.subunitate
	left join personal p on r.gestiune = p.marca
	left join lm l on l.cod=r.loc_de_munca
	left outer join terti t on r.tert=t.tert and r.subunitate=t.Subunitate
where (isnull(n.denumire,'')='' or n.denumire like '%'+isnull(@q_den,'')+'%')
	and (0<>(select sum(stoci) from #stocuri si where si.cod_intrare=r.cod_intrare and si.cod=r.cod
			and si.gestiune=r.gestiune and si.tip_document='SI' and si.tip_document=r.tip_document)
		or r.data between @q_dDataJos and @q_dDataSus --and r.tip_document<>'SI'
	)
	and ('' in (@tipDoc) or r.tip_document in (@tipDoc))
order by r.gestiune,
		(case when @ordArticole=1 then n.Denumire else r.cod end),
		data, cod_intrare

-->	se calculeaza valori cumulate ale stocului in cadrul codurilor de intrare:
declare @stoc float, @valoare float, @grupare varchar(500)
select @stoc=0, @valoare=0, @grupare=''
update d set	@stoc=(case when @grupare=d.ordonareGrupare then @stoc else 0 end)+
						d.stoci+d.intrari-d.iesiri, stocCumulat=@stoc,
				@valoare=(case when @grupare=d.ordonareGrupare then @valoare else 0 end)+
						(d.stoci+d.intrari-d.iesiri)*d.pret, valStocCumulat=@valoare,
				@grupare=d.ordonareGrupare
	from #de_cumulatstoc d
	
select d.ordineNivDoc, cont, cod, cod_intrare, gestiune, pret, tip_document, numar_document, data, stoci, 
	intrari, iesiri, DenGest, DenProd, um, grupa, nume_grupa, nume_cont, loc_de_munca,
	den_marca, den_lm, predator, stocCumulat, valStocCumulat, comanda --,ordonareGrupare
from #de_cumulatstoc d order by d.cod, d.ordineNivDoc, d.data
	

if object_id('tempdb.dbo.#stocuri') is not null drop table #stocuri
if object_id('tempdb.dbo.#de_cumulatstoc') is not null drop table #de_cumulatstoc