--***
/**	procedura pt. afisare salariati cu date necesare in revisal si necompletate */
Create procedure pValidariRevisal 
	(@dataJos datetime, @dataSus datetime, @Marca char(6)) --	@dataSus se trimite din PSplus ca data la care se genereaza registru
as
/*
	exemplu de apel
	if object_id('tempdb..#vRevisal') is not null
		drop table #vRevisal
	create table #vRevisal (data datetime)
	exec CreeazaDiezSalarii @numeTabela='#vRevisal'
	exec pValidariRevisal '04/01/2014', '04/30/2014', ''
	select * from #vRevisal
*/
begin
	declare @userASiS char(10), @oMarca int, @multiFirma int, 
		@ModifDateSalAmanate int, @NrZileAmanare int, @lunaInch int, @anulInch int, @dataInch datetime

	-- pt filtrare pe proprietatea LOCMUNCA a utilizatorului (daca e definita)
	set @userASiS=dbo.fIaUtilizator(null)
	select	
		@ModifDateSalAmanate=max(case when tip_parametru='PS' and Parametru='GREVMDSAM' then val_logica else 0 end),
		@NrZileAmanare=max(case when tip_parametru='PS' and Parametru='GREVMDSAM' then val_numerica else 0 end),
		@lunaInch=max(case when tip_parametru='PS' and Parametru='LUNA-INCH' then val_numerica else 0 end),
		@anulInch=max(case when tip_parametru='PS' and Parametru='ANUL-INCH' then val_numerica else 0 end)
	from par 
	where Tip_parametru in ('PS','SP') 
		and Parametru in ('GREVMDSAM','LUNA-INCH','ANUL-INCH')
	set @dataInch=dbo.EOM(convert(datetime,str(@lunaInch,2)+'/01/'+str(@anulInch,4)))
	
	if exists (select * from sysobjects where name ='pValidariRevisalSP')
		exec pValidariRevisalSP @dataJos, @dataSus, @Marca
	
	set @oMarca=(case when @Marca<>'' then 1 else 0 end)
	select @multiFirma=0
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1
	
	create table #tmpValidari  
		(Data datetime, Marca char(6), Nume char(50), CodSiruta varchar(10), FunctieCOR char(10), FunctieCORErr char(10), NrContract varchar(20), TemeiIncetare char(30), 
		DataIncheiere datetime, DataAngajarii datetime, DataSfarsit datetime, ExceptieDataSfarsit varchar(100), Plecat int, Data_plecarii datetime Unique (Data, Marca))

	insert into #tmpValidari
	select dbo.EOM(@dataJos) as data, p.Marca, p.Nume, 
		(case when c.Val_inf not in ('','Romana') then 'Nu validam' else isnull(l.cod_postal,'') end), -- nu validam codul siruta pentru persoanele care au alta cetatenie decat cea Romana
		isnull(fc.Val_inf,''), (case when fcor.Cod_functie is null then isnull(fc.Val_inf,'') else '' end) as FunctieCorErr, 
		isnull(isnull(nullif(p.Nr_contract,''),ip.Nr_contract),''), 
		(case when convert(char(1),p.Loc_ramas_vacant)='1' then isnull(t.Val_inf,'') else 'Activ' end), 
		isnull(dc.Data_inf,'01/01/1901'), p.Data_angajarii_in_unitate, (case when p.Mod_angajare='D' then p.Data_plec end), rtrim(isnull(eds.Val_inf,'')),
		convert(int,p.Loc_ramas_vacant) as plecat, p.Data_plec as data_plecarii
	from personal p
		left outer join infopers ip on ip.Marca=p.Marca
		left outer join extinfop cs on cs.Marca=p.Marca and cs.Cod_inf='CODSIRUTA'
		left outer join Localitati l on l.cod_oras=cs.Val_inf 
		left outer join extinfop c on c.Marca=p.Marca and c.Cod_inf='RCETATENIE'
		left outer join extinfop fc on fc.Marca=p.Cod_functie and fc.Cod_inf='#CODCOR'
		left outer join Functii_COR fcor on fcor.Cod_functie=fc.Val_inf
		left outer join extinfop t on t.Marca=p.Marca and t.Cod_inf='RTEMEIINCET'
				and (t.Val_inf<>'' or t.Val_inf='' and not exists (select 1 from extinfop t1 where t1.cod_inf=t.cod_inf and t1.Marca=t.Marca and t1.Val_inf<>''))
		left outer join extinfop dc on dc.Marca=p.Marca and dc.Cod_inf='DATAINCH'
		left outer join extinfop eds on eds.Marca=p.Marca and eds.Cod_inf='EXCEPDATASF'
	where (@oMarca=0 or p.Marca=@Marca) and p.grupa_de_munca not in ('O','P','') 
		and (convert(char(1),p.Loc_ramas_vacant)='0' or p.Data_plec>='08/01/2011' or @multiFirma=1 and dc.Data_inf>='01/01/2013')	
		and p.Mod_angajare not in ('R','F')

	if object_id('tempdb..#vRevisal') is null
	begin
		create table #vRevisal (data datetime)
		exec CreeazaDiezSalarii @numeTabela='#vRevisal'
	end
	insert #vRevisal
	select Data, Marca, Nume, 'Cod Siruta necompletat!' 
	from #tmpValidari where CodSiruta=''
	union all 
	select Data, Marca, Nume, 'Functie COR necompletata!'
	from #tmpValidari where FunctieCOR=''
	union all 
	select Data, Marca, Nume, 'Functie COR ('+rtrim(FunctieCorErr)+') inexistenta in catalogul de "Functii COR"!'
	from #tmpValidari where FunctieCORErr<>'' 
	union all 
	select Data, Marca, Nume, 'Numar contract de munca necompletat!'
	from #tmpValidari where NrContract=''
	union all
	select Data, Marca, Nume, 'Data incheiere contract necompletata!'
	from #tmpValidari where DataIncheiere='01/01/1901' or DataIncheiere='01/01/1900'
	union all
	select Data, Marca, Nume, 'Data incepere contract (data angajarii) necompletata!'
	from #tmpValidari where DataAngajarii='01/01/1901' or DataAngajarii='01/01/1900'
	union all
	select Data, Marca, Nume, 'Data sfarsit contract necompletata'
	from #tmpValidari where DataSfarsit='01/01/1901' and ExceptieDataSfarsit=''
	union all
	select t.Data, t.Marca, t.Nume, 'Numar contract de munca - '+rtrim(t.NrContract)+ ' - apare la mai multe marci!'
	from  #tmpValidari t
	left outer join (select NrContract, count(1) as ordine from #tmpValidari where (Plecat=0 or data_plecarii>='01/01/2012') and rtrim(NrContract)<>'' group by NrContract) j 
			on t.NrContract=j.NrContract and j.ordine>1
	where j.NrContract is not null
		and (Plecat=0 or data_plecarii>='01/01/2012')
	union all
	select Data, Marca, Nume, 'Temei legal de incetare contract necompletat'
	from #tmpValidari where TemeiIncetare=''
	order by Nume


--	validare data sfarsit contract pe perioada determinata
	insert #vRevisal
	select dbo.EOM(@dataJos) as data, p.Marca, p.Nume, 'Data sfarsit contract perioada determinata '+convert(char(10),p.Data_plec,103)+', incorecta!' 
	from Personal p 
	where DateADD(day,@NrZileAmanare,p.Data_plec)<@dataSus
		and p.Mod_angajare='D' --and p.data_plec not in ('01/01/1901','01/01/1900') 
		and p.grupa_de_munca not in ('O','P','') 
		and p.Loc_ramas_vacant=0
		and not exists (select 1 from #tmpValidari t where t.marca=p.marca and t.ExceptieDataSfarsit<>'')
end