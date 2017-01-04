
CREATE PROCEDURE wOPAlocarePlajaDocumente @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	declare
		@userASiS varchar(20), @plaja int, @rootXml varchar(20), @iDoc int, @multiFirma int

	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS OUTPUT	
	select
		@plaja = @parXML.value('(/*/@plaja)[1]','int')

	set @multiFirma=0
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @parXml

	if @parXML.exist('(/parametri/row)')=1 
		set @rootXml='/parametri/row'  
	else
		set @rootXml='/parametri'

		select
			tabela,
			numarinf,
			numarsup,
			serie,
			isnull(datajos,'01/01/1901') as datajos,
			isnull(datasus,'12/31/2999') as datasus
		into #tmpupdate
		from OPENXML(@iDoc, @rootXml)
		WITH 
		(
			tabela varchar(50) '@tabela',
			numarinf bigint '@numarinf',
			numarsup bigint '@numarsup', 
			serie varchar(20) '@serie',
			datajos datetime '@datajos',
			datasus datetime '@datasus'
		)

	--if isnull((select count(1) from (select distinct tabela from #tmpupdate) tab),0)>1
	--	raiserror ('Pentru alocare trebuie selectate plaje de facturi dintr-o singura tabela',16,1)

	if APP_NAME() like '%Management Studio%'
	begin
		select * from #tmpupdate where tabela='doc'
		
		select *
		from Doc d
		JOIN #tmpupdate t on d.factura like t.serie+'%' 
		and convert(bigint,case when isnumeric(ltrim(replace(replace(replace(d.factura,',','X'),'.','X'),serie,'')))=0 then null else ltrim(replace(d.factura,serie,'')) end)  between t.numarinf and t.numarsup --Tot mai pot scapa cateva 
		--and convert(bigint,(case when t.serie='' or isnumeric(ltrim(replace(d.factura,t.serie,'')))=0 then '0' else ltrim(replace(d.factura,t.serie,'')) end)) between t.numarinf and t.numarsup --varianta Ghita
		where d.tip in ('AS','AP') and LEFT(d.Cont_factura,3) not in ('418') and d.idplaja is null and d.data between t.datajos and t.datasus
			and (@multiFirma=0 or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=d.Loc_munca))
			and tabela='doc'
	end
		
	update d
		set idplaja=@plaja
	from Doc d
	JOIN #tmpupdate t on d.factura like t.serie+'%' 
		and convert(bigint,case when isnumeric(ltrim(replace(replace(replace(d.factura,',','X'),'.','X'),serie,'')))=0 then null else ltrim(replace(d.factura,serie,'')) end)  between t.numarinf and t.numarsup --Tot mai pot scapa cateva 
		--and convert(bigint,(case when t.serie='' or isnumeric(ltrim(replace(d.factura,t.serie,'')))=0 then '0' else ltrim(replace(d.factura,t.serie,'')) end)) between t.numarinf and t.numarsup --varianta Ghita
		and isnull(t.tabela,'doc')='doc'
	where tip in ('AS','AP') and LEFT(d.Cont_factura,3) not in ('418') and d.idplaja is null and d.data between t.datajos and t.datasus
		and (@multiFirma=0 or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=d.Loc_munca))

	update d
		set d.idplaja=@plaja
	from pozadoc d
	JOIN #tmpupdate t on d.factura_stinga like t.serie+'%' 
		and convert(bigint,case when isnumeric(ltrim(replace(replace(replace(d.factura_stinga,',','X'),'.','X'),serie,'')))=0 then null else ltrim(replace(d.factura_stinga,serie,'')) end) between t.numarinf and t.numarsup and isnull(t.tabela,'doc')='pozadoc'
		--and convert(bigint,(case when t.serie='' or isnumeric(ltrim(replace(d.factura_stinga,t.serie,'')))=0 then '0' else ltrim(replace(d.factura_stinga,t.serie,'')) end)) between t.numarinf and t.numarsup  --varianta Ghita
		and isnull(t.tabela,'doc')='pozadoc'
	where d.tip in ('IF','FB') and LEFT(d.Cont_deb,3) not in ('418') and d.idplaja is null and d.data between t.datajos and t.datasus 
		and (d.TVA22<>0 or d.TVA11<>0 and d.Stare<>0)
		and (@multiFirma=0 or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=d.Loc_munca))

	update f
		set bon.modify ('insert attribute idplaja {sql:variable("@plaja")} into (/date/document)[1]')
	from antetBonuri f
	JOIN antetBonuri b on b.Factura=f.Factura and b.Data_facturii=f.Data_facturii and b.tert=f.tert and b.idAntetBon<>f.idAntetBon and b.Chitanta=1
	JOIN #tmpupdate t on f.Factura like t.serie+'%' 
		and convert(bigint,case when isnumeric(ltrim(replace(replace(replace(f.factura,',','X'),'.','X'),serie,'')))=0 then null else ltrim(replace(f.factura,serie,'')) end) between t.numarinf and t.numarsup 
		--and convert(bigint,(case when t.serie='' or isnumeric(ltrim(replace(f.factura,serie,'')))=0 then '0' else ltrim(replace(f.factura,serie,'')) end)) between t.numarinf and t.numarsup -- varianta Ghita
		and isnull(t.tabela,'doc')='antetBonuri'
	where f.Chitanta=0 and isnull(f.factura,'')<>'' and isnumeric(ltrim(replace(f.factura,serie,'')))=1 and f.bon.value('(/date/document/@idplaja)[1]','int') is null
		and f.Data_facturii between t.datajos and t.datasus
		and (@multiFirma=0 or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=f.Loc_de_munca))
		
	IF EXISTS (SELECT * FROM sysobjects WHERE NAME = 'wOPAlocarePlajaDocumenteSP')
		exec wOPAlocarePlajaDocumenteSP @sesiune=@sesiune, @parXML=@parXML	
			
END TRY
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'+ltrim(str(error_line()))
	raiserror (@mesaj, 15, 1)
END CATCH
