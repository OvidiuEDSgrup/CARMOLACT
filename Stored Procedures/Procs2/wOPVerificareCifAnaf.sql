Create procedure wOPVerificareCifAnaf @sesiune varchar(50)=null, @parXML xml
as
declare @subunitate varchar(9), @userASiS varchar(20), @lmUtilizator varchar(20), @nrLMFiltru int, @lmFiltru varchar(9), @data datetime, @datajos datetime, @datasus datetime, @luna int, @an int, @dataprec datetime, 
		@dateInitializare XML, @D394 int, @tipdecl varchar(1), @limita int, @dataCitire datetime

begin try
	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS OUTPUT
	select @lmFiltru=isnull(min(Cod),''), @nrLMFiltru=count(1) from LMfiltrare where utilizator=@userASiS and cod in (select cod from lm where Nivel=1)
	if @nrLMFiltru=1
		set @lmUtilizator=rtrim(@lmFiltru)

	if @lmUtilizator is not null
	begin
		if @parXML.value('(/*/@lm)[1]','varchar(40)') IS NULL
			set @parXML.modify ('insert attribute lm {sql:variable("@lmUtilizator")} into (/*)[1]')
		else 
			set @parXML.modify('replace value of (/*/@lm)[1] with sql:variable("@lmUtilizator")')
	end

	if exists (select * from sysobjects where name ='wJurnalizareOperatie' and type='P')
		exec wJurnalizareOperatie @sesiune=@sesiune, @parXML=@parXML, @obiectSql='wOPVerificareCifAnaf'

	select @Subunitate=isnull((select max(val_alfanumerica) from par where tip_parametru='GE' and parametru='SUBPRO'),'1')
	set @limita=50
	select @luna=@parXML.value('(/*/@luna)[1]','int'), @an=@parXML.value('(/*/@an)[1]','int')
	if nullif(@luna,0) is not null and nullif(@an,0) is not null
		set @data=dbo.EOM(convert(datetime,str(@luna,2)+'/01/'+str(@an,4)))
	else
		set @data=coalesce(@parXML.value('(/*/@datalunii)[1]','datetime'),@parXML.value('(/*/@datasus)[1]','datetime'),@parXML.value('(/*/@data)[1]','datetime'),getdate())
	set @dataprec=dbo.eom(dateadd(day, -1, dbo.bom(@data)))
	set @D394=isnull(@parXML.value('(/*/@D394)[1]','int'),0)

	set @tipdecl = ISNULL(@parXML.value('(/*/@tipdecl)[1]', 'varchar(1)'), 'L')

	if @tipdecl<>''
	begin
		select @datajos=dbo.bom((case @tipdecl when 'L' then @data
									when 'T' then dateadd(M,-(month(@data)-1) % 3,@data)
									when 'S' then dateadd(M,-(month(@data)-1) % 6,@data)
									when 'A' then dateadd(M,-month(@data)+1,@data)
									else @datajos end)),
				@datasus=dbo.eom((case @tipdecl when 'L' then @data
									when 'T' then dateadd(M,-(month(@data)-1) % 3 +2,@data)
									when 'S' then dateadd(M,-(month(@data)-1) % 6 + 5,@data)
									when 'A' then dateadd(M,-month(@data)+12,@data)
									else @datajos end))

	end
	else
		select @datajos=dbo.BOM(@data), @datasus=dbo.EOM(@data)

	if OBJECT_ID('tempdb..#informTVA') is null 
		begin
			create table #informTVA (cui varchar(20))
			exec CreazaDiezTerti @numeTabela='#informTVA'
		end
	if @D394=1
	begin
		insert into #informTVA (cui, denumire)
		select distinct cuiP, denP from d394 where data=dbo.eom(@data) and cuiP is not null
	end
	else
	begin
		create table #tvavanz (subunitate char(9))
		exec CreazaDiezTVA @numeTabela='#tvavanz'
		exec TVAVanzari @DataJ=@datajos, @DataS=@datasus, @ContF='', @ContFExcep=0, @Gest='', @LM='', @LMExcep=0, @Jurnal=''
			,@ContCor='', @TVAnx=0, @RecalcBaza=0, @CtVenScDed='', @CtPIScDed='', @nTVAex=8, @FFFBTVA0='1'
			,@SiFactAnul=0, @TipCump=1, @TVAAlteCont=0, @DVITertExt=0, @OrdDataDoc=0, @OrdDenTert=0
			,@Tert='', @Factura='', @D394=0, @FaraCump=1, @parXML='<row />'

		create table #tvacump (subunitate char(9))
		exec CreazaDiezTVA @numeTabela='#tvacump'
		exec TVACumparari @DataJ=@datajos, @DataS=@datasus, @ContF='', @Gest='', @LM='', @LMExcep=0, @Jurnal='', @ContCor='', @TVAnx=0, @RecalcBaza=0
				,@nTVAex=0, @FFFBTVA0='2', @SFTVA0='2', @IAFTVA0=0, @TipCump=1, @TVAAlteCont=2, @DVITertExt=0
				,@OrdDataDoc=0, @Tert='', @Factura='', @UnifFact=0, @FaraVanz=1, @nTVAned=2, @parXML='<row />'

		select distinct tert into #tert 
		from #tvavanz t
		where vanzcump='V' and (tipD<>'FA' and not (tipD='BP' and tip='F') or tipD='BP' and tip='F' and charindex('R', cont_TVA)>0)
			and not (tipD='FA' and factura='FACT.UA' and tert='ABON.UA')
			and not exists (select 1 from #tvacump tt where tt.tert=t.tert)
		union all select tert from #tvacump
		where vanzcump='C' and tipD<>'FA' 

		insert into #informTVA (cui, denumire)
		select replace(replace(replace(isnull(t.cod_fiscal,''), 'RO', ''), 'R', ''), ' ','') as cui, max(t.denumire) as denumire
		from #tert a
			inner join terti t on t.subunitate=@Subunitate and t.tert=a.tert
			left join infotert it on it.subunitate=@Subunitate and it.tert=a.tert and it.identificator=''
		-->	Excludem de la verificare tertii UE/Externi sau cei interni care sunt persoane fizice.
		where not(isnull(it.zile_inc, 0)<>0 or isnull(it.zile_inc, 0)=0 and (len(rtrim(t.Cod_fiscal))=13 or isnull(t.detalii.value('(/row/@_persfizica)[1]','int'),0)=1))
		group by replace(replace(replace(isnull(t.cod_fiscal,''), 'RO', ''), 'R', ''), ' ','')
	end

	--populare cu abonatii din UA
	if exists (select 1 from sysobjects o where o.type='U' and o.name='tvapeabonati')  and exists (select 1 from sysobjects o where o.type='P' and o.name='PopulareCifUA') 
	begin
		declare @p1 xml
		set @p1=(select @datajos as datajos, @datasus as datasus for xml raw)
		exec PopulareCifUA @sesiune=@sesiune,@parXML=@p1
	end

	-->	Apelare SP care sa permita modificarea continutului tabelei #informTVA
	if exists (select 1 from sysobjects where [type]='P' and [name]='wOPVerificareCifAnafSP')
		exec wOPVerificareCifAnafSP @sesiune, @parXML

	-->	Aici va trebui apelata procedura wValidareCodFiscal pentru a vedea daca sunt coduri fiscale eronate. De regula in acest caz web service-ul ANAF da eroare.
	declare @mesajEroare varchar(1000), @msgEroare varchar(8000)
	
	if object_id('tempdb..#validCUI') is not null drop table #validCUI
	create table #validCUI (cui varchar(20))
	exec CreazaDiezTerti @numeTabela='#validCUI'

	insert into #validCUI (cui, den_tert)
	select distinct cui, denumire from #informTVA
	
	exec pValidareCodFiscal

	set @msgEroare=''
	select @msgEroare=@msgEroare+', ('+rtrim(cui)+' '+rtrim(den_tert)+')'
	from #validCUI 
	where cod_eroare in (1,2,3)
	
	if len(@msgEroare)>1
	begin
		set @msgEroare='Cui eronat: '+rtrim(@msgEroare)
		raiserror (@msgEroare,16,1)
	end
	
	if OBJECT_ID('tempdb..#eroriTVA') is null 
		create table #eroriTVA (raspuns varchar(max), eroare varchar(500))
	set @dataCitire=(case when @data>getdate() then convert(datetime,convert(varchar(10),getdate(),101),101) else @data end)
	exec pCitireCifAnaf @dataRap=@dataCitire, @limita=@limita
	/*    -  parte de citire luna precedenta
	if OBJECT_ID('tempdb..#informTVAcurr') is not null drop table #informTVAcurr
	select * into #informTVAcurr from #informTVA 
	
	delete i 
	from #informTVA i
	where exists (select 1 from cereriInformareTVA c where i.cui=c.cui and c.data_raportare=@dataprec)
	exec pCitireCifAnaf @dataRap=@dataprec, @limita=@limita
	
	update ci
		set ci.data_ora=it.data_ora, 
			ci.tip=it.tip, 
			ci.is_tva=it.is_tva, 
			ci.adresa=it.adresa,
			ci.valid=it.valid
	from cereriInformareTVA ci
		inner join #informTVAcurr it on it.data_raportare=ci.data_raportare and it.cui=ci.cui and it.data_ora is not null
	where exists (select 1 from cereriInformareTVA c where c.data_raportare=ci.data_raportare and c.cui=ci.cui)

	insert into cereriInformareTVA (data_ora, data_raportare, tip, cui, is_tva, adresa, valid)
	select data_ora, data_raportare, tip, cui, is_tva, adresa, valid
	from #informTVAcurr i
	where not exists (select 1 from cereriInformareTVA c where c.data_raportare=i.data_raportare and c.cui=i.cui) and i.data_ora is not null
	*/
	update ci
		set ci.data_ora=it.data_ora, 
			ci.tip=it.tip, 
			ci.is_tva=it.is_tva, 
			ci.adresa=it.adresa,
			ci.valid=it.valid
	from cereriInformareTVA ci
		inner join #informTVA it on it.data_raportare=ci.data_raportare and it.cui=ci.cui and it.data_ora is not null
	where exists (select 1 from cereriInformareTVA c where c.data_raportare=ci.data_raportare and c.cui=ci.cui)

	insert into cereriInformareTVA (data_ora, data_raportare, tip, cui, is_tva, adresa, valid)
	select data_ora, data_raportare, tip, cui, is_tva, adresa, valid
	from #informTVA i
	where not exists (select 1 from cereriInformareTVA c where c.data_raportare=i.data_raportare and c.cui=i.cui) and i.data_ora is not null
	/*    -  parte de citire luna precedenta
	truncate table #informTVA
	insert into #informTVA
	select * from #informTVAcurr
	*/
	exec pCitireTertiTLIClient @datasus=@datasus, @limita=@limita

	update ci
		set ci.is_tli=it.is_tli,
			ci.dela=it.dela
	from cereriInformareTVA ci
		inner join #informTVA it on it.cui=ci.cui and it.data_raportare=ci.data_raportare


	/*        citirea diferentelor de TVA de la platitor la neplatitor sau invers   
				-   daca se modifica in wOPModificariTipTVA_p trebuie modificat si aici     */
	if object_id('tempdb..#diferenteTVA') is not null drop table #diferenteTVA
	create table #diferenteTVA (cui varchar(20), tipNou char(1), tipVechi char(1))

	insert into #diferenteTVA (cui, tipNou, tipVechi)
		select c.cui, (case when isnull(c.is_tli,0)=1 then 'I' when isnull(c.is_tva,0)=1 then 'P' else 'N' end), isnull(cl.tip_tva,'P')
	from cereriInformareTVA c  
		inner join terti t on c.cui=replace(replace(replace(isnull(t.cod_fiscal,''), 'RO', ''), 'R', ''), ' ','')
		outer apply 
			(select top 1 tip_tva 
				from TvaPeTerti tt 
				where tt.tert=t.tert 
					and nullif(tt.factura,'') is null and tt.tipf='F' and tt.dela<=@datasus
				order by tt.dela desc) cl
	where c.data_raportare=@dataCitire 
	
	--populare cu diferente UA
	if exists (select 1 from sysobjects o where o.type='U' and o.name='tvapeabonati')  and exists (select 1 from sysobjects o where o.type='P' and o.name='DiferenteTVACifUA') 
	begin
		set @p1=(select @dataCitire as dataCitire, @datasus as datasus for xml raw)
		exec DiferenteTVACifUA @sesiune=@sesiune,@parXML=@p1
	end

	update c
		set c.dela=dateadd(day,1,c.dela)
	from cereriInformareTVA c 
		inner join #diferenteTVA di on di.cui=c.cui and di.tipVechi='I' and di.tipNou='N'
	where c.data_raportare=@dataCitire

	truncate table #informTVA
	insert into #informTVA (cui, data_raportare)
	select distinct cui, c.Data
	from #diferenteTVA d
		inner join dbo.fCalendar(@dataJos, @dataSus) c on 1=1
	where (d.tipnou='P' and d.tipvechi='N') or (d.tipnou='N' and d.tipvechi='P')

	exec pCitireCifAnaf @dataRap=@dataCitire, @limita=@limita

	if object_id('tempdb..#date_rap') is not null drop table #date_rap
	select cui, isnull(t.data_raportare,@datajos) dela
	into #date_rap
	from #informTVA i
		outer apply (select top 1 data_raportare from #informTVA i1 where i1.cui=i.cui and i1.is_tva!=i.is_tva order by i1.cui, i1.data_raportare asc) t
	where i.data_raportare=@datajos
	
	update c
		set c.dela=d.dela
	from cereriInformareTVA c 
		inner join #date_rap d on d.cui=c.cui and c.data_raportare=@dataCitire

	if exists (select 1 from cereriInformareTVA) and exists (select 1 from webConfigTipuri where meniu='T' and tip='T' and subtip='CV' and fel='O')
		begin
			SET @dateInitializare='<row datalunii="'+convert(char(10),@data,101)+'" datajos="'+convert(char(10),@datajos,101)+'" datasus="'+convert(char(10),@datasus,101)+'"/>'
			SELECT 'Validari Cereri TVA' nume, 'T' codmeniu, 'C' tipmacheta, 'T' tip, 'CV' subtip,'O' fel,
				(SELECT @dateInitializare ) dateInitializare
			FOR XML RAW('deschideMacheta'), ROOT('Mesaje')
		end
end try 

begin catch
	declare @eroare varchar(8000)
	set @eroare='Procedura wOPVerificareCifAnaf (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
