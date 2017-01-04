
CREATE PROCEDURE wIaFacturiFiscale @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	declare
		@subunitate varchar(9), @userASiS varchar(20), @f_tert varchar(200), @f_factura varchar(200), @datajos datetime, @datasus datetime,
		@f_expandare int, @f_plaja varchar(200), @debug bit, @f_numar varchar(20), @f_lm varchar(20), @cuTabela bit, @f_idplaja int, @cgplus int,
		@multiFirma int

	set @subunitate = isnull(nullif((select max(Val_alfanumerica) from par where Tip_parametru='GE' and Parametru='SUBPRO'),''),'1')

	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS OUTPUT
	select @cuTabela=0
	select
		@datajos = @parXML.value('(//@datajos)[1]','datetime'),
		@datasus = @parXML.value('(//@datasus)[1]','datetime'),
		@f_expandare = isnull(@parXML.value('(//@f_expandare)[1]','int'),0),
		@debug = isnull(@parXML.value('(//@debug)[1]','bit'),0),
		@f_plaja = '%' + isnull(@parXML.value('(//@f_plaja)[1]','varchar(100)'),'%') + '%',
		@f_numar = '%' + ISNULL(@parXML.value('(//@f_numar)[1]','varchar(20)'),'%') +'%',
		@f_factura = '%' + ISNULL(@parXML.value('(//@f_factura)[1]','varchar(20)'),'%') +'%',
		@f_lm = ISNULL(@parXML.value('(//@f_lm)[1]','varchar(20)'),'') ,
		@f_idplaja = @parXML.value('(//@f_idplaja)[1]','int'),
		@cgplus = isnull(@parXML.value('(//@cgplus)[1]','int'),0)

	set @multiFirma=0
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1

	IF OBJECT_ID('tempdb.dbo.#facturi1') is not null
		drop table #facturi1	
	IF OBJECT_ID('tempdb.dbo.#f1') is not null
		drop table #f1	

	if object_id('tempdb.dbo.#plajeserii') is null
	begin
		create table #plajeserii(idplaja int)
		exec wIaFacturiFiscale_faTabela
	end
	else select @cuTabela=1

	/* Plajele */
	insert into #plajeserii (idplaja, denumire, numarinf, numarsup, ultimnr, ordine, seriefiscala, serie, marcat)
	select
		id, rtrim(ltrim(ISNULL(NULLIF(descriere, ''), isnull(nullif(serie,''), '') + ' '+ convert(Varchar(20), numarinf) + ' - '+ convert(Varchar(20), numarsup)))), 
		convert(Varchar(20), numarinf), convert(Varchar(20), numarsup), convert(Varchar(20), ultimulnr), row_number() over (order by newid()), 
		rtrim(detalii.value('(/*/@seriefiscala)[1]','varchar(20)')), rtrim(Serie),1
	from DocFiscale where tipDoc in ('AP','AS','UF','UO','UV')  and  isnull(factura, 0) = 1	--Am tratat aici si plajele de facturi din UA.
		and dela<=@datasus and panala>=@datajos
		and isnull(docfiscale.serie,'%') like @f_plaja
		and (@multiFirma=0 or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=detalii.value('(/row/@lm)[1]','varchar(20)')))
		
	/* Plaja" fictiva de nealocate */
	insert into #plajeserii (idplaja, denumire, numarinf, numarsup, ultimnr, ordine, marcat)
	select -1, 'Nealocate','','','', 0,0

	update #plajeserii set seriefiscala = rtrim(serie) where nullif(seriefiscala,'') is null and nullif(serie,'') is not null

	create table #facturi1 (tabela varchar(50), factura varchar(20), idplaja int, serie varchar(20), numar_alfa varchar(20),numar bigint, factura_externa int default 0)
	
	/* punem facturile care sunt legate de plaje*/
	insert into #facturi1 (tabela, factura, idplaja, serie, numar_alfa, factura_externa)
	select  
		'doc' as tabela,
		rtrim(d.factura), 
		d.idplaja idplaja, 
		df.serie serie, 
		--	Lucian: Discutat cu Ghita sa extragem din factura seria daca seria este la inceputul facturii, chiar daca nu este pus campul SerieInNumar=1.
		substring(d.factura, (case when len(df.serie)>0 and (isnull(df.SerieInNumar,0) = 1 or charindex(rtrim(df.serie),d.Factura)=1) then len(df.serie)+1 else 0 end), 20) numar, 
		isnull(it.zile_inc,0)
	from Doc d	
	JOIN DocFiscale df on df.id=d.idplaja
	JOIN terti t on t.subunitate=@subunitate and t.tert=d.cod_tert
	LEFT OUTER JOIN infotert it on it.subunitate=t.subunitate and it.tert=d.cod_tert and it.identificator=''
	where 
		d.subunitate=@subunitate and d.tip in ('AS','AP') 
		and d.data_facturii between @datajos and @datasus 
		and LEFT(d.Cont_factura,3) not in ('418')
		and (@multiFirma=0 or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=d.Loc_munca))
		and d.Loc_munca like @f_lm+'%'
		and d.factura like @f_factura
	union all	-->	Facturi din pozadoc
	select distinct 
		'pozadoc' as tabela,
		rtrim(pd.factura_stinga), 
		pd.idplaja idplaja, 
		df.serie serie, 
		substring(pd.factura_stinga, (case when len(df.serie)>0 and (isnull(df.SerieInNumar,0) = 1 or charindex(rtrim(df.serie),pd.Factura_stinga)=1) then len(df.serie)+1 else 0 end), 20) numar, 
		isnull(it.zile_inc,0)
	from pozadoc pd	
	JOIN DocFiscale df on df.id=pd.idplaja
	JOIN terti t on t.subunitate=@subunitate and t.tert=pd.tert
	LEFT OUTER JOIN infotert it on it.subunitate=t.subunitate and it.tert=pd.tert and it.identificator=''
	where 
		pd.subunitate=@subunitate and pd.tip in ('IF','FB') 
		and pd.data between @datajos and @datasus 
		and LEFT(pd.Cont_deb,3) not in ('418') 
		and (TVA22<>0 or TVA11<>0 and Stare<>0)	--	luam in calcul doar facturile cu TVA.
		and (@multiFirma=0 or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=pd.Loc_munca))
		and pd.Loc_munca like @f_lm+'%'
		and pd.factura_stinga like @f_factura
	union all	-->	Facturi din bonuri
	select distinct 
		'antetBonuri' as tabela,
		rtrim(f.factura), 
		isnull(f.bon.value('(/*/*/@idplaja)[1]','int'),f.bon.value('(/*/*/*/@idplaja)[1]','int')) idplaja, 
		df.serie serie, 
		substring(f.factura, (case when len(df.serie)>0 and (isnull(df.SerieInNumar,0) = 1 or charindex(rtrim(df.serie),f.Factura)=1) then len(df.serie)+1 else 0 end), 20) numar, 
		isnull(it.zile_inc,0)
	from antetBonuri f	
	-->	antet "factura" JOIN cu antet "bon". Pozitiile care au antet "Factura" dar nu au antet "Bon" sunt Facturi scrise doar in pozdoc cu tip=AP. Pe pozitia cu antet "factura" se salveaza idplaja.
	JOIN antetBonuri b on b.Factura=f.Factura and b.Data_facturii=f.Data_facturii and b.tert=f.tert and b.idAntetBon<>f.idAntetBon and b.Chitanta=1
	JOIN DocFiscale df on df.id=isnull(f.bon.value('(/*/*/@idplaja)[1]','int'),isnull(f.bon.value('(/*/*/*/@idplaja)[1]','int'),0))
	JOIN terti t on t.subunitate=@subunitate and t.tert=f.tert
	LEFT OUTER JOIN infotert it on it.subunitate=t.subunitate and it.tert=f.tert and it.identificator=''
	where f.Chitanta=0 and isnull(f.factura,'')<>'' 
		and substring(f.factura, (case when len(df.serie)>0 and isnull(df.SerieInNumar,0) = 1 then len(df.serie)+1 else 0 end), 20)=f.Numar_bon
		and f.data_facturii between @datajos and @datasus 
		and (@multiFirma=0 or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=f.Loc_de_munca))
		and f.Loc_de_munca like @f_lm+'%'
		and f.factura like @f_factura

	/* cele care incercam sa le legam de plaje (prin serie....)*/
	insert into #facturi1 (tabela, factura, idplaja, serie, numar_alfa)
	select 
		distinct 'doc' as tabela,
		rtrim(d.factura), 
		-1 idplaja, 
		ISNULL(rtrim(seriefiscala),'') serie,
		substring(rtrim(d.factura), (case when len(rtrim(seriefiscala))>0 then len(rtrim(seriefiscala))+1 else 0 end), 20) numar		
	from Doc d
	LEFT JOIN #plajeserii s on rtrim(d.factura) like rtrim(seriefiscala)+'%'	
	where 
		d.subunitate=@subunitate and d.tip in ('AS','AP') 
		and d.data_facturii between @datajos and @datasus 
		and LEFT(d.Cont_factura,3) not in ('418') 
		and d.idplaja is null
		and isnull(d.detalii.value('(/row/@_modemitfact)[1]','char(1)'),'') not in ('B','T')
		and (@multiFirma=0 or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=d.Loc_munca))
		and d.Loc_munca like @f_lm+'%'
		and d.factura like @f_factura
	union all	-->	Facturi din pozadoc
	select distinct 
		'pozadoc' as tabela,
		rtrim(pd.factura_stinga), 
		-1 idplaja, 
		ISNULL(rtrim(seriefiscala),'') serie,
		substring(rtrim(pd.factura_stinga), (case when len(rtrim(seriefiscala))>0 then len(rtrim(seriefiscala))+1 else 0 end), 20) numar		
	from pozadoc pd	
	LEFT JOIN #plajeserii s on rtrim(pd.factura_stinga) like rtrim(seriefiscala)+'%'	
	where 
		pd.subunitate=@subunitate and pd.tip in ('IF','FB') 
		and pd.data between @datajos and @datasus 
		and LEFT(pd.Cont_deb,3) not in ('418') 
		and pd.idplaja is null
		and (TVA22<>0 or TVA11<>0 and Stare<>0)	--	luam in calcul doar facturile cu TVA.
		and (@multiFirma=0 or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=pd.Loc_munca))
		and pd.Loc_munca like @f_lm+'%'
		and pd.factura_stinga like @f_factura
	union all	-->	Facturi din bonuri
	select distinct 
		'antetBonuri' as tabela,
		rtrim(f.factura),
		-1 idplaja, 
		ISNULL(rtrim(seriefiscala),'') serie,
		substring(rtrim(f.factura), (case when len(rtrim(seriefiscala))>0 then len(rtrim(seriefiscala))+1 else 0 end), 20) numar
	from antetBonuri f 
	JOIN antetBonuri b on b.Factura=f.Factura and b.Data_facturii=f.Data_facturii and b.tert=f.tert and b.idAntetBon<>f.idAntetBon and b.Chitanta=1
	LEFT JOIN #plajeserii s on rtrim(f.factura) like rtrim(seriefiscala)+'%'	
	where f.Chitanta=0 and isnull(f.factura,'')<>'' 
		and substring(rtrim(f.factura), (case when len(rtrim(seriefiscala))>0 then len(rtrim(seriefiscala))+1 else 0 end), 20)=f.Numar_bon
		and f.data_facturii between @datajos and @datasus 
		and isnull(f.bon.value('(/*/*/@idplaja)[1]','int'),f.bon.value('(/*/*/*/@idplaja)[1]','int')) is null
		and (@multiFirma=0 or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=f.Loc_de_munca))
		and f.Loc_de_munca like @f_lm+'%'
		and f.factura like @f_factura

	IF EXISTS (SELECT * FROM sysobjects WHERE NAME = 'wIaFacturiFiscaleUA')
		exec wIaFacturiFiscaleUA @sesiune=@sesiune, @parXML=@parXML

	IF EXISTS (SELECT * FROM sysobjects WHERE NAME = 'wIaFacturiFiscaleSP')
		exec wIaFacturiFiscaleSP @sesiune=@sesiune, @parXML=@parXML
	
	update #facturi1
	set numar=convert(bigint,facturanumerica)
	from (
		select numar_alfa,facturanumerica
		from #facturi1
		cross apply 
		(select (select C+''
				from (select N, substring(numar_alfa, N, 1) C from tally where N<=len(numar_alfa)) [1]
				where C between '0' and '9'
				order by N
				for xml path(''))
		) p (facturanumerica)) fn
		where fn.numar_alfa=#facturi1.numar_alfa

	/*
		Adaugam plajele de facturi folosite dar nemarcata
	*/
	insert into #plajeserii (idplaja, denumire, numarinf, numarsup, ultimnr, ordine, seriefiscala, serie,marcat)
	select
		id, rtrim(ltrim(ISNULL(NULLIF(descriere, ''), isnull(nullif(serie,''), '') + ' '+ convert(Varchar(20), numarinf) + ' - '+ convert(Varchar(20), numarsup)))), 
		convert(Varchar(20), numarinf), convert(Varchar(20), numarsup), convert(Varchar(20), ultimulnr), row_number() over (order by newid()), 
		rtrim(detalii.value('(/*/@seriefiscala)[1]','varchar(20)')), rtrim(Serie),0
		from DocFiscale where 
		id in 
			(select distinct idplaja from #facturi1 )
		and id not in
			(select idplaja from #plajeserii)


	declare @idplajadetratat int,@randuriafectate int,@delta int
	select @idplajadetratat =-1,@randuriafectate=1,@delta=1000
	
	while @randuriafectate>0
	begin
		update f
			set nrmin_folosit=cal.mn,numarinf=cal.mn,
			nrmax_folosit=cal.mx,numarsup=cal.mx
		from #plajeserii f JOIN
		(
			select
				isnull(idplaja,@idplajadetratat) as idplaja, min(numar) mn, max(numar)mx
			from #facturi1
			group by idplaja
		) cal on cal.idplaja=isnull(f.idplaja,@idplajadetratat)

		update f set
			nrmax_folosit=cal.mx,numarsup=cal.mx
		from #plajeserii f JOIN
		(
			select
				f1.idplaja as idplaja, max(numar)mx
			from #facturi1 f1
			inner join #plajeserii p on f1.idplaja=p.idplaja
			WHERE f1.numar<=p.nrmin_folosit+@delta
			group by f1.idplaja
		) cal on f.idplaja=@idplajadetratat and cal.idplaja=f.idplaja
		

		update f1
		set idplaja=@idplajadetratat-1
		from #facturi1 f1
		inner join #plajeserii p on f1.idplaja=p.idplaja
		where f1.idplaja=@idplajadetratat and not f1.numar between p.nrmin_folosit and p.nrmax_folosit
		
		select @randuriafectate=count(*) from #facturi1 where idplaja=@idplajadetratat-1
		if @randuriafectate>0
			insert into #plajeserii (idplaja, denumire, numarinf, numarsup, ultimnr, ordine,marcat)
			select @idplajadetratat-1, 'Nealocate','','','', 0,0

		set @idplajadetratat=@idplajadetratat-1
	end

	update #facturi1 set tabela='ASiS' where idplaja>-1
	
	CREATE INDEX idx_nr ON #facturi1 (numar)		

	/*
	Corectii pentru plaje de peste 100.000 de facturi nealocate
	*/


	select 
		t.n-1 as n,
		p.idplaja,
		row_number() over (partition by p.idplaja,d1.serie order by t.n)-row_number() over (partition by p.idplaja,d1.serie,t.n order by t.n) as ranc,
		row_number() over (partition by p.idplaja order by t.n) rn,
		 row_number() over (partition by p.idplaja,d1.serie order by t.n)-row_number() over (partition by p.idplaja,d1.serie,t.n order by t.n)  
		 - row_number() over (partition by p.idplaja order by t.n) as grup,
		d1.serie,
		isnull(d1.numar,p.nrmin_folosit+t.n-1) as factura,
		d1.tabela, isnull(d1.factura_externa,0) as factura_externa
	into #f1
	from #plajeserii p
	left join tally t on t.N<=p.nrmax_folosit-p.nrmin_folosit+1
	left join #facturi1 d1 on p.idplaja=isnull(d1.idplaja,-1) and p.nrmin_folosit+t.n-1=convert(bigint, d1.numar) and isnumeric(d1.numar)=1 and rtrim(d1.numar) not LIKE '%[^0-9]%' 
		and isnull(factura_externa,0)=0
	group by p.idplaja,p.nrmin_folosit,t.n,d1.serie,d1.numar,d1.tabela,d1.factura_externa
	order by t.N

	update f1 set factura_externa=1
	from #f1 f1
		inner join #facturi1 f on f.idplaja=f.idplaja and f.factura_externa>=1 and f1.factura=f.numar and f1.serie is null and f.idplaja>-1

	-->	Daca este creata tabela #plajeUtilizate (creata din procedura Declaratia394) o populam. Avem nevoie de aceste date pentru a declara plajele de facturi emise (utilizate).
	if object_id('tempdb..#plajeUtilizate') is not null
	begin
		-->	Stergem acele facturi aferente tertilor UE/extern
		delete f1 from #f1 f1
		inner join #facturi1 f on f.idplaja=f.idplaja and f.factura_externa>=1 and f1.serie is null and f.idplaja>-1

		-->	Pentru D394 nu ne intereseaza acele plaje de facturi folosite dar nemarcate.
		delete from ps
		from #plajeserii ps
		inner join docfiscale df on df.id=ps.idplaja
		where isnull(df.factura, 0) = 0

		insert into #plajeUtilizate (idplaja, denumire, serie, numarinf, numarsup, tabela, nr, continuare, observatii)
		select f.idplaja, max(n1.denumire) denumire, isnull(f.serie,'') serie,  min(f.factura) numarinf, max(f.factura) numarsup, isnull(f.tabela,''), 
			count(*) nr,
			(case when f.serie is null then 0 else 1 end) as continuare, (case when f.serie is null then 'LIPSA' else max(n1.denumire) end) as observatii
		from #f1 f
			inner join #plajeserii n1 on n1.idplaja=f.idplaja
		where f.idplaja=n1.idplaja and (f.serie is not null or @cgplus=1)
			and (@f_idplaja is null or f.idplaja=@f_idplaja)
		group by f.idplaja, f.grup, f.serie, isnull(f.tabela,'')
		having min(factura) like @f_numar and max(isnull(f.serie,'%')) like @f_plaja
		order by min(factura)

		-->	Prin exceptie pentru plajele de facturi alocate valabile incepand cu declaratia lunii octombrie 2016, trebuie declarat ca numar inferior, primul numar de factura utilizat dupa 01.10.2016.
		-->	Pentru aceasta vom stoca in detalii acest numar si il vom citi pentru perioada 01.10.2016 - 31.12.2016. Vom face aceste operatii la generarea Declaratiei 394.
		if @datajos='10/01/2016' and @cgplus=0
		begin
			update df set detalii='<row/>'
			from docfiscale df
				inner join #plajeserii ps on ps.idplaja=df.id and ps.idplaja>-1
			where df.detalii is null

			update df set detalii.modify('replace value of (/row/@numarinf1016)[1] with sql:column("ni.NumarInf")')
			from docfiscale df
				inner join #plajeserii ps on ps.idplaja=df.id and ps.idplaja>-1
				outer apply (select top 1 f.NumarInf from #plajeUtilizate f where f.idplaja=df.id order by f.NumarInf) ni
			where df.detalii.value('(/row/@numarinf1016)[1]','bigint') is not null and ni.NumarInf<>''

			update df set detalii.modify('insert attribute numarinf1016 {sql:column("ni.NumarInf")} into (/row)[1]') 
			from docfiscale df
				inner join #plajeserii ps on ps.idplaja=df.id and ps.idplaja>-1
				outer apply (select top 1 f.NumarInf from #plajeUtilizate f where f.idplaja=df.id order by f.NumarInf) ni
			where df.detalii.value('(/row/@numarinf1016)[1]','bigint') is null and ni.NumarInf<>''
		end

		update ps set ps.NumarInf=(case when @dataSus between '10/01/2016' and '12/31/2016' 
				then ISNULL(ISNULL(NULLIF(df.detalii.value('(/row/@numarinf1016)[1]','bigint'),''),convert(bigint,df.NumarInf)),ps.NumarInf)
				else ISNULL(convert(bigint,df.NumarInf),ps.NumarInf) end), 
			ps.NumarSup=isnull(convert(bigint,df.NumarSup),ps.NumarSup)
		from #plajeserii ps
		LEFT JOIN docfiscale df on df.id=ps.idplaja
		return
	end

	select
	(
		select
			(case when n1.idplaja>0 and n1.marcat=0 then '!!! PLAJA NEMARCATA FACTURI - ' else '' end)+n1.denumire grupare,
			max(isnull(convert(bigint,df.NumarInf),n1.NumarInf)) numarinf,
			max(isnull(convert(bigint,df.NumarSup),n1.NumarSup)) numarsup,
			n1.denumire as  observatii,
			count(f1.numar) as nr, (case when @f_expandare = 2 then 'Da' else 'Nu' end) _expandat,
			(case when n1.marcat=0 then '#0000ff' else null end) as culoare,
			(
				select 
					max(n1.denumire) grupare, 
					f.tabela, 
					(case when f.factura_externa=1 then 'ASiS' when f.serie is null then 'Lipsa' else (case f.tabela when 'doc' then 'Facturi AP,AS' when 'pozadoc' then 'Facturi IF,FB' when 'ASiS' then 'ASiS' else 'Facturi din bonuri' end) end) as dentabela,
					min(f.factura) numarinf, 
					(case when @f_expandare = 2 then 'Da' else 'Nu' end) _expandat,
					max(f.factura) numarsup, 
					f.serie serie, 
					f.idplaja idplaja, 
					count(*) nr,
					(case when f.factura_externa=1 then '#9900FF' when f.serie is null then '#FF0000' end) as culoare,
					(case when f.factura_externa=1 then 'Factura UE/extern' when f.serie is null then 'LIPSA' end) as observatii, 
					convert(varchar(10),@datajos,101) as datajos, 
					convert(varchar(10),@datasus,101) as datasus
				from #f1 f
				where f.idplaja=n1.idplaja
				group by f.idplaja, f.grup, f.serie, f.tabela, f.factura_externa
				having min(numar) like @f_numar and max(isnull(f.serie,'%')) like @f_plaja
				order by min(f.factura)
				for xml raw, type
			)
		from #facturi1 f1
		JOIN #plajeserii n1 on f1.idplaja=n1.idplaja
		LEFT JOIN docfiscale df on df.id=n1.idplaja
		group by n1.idplaja, n1.marcat,n1.ordine, n1.denumire
		order by n1.idplaja, n1.ordine
		for xml raw, root('Ierarhie'), type
	) for xml path('Date')

			
END TRY
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH
