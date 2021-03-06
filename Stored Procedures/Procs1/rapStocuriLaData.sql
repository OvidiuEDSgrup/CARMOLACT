﻿create procedure rapStocuriLaData
/**	Procedura folosita la rapoartele CG\Stocuri:
		- Stocuri pe gestiuni
		- Stocuri detaliat
		- Stocuri in folosinta
		- Stocuri in custodie
*/
	(@dData datetime
		,@tipstoc varchar(1)	-->	D=Depozit, F=Folosinta, C=Custodie
		,@gruppret bit			--> Grupare pe pret:	1=Da, 0=Nu
		,@ordonare varchar(1)='c'	--> c=Cod (nomenclator), d=Denumire (nomenclator)
		,@tippret varchar(1)='s'	--> s,t,v s=pret de stoc, t=f(tip gestiune), v=pret vanzare
		,@cont varchar(40)=null, @cCod varchar(40)=null,@cGestiune varchar(40)=null,@den varchar(200)=null
		,@nStocMin varchar(50)=null,@nStocMax varchar(50)=null,@gr_cod varchar(40)=null,@locatie varchar(40)=null
		,@lm varchar(40)=null	--> pt varianta in folosinta a raportului
		,@locmg varchar(200)=null	--> locul de munca al gestiunii
		,@comanda varchar(40)=null,@contract varchar(40)=null,@furnizor varchar(40)=null
		,@lot varchar(40)=null, @categPret smallint=null
		,@stoclimita bit=0			--> doar stocuri sub limita configurata in nomenclator: 1=Da, 0=Nu
		,@gGestiuni varchar(20)=null		--> grup de gestiuni
		,@grupa varchar(20)=null
		,@furnizor_nomenclator varchar(30)=null
		,@grupare int=100		/*	 pentru a trece in detalii "alternativa" gruparii;
									0=gestiuni, lm
									,1=conturi, lm
									,2=grupa nomenclator, pt folosinta: lm,gestiuni
									,3=lm
									,4=gestiuni
									,5=fara grupare superioara
									,6=comenzi
									,7=grupa nomenclator
								*/
				-->  @nivel1 si @nivel2: daca sunt pe default si @grupare nu e pe default vor fi setati in functie de @grupare
		,@nivel1 varchar(20)	='L'
		,@nivel2 varchar(20)	='M'	/*	U	= Unitate
									L	= Loc de munca
									M	= Marca
									CN	= Cont
									GR	= Grupa nomenclator
									CD	= Cod
									GE	= Gestiune
									CM	= Comanda
								*/
		,@centralizare varchar(20)	='3'	--> nivelul de centralizare:	nivel1, nivel2, cod, fara
		,@folosinta bit =0	--> e necesar pentru ca se suprapune valoare=2 a parametrului @grupare intre folosinta si restul;
						--> o solutie mai buna ar fi modificarea in raport folosinta dar ar trebui dupa aceea reintegrat cu asisplus.
		,@sesiune varchar(50)=null
		,@stocnegativ varchar(2) =null	--> sa se aduca doar stocurile negative: null=nu, CI = pe cod de intrare, CD = pe cod de nomenclator
		,@dataIntrareInFirma bit=0	--> daca sa se aduca data intrarii in firma in detalii
		)
as
/*	--	apel procedura pt teste:
	declare @cont nvarchar(4000),@tipstoc nvarchar(1),@dData datetime,@cCod nvarchar(4000)
		,@cGestiune nvarchar(4),@den nvarchar(4000),@nStocMin nvarchar(4000),@nStocMax nvarchar(4000)
		,@gr_cod nvarchar(4000),@locatie nvarchar(4000),@lm nvarchar(4000),@comanda nvarchar(4000)
		,@contract nvarchar(4000),@furnizor nvarchar(4000),@lot nvarchar(4000),@gruppret bit
		,@ordonare nvarchar(1), @gGestiuni varchar(20)
	select @cont=NULL,@tipstoc=N'D',@dData='2012-01-13 00:00:00',@cCod=NULL,@cGestiune=N'101M',
		@den=NULL,@nStocMin=NULL,@nStocMax=NULL,@gr_cod=NULL,@locatie=NULL,@lm=NULL,@comanda=NULL,
		@contract=NULL,@furnizor=NULL,@lot=NULL,@gruppret=0,@ordonare=N'c', @gGestiuni=null
		
	exec rapStocuriLaData @dData=@dData,@tipstoc=@tipstoc,@gruppret=@gruppret,@ordonare=@ordonare
		,@cont=@cont,@cCod=@cCod,@cGestiune=@cGestiune,@den=@den
		,@nStocMin=@nStocMin,@nStocMax=@nStocMax,@gr_cod=@gr_cod,@locatie=@locatie
		,@lm=@lm,@comanda=@comanda,@contract=@contract,@furnizor=@furnizor,@lot=@lot
--*/
set transaction isolation level read uncommitted
declare @eroare varchar(500)
begin try
	if object_id('tempdb..#preturi') is not null drop table #preturi
	if object_id('tempdb..#stocuri') is not null drop table #stocuri
	if object_id('tempdb..#final') is not null drop table #final
	
	--> compatibilitate in urma pt regulile de grupare:
		--> deocamdata @nivel1 si @nivel2 sunt doar pe folosinta, valorile default fiind loc de munca si marca; daca sunt modificate inseamna ca sunt folosite deci grupare nu e folosit
	if /*@folosinta=1 and */	@nivel1='L' and @nivel2 in ('M','GE') and @grupare<>100
		select	@nivel1=(case	when @grupare=0 then 'M'
								when @grupare=1 then 'CN'
								when @grupare=2 and @folosinta=1 or @grupare=100 then 'L'
								when @grupare=2 and @folosinta=0 then 'GR'
								when @grupare=6 and @folosinta=0 then 'CM'
								else 'U' end)
				,@nivel2=(case	when @centralizare=1 then 'U'
								when @grupare=0 or @grupare=1 or @grupare=3 then 'L'
								when @grupare=7 then 'GR'
								else 'M' end)
	declare @comanda_str varchar(max)	
	declare @q_cont varchar(20) 
	set @q_cont=ISNULL(@cont,'')
	if (@tippret not in ('s','t') and @cGestiune is null and @categPret is null)
		raiserror('Pentru tip pret diferit de pret de stoc alegeti o categorie de pret!',16,1)
	
	select @grupa=@grupa+(case when isnull((select val_logica from par where tip_parametru='GE' and parametru='GRUPANIV'),0)=0 then '' else '%' end)
		--> daca pentru grupele de nomenclator e activa setarea de grupe pe nivele se filtreaza cu 'like %'

		/**	Pregatire filtrare pe proprietati utilizatori*/
	declare @SFL int
	set @SFL=isnull((select max(convert(int, val_logica)) from par where tip_parametru='GE' and parametru='SUBGLMFOL'),0)
	declare @utilizator varchar(20), @fltGstUt int, @eLmUtiliz int
	select @utilizator=dbo.fIaUtilizator(@sesiune)
	declare @GestUtiliz table(valoare varchar(200), cod varchar(20))
	insert into @GestUtiliz (valoare,cod)
	select valoare, cod_proprietate from fPropUtiliz(null) where cod_proprietate='GESTIUNE' and valoare<>'' and @TipStoc<>'F'
	set	@fltGstUt=isnull((select count(1) from @GestUtiliz),0)
	declare @LmUtiliz table(valoare varchar(200), marca varchar(20))
	insert into @LmUtiliz(valoare, marca)
	select l.cod, p.marca
			from lmfiltrare l left join personal p 
				on l.utilizator=@utilizator and (@sfl=1 or rtrim(l.cod)=rtrim(p.loc_de_munca))
		where l.cod<>'' and @TipStoc='F'
			and l.utilizator=@utilizator
	set @eLmUtiliz=isnull((select max(1) from @LmUtiliz),0)

	create table #stocuri(subunitate varchar(20), cod varchar(20), gestiune varchar(20), cod_intrare varchar(20), pret float,
			tip_gestiune varchar(1), data datetime, stoc float, loc_de_munca varchar(20), cont varchar(20),pret_cu_amanuntul float,
			data_expirarii datetime, comanda varchar(100) default null, idIntrareFirma int, dataIntrarii varchar(20) default null)

	if @dData is null
	begin
		set @dData=convert(char(10),getdate(),101)
		insert into #stocuri(subunitate, cod, gestiune, cod_intrare, pret, tip_gestiune, data, stoc, loc_de_munca, cont,pret_cu_amanuntul, data_expirarii, comanda, idIntrareFirma, dataIntrarii)
		select subunitate, cod, rtrim(cod_gestiune), cod_intrare, pret, tip_gestiune, data, stoc, loc_de_munca, cont,pret_cu_amanuntul, data_expirarii, comanda, 0 idIntrareFirma, null
		from stocuri 
		where (@cCod is null or cod=@cCod) 
			and (@cGestiune is null or Cod_gestiune=@cGestiune)
			and (@tipstoc='D' and Tip_gestiune not in ('F','T') or @tipstoc=Tip_gestiune)
			and cont like RTRIM(@q_cont)+'%'
			and (@locatie is null or locatie=@locatie)
			and (@comanda is null or comanda=@comanda)
			and (@contract is null or contract=@contract)
			and (@furnizor is null or Furnizor=@furnizor)
			and (@fltGstUt=0 or exists(select 1from @GestUtiliz pr where pr.valoare=cod_gestiune))
			and (@locatie is null or locatie=@locatie)
			and (isnull(@lm,'')='' or @tipstoc='F' and @SFL=1 and rtrim(loc_de_munca) like rtrim(@lm)+'%' or @tipstoc='F' and @SFL=0 and exists (select 1 from personal where marca=stocuri.cod_gestiune and rtrim(loc_de_munca) like rtrim(@lm)+'%')) 
			and (@eLmUtiliz=0 or 
			exists(select 1from @LMUtiliz pr
				where rtrim(pr.valoare) like rtrim(loc_de_munca)+'%'
					and (@sfl=1 or rtrim(pr.marca)=rtrim(furnizor))))
		----, @lot
	end
	else
	begin
		declare @parXML xml
		select @parXML=(select --convert(varchar(20),@dDataJos,102) dDataJos, 
			convert(varchar(20),@dData,102) dDataJos,
			convert(varchar(20),@dData,102) dDataSus,
			@cCod cCod, @cGestiune cGestiune, 1 GrCod, 1 GrGest, 1 GrCodi, @TipStoc TipStoc, @q_cont cCont, 
				@grupa cGrupa, @locatie Locatie, @comanda Comanda, @contract Contract, @furnizor Furnizor, @lot Lot--, 1 cufStocuri
				,(case when @tipstoc='F' then @lm else @locmg end) lm, (case when @tipstoc<>'D' then null else @gGestiuni end) as grupGestiuni
				,@sesiune sesiune
		for xml raw)
				
		if object_id('tempdb..#docstoc') is not null drop table #docstoc
			create table #docstoc(subunitate varchar(9))
			exec pStocuri_tabela
		 
		exec pstoc @sesiune=@sesiune, @parxml=@parxml

		insert into #stocuri(subunitate, cod, gestiune, cod_intrare, pret, tip_gestiune, data, stoc, loc_de_munca, cont,pret_cu_amanuntul, data_expirarii, comanda, idIntrareFirma, dataIntrarii)
		select subunitate, cod, gestiune, cod_intrare, pret, tip_gestiune, data, stoc, loc_de_munca, cont, pret_cu_amanuntul, data_expirarii, comanda, idIntrareFirma, null
		--from dbo.fStocuriCen(@dData,@cCod,@cGestiune,NULL,1,1,1, @tipstoc, @q_cont, @grupa, @locatie, null, @comanda, @contract, @furnizor, @lot)
		from #docstoc 
		--where (@gGestiuni is null or gestiune like @gGestiuni+'%')
		
		if @dataIntrareInFirma=1
		update s set dataIntrarii=convert(varchar(20),p.data,103)
		from #stocuri s left join pozdoc p on s.idIntrareFirma=p.idpozdoc
	end
--test		select * from #docstoc where abs(stoc)>0
	create table #preturi(cod varchar(20),nestlevel int)
	
	insert into #preturi
	select s.cod, @@NESTLEVEL
	from #stocuri s
	group by s.cod

	exec CreazaDiezPreturi
	
	if (@tippret='V')
	begin
		declare @px xml
		select @px=(select @categPret as categoriePret,@dData as data,@cGestiune as gestiune for xml raw)
		exec wIaPreturi @sesiune=null,@parXML=@px
	end
	
	--Pentru gestiunile cu Evaluare
	if exists(select 1 from #stocuri d inner join gestiuni g on d.gestiune=g.cod_gestiune where g.pret_am=1)
	begin

		create table #preturiam(idpozdoc int,cod varchar(20),tip varchar(20),gestiune varchar(20))
		exec CreazaDiezPreturiAmanunt

		insert into #preturiam(idpozdoc,cod,tip,gestiune)
		select 0,p.cod,'SI',p.gestiune
		from #stocuri p
		group by gestiune,cod
		
				declare @p1 xml
		set @p1=(select convert(char(10),@dData,101) data for xml raw) 
		exec wIaPreturiAmanunt @sesiune,@p1
		
		update p set pret_cu_amanuntul=pa.pret_amanunt
		from #stocuri p
		inner join #preturiam pa on pa.cod=p.cod and pa.gestiune=p.gestiune
	end
	
	select convert(varchar(1000),'') grupare1, convert(varchar(1000),'') dengrupare1,
			convert(varchar(1000),'') grupare2, convert(varchar(1000),'') dengrupare2,
		@tipstoc tip_stoc, r.cod, max(n.denumire) as denprod, max(n.um) as um, 
		r.gestiune,
		--ltrim(rtrim(case @tipstoc when 'F' then max(p.nume) when 'T' then max(t.Denumire) else max(g.denumire_gestiune) end)) as dengest,
		max(ltrim(rtrim(case @tipstoc when 'F' then p.nume when 'T' then t.Denumire else g.denumire_gestiune end))) as dengest,
		max(r.cod_intrare) as cod_intrare, 
		(case @tippret when 's' then r.pret  --Pret de stoc
			when 'v' then max(pr.pret_amanunt) --Pret vanzare pe o categorie din wIaPreturi 
			else	--In functie de tipul gestiunii
				(case when max(r.tip_gestiune)='A' or isnull(g.pret_am,0)=1 then max(r.Pret_cu_amanuntul) else max(r.pret) end) 
		end) as pret,
		min(r.data) as data, sum(r.stoc) as stoc, max(r.loc_de_munca) as loc_de_munca,MAX(l.Denumire) as nume_lm,
		rtrim(r.cont) as cont, max(rtrim(c.Denumire_cont)) as Denumire_cont,
		min(isnull(sl.stoc_min,slstd.stoc_min)) as stocmin,
		max(n.grupa) grupa,
		convert(varchar(20),min(r.data),103)+
			isnull((case when @tipstoc='F' then ' -> '+convert(varchar(20),min((case when r.data_expirarii<'1902-1-1'
						then dateadd(month,isnull(n.detalii.value('(row/@duratafolosinta)[1]','int'),0),r.data) else r.data_expirarii end))
					,103)
				else '' end)+' - ','')
				+isnull(dataIntrarii+' - ','')
				+isnull(case when 'CN' in (@nivel1, @nivel2) then max(rtrim(r.gestiune)+'-'+
						rtrim((case when @tipstoc='F' then p.nume else g.denumire_gestiune end))
						)
					else rtrim(r.cont) end,'') as detalii,
		min(r.data_expirarii) data_expirarii,
		max(rtrim(gr.denumire)) denGrupa,
		rtrim(
			(case @nivel1	when 'CN' then max(r.cont)
							when 'L' then max(r.loc_de_munca)
							when 'GR' then max(n.grupa)
							when 'L' then max(r.loc_de_munca)
							when 'U' then ''
							when 'CM' then max(r.comanda)
							when 'CD' then rtrim(case when @ordonare='c' then max(r.cod) else max(n.denumire) end)
							else max(r.gestiune) end)
			)+'|'
			+(case @nivel2	when 'CN' then max(r.cont)
							when 'L' then max(r.loc_de_munca)
							when 'GR' then max(n.grupa)
							when 'L' then max(r.loc_de_munca)
							when 'U' then ''
							when 'CM' then max(r.comanda)
							when 'CD' then rtrim(case when @ordonare='c' then max(r.cod) else max(n.denumire) end)
							else max(r.gestiune) end
			)
			ord1,
		rtrim(case when @ordonare='c' then max(r.cod) else max(n.denumire) end) ord2,
		rtrim(case when @gruppret=0 then max(r.cod_intrare) else '' end) as ordCodIntrare,
		max(rtrim(n.um_1)) um_1,
		convert(decimal(15,2),sum(case when n.um_1='' or abs(coeficient_conversie_1)<0.001 then '' else r.stoc/n.coeficient_conversie_1 end)) cantitate_1,
		max(r.comanda) comanda,
		max(rtrim(n.um_2)) um_2,
		convert(decimal(15,2),sum(case when n.um_2='' or abs(coeficient_conversie_2)<0.001 then '' else r.stoc/n.coeficient_conversie_2 end)) cantitate_2
		,convert(decimal(20,3),0) as valoare
		,dataIntrarii
	into #final
	from #stocuri r
		left join #preturi pr on pr.Cod=r.cod
		left outer join nomencl n on r.cod=n.cod
		left join gestiuni g on r.subunitate=g.subunitate and r.gestiune=g.cod_gestiune
		left join lm l on rtrim(r.loc_de_munca)=rtrim(l.Cod) and @tipstoc='F'
		left join conturi c on c.Cont=r.cont
		left join stoclim sl on r.cod=sl.cod and sl.subunitate='1' and sl.tip_gestiune=g.tip_gestiune and sl.cod_gestiune=r.gestiune
		left join stoclim slstd on r.cod=slstd.cod and slstd.subunitate='1' and slstd.tip_gestiune='' and slstd.cod_gestiune=''
		left join grupe gr on gr.grupa=n.grupa
		left join personal p on r.gestiune=p.marca
		left join terti t on t.Subunitate='1' and t.Tert=r.gestiune
	where (isnull(n.denumire,'')='' or n.denumire like '%'+ isnull(@den,'')+'%')
		--and (@gGestiuni is null or r.gestiune like @gGestiuni+'%')
		and (@grupa is null or n.grupa like @grupa)
		and (@furnizor_nomenclator is null or @furnizor_nomenclator=n.furnizor)
	group by r.cod, r.gestiune, isnull(g.pret_am,0), (case when @gruppret=0 then r.cod_intrare else '' end),
		r.pret, l.cod, r.cont, dataIntrarii
	having 
		(@nStocMin is null or sum(r.stoc)>=@nStocMin) and 
		(@nStocMax is null or sum(r.stoc)<=@nStocMax) and 
		--(@stoclimita=0 or sum(r.stoc)<sum(isnull(sl.stoc_min,isnull(slstd.stoc_min,0)))) and 
		(isnull(@gr_cod,'')='' or r.cod like @gr_cod+'%') and abs(sum(r.stoc))>0.0009
	--order by (case when @ordonare='c' then r.cod else max(n.denumire) end), data
	
	update #final set valoare=stoc*pret
	
	if @stoclimita=1
	begin
		set @comanda_str='
		delete f from #final f inner join
			(select (case when sum(stoc)<min(stocmin) then 1 else 0 end) as sub_stoc, r.cod, r.gestiune
			from #final r group by r.cod, r.gestiune) r on f.cod=r.cod and f.gestiune=r.gestiune and sub_stoc=0'
		exec (@comanda_str)
	end
	
	if exists (select 1 from sys.objects o where name='rapStocuriLaData_detaliiSP')
		exec rapStocuriLaData_detaliiSP
		
	declare @p xml
	select @p=(select @tipstoc tipstoc, @dData dData for xml raw)
	if exists (select 1 from sys.objects o where name='rapStocuriLaDataSP')
		exec rapStocuriLaDataSP @sesiune=@sesiune, @parxml=@p
	
	/*
	0=gestiuni, lm
	,1=conturi, lm
	,2=grupa nomenclator, pt folosinta: lm,gestiuni
	,3=lm
	,4=gestiuni
	,5=fara grupare superioara
	,6=comenzi
	,7=grupa nomenclator
	*/
	
	if @folosinta=0
	begin
		update f set 
			grupare1=isnull(rtrim(case @nivel1 when 'U' then '' when 'GE' then gestiune when 'M' then gestiune when 'CN' then cont when 'GR' then grupa else '' end),''),
			dengrupare1=isnull(rtrim(case @nivel1 when 'U' then '' when 'GE' then dengest when 'M' then dengest when 'CN' then denumire_cont when 'GR' then dengrupa else '' end),'')
		from #final f
		
		if @nivel1='CM'	--> comanda
		update f set 
			grupare1=isnull(rtrim(f.comanda),''),
			dengrupare1=isnull(rtrim(c.descriere),'')
		from #final f left join comenzi c on f.comanda=c.comanda
	end
	
	if @folosinta=1
	begin
		update f set 
			grupare1=isnull(rtrim(case @nivel1 when 'U' then ''
					when 'GE' then gestiune
					when 'M' then gestiune
					when 'CD' then cod
					when 'GR' then grupa
					when 'CN' then cont
					when 'CM' then comanda
					when 'L' then loc_de_munca else '' end),''),
			dengrupare1=isnull(rtrim(case @nivel1 when 'U' then ''
					when 'GE' then dengest
					when 'M' then dengest
					when 'CD' then denprod
					when 'GR' then dengrupa
					when 'CN' then denumire_cont
					when 'CM' then comanda
					when 'L' then nume_lm else '' end),'')
		from #final f
		
		update f set 
			grupare2=isnull(rtrim(case @nivel2 when 'U' then '' when 'GE' then gestiune when 'M' then gestiune when 'GR' then grupa else loc_de_munca end),''),
			dengrupare2=isnull(rtrim(case @nivel2 when 'U' then '' when 'GE' then dengest when 'M' then dengest when 'GR' then dengrupa else nume_lm end),'')
		from #final f
	end
	
	--> aici tratam sa se vada doar stocurile negative pe anumite grupari - daca s-a cerut:
	if @stocnegativ is not null
	begin
		if @stocnegativ='CI'
		delete f from #final f
			inner join (select ff.cod_intrare from #final ff group by ff.cod_intrare having sum(ff.stoc)>=0) ff on f.cod_intrare=ff.cod_intrare
		
		if @stocnegativ='CD'
		delete f from #final f
			inner join (select ff.cod from #final ff group by ff.cod having sum(ff.stoc)>=0) ff on f.cod=ff.cod
		
	end
	if @centralizare<2
		update #final set cod='', denprod='', um=''
	
	if @centralizare<3
		update #final set pret=0, cod_intrare=0, detalii=''
	
	select grupare1, max(dengrupare1) dengrupare1, grupare2, max(dengrupare2) dengrupare2,
		max(r.cod) cod, max(r.denprod) denprod, max(r.um) um, max(r.gestiune) gestiune, max(dengest) as dengest,
		max(r.cod_intrare) cod_intrare, max(r.pret) pret, max(r.data) data, sum(r.stoc) stoc,
		max(r.loc_de_munca) loc_de_munca, max(r.nume_lm) nume_lm, max(r.cont) cont,
		max(r.Denumire_cont) Denumire_cont, max(r.stocmin) stocmin,
		max(rtrim(r.grupa)) grupa, max(denGrupa) denGrupa, max(r.detalii) detalii,
		max(data_expirarii) data_expirarii,
		max(um_1) um_1, sum(cantitate_1) cantitate_1, max(um_2) um_2, sum(cantitate_2) cantitate_2
		,sum(valoare) valoare
	from #final r
	group by grupare1, grupare2, cod, pret, cod_intrare, dataIntrarii
	order by max(ord1), max(ord2), max(ordCodIntrare), max(pret)
end try
begin catch
	set @eroare='rapStocuriLaData: '+ERROR_MESSAGE()
end catch

if object_id('tempdb..#preturi') is not null drop table #preturi
if object_id('tempdb..#stocuri') is not null drop table #stocuri
if object_id('tempdb..#final') is not null drop table #final
if len(@eroare)>0 raiserror(@eroare,16,1)
