--***
Create procedure wScriuTichete @sesiune varchar(50), @parXML xml 
as
declare @marca varchar(6), @data datetime, @datalunii1 datetime, @tip varchar(40), @subtip varchar(2), @lmantet varchar(9), 
	@densalariat varchar(50), @denlmantet varchar(30), @denfunctie varchar(80), @salarincadrare decimal(10), @userASiS varchar(20), 
	@docXMLIaDLSalarii xml, @eroare xml, @mesaj varchar(1000)

begin try

	select @lmantet=xA.row.value('@lmantet', 'varchar(9)') from @parXML.nodes('row') as xA(row) 	

	if exists (select 1 from sysobjects where [type]='P' and [name]='wScriuTicheteSP')
		exec wScriuTicheteSP @sesiune, @parXML OUTPUT
	exec wValidareTichete @sesiune, @parXML
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS output

	declare @iDoc int
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @parXML

	if OBJECT_ID('tempdb..#dateTichete') is not null drop table #dateTichete
	if OBJECT_ID('tempdb..#descris') is not null drop table #descris

	create table #dateTichete
	(  
		tip varchar(20), subtip varchar(2), o_marca varchar(6), marca varchar(6), data datetime, o_tip_operatie varchar(1), tip_operatie varchar(1),
		o_serie_inceput varchar(13), serie_inceput varchar(13), serie_sfarsit varchar(13), 
		nr_tichete decimal(5), nr_tichete_cuvenite decimal(5), nr_tichete_stoc decimal(5), nr_tichete_supl decimal(5), nr_tichete_retinute decimal(5),
		valoare_tichet decimal(12,2), densalariat varchar(50), denlmantet varchar(30), denfunctie varchar(80), salarincadrare float, ptupdate int
	)  
	create table #descris
		(marca varchar(6), data_lunii datetime, tip_operatie varchar(1), serie_inceput varchar(13), serie_sfarsit varchar(13), nr_tichete real, valoare_tichet float)

	insert into #dateTichete
		(tip, subtip, o_marca, marca, data, o_tip_operatie, tip_operatie, o_serie_inceput, serie_inceput, serie_sfarsit, 
		nr_tichete, nr_tichete_cuvenite, nr_tichete_stoc, nr_tichete_supl, nr_tichete_retinute,
		valoare_tichet, densalariat, denlmantet, denfunctie, salarincadrare, ptupdate)
	select isnull(tip, '') as tip, isnull(subtip, '') as subtip, isnull(o_marca, isnull(marca, '')) as o_marca, 
		(case when isnull(marca, '')='' then isnull(marca_poz, '') else isnull(marca, '') end) as marca, 
		isnull(data, '01/01/1901') as data, 
		isnull(o_tip_operatie, '') as o_tip_operatie,
		isnull(tip_operatie, '') as tip_operatie,
		isnull(o_serie_inceput, '') as o_serie_inceput,
		isnull(serie_inceput, '') as serie_inceput,
		isnull(serie_sfarsit, '') as serie_sfarsit,
		isnull(nr_tichete, 0) as nr_tichete,
		isnull(nr_tichete_cuvenite, 0) as nr_tichete_cuvenite,
		isnull(nr_tichete_stoc, 0) as nr_tichete_stoc,
		isnull(nr_tichete_supl, 0) as nr_tichete_supl,
		isnull(nr_tichete_retinute, 0) as nr_tichete_retinute,
		isnull(valoare_tichet, 0) as valoare_tichet,
		isnull(densalariat,'') as densalariat,
		isnull(denlmantet,'') as denlmantet,
		isnull(denfunctie,'') as denfunctie,
		isnull(salarincadrare,0) as salarincadrare,
		isnull(ptupdate, 0) as ptupdate
	from OPENXML(@iDoc, '/row/row')
	WITH 
	(
		tip char(40) '../@tip', 
		subtip char(40) '@subtip', 
		o_marca varchar(6) '@o_marca', 
		marca varchar(6) '../@marca', 
		marca_poz varchar(6) '@marca', 
		data datetime '../@data', 
		o_tip_operatie char(1) '@o_tiptichet',
		tip_operatie char(1) '@tiptichet',
		o_serie_inceput float '@o_serieinceput',
		serie_inceput varchar(13) '@serieinceput',
		serie_sfarsit varchar(13) '@seriesfarsit',
		nr_tichete decimal(5) '@nrtichete', 
		nr_tichete_cuvenite decimal(5) '@nrtichetecuv', 
		nr_tichete_stoc decimal(5) '@nrtichetestoc',
		nr_tichete_supl decimal(5) '@nrtichetesupl',
		nr_tichete_retinute decimal(5) '@nrticheteret',
		valoare_tichet decimal(12,2) '@valtichet', 
		densalariat varchar(50) '../@densalariat', 
		denlmantet varchar(30) '../@denlmantet', 
		denfunctie varchar(30) '../@denfunctie', 
		salarincadrare float '../@salarincadrare', 
		ptupdate int '@update'
	)

	exec sp_xml_removedocument @iDoc 

	select top 1 @datalunii1=dbo.BOM(data), @data=dbo.EOM(data)
	from #dateTichete
	
	update t set t.valoare_tichet=pl.Val_numerica
	from #dateTichete t
	left outer join par_lunari pl on pl.data=t.data and pl.tip='PS' and pl.Parametru='VALTICHET'
	where t.valoare_tichet=0

	begin tran wScriuTichete
		if exists (select 1 from #dateTichete where ptupdate=1)
		begin
			if exists (select 1 from #dateTichete where tip='TM' and (marca<>o_marca or tip_operatie<>o_tip_operatie or serie_inceput<>o_serie_inceput))
				delete t
				from Tichete t 
				inner join #dateTichete d on t.Data_lunii=d.data and t.marca=d.o_marca and t.Tip_operatie=d.o_tip_operatie and t.Serie_inceput=d.o_serie_inceput
		end

		if exists (select 1 from #dateTichete where tip='TC')
		begin
			insert into #descris (marca, data_lunii, tip_operatie, serie_inceput, serie_sfarsit, nr_tichete, valoare_tichet)
			Select Marca, Data, 'C', '' as serie_inceput, '' as serie_sfarsit, nr_tichete_cuvenite, Valoare_tichet
			from #dateTichete 
			where nr_tichete_cuvenite<>0
			union all 
			Select Marca, Data, 'P', '' as serie_inceput, '' as serie_sfarsit, nr_tichete_stoc, Valoare_tichet
			from #dateTichete 
			where nr_tichete_stoc<>0
			union all 
			Select Marca, Data, 'R', '' as serie_inceput, '' as serie_sfarsit, nr_tichete_retinute, Valoare_tichet
			from #dateTichete 
			where nr_tichete_retinute<>0
		end
		else
		begin
			insert into #descris (marca, data_lunii, tip_operatie, serie_inceput, serie_sfarsit, nr_tichete, valoare_tichet)
			Select Marca, Data, Tip_operatie, Serie_inceput, Serie_sfarsit, Nr_tichete, Valoare_tichet
			from #dateTichete d
		end

		update t set 
			t.Serie_sfarsit=d.serie_sfarsit, t.Nr_tichete=d.nr_tichete, t.Valoare_tichet=d.valoare_tichet, t.Valoare_imprimat=0, t.TVA_imprimat=0
		from Tichete t 
			inner join #descris d on t.Data_lunii=d.data_lunii and t.marca=d.marca and t.Tip_operatie=d.Tip_operatie and t.Serie_inceput=d.Serie_inceput

		if exists (select 1 from sysobjects where [type]='P' and [name]='wScriuTicheteSP1')
			exec wScriuTicheteSP1 @sesiune, @parXML

		insert into Tichete (Marca, Data_lunii, Tip_operatie, Serie_inceput, Serie_sfarsit, Nr_tichete, Valoare_tichet, Valoare_imprimat, TVA_imprimat)
		Select d.marca, d.data_lunii, d.tip_operatie, d.serie_inceput, d.serie_sfarsit, d.nr_tichete, d.valoare_tichet, 0, 0
		from #descris d
		where not exists (select 1 from Tichete t where t.Data_lunii=d.data_lunii and t.Marca=d.Marca and t.Tip_operatie=d.Tip_operatie and t.Serie_inceput=d.Serie_inceput)

		delete t 
		from Tichete t 
		inner join #dateTichete d on t.Data_lunii=d.data and t.marca=d.marca
		where t.Nr_tichete=0

		/*	Daca operam pe o marca stabilim marca si apelam scrierea in istpers. */
		if (select count(1) from #dateTichete)=1
		begin
			select top 1 @tip=tip, @marca=marca, @densalariat=densalariat, @denlmantet=denlmantet, @denfunctie=denfunctie, @salarincadrare=salarincadrare
			from #dateTichete
			exec scriuistPers @DataJos=@datalunii1, @DataSus=@data, @pMarca=@marca, @pLocm='', @Stergere=0, @Scriere=1
		end
	commit tran wScriuTichete

	set @docXMLIaDLSalarii='<row tip="'+rtrim(@tip)+'" marca="'+rtrim(@marca)+'" lmantet="' +rtrim(@lmantet)+'" data="'+convert(char(10),@data,101)+'" densalariat="'
		+ rtrim(@densalariat)+'" denlmantet="'+rtrim(@denlmantet)+'" denfunctie="'+rtrim(@denfunctie)+'" salarincadrare="'+ rtrim(convert(char(10),convert(decimal(10,2),@salarincadrare)))+'"/>'
	exec wIaPozSalarii @sesiune=@sesiune, @parXML=@docXMLIaDLSalarii 

end try

begin catch
	if @@trancount>0 and EXISTS (SELECT 1 FROM sys.dm_tran_active_transactions WHERE name = 'wScriuTichete')
		ROLLBACK TRAN wScriuTichete

	if isnull(@eroare.value('(/error/@coderoare)[1]', 'int'), 0)=0
		set @mesaj=ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror(@mesaj, 11, 1)
end catch
