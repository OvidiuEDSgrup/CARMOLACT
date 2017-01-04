
CREATE procedure wScriuPontajElectronic @sesiune varchar(50), @parXML XML
as
begin try
	declare @subtip varchar(2), @idJurnalPE int, @marca varchar(6), @datalunii datetime, @update int, @operatie varchar(100), @docPozitii XML, @mesaj varchar(400)

	set @subtip = @parXML.value('(/*/*/@subtip)[1]', 'varchar(2)')
	set @marca = @parXML.value('(/*/@marca)[1]', 'varchar(6)')
	set @datalunii = @parXML.value('(/*/@data)[1]', 'datetime')
	set @operatie = @parXML.value('(/*/@operatie)[1]', 'varchar(100)')
	set @update = isnull(@parXML.value('(/*/*/@update)[1]', 'int'),0)

	if OBJECT_ID('tempdb..#PontajElectronic') is not null drop table #PontajElectronic
	create table #PontajElectronic
	(
		idPontajElectronic int, 
		marca varchar(6), 
		data_ora_intrare datetime,
		data_ora_iesire datetime,
		data_intrare datetime,
		o_data_intrare datetime,
		data_iesire datetime,
		o_data_iesire datetime,
		ora_intrare varchar(10),
		o_ora_intrare varchar(10),
		ora_intrare_ore varchar(2),
		ora_intrare_minute varchar(2),
		ora_iesire varchar(10),
		o_ora_iesire varchar(10),
		ora_iesire_ore varchar(2),
		ora_iesire_minute varchar(2),
		detalii xml, 
		idJurnalPE int, 
		_update int
	)

	declare @iDoc int,@rootDoc varchar(20),@multiDoc int
	set @multiDoc=0
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @parXML
	if @parXML.exist('(/Date)')=1 --Daca exista parametrul row de 2 ori inseamna ca se apeleaza din macheta de Ria
	begin
		set @rootDoc='/Date/row/row'
		set @multiDoc=1
	end	
	else
		set @rootDoc='/row/row'

	insert into #PontajElectronic
		(idPontajElectronic,marca,data_ora_intrare,data_ora_iesire,data_intrare,o_data_intrare,ora_intrare,o_ora_intrare,ora_intrare_ore,ora_intrare_minute,
		data_iesire,o_data_iesire,ora_iesire,o_ora_iesire,ora_iesire_ore,ora_iesire_minute,detalii,idJurnalPE,_update)
	select idPontajElectronic,(case when isnull(marca,'')='' then marca_antet else marca end),
		data_ora_intrare, data_ora_iesire, data_intrare, o_data_intrare, ora_intrare, o_ora_intrare, '', '', 
		data_iesire, o_data_iesire, ora_iesire, o_ora_iesire, '', '', detalii, idJurnalPE, _update
	from OPENXML(@iDoc, @rootDoc)
	WITH 
	(
		idPontajElectronic int '@idPontajElectronic',
		marca_antet varchar(6) '../@marca', 
		marca varchar(6) '@marca', 
		data_ora_intrare datetime '@dataoraintrare', 
		data_ora_iesire datetime '@dataoraiesire', 
		data_intrare datetime '@dataintrare', 
		o_data_intrare datetime '@o_dataintrare', 
		data_iesire datetime '@dataiesire', 
		o_data_iesire datetime '@o_dataiesire', 
		ora_intrare varchar(10) '@oraintrare', 
		o_ora_intrare varchar(10) '@o_oraintrare', 
		ora_iesire varchar(10) '@oraiesire', 
		o_ora_iesire varchar(10) '@o_oraiesire', 
		detalii xml '@detalii',
		idJurnalPE int '@idJurnalPE',
		_update bit '@update'
	)

--	pentru cazul in care procedura este apelata dinspre macheta (se va fac validarile pentru orele introduse)
	if @multiDoc=0
	Begin
--> validari (care nu se pot face in trigger):
		if exists (select 1 from #PontajElectronic p where isnull(ora_intrare,'')='' or isnull(ora_iesire,'')='')
			raiserror('Ati omis sa completati campurile corespunzatoare orei de intrare si/sau orei de iesire!',11,1)	
		
--	calculez ora inceput si sfarsit
		update #PontajElectronic set 
			ora_intrare_ore=isnull(oi.intrare_ora,'00'), ora_intrare_minute=isnull(mi.intrare_minute,'00'),
			ora_iesire_ore=isnull(oe.iesire_ora,'00'), ora_iesire_minute=isnull(me.iesire_minute,'00')
		from #PontajElectronic pe
			outer apply (select top 1 isnull(string,'00') as intrare_ora from dbo.fsplit(pe.ora_intrare,':') where id=1) oi
			outer apply (select top 1 isnull(string,'00') as intrare_minute from dbo.fsplit(pe.ora_intrare,':') where id=2) mi
			outer apply (select top 1 isnull(string,'00') as iesire_ora from dbo.fsplit(pe.ora_iesire,':') where id=1) oe
			outer apply (select top 1 isnull(string,'00') as iesire_minute from dbo.fsplit(pe.ora_iesire,':') where id=2) me

		if exists (select 1 from #PontajElectronic p where isnumeric(isnull(ora_intrare_ore,'00'))<>1 or isnumeric(isnull(ora_intrare_minute,'00'))<>1)
			raiserror('Ora intrare introdusa gresit! Formatul acceptat: 00:00',11,1)
		if exists (select 1 from #PontajElectronic p where isnumeric(isnull(ora_iesire_ore,'00'))<>1 or isnumeric(isnull(ora_iesire_minute,'00'))<>1)
			raiserror('Ora iesire introdusa gresit! Formatul acceptat: 00:00',11,1)

--	calculez ora intrare/ora iesire din ora si minute
		update #PontajElectronic set 
			ora_intrare=replace(isnull(str(ora_intrare_ore,2),'00'),' ','0')+':'+replace(isnull(str(ora_intrare_minute,2),'00'),' ','0')+':00', 
			ora_iesire=replace(isnull(str(ora_iesire_ore,2),'00'),' ','0')+':'+replace(isnull(str(ora_iesire_minute,2),'00'),' ','0')+':00'
--	formez data de pus in tabela
		update #PontajElectronic set 
			data_ora_intrare=data_intrare+convert(time,ora_intrare),
			data_ora_iesire=data_iesire+convert(time,ora_iesire)
	End

	if @operatie is null
		if @update=0
			set @operatie='Adaugare'
		else
			set @operatie='Modificare'

	set @parXML.modify ('insert attribute operatie {sql:variable("@operatie")} into (/row/row)[1]')

	if @update=0 or exists (select 1 from #PontajElectronic 
		where data_intrare<>o_data_intrare or ora_intrare<>o_ora_intrare or data_iesire<>o_data_iesire or ora_iesire<>o_ora_iesire)
	Begin
		exec wScriuJurnalPontajElectronic @sesiune=@sesiune, @parXML=@parXML output
		set @idJurnalPE = @parXML.value('(/*/@idJurnalPE)[1]', 'int')
	End

	update PontajElectronic set data_ora_intrare=p1.data_ora_intrare, data_ora_iesire=p1.data_ora_iesire, detalii = p1.detalii, 
		idJurnalPE=(case when @idJurnalPE is null then p.idJurnalPE else @idJurnalPE end)
	from PontajElectronic p
		inner join #PontajElectronic p1 on p.idPontajElectronic=p1.idPontajElectronic

	insert into PontajElectronic (Marca, data_ora_intrare, data_ora_iesire, idJurnalPE, detalii)
	select marca, data_ora_intrare, data_ora_iesire, @idJurnalPE, p.detalii
	from #PontajElectronic p
	where not exists (select 1 from PontajElectronic p1 where p1.idPontajElectronic=p.idPontajElectronic)

--> pentru apel direct din macheta:
	if @multiDoc=0
	begin
		set @docPozitii = (select @marca marca, @datalunii data for xml raw)
		exec wIaPontajElectronic @sesiune = @sesiune, @parXML = @docPozitii
	end	

end try

begin catch
	set @mesaj = ERROR_MESSAGE() + ' (wScriuPontajElectronic)'+'(linia '+convert(varchar(20),ERROR_LINE())+') :'

	raiserror (@mesaj, 11, 1)
end catch
