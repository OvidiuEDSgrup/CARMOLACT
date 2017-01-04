--***
create procedure wOPGenerareAvizeDinComenzi @sesiune varchar(50), @parXML XML
as
begin try
	declare @mesaj varchar(500), @tert varchar(20), @comanda varchar(20), @grupa_terti varchar(20), @datajos datetime, @datasus datetime,@docXML xml,
	@crsData datetime, @crsContract varchar(20), @crsTert varchar(20), @status int, @utilizator varchar(100), @pozitii xml,

	/*Parametrii de expeditie:*/ 
	@numedelegat varchar(30),@mijloctp varchar(30),@nrmijtransp varchar(20),@seriabuletin varchar(10),
	@numarbuletin varchar(10),@eliberat varchar(30)

	/** Date si filtre din macheta de operatie **/
	set @tert=isnull(@parXML.value('(/*/@tert)[1]','varchar(20)'),'')
	set @comanda=isnull(@parXML.value('(/*/@comanda)[1]','varchar(20)'),'')
	set @grupa_terti=isnull(@parXML.value('(/*/@grupa_terti)[1]','varchar(20)'),'')
	set @datajos=isnull(@parXML.value('(/*/@datajos)[1]','datetime'),'01/01/1910')
	set @datasus=isnull(@parXML.value('(/*/@datasus)[1]','datetime'),'01/01/2110')

	/* Date pentru expeditie **/
	select
	@numedelegat=upper(ISNULL(@parXML.value('(/*/@numedelegat)[1]', 'varchar(30)'), '')),
	@mijloctp=ISNULL(@parXML.value('(/*/@mijloctp)[1]', 'varchar(30)'), ''),		
	@nrmijtransp=upper(ISNULL(@parXML.value('(/*/@nrmijltransp)[1]', 'varchar(20)'), '')),		
	@seriabuletin=upper(ISNULL(@parXML.value('(/*/@seriabuletin)[1]', 'varchar(10)'), '')),		
	@numarbuletin=upper(ISNULL(@parXML.value('(/*/@numarbuletin)[1]', 'varchar(10)'), '')),		
	@eliberat=upper(ISNULL(@parXML.value('(/*/@eliberat)[1]', 'varchar(30)'), ''))


	if @numedelegat='' or @mijloctp='' or @nrmijtransp ='' or @seriabuletin='' or @numarbuletin='' or @eliberat=''
		raiserror('Compleati datele legate pentru expeditie',11,1)

	if OBJECT_ID('tempdb..#CON') is not null
		drop table #CON
	if OBJECT_ID('tempdb..#POZCON') is not null
		drop table #POZCON

	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output

	/** Se filtraeza in tabela temporara Comenzile de luat in considerare **/
	select c.data, rtrim(c.contract) contract, rtrim(c.tert) tert
	into #CON
	from con c 
	JOIN terti t on t.Tert=c.Tert where c.Subunitate='1' and c.tip='BK' and (@comanda='' OR c.Contract=@comanda)
	and c.data between @datajos and @datasus and (@grupa_terti='' OR t.Grupa=@grupa_terti ) and (@tert='' or c.Tert=@tert)


	/** Pe baza comenzilor (antete) de mai sus se filtreaza si pozitiile **/
	select 
			rtrim(pc.cod) cod,convert(decimal(15,2),pc.cantitate) cantitate_factura ,convert(decimal(15,2),pc.cantitate) cantitate_disponibila,
			convert(decimal(15,2),pc.cant_aprobata) cant_aprobata,convert(decimal(15,2),pc.cant_realizata ) cant_realizata,rtrim(pc.Subunitate) subunitate ,'BK' as tip,
			pc.data ,rtrim(pc.contract) contract,rtrim(pc.tert) tert,pc.numar_pozitie
	into #POZCON
	from PozCon pc
	JOIN #CON c on pc.Subunitate='1' and pc.contract=c.Contract and pc.Data=c.Data and pc.tert=c.Tert and pc.tip='BK'

	/** Cursor pentru apel wOPGenerareUnAPdinBK in dreptul fiecari comenzi **/
	declare antCon cursor for select data, contract, tert from #CON
	open antCon
	fetch next from antCon into @crsData, @crsContract, @crsTert
	select @status=@@FETCH_STATUS

	while @status=0
	begin
		
		/** Se formeaza pozitiile aferente antetului pt. a putea fi transmise in formatul cerut de wOPGenerareUnAPdinBK **/
		set @pozitii=
			(
				select * 
				from #POZCON where contract=@crsContract and data=@crsData and tert=@crsTert
				for xml raw,type
			)

		/** Se formeaza documetul de trimis la procedura wOPGenerareUnAPdinBK, cu tot cu pozitii **/
		set @docXML=
			(
				select 
					'BK' as tip, @crsContract as numar , @crsData as data, @crsTert as tert, @numedelegat numedelegat, @mijloctp mijloctp, @nrmijtransp nrmijtransp, 
					@seriabuletin seriabuletin,@numarbuletin numarbuletin, @eliberat eliberat,@pozitii DateGrid,
					'1' faramesaje, GETDATE() datadoc
				for xml raw
			)

		exec wOPGenerareUnAPdinBK @sesiune=@sesiune, @parXML=@docXML

		fetch next from antCon into @crsData, @crsContract, @crsTert
		select @status=@@FETCH_STATUS
	end

	close antCon
	deallocate antCon

end try

begin catch
	set @mesaj=ERROR_MESSAGE()+ ' (wOPGenerareAvizeDinComenzi)'
	raiserror(@mesaj, 11,1)
end catch