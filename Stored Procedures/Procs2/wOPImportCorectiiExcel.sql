--***
Create procedure wOPImportCorectiiExcel @sesiune varchar(50), @parXML xml    
as      
Begin try 
	if exists (select 1 from sysobjects where [type]='P' and [name]='wOPImportCorectiiExcelSP')
	begin
		exec wOPImportCorectiiExcelSP @sesiune=@sesiune, @parXML=@parXML output
		return
	end

	declare @utilizator varchar(20), @datajos datetime, @datasus datetime, @numefisier varchar(1000), @fisier varchar(1000), 
			@stergere int, @datacorectie datetime, @tipcorectie varchar(10), @tipsuma char(1), 
			@caleform varchar(1000), @cale_fisier varchar(1000), @subtipcor int, @dencorectie varchar(30)

	select @caleForm = RTRIM(val_alfanumerica) from par where Tip_parametru='AR' and Parametru='CALEFORM'
	select @subtipcor = RTRIM(val_logica) from par where Tip_parametru='PS' and Parametru='SUBTIPCOR'
	    
	select
		@datajos=isnull(@parXML.value('(/parametri/@datajos)[1]','datetime'),'01/01/1901'),
		@datasus=isnull(@parXML.value('(/parametri/@datasus)[1]','datetime'),'01/01/1901'),
		@numefisier=isnull(@parXML.value('(/parametri/@fisier)[1]','varchar(1000)'),''),
		@stergere=isnull(@parXML.value('(/parametri/@stergere)[1]','int'),0),
		@datacorectie=isnull(@parXML.value('(/parametri/@datacor)[1]','datetime'),@datasus),
		@tipcorectie=isnull(@parXML.value('(/parametri/@tipcor)[1]','varchar(10)'),''),
		@tipsuma=isnull(@parXML.value('(/parametri/@tipsuma)[1]','varchar(1)'),'B')

	if @subtipcor=1
		select @dencorectie=denumire from subtipcor where subtip=@tipcorectie
	else
		select @dencorectie=denumire from tipcor where tip_corectie_venit=@tipcorectie

	if @datajos='01/01/1901'
		select @datajos=dbo.BOM(@datacorectie), @datasus=dbo.EOM(@datacorectie)
	    
	set @cale_fisier=rtrim(@caleForm)+(case when right(rtrim(@caleForm),1)!='\' then '\' else '' end)+'uploads\'    
	set @fisier=rtrim(@cale_fisier)+rtrim(@numefisier)

	declare @sql varchar(8000), @mesajEroare varchar(1000), @lm varchar(9)    

	set @utilizator=dbo.fIaUtilizator(null)    

	if object_id('tempdb..#personal') is not null drop table #personal
--	pun datele din personal in tabela temporara ca sa nu fac apel la prefiltare din LMFiltrare in fiecare select.
	select p.* into #personal
	from personal p 
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=p.loc_de_munca
	where (dbo.f_areLMFiltru(@utilizator)=0 or lu.cod is not null) 
        
	-- sterg corectiile generate anterior    
	if @stergere=1
	begin
		if OBJECT_ID('tempdb..#c_sterse') is not null
			drop TABLE #c_sterse
		create table #c_sterse (data datetime, marca varchar(6), loc_de_munca varchar(9), tip_corectie_venit varchar(10))
		
		delete from corectii 
		OUTPUT deleted.data,deleted.marca,deleted.loc_de_munca,deleted.tip_corectie_venit
		into #c_sterse (data, marca, loc_de_munca, tip_corectie_venit) 
		where data=@datacorectie and Tip_corectie_venit=@tipcorectie and exists (select 1 from #personal p where p.Marca=corectii.Marca)

		if @numefisier=''
			select 
				'A fost stearsa corectia '+rtrim(@tipcorectie)+' ('+rtrim(@dencorectie)+') pentru '+convert(varchar, count(*))+' salariati.' textMesaj,'Finalizare stergere corectii' titluMesaj
			from #c_sterse
			for xml raw, root('Mesaje')
	end

	if @numefisier<>''
	begin
		set @sql = 'SELECT * into ##corectii
			FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',    
			''Excel 12.0;Database='+@fisier+';Extended Properties="Excel 12.0;HDR=Yes;IMEX=1;TypeGuessRows=0;ImportMixedTypes=Text"'',     
			''SELECT * FROM [Sheet1$]'')'    
	    
		if (select count(1) from tempdb..sysobjects where name='##corectii')>0 
			drop table ##corectii
		exec (@sql)    
		delete from ##corectii where marca is null or suma is null

--	mesaj de eroare daca sunt Marci in fisierul Excel care nu au definita marca in baza de date
		if exists (select 1 from ##corectii where marca not in (select marca from #personal where (Loc_ramas_vacant=0 or Data_plec>@datajos)))
		begin
			set @mesajEroare='Marca: '+(select top 1 rtrim(marca) from ##corectii where marca not in (select marca from #personal where (Loc_ramas_vacant=0 or Data_plec>@datajos)))
				+' nu are definita marca in baza de date! Nu s-a efectuat importul!!!'
			raiserror (@mesajEroare,16,1)
			return
		end	

		if (select count(1) from tempdb..sysobjects where name='#corectii')>0 
			drop table #corectii
		select @datacorectie as data, a.Marca, p.loc_de_munca, @tipcorectie as tip_corectie_venit, 
			(case when @tipsuma='B' then suma else 0 end) as suma_corectie, 0 as procent_corectie, (case when @tipsuma='B' then 0 else suma end) as suma_neta
		into #corectii
		from ##corectii a
			inner join #personal p on convert(varchar(6),a.marca)=p.marca

--	mesaj de eroare daca exista deja un import pe marca, loc de munca, data corectie, tip corectie venit.
		if exists (select 1 from corectii c inner join #corectii ci on ci.data=c.data and ci.marca=c.marca and ci.loc_de_munca=c.loc_de_munca and ci.tip_corectie_venit=c.tip_corectie_venit)
		begin
			set @mesajEroare='Exista deja date importate in conditiile selectate in macheta de import! Nu s-a efectuat importul!!!'
			raiserror (@mesajEroare,16,1)
			return
		end	
    
--scriere corectii
		begin tran preluareCorectiiExcel

			if OBJECT_ID('tempdb..#c_inserate') is not null
				drop TABLE #c_inserate
			create table #c_inserate(data datetime, marca varchar(6), loc_de_munca varchar(9), tip_corectie_venit varchar(10))

			/*	Pentru prelucrare tabela temporara #corectii. */
			if exists (select * from sysobjects where name ='wOPImportCorectiiExcelSP1')
				exec wOPImportCorectiiExcelSP1 @sesiune=@sesiune, @parXML=@parXML output

			insert into Corectii (Data,Marca,Loc_de_munca,Tip_corectie_venit,Suma_corectie,Procent_corectie,Suma_neta)    
			OUTPUT inserted.data,inserted.marca,inserted.loc_de_munca,inserted.tip_corectie_venit
			into #c_inserate (data, marca, loc_de_munca, tip_corectie_venit) 
			select data, marca, loc_de_munca, tip_corectie_venit, suma_corectie, procent_corectie, suma_neta
			from #corectii

			/*	Pentru a genera daca este cazul alte corectii sau alte tipuri de date (ex. retineri) in salarii. */
			if exists (select * from sysobjects where name ='wOPImportCorectiiExcelSP2')
				exec wOPImportCorectiiExcelSP2 @sesiune=@sesiune, @parXML=@parXML output

			select 
				'A fost importata corectia '+rtrim(@tipcorectie)+' ('+rtrim(@dencorectie)+') pentru '+convert(varchar, count(*))+' salariati.' textMesaj,'Finalizare import corectii' titluMesaj
			from #c_inserate
			for xml raw, root('Mesaje')
		commit tran preluareCorectiiExcel
	end

End try

begin catch
	if EXISTS (SELECT 1 FROM sys.dm_tran_active_transactions WHERE name = 'preluareCorectiiExcel')
		ROLLBACK TRAN preluareCorectiiExcel

	declare @eroare varchar(1000)
	set @eroare=ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@eroare, 16, 1)
end catch
    
/*    
 exec wOPImportCorectiiExcel 'BBB770C385121', '<parametri datajos="09/01/2014" datasus="09/30/2014" fisier="Import corectii.xlsx" stergere="1" tipcorectie='I-' />'
 select * from corectii where DATA='07-31-2015' and tip_corectie_venit='I-'    
*/