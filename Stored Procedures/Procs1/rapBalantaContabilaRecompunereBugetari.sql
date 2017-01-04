--***
create procedure rapBalantaContabilaRecompunereBugetari @parXML xml
as
begin try
	
	declare 
		@indicator varchar(100), @p_dData_sf_luna datetime, @conturiRecompuse int,
		@ContJos varchar(20), @cLM varchar(20), @direct bit

	SELECT
		@indicator=@parXML.value('(row/@indicator)[1]','varchar(100)'),
		@ContJos=@parXML.value('(row/@ContJos)[1]','varchar(20)'),
		@p_dData_sf_luna=@parXML.value('(row/@p_dData_sf_luna)[1]','datetime'),
		@conturiRecompuse=@parXML.value('(row/@conturiRecompuse)[1]','int'),
		@direct=@parXML.value('(row/@direct)[1]','bit'),
		@cLM=@parXML.value('(row/@lm)[1]','varchar(20)')
		
	IF OBJECT_ID('tempdb.dbo.#lmsurse') IS NOT NULL
		DROP TABLE #lmsurse

	create table #lmsurse (cod varchar(20), sursaf varchar(20), detalii xml)
	
	insert into #lmsurse (cod, sursaf)
	select 
		rtrim(cod), detalii.value('(row/@sursaf)[1]','varchar(20)')	
	from lm where NULLIF(detalii.value('(row/@sursaf)[1]','varchar(20)'),'') IS NOT NULL
	
	declare 
		@sector_cont_par varchar(2), @sursa_cont_par varchar(1)	-->	acesti 2 par se folosesc doar daca se merge pe specificul de conturi ultradetaliate
		
	/*	citire sector activitate si sursa de finantare din parametrii */
	select 
		@sector_cont_par=(case when Parametru='SECTORACT' then val_alfanumerica else @sector_cont_par end),
		@sursa_cont_par=(case when Parametru='SURSAF' then val_alfanumerica else @sursa_cont_par end)
	from par 
	where tip_parametru='GE' and parametru in ('SECTORACT','SURSAF')
	
	select 
		@sector_cont_par=isnull(@sector_cont_par,'01'), 
		@sursa_cont_par=isnull(@sursa_cont_par,'F'),
		@indicator=@indicator+'%'

	--> rulajele de pe conturi recompuse vor trebui propagate in sus pe balanta; ma folosesc de aceasta tabela pt asta:
	
	create table #conturiRecompuseTerti(
			cont varchar(100),			--> contul de propagat
			contSuperior varchar(100))	--> contul care se va completa cu suma din "cont"

	delete #conturi1 where len(cont)>7
	
	update #conturi1 set are_analitice=1 where len(cont)=7
	insert into #conturi1 (Subunitate, Cont, ContOriginal, Denumire_cont, Tip_cont, Cont_parinte,
				Are_analitice, Apare_in_balanta_sintetica, Sold_debit, Sold_credit, Nivel,
				Articol_de_calculatie, Logic)
	select '1', left(r.cont, 7)+@sector_cont_par+COALESCE(lm.sursaf,c.sursaf,@sursa_cont_par)+rtrim(r.indbug) as Cont,
			left(r.cont, 7)+@sector_cont_par+COALESCE(lm.sursaf,c.sursaf,@sursa_cont_par)+rtrim(r.indbug) as ContOriginal,
			max(rtrim(isnull(i.denumire,c.denumire))) denumire, max(c.tip_cont), left(r.cont, 7) cont_parinte, 0 are_analitice, 0 Apare_in_balanta_sintetica, max(Sold_debit), max(Sold_credit), max(Nivel),
			max(Articol_de_calculatie), 1
	from #datebaza r
	left join #lmsurse lm on r.loc_de_munca=lm.cod
		left join (select nullif(c.detalii.value('(row/@sursaf)[1]','varchar(20)'),'') sursaf, cont, denumire_cont denumire, tip_cont,
				Apare_in_balanta_sintetica, Sold_debit, Sold_credit, nivel, Articol_de_calculatie
			from conturi c) c on r.cont=c.cont
		left join indbug i on i.indbug=r.indbug
		where len(r.cont)=7
	group by left(r.cont, 7), coalesce(lm.sursaf,c.sursaf,@sursa_cont_par), r.indbug
	
	if @direct=1 and left(isnull(@ContJos,''),1) not in ('8','9') -- din raport, fara filtru 8 sau 9
		delete #conturi1 where left(cont,1) in ('8','9')

	--> se iau separat rulajele conturilor recompuse:
	select max(r.tip_suma) tip_suma, max(r.subunitate) subunitate,
		left(r.cont, 7)+max(@sector_cont_par+r.sursaf)+rtrim(r.indbug) cont,
		sum(r.rulaj_debit) rulaj_debit, sum(r.rulaj_credit) rulaj_credit, r.loc_de_munca, max(r.data) data, max(r.valuta) valuta, max(r.indbug) indbug
	into #rulajeindbug
	from	--> probabil ca exista o metoda mai frumoasa, dar prin urmatoarele group by-uri am rezolvat pb conturilor cu lungime > 7 care au analitice si a luarii indicatorilor pt conturi de lungime 7 sau mai mare
	(select max(tip_suma) tip_suma,  max(r.subunitate) subunitate, max(r.rulaj_debit) rulaj_debit, max(r.rulaj_credit) rulaj_credit
				,r.indbug, left(r.cont,7) cont, r.data, r.valuta, r.loc_de_munca
				,max(coalesce(nullif(l.detalii.value('(row/@sursaf)[1]','varchar(20)'),''),nullif(c.detalii.value('(row/@sursaf)[1]','varchar(20)'),''),@sursa_cont_par)) sursaf
		from
		(	select max(r.tip_suma) tip_suma, max(r.subunitate) subunitate, sum(r.rulaj_debit) rulaj_debit, sum(r.rulaj_credit) rulaj_credit
				,r.indbug, left(r.cont,7) cont, r.data, r.valuta, r.loc_de_munca
			from #datebaza r	--> se iau doar sumele conturilor care sunt de lungime > 7 si care nu au analitice			
			where not exists(select 1 from conturi c where r.cont=c.cont_parinte)
			group by r.indbug, left(r.cont,7), r.data, r.loc_de_munca, r.valuta
		) r
				inner join conturi c on r.cont=c.cont --and len(c.cont_parinte)=7
				left join #lmsurse l on l.cod=r.loc_de_munca
			where (len(c.cont_parinte)=7 or len(r.cont)=7)
		group by r.indbug, left(r.cont,7), r.data, r.loc_de_munca, r.valuta
	) r --inner join conturi p on p.cont=r.cont_parinte and len(p.cont)=7
	group by left(r.cont, 7),rtrim(r.indbug), r.loc_de_munca, r.data

	delete #datebaza where len(cont)>7
	
	--> sufixare conturi recompuse care nu au indicatori:
	update c set cont=rtrim(cont)+'<fara ind>', contoriginal=rtrim(contoriginal)+'<fara ind>'
	from #conturi1 c where len(c.cont)=10

	--> creare conturi parinti pentru cele recompuse:
		--> inserare cont parinte pentru cele recompuse:
	insert into #conturi1 (Subunitate, Cont, ContOriginal, Denumire_cont, Tip_cont, Cont_parinte,
				Are_analitice, Apare_in_balanta_sintetica, Sold_debit, Sold_credit, Nivel,
				Articol_de_calculatie, Logic)
	select max(c.Subunitate), left(c.Cont,10) cont,
			left(c.Cont,10) ContOriginal, max(cn.Denumire_cont), max(c.Tip_cont),
			max(left(c.cont,7)) Cont_parinte, 1 Are_analitice, max(c.Apare_in_balanta_sintetica),
			max(c.Sold_debit), max(c.Sold_credit), max(c.Nivel),
			max(c.Articol_de_calculatie), max(c.Logic)
	from #conturi1 c
		left join conturi cn on left(c.cont,7)=cn.cont
	where len(c.cont)>10
	group by left(c.Cont,10)

	
	--> modificare parinte astfel incat sa fie noile conturi inserate:
	update c set c.cont_parinte=left(c.cont,10)
	from #conturi1 c where len(c.cont)>10
			
	update c set c.nivel=c.nivel+1
	from #conturi1 c where len(c.cont)>7
			
	update c set are_analitice=1
	from #conturi1 c
	where exists (select 1 from #conturi1 cf where cf.cont_parinte=c.cont)
			
	update c set are_analitice=0
	from #conturi1 c
	where not exists (select 1 from #conturi1 cf where cf.cont_parinte=c.cont)

	update r set  cont=rtrim(cont)+'<fara ind>'
		from #rulajeindbug r where len(r.cont)=10
	--/*
	insert into #rulajeindbug(tip_suma, subunitate, cont, rulaj_debit, rulaj_credit, loc_de_munca, data, valuta, indbug)
	select max(r.tip_suma), max(r.subunitate),
		left(r.cont, 10) cont,
		sum(r.rulaj_debit), sum(r.rulaj_credit), r.loc_de_munca, max(r.data), max(r.valuta), max(r.indbug)
	from #rulajeindbug r
	where len(cont)>=10
	group by left(r.cont, 10), r.loc_de_munca, r.data
	--> completare cu analitice bugetari pt conturile de 7 caractere care nu au analitice:
		--select * from #conturi1 c1 where c1.cont_parinte='5610300'
				
				
	select cont into #conturirecompusecurulaje from #rulajeindbug group by cont
				
	insert into #rulajeindbug(tip_suma, subunitate, cont, rulaj_debit, rulaj_credit, loc_de_munca, data, valuta, indbug)
	select max(r.tip_suma), max(r.subunitate),
		r.cont+max(@sector_cont_par+COALESCE(lm.sursaf,nullif(cc.detalii.value('(row/@sursaf)[1]','varchar(20)'),''),@sursa_cont_par)+rtrim(r.indbug)) cont,
		sum(r.rulaj_debit), sum(r.rulaj_credit), r.loc_de_munca, max(r.data), max(r.valuta), max(r.indbug)
	from #datebaza r inner join conturi cc on r.cont=cc.cont left join #lmsurse lm on lm.cod=r.loc_de_munca
	where len(r.cont)=7
		and not exists (select 1 from #conturirecompusecurulaje c1 where c1.cont like r.cont+'%')
	--	and r.cont like '5610300%'
	group by r.cont, r.loc_de_munca, r.data

	insert into #datebaza(tip_suma, subunitate, cont, rulaj_debit, rulaj_credit, loc_de_munca, data, valuta, indbug)
	select tip_suma, subunitate, cont, rulaj_debit, rulaj_credit, loc_de_munca, data, valuta, indbug
	from #rulajeindbug

	IF OBJECT_ID('tempdb.dbo.#DateTerti') IS NOT NULL
		DROP TABLE #DateTerti
		
	IF @conturiRecompuse = 2 and EXISTS (select 1 from #datebaza where left(cont,3) in ('401','411','404','409','419')) -- >22 car.
	BEGIN
		declare
			@data datetime, @parxmlF xml

		select 
			@data= @p_dData_sf_luna
		
		if object_id('tempdb..#docfacturi') is not null 
			drop table #docfacturi
		create table #docfacturi (furn_benef char(1))

		exec CreazaDiezFacturi @numeTabela='#docfacturi'		
		select @parxmlF=(select dbo.boy(@data) as datajos, @data as datasus, @indicator indicator,@cLM locm for xml raw)
		if object_id('tempdb..#docfacturi2') is not null 
			drop table #docfacturi2

		select top 0 * into #docfacturi2 from #docfacturi

		IF exists (select 1 from #datebaza where left(cont,3) in ('401','404','409'))
		begin			
			set @parxmlF.modify('insert attribute furnbenef {"F"} into (/row)[1]')			
			exec pFacturi @sesiune=null, @parxml=@parxmlF		
			
			insert into #docfacturi2
			select * from #docfacturi
		end	

		IF exists (select 1 from #datebaza where left(cont,3) in ('411','419'))
		begin	
			set @parxmlF.modify('delete (/row/@furnbenef)[1]')	
			set @parxmlF.modify('insert attribute furnbenef {"B"} into (/row)[1]')
			
			exec pFacturi @sesiune=null, @parxml=@parxmlF

			insert into #docfacturi2
			select * from #docfacturi
		end	

		-- din documentele aduse se sterg cele care nu corespund filtrelor:
		delete #docfacturi2 where cont_de_tert not like rtrim(@ContJos)+'%'
			--not in (select cont from #conturi1)
		
		-- unele facturi au sold initial zero la inceputul anului, acestea sunt ignorate la defalcarea pe indicatori (unde este posibil sa aiba sold plus/minus):
		delete from #docfacturi2 where data<dbo.boy(@data) and tert+factura in (select tert+factura from #docfacturi2 where data<dbo.boy(@data) group by tert, factura having abs(sum(Valoare+tva-achitat))<0.01) 

		select 
			--cont(7) + sector(2) + sursa(1) + indicator(12) + cod esa tert(5) + cui tert(13) 
			rtrim(left(d.cont_de_tert,7))+@sector_cont_par+
				COALESCE(lm.sursaf,nullif(cc.detalii.value('(row/@sursaf)[1]','varchar(20)'),''),@sursa_cont_par)+rtrim(d.indbug) 
				+ replicate(' ',12-len(rtrim(d.indbug)))
				+ISNULL(rtrim(t.detalii.value('(//@codesa)[1]','varchar(5)')),'') +replicate(' ',5-len(ISNULL(rtrim(t.detalii.value('(//@codesa)[1]','varchar(5)')),'')))+rtrim(case when t.cod_fiscal='' then '<faraCUI>' else t.cod_fiscal end) cont, 
			rtrim(left(d.cont_de_tert,7))+@sector_cont_par+
			COALESCE(lm.sursaf,nullif(cc.detalii.value('(row/@sursaf)[1]','varchar(20)'),''),@sursa_cont_par)
			+rtrim(d.indbug) prec,  
			rtrim(d.cont_de_tert) cont_din_conturi,
			rtrim(indbug) indbug,
			rtrim(t.denumire) dentert, 
			d.loc_de_munca loc_de_munca,	
			(case when d.data<dbo.boy(@data) then 'sold' when d.data<dbo.bom(@data) then 'rp' else 'rc' end) tip_suma,							 
			(case when d.data<dbo.boy(@data) then dbo.boy(@data) else @data end)  data,
			(case furn_benef when 'F' then (case when d.data<dbo.boy(@data) then 0 else achitat end) when 'B' then (case when d.data<dbo.boy(@data) then Valoare+tva-achitat else Valoare+tva end) end) rulaj_debit,
			(case furn_benef when 'F' then (case when d.data<dbo.boy(@data) then Valoare+tva-achitat else Valoare+tva end) when 'B' then (case when d.data<dbo.boy(@data) then 0 else achitat end) end) rulaj_credit			
		INTO #DateTertiDet
		from #docfacturi2 d 
		join terti t on t.tert=d.tert
		join Conturi cc on cc.cont=d.cont_de_tert
		left join #lmsurse lm on lm.cod=d.loc_de_munca

		if object_id('tempdb..#docfacturi') is not null drop table #docfacturi			

		insert into #datebaza (tip_suma, subunitate, cont, rulaj_debit, rulaj_credit, loc_de_munca, data, valuta, indbug)			
		select
			tip_suma, '1', cont, sum(isnull(rulaj_debit,0)), sum(isnull(rulaj_credit,0)), loc_de_munca, data, '' valuta, indbug
		from #DateTertiDet
		group by tip_suma, cont, loc_de_munca, data, indbug			

		delete #datebaza where rulaj_debit=0 and rulaj_credit=0 

		insert into #conturiRecompuseTerti(cont, contSuperior)
		select
			cont, prec
		from #DateTertiDet
		group by cont, prec

		insert into #conturi1 (Subunitate, Cont, ContOriginal, Denumire_cont, Tip_cont, Cont_parinte,
				Are_analitice, Apare_in_balanta_sintetica, Sold_debit, Sold_credit, Nivel,
				Articol_de_calculatie, Logic)
		select
			'1', d.cont, d.cont, max(dentert),  max(c.tip_cont), max(prec), 0, 0, 0, 0, max(cp.nivel)+1, '', 0
		from #DateTertiDet	d
		JOIN Conturi c on d.cont_din_conturi=c.cont		
		JOIN #conturi1 cp on cp.cont=d.prec
		group by d.cont
		
	END  	
	
	/* Se respecta regulile din dbo.wfReguliDezvoltareIndBug()*/
	declare 
		@prioritate int, @max_prioritate int

	/** Pentru compatibilitate cu 2005, variabila locala trebuie intai declarata si abia apoi
		atribuit o valoare. */
	set @prioritate = 1

	SELECT * INTO #reguli from dbo.wfReguliDezvoltareIndBug()--RETURNEAZA CONT,CARACTERE,PRIORITATE
	SELECT @max_prioritate = MAX(prioritate) from #reguli
				
	/* Marcam conturile care corespund conform regulilor, restul le stergem*/
	WHILE @prioritate<=@max_prioritate
	BEGIN							
		update db
			set marcat = 1
		from #datebaza db
		JOIN #reguli r on db.cont LIKE r.cont+'%' and LEN(db.cont)<=r.caractere and r.prioritate = @prioritate
					
		delete db
		from #datebaza db
		JOIN #reguli r on db.cont LIKE r.cont+'%' and isnull(db.marcat,0)=0 and r.prioritate = @prioritate 
					
		select @prioritate = @prioritate + 1
	END

	DELETE #datebaza where ISNULL(marcat,0)=0
	
	
end try
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH
