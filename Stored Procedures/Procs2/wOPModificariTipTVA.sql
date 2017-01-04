Create procedure wOPModificariTipTVA @sesiune varchar(50)=null, @parXML xml
as
declare @subunitate varchar(9), @utilizator varchar(20), @data datetime, @datajos datetime, @datasus datetime, @iDoc int, @binar varbinary(128)

begin try
	select @Subunitate=isnull((select max(val_alfanumerica) from par where tip_parametru='GE' and parametru='SUBPRO'),'1')
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator OUTPUT

	set @datajos=@parXML.value('(/*/@datajos)[1]','datetime')
	set @datasus=@parXML.value('(/*/@datasus)[1]','datetime')

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @parXML
	if object_id('tempdb..#tertiDePrelucrat') is not null drop table #tertiDePrelucrat
	
	select firma, cui, adresa, tipnou, tipvechi, modificare, tert, dela, datajos, datasus
	into #tertiDePrelucrat
	from openxml(@iDoc, '/*/DateGrid/row')
	with
	(
		firma varchar(100) '@firma'
		,cui varchar(20) '@cui'
		,adresa varchar(100) '@adresa'
		,tipnou varchar(1) '@tipnou' 
		,tipvechi varchar(1) '@tipvechi'
		,modificare int '@modificare'
		,tert varchar(20) '@tert'
		,dela datetime '@dela'
		,datajos datetime '@datajos'
		,datasus datetime '@datasus'
	)
	where modificare=1
	EXEC sp_xml_removedocument @iDoc

	if @datasus is null
		select @datajos=max(datajos), @datasus=max(datasus) from #tertiDePrelucrat

	update #tertiDePrelucrat set dela=isnull((case when dela<@datajos then @datajos else dela end),@datajos)

	/* Acest SP va putea alter datele din tabelul tmp. #tertiDePrelucrat	*/
	IF EXISTS (SELECT *	FROM sysobjects	WHERE NAME = 'wOPModificariTipTVASP')
		exec wOPModificariTipTVASP @sesiune = @sesiune, @parXML = @parXML

	-->	Scriere in DocDeContat a documentelor (receptii si facturi furnizori) pentru tertii cu diferente.
	if object_id('tempdb..#facturi_cu_tli') is not null
		drop table #facturi_cu_tli
	create table  #facturi_cu_tli (tip varchar(2), tipf char(1), tert varchar(20),factura varchar(20),tip_TVA char(1),data datetime,cont varchar(20),numar varchar(20))
	insert #facturi_cu_tli (tip,tipf,tert,factura,tip_TVA,data,numar)
	select distinct p.tip,'F',t.tert,p.factura,'',p.data,p.numar
	from #tertiDePrelucrat t
		inner join pozdoc p on p.tert=t.tert and p.data>=t.dela and p.tip in ('RM','RS') and p.procent_vama=0
		inner join terti tt on t.cui=replace(replace(replace(isnull(tt.cod_fiscal,''), 'RO', ''), 'R', ''), ' ','')
	union all 
	select distinct p.tip,'F',t.tert,p.Factura_dreapta,'',p.data,p.Numar_document
	from #tertiDePrelucrat t
		inner join pozadoc p on p.tert=t.tert and p.data>=t.dela and p.tip in ('FF') and p.Stare=0
		inner join terti tt on t.cui=replace(replace(replace(isnull(tt.cod_fiscal,''), 'RO', ''), 'R', ''), ' ','')

	exec tipTVAFacturi '09/30/2016',@datasus --nu conteaza data. Ea se citeste din #facturi_cu_tli

	insert into DocDeContat (subunitate, tip, numar, data)
	select distinct @Subunitate, f.tip, f.numar, f.data
	from #tertiDePrelucrat t
		inner join terti tt on t.cui=replace(replace(replace(isnull(tt.cod_fiscal,''), 'RO', ''), 'R', ''), ' ','')
		inner join #facturi_cu_tli f on t.tert=f.tert
	where f.tip_TVA!=t.tipnou and (f.tip_TVA in ('I','P') or t.tipnou in ('I','P'))
		and not exists (select 1 from DocDeContat dd where dd.subunitate=@subunitate and dd.tip=f.tip and dd.numar=f.numar and dd.data=f.data)

	if object_id('tempdb..#facturi_cu_tli') is not null
		drop table #facturi_cu_tli

	-->	Tratat scriere diferente in TVAPeTerti.
	--setare context info pentru completare tip_tva in TVAPeTerti dinspre operatia de Verificare terti ANAF
	set @binar=cast('dinoperatiaverifanaf' as varbinary(128))
	set CONTEXT_INFO @binar
	insert into TvaPeTerti(Tert, dela,tip_tva,tipf,utilizator)
	select distinct 
		t.Tert, (case when t.dela<@datajos then @datajos else t.dela end), t.tipnou,'F', @utilizator
	from #tertiDePrelucrat t	
	inner join terti ta on t.cui=replace(replace(replace(isnull(ta.cod_fiscal,''), 'RO', ''), 'R', ''), ' ','')
	where not exists(select 1 from tvapeterti tt where tt.tert=t.tert and tt.dela=(case when t.dela<@datajos then @datajos else t.dela end) and tt.tipf='F' and nullif(tt.factura,'') is null )
	set CONTEXT_INFO 0x00

	--modificare abonati din UA
	if exists (select 1 from sysobjects o where o.type='U' and o.name='tvapeabonati')  and exists (select 1 from sysobjects o where o.type='P' and o.name='wOPModificariTipTVAUA') 
	begin
		exec wOPModificariTipTVAUA @sesiune=@sesiune,@parXML=@parXML
	end

	select 
		'Tertii au fost actualizati!' as textMesaj, 'Notificari' as titluMesaj
	for XML raw, root('Mesaje')
end try 

begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura wOPModificariTipTVA (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
