--***
CREATE PROCEDURE initializareLunaStocuriRIA @sesiune VARCHAR(50), @parXML XML
AS
/* Initializare stocuri
	exec initializareLunaStocuriRIA @sesiune='',@parXML='<row an="2013" luna="12"/>'
	=> 31.12.2013 
*/
if OBJECT_ID('initializareLunaStocuriRIASP') is not null
begin
	exec initializareLunaStocuriRIASP @sesiune=@sesiune, @parXML=@parXML
	return
end
BEGIN TRY
declare @an int,@luna int
select	@an=@parXML.value('(/*/@an)[1]','int')
	set @luna=@parXML.value('(/*/@luna)[1]','int')

	declare @dDataSus datetime, @cCod char(20), @cGestiune char(20), @cCodi char(20), @GrCod int, @GrGest int, @GrCodi int, @TipStoc char(1), @cCont varchar(20), @cGrupa char(13), 
		@Locatie char(30), @LM char(9), @Comanda char(40), @Contract char(20), @Furnizor char(13), @Lot char(20)

	select @dDataSus=dateadd(day,-1,dateadd(month,@luna,dateadd(year,@an-1901,'01/01/1901'))),
		@cCod=null, @cGestiune=null, @cCodi=null, @GrCod=null, @GrGest=null, @GrCodi=null, @TipStoc=null, @cCont='', @cGrupa='%'
		,@Locatie='', @LM='', @Comanda='', @Contract='', @Furnizor='', @Lot=''
	/*
	select *
	into #stocuriDet
	from dbo.fStocuri(null, @dDataSus, @cCod, @cGestiune, @cCodi, @cGrupa, @TipStoc, @cCont, 0, @Locatie, @LM, @Comanda, @Contract, @Furnizor, @Lot,@parXML)
	*/
	declare @p xml
	select @p=(select @dDataSus dDataSus, @cCod cCod, @cGestiune cGestiune, @cCodi cCodi,
		@cGrupa cGrupa,	@TipStoc TipStoc, @cCont cCont, 0 Corelatii, @Locatie Locatie,
		@LM LM, @Comanda Comanda, @Contract Contract, @Furnizor Furnizor, @Lot Lot
	for xml raw)
--test	select @p
		if object_id('tempdb..#docstoc') is not null drop table #docstoc
		create table #docstoc(subunitate varchar(9))
		exec pStocuri_tabela
		 
		exec pstoc @sesiune='', @parxml=@p

	select
		sd.Subunitate, 
		@dDataSus as datasus, 
		sd.Tip_gestiune, 
		sd.Gestiune, 
		sd.Cod, 
		min(sd.Data) as data, 
		sd.Cod_intrare, 
		max(sd.Pret) as pret, 
		/*(case when sd.tip_gestiune='A' then sd.TVA_neexigibil else 0 end)*/ max(sd.TVA_neexigibil) as TVA_neexigibil, 
		max(case when sd.tip_gestiune='A' then sd.Pret_cu_amanuntul else 0 end) as Pret_cu_amanuntul,
		sum(sd.cantitate*(case when sd.tip_miscare='I' then 1 when sd.tip_miscare='E' then -1 else 0 end)) as Stoc,
		sd.Cont, 
		--min(isnull(isnull(pdif.Locatie,pdi.Locatie),
		max(sd.locatie) as locatie, --Lasat locatia returnata de pstoc. (Discutat cu Ghita. Compatibilitate in urma).
		--min(isnull(isnull(pdif.Data_expirarii,pdi.data_expirarii),
		'01/01/1901' as data_expirarii, 
		0 as Pret_vanzare, --Nu inteleg rostul acestui camp
		max(sd.Loc_de_munca) as Loc_de_munca, --Nu inteleg rostul acestui camp. Pastrat loc de munca returnat de pstoc (este necesar pentru cei care lucreaza cu rulaje pe locuri de munca).
		max(sd.Comanda) as Comanda, --Nu inteleg rostul acestui camp. Pastrat comanda returnata de pstoc (Discutat cu Ghita. Compatibilitate in urma).
		max(sd.contract) as contract, --Pastrat contractul returnat de pstoc (Discutat cu Ghita. Compatibilitate in urma).
		max(sd.Furnizor) as Furnizor, --Pastrat furnizorul returnat de pstoc (Discutat cu Ghita. Compatibilitate in urma).
		max(sd.lot) as lot,	--Pastrat lotul returnat de pstoc (compatibilitate in urma).
		sum(sd.cantitate_um2*(case when sd.tip_miscare='I' then 1 when sd.tip_miscare='E' then -1 else 0 end)) as Stoc_UM2,
		'' Val1,
		'' Alfa1, 
		'' Data1,
		max(sd.idIntrareFirma) idintrareFirma, 
		max(sd.idIntrare) idIntrare,
		row_number() over (partition by sd.Subunitate,sd.Gestiune, sd.Cod,sd.Cod_intrare order by sd.Subunitate,sd.Gestiune, sd.Cod,sd.Cod_intrare) as nrrand
	into #stocuriCen
	from #docstoc sd
	/*left outer join PozDoc pdi on max(sd.idIntrare)=pdi.idPozDoc
	left outer join PozDoc pdif on max(sd.idIntrareFirma)=pdif.idPozDoc*/
	group by --sd.idIntrare,sd.idIntrareFirma,
	sd.Subunitate,sd.Tip_gestiune, sd.Gestiune, sd.Cod,sd.Cod_intrare,round(convert(decimal(17,5),sd.Pret),2),sd.Cont
		,round(convert(decimal(17,5),(case when sd.tip_gestiune='A' then sd.Pret_cu_amanuntul else 0 end)),2)
		--,(case when sd.tip_gestiune='A' then sd.TVA_neexigibil else 0 end)


	delete from #stocuriCen where abs(stoc)<0.001

	delete from istoricstocuri where Data_lunii>=@dDataSus

	insert into istoricstocuri(Subunitate, Data_lunii, Tip_gestiune, Cod_gestiune, Cod, Data, Cod_intrare, Pret, TVA_neexigibil, Pret_cu_amanuntul, Stoc, Cont, Locatie, Data_expirarii, Pret_vanzare, Loc_de_munca, Comanda, Contract, Furnizor, Lot, Stoc_UM2, Val1, Alfa1, Data1, idIntrareFirma, idIntrare)
	select
		Subunitate, 
		datasus, 
		Tip_gestiune, 
		Gestiune, 
		Cod, 
		data, 
		(case when nrrand=1 then ltrim(Cod_intrare) else 'S'+replace(substring(convert(char(10),@dDataSus,3),4,5),'/','')+replace(str(row_number() over (order by gestiune,cod),8),' ','0') end), 
		Pret, 
		TVA_neexigibil, 
		Pret_cu_amanuntul, 
		Stoc,
		Cont, 
		locatie, 
		data_expirarii, 
		Pret_vanzare, --Nu inteleg rostul acestui camp
		Loc_de_munca, --Nu inteleg rostul acestui camp
		Comanda, --Nu inteleg rostul acestui camp
		contract, 
		Furnizor, 
		lot,
		Stoc_UM2,
		'' Val1,
		'' Alfa1, 
		'' Data1,
		idIntrareFirma, 
		idIntrare
	from #stocuriCen

	if not exists(select 1 from par where Tip_parametru='GE' and Parametru='ANULINC')
		insert into par(Tip_parametru, Parametru, Denumire_parametru, Val_logica, Val_numerica, Val_alfanumerica)
		values('GE','ANULINC','Anul inchis',0,@An,'')
	
	if not exists(select 1 from par where Tip_parametru='GE' and Parametru='LUNAINC')
		insert into par(Tip_parametru, Parametru, Denumire_parametru, Val_logica, Val_numerica, Val_alfanumerica)
		values('GE','LUNAINC','Luna inchisa',0,@luna,'')

	update par set Val_numerica=@An where tip_parametru='GE' and parametru='ANULINC'
	update par set Val_numerica=@luna, Val_alfanumerica=dbo.fDenumireLuna(@dDataSus) where tip_parametru='GE' and parametru='LUNAINC'

END TRY

BEGIN CATCH
	declare @mesaj varchar(1000)
	SET @mesaj = ERROR_MESSAGE() + ' (initializareLunaStocuriRIA)'
	RAISERROR (@mesaj, 11, 1)
END CATCH
if object_id('tempdb..#docstoc') is not null drop table #docstoc
