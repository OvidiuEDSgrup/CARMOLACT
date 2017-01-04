--***
Create procedure rapStocVechimi
--> procedura raportului CG/Stocuri/Stocuri pe vechimi.rdl
	@sesiune varchar(50)=null,
	@dDataRef datetime, @cGestiune varchar(9),
	@cCod_range varchar(20), @cCont_range varchar(40),
	@i1 int=60, @i2 int=120, @i3 int=180, @i4 int=365, @ZileVechime int,
	@TipStoc char(1)='',	--> Depozit, Folosinta, Custodie
	@GRLocM char(1)='', 
	@grupa char(13)=null,
	@Grupare varchar(1)='G',	--> G=gestiune, C=cont, M= gestiune si loc de munca
	@tippret varchar(1)='s', --> s,t,v s=pret de stoc, t=f(tip gestiune), v=pret vanzare
	@categpret smallint=null,
	@locatie varchar(200)=null,
	@dupa_data_intrarii_in_firma bit=0,
	@grupGestiuni varchar(9)=null,
	@intervaleZile varchar(2000)='60,120,180,365',	--> parametru pentru versiunea matrix a raportului, inlocuieste anteriorii parametri @i[1..4]; separatorul este ','
	@tipsume varchar(1)='R',	--> A=Ambele, C=Doar cantitate, V=Doar valoare, R=flag raport vechi
	@grupari varchar(200)	='U,G,L,C'
		--> grupari noi - interschimbabile, pe 4 nivele (inclus detalii):
		/*	G	=	gestiune
			M	=	marca
			C	=	cont
			L	=	loc de munca
			N	=	cod de nomenclator
		' ', U	=	unitate
		*/
	,@lm varchar(200)=null
	,@top int=10000000	--> cate linii sa se returneze; il folosesc la depanare, la apelul din sql - daca e 0 se seteaza mai jos pe maxint
as
/*
Exemplu de rulare:
exec rapStocVechimi @dDataRef ='2013-12-31', @cGestiune= '88',
	@cCod_range='0000362', @cCont_range=null,
	@i1 =30, @i2 =60, @i3 =270, @i4= 365, @ZileVechime =0, @TipStoc ='', @GRLocM ='', @grupa =null,
	@Grupare ='G',	--> G=gestiune, C=cont, M= gestiune si loc de munca
	@tippret ='s', --> s,t,v s=pret de stoc, t=f(tip gestiune), v=pret vanzare
	@categpret =null,
	@locatie =null,
	@dupa_data_intrarii_in_firma=1
*/
	set transaction isolation level read uncommitted

if object_ID('tempdb..#stocvech') is not null drop table #stocvech
if object_ID('tempdb..#stocuri') is not null drop table #stocuri
if object_id('tempdb.dbo.#preturi') is not null drop table #preturi
if object_id('tempdb..#intervale') is not null drop table #intervale

declare @eroare varchar(4000)
select @eroare=''
begin try
	declare @cSub varchar(9)
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @cSub output
	select @cSub=rtrim(@cSub)

	select @cCont_range=rtrim(@cCont_range)+'%'
	declare @nStoc1 float, @nStoc2 float, @nStoc3 float, @nStoc4 float, @nStoc5 float, 
			@nVal1 float, @nVal2 float, @nVal3 float, @nVal4 float, @nVal5 float, 
			@cTip_gest char(1), @cGest char(9), @cCod char(20), @cDen char(80), @cLm varchar(20), @cont varchar(40), @dData datetime, @nPret float, @nStoc float, 
			@gTip_gest char(1), @gGest char(9), @gCod char(20), @gDen char(80), @gLm varchar(20), @gCont varchar(40)
			,@grupare1 varchar(2), @grupare2 varchar(2), @grupare3 varchar(2), @grupare4 varchar(2)

	--> Raportul are compatibilitate cu ASiSplus dar a fost tratata direct in fisierul .rdl deoarece oricum trebuie avut grija si de partea grafica in functie de acest aspect

	--> identificarea gruparilor; mai este de lucru aici
	select @grupare1=substring(@grupari,1,1)
		,@grupare2=substring(@grupari,3,1)
		,@grupare3=substring(@grupari,5,1)
		,@grupare4=substring(@grupari,7,1)
	--> crearea tabelei de intervale; fac aici astfel incat daca apar erori sa se opreasca procedura inainte de a apela inutil pstoc
		--> setarea intervalelor:
		declare @maxinterval int
		select @maxinterval=datediff(d,'1910-1-1',isnull(@dDataRef,getdate()))
		select @intervaleZile=',1,'+@intervaleZile+','+convert(varchar(20),@maxinterval)+','
		
		create table #intervale(nrcrt int, start int, stop int, interval varchar(8000), datastart datetime, datastop datetime, denInterval varchar(2000))
		
		--> generez lista de intervale:
		exec listaIntervaledinSir @intervale=@intervalezile
		
		--> pt ca e vorba de vechimi trebuie inversata ordinea intervalelor:
		update #intervale set start=stop, stop=start
	-----------------
	declare @comanda_str varchar(max)	--> cu sql dinamic pe unde e benefic

	if @cCod_range='' set @cCod_range=null
	if @cGestiune='' set @cGestiune=null
	if @Grupa='' set @grupa=null
	if @grupGestiuni is not null  set @grupGestiuni=rtrim(@grupGestiuni)+'%'
		/**	se iau datele din stocuri si se trec printr-un cursor pentru impartirea stocurilor in functie de intervalele cerute: */

	declare @p xml
	select @p=(select @dDataRef dDataSus, @cCod_range cCod, @cGestiune cGestiune, @cCont_range ccont
			,@lm+'%' lm, 1 GrCod, 1 GrGest, 1 GrCodi, @TipStoc TipStoc, @locatie Locatie, @grupGestiuni grupgestiuni, @grupa cgrupa for xml raw)

	if object_id('tempdb..#docstoc') is not null drop table #docstoc
		create table #docstoc(subunitate varchar(9))
		exec pStocuri_tabela
	if @dDataRef is not null
		exec pstoc @sesiune='', @parxml=@p
	else if isnull(@TipStoc,'') in ('','D')
	begin
		set @dDataRef=convert(varchar(20),getdate(),102)
		insert into #docstoc(subunitate, gestiune, cont, cod, data, data_stoc, cod_intrare, pret,
			tip_document, numar_document, cantitate, cantitate_UM2, tip_miscare, in_out, 
			predator, jurnal, tert, serie, pret_cu_amanuntul, tip_gestiune, locatie, 
			data_expirarii, TVA_neexigibil, pret_vanzare, accize_cump, loc_de_munca, comanda, 
			[contract], furnizor, lot, numar_pozitie, cont_corespondent, schimb, idIntrareFirma, idIntrare, stoc)
		select '1', s.cod_gestiune gestiune, s.cont cont, s.cod, s.data, '1901-1-1', '', s.pret,
				'', '', 0,0,'', 0,
				'', '', '', '', s.pret_cu_amanuntul, s.tip_gestiune, '',
				'1901-1-1', 0, 0, 0, s.loc_de_munca as loc_de_munca, '',
				'', '', '', '', '', '', isnull(idIntrareFirma,0) idIntrareFirma, 0, s.stoc stoc
		from stocuri s 
		inner join nomencl n on n.cod=s.cod 
		where s.subunitate = @cSub
		--and datediff(d,s.data,@dDataRef) >= isnull(@ZileVechime, 0)
		and (isnull(@cGestiune, '') = '' or s.cod_gestiune like @cGestiune) 
		and (isnull(@grupGestiuni, '') = '' or s.cod_gestiune like @grupGestiuni)
		and (isnull(@cCod_range, '') = '' or s.cod like @cCod_range) 
		and (isnull(@cCont_range, '') = '' or s.cont like rtrim(@cCont_range)+'%') 
		and (isnull(@locatie, '') = '' or s.Locatie = @locatie) 
		and (isnull(@grupa, '') = '' or n.Grupa like @grupa) 
		and (isnull(@lm, '') = '' or s.loc_de_munca like @lm+'%')
		and (abs(s.stoc)>0.0001)
	end
	delete d from #docstoc d where abs(convert(decimal(12,3),stoc))<=0.0001	-- sa ramina doar pozitiile cu stoc
	/*	if @grupGestiuni is not null
			delete d from #docstoc d where d.gestiune not like @grupGestiuni*/
	update s set
		pret=(case when s.tip_gestiune='A' then s.pret_cu_amanuntul else s.pret end)
		,loc_de_munca=isnull(s.loc_de_munca,'')
	from #docstoc s
	
	select s.tip_gestiune, s.gestiune, s.cod, s.loc_de_munca as loc_de_munca, s.data, 
		s.pret, sum(s.stoc) stoc, max(s.cont) cont, max(isnull(idIntrareFirma,0)) idIntrareFirma
		, 500 idInterval, convert(varchar(300),'') denInterval
		, convert(varchar(200),'') grupare1, convert(varchar(200),'') grupare2, convert(varchar(200),'') grupare3, convert(varchar(200),'') grupare4	--> aceste campuri sint pentru grupari; se completeaza mai jos
		, convert(varchar(2000),'') dengrupare1, convert(varchar(2000),'') dengrupare2, convert(varchar(2000),'') dengrupare3, convert(varchar(2000),'') dengrupare4
	into #stocuri
	--from dbo.fStocuriCen(@dDataRef, @cCod_range, @cGestiune, null, 1, 1, 1, @TipStoc, '', '', @locatie, '', '', '', '', '') s
	from #docstoc s
	group by s.tip_gestiune, s.gestiune, s.cod, s.loc_de_munca, s.cont, s.data, s.pret, (case when @dupa_data_intrarii_in_firma=1 then isnull(idIntrareFirma,0) else 0 end)
	order by s.tip_gestiune, s.gestiune, s.cod, s.loc_de_munca

	select @comanda_str=''
	if @dupa_data_intrarii_in_firma=1
		select @comanda_str='
		update s set data=p.data
		from #stocuri s inner join pozdoc p on s.idIntrareFirma=p.idpozdoc
		'
	exec(@comanda_str)

	--> setez datele in intervale; cam aici ar trebui modificat daca se vor adauga si alte tipuri de intervale (luni, saptamani, ...)
			--> ma asigur ca nu ies din limitele calendaristice ale sql server:
			update st set
				start=(case when @maxinterval<start then @maxinterval else start end)
				,stop=(case when @maxinterval<stop then @maxinterval else stop end)
			from #intervale st
			
			--> stabilesc datele si denumirea intervalelor:
			update st set
				datastart=@dDataRef-start,
				datastop=@dDataRef-stop,
				denInterval=(case when st.start=@maxinterval then 'Peste '+convert(varchar(20),st.stop)+' zile'
											when st.stop=1 then 'Sub '+convert(varchar(20),st.start)+' zile'
								else 'Intre '+convert(varchar(20),st.stop)+' si '+convert(varchar(20),st.start)+' zile' end) --> setez denumirile de intervale
			from #intervale st
		
		update s set idinterval=i.nrcrt, deninterval=i.deninterval from #stocuri s inner join #intervale i on s.data between i.datastart and i.datastop
		
	if @tippret<>'s'
	begin
		create table #preturi(cod varchar(20),nestlevel int)
		
		insert into #preturi
		select cod,@@NESTLEVEL
		from #stocuri
		group by cod

		exec CreazaDiezPreturi
		declare @px xml
		select @px=(select @categPret as categoriePret,@dData as data,@cGestiune as gestiune for xml raw)
		exec wIaPreturi @sesiune=null,@parXML=@px
		
		if @tippret='v'	--> pret vanzare
			update s set	pret=isnull(pr.pret_vanzare,0)
			from #stocuri s 
				inner join #preturi pr on pr.cod=s.cod
		
		if @tippret='t'	--> pe tip gestiune
			update s set pret=isnull(pr.pret_amanunt,0)
			from #stocuri s 
				inner join #preturi pr on pr.cod=s.cod and s.tip_gestiune='A'
	end
	
	-->
	declare @comanda_grupare varchar(8000)	-->regulile de grupare sunt aceleasi pentru toate 4 gruparile, asa ca scriu o data si apoi inlocuiesc:
	select @comanda_grupare='
	declare @{grupare} varchar(200)
	select @{grupare}=''{valgrupare}''
	
	if @{grupare} not in ('''',''U'')
	update #stocuri set {grupare}=rtrim(case @{grupare}
									when ''G'' then gestiune
									when ''M'' then gestiune
									when ''C'' then cont
									when ''L'' then loc_de_munca
									when ''N'' then cod
									else '''' end)
	
	if @{grupare}=''G''
	update s set den{grupare}=rtrim(g.denumire_gestiune)
		from #stocuri s inner join gestiuni g on s.{grupare}=g.cod_gestiune
	
	if @{grupare}=''M''
	update s set den{grupare}=rtrim(p.nume)
		from #stocuri s inner join personal p on s.{grupare}=p.marca

	if @{grupare}=''C''
	update s set den{grupare}=rtrim(c.denumire_cont)
		from #stocuri s inner join conturi c on s.{grupare}=c.cont
	
	if @{grupare}=''L''
	update s set den{grupare}=rtrim(l.denumire)
		from #stocuri s inner join lm l on s.{grupare}=l.cod
	
	if @{grupare}=''N''
	update s set den{grupare}=rtrim(n.denumire)
		from #stocuri s inner join nomencl n on s.{grupare}=n.cod
	'
	select @comanda_str=
		replace(replace(@comanda_grupare,'{valgrupare}',@grupare1),'{grupare}','grupare1')
		+replace(replace(@comanda_grupare,'{valgrupare}',@grupare2),'{grupare}','grupare2')
		+replace(replace(@comanda_grupare,'{valgrupare}',@grupare3),'{grupare}','grupare3')
		+replace(replace(@comanda_grupare,'{valgrupare}',@grupare4),'{grupare}','grupare4')
	exec (@comanda_str)
	
	--if @tipsume<>'R'
	begin
		--select * from #stocuri
--		select * from #intervale
--		select sum(s.stoc) cantitate, sum(s.stoc*s.pret) valoare, idinterval, max(s.deninterval) from #stocuri s group by idinterval
		--select @comanda_str for xml path('')
--	/*	
	select top (@top) * from(
		select 0 idInterval, grupare1, grupare2, grupare3, grupare4
			, 'Cod grupare' denInterval
			, max(dengrupare1) dengrupare1, max(dengrupare2) dengrupare2, max(dengrupare3) dengrupare3, max(dengrupare4) dengrupare4
			, 0 as valoare
			, 'D' as tip, '' dentip
			from #stocuri
			group by /*idinterval, */grupare1, grupare2, grupare3, grupare4
		union all	--*/
		select idInterval, grupare1, grupare2, grupare3, grupare4
			, max(denInterval) denInterval
			, max(dengrupare1) dengrupare1, max(dengrupare2) dengrupare2, max(dengrupare3) dengrupare3, max(dengrupare4) dengrupare4
			, sum(stoc) as valoare
			, 'C' as tip, 'Cantitate' dentip
			from #stocuri where @tipsume in ('A','C')
			group by idinterval, grupare1, grupare2, grupare3, grupare4
		union all
		select idInterval, grupare1, grupare2, grupare3, grupare4
			, max(denInterval) denInterval
			, max(dengrupare1) dengrupare1, max(dengrupare2) dengrupare2, max(dengrupare3) dengrupare3, max(dengrupare4) dengrupare4
			, sum(pret*stoc) as valoare
			, 'V' as tip, 'Valoare' dentip
			from #stocuri where @tipsume in ('A','V')
			group by idinterval, grupare1, grupare2, grupare3, grupare4
		union all	--> iau coloanele de totaluri:
		select 1000 idInterval, grupare1, grupare2, grupare3, grupare4
			, 'Total' denInterval
			, max(dengrupare1) dengrupare1, max(dengrupare2) dengrupare2, max(dengrupare3) dengrupare3, max(dengrupare4) dengrupare4
			, sum(stoc) as valoare
			, 'C' tip, 'Cantitate' dentip
			from #stocuri where @tipsume in ('A','C')
			group by grupare1, grupare2, grupare3, grupare4
		union all	--> iau coloanele de totaluri:
		select 1000 idInterval, grupare1, grupare2, grupare3, grupare4
			, 'Total' denInterval
			, max(dengrupare1) dengrupare1, max(dengrupare2) dengrupare2, max(dengrupare3) dengrupare3, max(dengrupare4) dengrupare4
			, sum(pret*stoc) as valoare
			, 'V' tip, 'Valoare' dentip
			from #stocuri where @tipsume in ('A','V')
			group by grupare1, grupare2, grupare3, grupare4
	) x
	order by grupare1, grupare2, grupare3, grupare4
		return
	end
end try
begin catch
	set @eroare=ERROR_MESSAGE() + char(10)+' (' + OBJECT_NAME(@@PROCID) + ')'
end catch

if object_ID('tempdb..#stocvech') is not null drop table #stocvech
if object_ID('tempdb..#stocuri') is not null drop table #stocuri
if object_id('tempdb.dbo.#preturi') is not null drop table #preturi
if object_id('tempdb..#intervale') is not null drop table #intervale
if len(@eroare)>0 
	select '<EROARE>' as gestiune ,@eroare as cont
		,'<EROARE>' as grupare1 ,@eroare as dengrupare1
