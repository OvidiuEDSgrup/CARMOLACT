--***
/* procedura pentru calcul indemnizatii concedii de odihna (brute/nete), prima de vacanta */
Create procedure CalculConcediiDeOdihna (@sesiune varchar(50), @parXML xml)
As
/*
	declare @parXML xml
	set @parXML=(select '12/01/2015' as datajos, '12/31/2015' as datasus, '' as marca for xml raw)
	exec CalculConcediiDeOdihna @sesiune=null, @parXML=@parXML
*/
Begin try
	-- parametri cititi din XML
	DECLARE @dataJos datetime, @dataSus datetime, @luna int, @an int, @datalunii datetime, 
		@pMarca char(6), @pData_inceput datetime, @pZile_lucratoare int, @pIndemnizatie_CO float, @pLocm char(9), @pCalcul_prima int, @Procent_prima float, 
		@pCalcul_CO_net int, @pCalcul_COnet_prima int, @lData_op int, @dData_op datetime, @Calcul_CO_net_FDP int, @Recalc_CO_luniant int,
		@StergCONetAnt int
	-- parametri generali
	declare @Utilizator char(10), @lista_lm int, @nLunaInch int, @nAnulInch int, @dDataInch datetime, @Ani_vechime int, @lCalcul_prima int, @Baza_calcul_prima char(1), 
		@Pun_ore_in_pontaj int,	@nSomaj float, @nCasindiv float, @lBuget int, @lInstitutie int,@Sindrom int,@Stoehr int, @Spicul int,
		@COEV_macheta int, @RotIndCO int, @Pontaj_zilnic int, 
		@cCod_sindicat char(13), @Detaliere_retineri int, @Data_inchisa_1 datetime, @Codb_exceptie char(1000), @dataSus_next datetime, @SubtipCor int, 
		@nData_op datetime, @procentPrima float, @PeLM int, @TipCorectie char(2)

	select @PeLm=0, @TipCorectie='O-'
-- citire parametri XML
	select 
		@dataJos=@parXML.value('(/*/@datajos)[1]','datetime'),
		@dataSus=@parXML.value('(/*/@datasus)[1]','datetime'),
		@pMarca=isnull(@parXML.value('(/*/@marca)[1]','varchar(6)'), ''),
		@pData_inceput=isnull(@parXML.value('(/*/@datainceput)[1]','datetime'), '1901-01-01'),
		@pZile_lucratoare=@parXML.value('(/*/@zilelucr)[1]','int'),
		@pIndemnizatie_CO=@parXML.value('(/*/@indco)[1]','float'),
		@pLocm=isnull(@parXML.value('(/*/@lm)[1]','varchar(9)'), ''),
		@pCalcul_prima=isnull(@parXML.value('(/*/@calcprimav)[1]','int'),0),
		@Procent_prima=isnull(@parXML.value('(/*/@procprimav)[1]','float'),0),
		@pCalcul_CO_net=isnull(@parXML.value('(/*/@calcconet)[1]','int'),0),
		@pCalcul_COnet_prima=isnull(@parXML.value('(/*/@calcconetprv)[1]','int'),0),
		@lData_op=isnull(@parXML.value('(/*/@odataop)[1]','int'),0),
		@dData_op=isnull(@parXML.value('(/*/@dataop)[1]','datetime'), '1901-01-01'),
		@Calcul_CO_net_FDP=isnull(@parXML.value('(/*/@calcconetfdp)[1]','int'),0),
		@Recalc_CO_luniant=isnull(@parXML.value('(/*/@recalccolant)[1]','int'),0),
		@StergCONetAnt=isnull(@parXML.value('(/*/@stergconet)[1]','int'),0),
		@procentPrima=@Procent_prima

	/*	Tratat si cazul in care in parXML s-ar trimite luna/anul pentru calcul. Dinspre ASiSria s-ar trimite direct in parXML din frame. */
	if @datajos is null
	begin
		set @luna = ISNULL(@parXML.value('(/*/@luna)[1]', 'int'), 0)
		set @an = ISNULL(@parXML.value('(/*/@an)[1]', 'int'), 0)
		if @luna<>0 and @an<>0
			set @datalunii=dbo.eom(convert(datetime,str(@luna,2)+'/01/'+str(@an,4)))
		set @dataJos = dbo.bom(@datalunii)
		set @dataSus = dbo.eom(@datalunii)
	end	

--  citire parameri din PAR
	select	
		@Pun_ore_in_pontaj=max(case when Parametru='ORECOPONT' then val_logica else 0 end),
		@lCalcul_prima=max(case when Parametru='PV%-INDCO' then val_logica else 0 end),
		@Procent_prima=max(case when Parametru='PV%-INDCO' then val_numerica else 0 end),
		@Baza_calcul_prima=max(case when Parametru='PV%-INDCO' then val_alfanumerica else '' end),
		@lInstitutie=max(case when Parametru='INSTPUBL'then val_logica else 0 end),
		@Sindrom=max(case when Parametru='SINDROM'then val_logica else 0 end),
		@Stoehr=max(case when Parametru='STOEHR'then val_logica else 0 end),
		@Spicul=max(case when Parametru='SPICUL'then val_logica else 0 end),
		@COEV_macheta=max(case when Parametru='COEVMCO'then val_logica else 0 end),
		@RotIndCO=max(case when Parametru='ROTINDCO'then val_numerica else 0 end),
		@Pontaj_zilnic=max(case when Parametru='PONTZILN'then val_logica else 0 end),
		@nLunaInch=max(case when tip_parametru='PS' and Parametru='LUNA-INCH'then val_numerica else 1 end),
		@nAnulInch=max(case when tip_parametru='PS' and Parametru='ANUL-INCH'then val_numerica else 1901 end),
		@cCod_sindicat=max(case when Parametru='SIND%' then Val_alfanumerica else '' end),
		@Codb_exceptie=max(case when Parametru='CO-RET' then Val_alfanumerica else '' end),
		@SubtipCor=max(case when Parametru='SUBTIPCOR' then Val_logica else 0 end), 
		@lBuget=max(case when parametru='UNITBUGET' then Val_logica else 0 end)
	from par 
	where Tip_parametru in ('PS','SP') 
		and Parametru in ('ORECOPONT','PV%-INDCO','SOMAJIND','CASINDIV','UNITBUGET','INSTPUBL','COEVMCO','ROTINDCO','PONTZILN',
			      'SINDROM','STOEHR','LUNA-INCH','ANUL-INCH','SIND%','CO-RET','SUBTIPCOR',
				  'COEVMCO','CO-OUG65','MEDVB_CO','CO-SP-V','CO-F-SPL','CO-SPEC','CO-S-PR','CO-IND',
				  'CO-SP1','CO-SP2','CO-SP3','CO-SP4','CO-SP5','CO-SP6','CO-SP7','SSP-SUMA','SC1-SUMA','SC2-SUMA','SC3-SUMA','SC4-SUMA','SC5-SUMA','SC6-SUMA',
				  'SPFS-SUMA','INDC-SUMA','CO-SPFIX','CO-COMP','SUMACOMP','SP-V-INDC','CALCUL-CO','CO-NRZILE','SSPEC',
				  'REGIMLV','UNITBUGET','ELCOND','DAFORA','REMARUL','NRMEDOL','ORET_LUNA')
	
	select @nSomaj=max(case when data=@dataSus and tip='PS' and Parametru='SOMAJIND' then val_numerica else 0 end),
		   @nCasindiv=max(case when data=@dataSus and tip='PS' and Parametru='CASINDIV' then val_numerica else 0 end)
	from par_lunari
	where parametru in ('SOMAJIND','CASINDIV')

	if @procentPrima<>0
		Set @Procent_prima=@procentPrima

	Set @nData_op=datediff(day,convert(datetime,'01/01/1901'),@dData_op)+69396

	SET @Utilizator = dbo.fIaUtilizator('')
	set @lista_lm = dbo.f_areLMFiltru(@utilizator)
	IF @Utilizator IS NULL or @nLunaInch not between 1 and 12 or @nAnulInch<=1901
		RETURN -1
	set @dDataInch=dbo.eom(convert(datetime,str(@nLunaInch,2)+'/01/'+str(@nAnulInch,4)))
	if @datajos is null
		raiserror('(CalculConcediiDeOdihna) Nu s-a trimis corect perioada de calcul concedii de odihna!' ,16,1)
	--	verific luna inchisa
	IF @dataSus<=@dDataInch
	Begin
		raiserror('(CalculConcediiDeOdihna) Luna pe care doriti sa efectuati calcul concedii de odihna este inchisa!' ,16,1)
		RETURN -1
	End	

--  initializari
	set @dataSus_next=dbo.eom(dateadd(month,1,@dataSus))
	if @pMarca is null set @pMarca=''
	if @pLocm is null set @pLocm=''

--	Procedura de generare concedii de odihna in avans fata de luna curenta (acele concedii din luna curenta care au data sfarsit > data de final a lunii de calcul).
	exec psGenerare_CO @dataJos=@dataJos, @dataSus=@dataSus, @marca=@pmarca, @lm=@pLocm

--	Generare #tempCO  -  cursorul unde se tin toate datele pentru concediu de odihna
	if object_id('tempdb..#personalCO') is not null
		drop table #personalCO

	if object_id('tempdb..#tmpPontaj') is not null
		drop table #tmpPontaj

	if object_id('tempdb..#primaVacanta') is not null
		drop table #primaVacanta

	if object_id('tempdb..#tempCO') is not null
		drop table #tempCO

	select p.* 
	into #personalCO
	from personal p 
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=p.loc_de_munca
	where (isnull(@pmarca,'')='' or p.Marca=@pmarca) 
		and (@pLocm='' or p.Loc_de_munca like rtrim(@pLocm)+'%')
		and (@lista_lm=0 or lu.cod is not null)

	select po.Marca, max(po.Tip_salarizare) as Tip_sal, max(po.Regim_de_lucru) as RL 
	into #tmpPontaj
	from pontaj po
	inner join #personalCO p on p.marca=po.marca  
	where po.data between @dataJos and @dataSus
	group by po.Marca

	select c.marca, count(1) as contor
	into #primaVacanta
	from corectii c 
	inner join #personalCO p on p.marca=c.marca  
	inner join concodih co on co.marca=c.marca and co.data between dbo.BOY(co.data) and co.data_inceput-1
	where c.data between dbo.boy(co.data) and co.data_inceput-1 and c.tip_corectie_venit='O-'
	group by c.marca

	if object_id('tempdb..#tmpCorectie') is not null
		drop table #tmpCorectie
	create table #tmpCorectie (data datetime, marca varchar(6), Loc_de_munca char(9), Tip_corectie char(2), suma_corectie float, suma_neta float)

	insert into #tmpCorectie
	select dbo.eom(c.data) as Data, c.marca, (case when @PeLm=1 then c.Loc_de_munca else '' end) as Loc_de_munca, 
		isnull(nullif(s.Tip_corectie_venit,''),c.Tip_corectie_venit) as tip_corectie, 
		round(round(sum(c.Suma_corectie),2),10,2) as Suma_corectie, round(round(sum(c.Suma_neta),2),10,2) as Suma_neta
	from corectii c 
		inner join #personalCO p on p.marca=c.marca  
		left outer join subtipcor s on s.subtip=c.Tip_corectie_venit
	where c.data between @dataJos and @dataSus and (isnull(@pmarca,'')='' or c.Marca=@pmarca) 
		and (isnull(@TipCorectie,'')='' or @Subtipcor=0 and c.tip_corectie_venit=@TipCorectie 
			or @Subtipcor=1 and (c.Tip_corectie_venit in (select s.Subtip from Subtipcor s where s.tip_corectie_venit=@TipCorectie) or c.Tip_corectie_venit=@TipCorectie))
	group by dbo.eom(c.data), c.Marca, (case when @PeLm=1 then c.Loc_de_munca else '' end), isnull(nullif(s.Tip_corectie_venit,''),c.Tip_corectie_venit)
	order by dbo.eom(c.data), c.Marca, (case when @PeLm=1 then c.Loc_de_munca else '' end), isnull(nullif(s.Tip_corectie_venit,''),c.Tip_corectie_venit)

	create table #tempCO (data datetime)
	exec CreeazaDiezSalarii @numeTabela='#tempCO'
	insert into #tempCO (data, marca, tip_CO, Data_inceput, Data_sfarsit, Zile_CO, introd_manual, Indemnizatie_CO, Zile_prima_vacanta, nDataInreg, dDataInreg, Tip_sal, RL, 
		Loc_de_munca, Grupa_de_munca, Salar_de_incadrare, Salar_de_baza, Tip_salarizare, Somaj_1, CASS, Zile_concediu_de_odihna, Data_angajarii_in_unitate, 
		Tip_colab, Funct_public, Salar_de_baza_istpers, Data_primei, Prima_vacanta, Data_inceput_CO, Data_primei_datainc, Prima_vacanta_datainc, Gasit_prima_ant,
		Ore_luna, media_zilnica, DataModifSalar, Suma_CO, ordine, Ore_CO, venit_net, deducere_pers, venit_baza, impozit, retineri_CO, vPrimaVacanta, 
		baza_stagiu_luna, zile_stagiu_luna,	baza_stagiu1, zile_stagiu1, baza_stagiu2, zile_stagiu2, baza_stagiu3, zile_stagiu3, condCalcul, condCalculNet)
	Select a.data as data, a.marca as marca, a.tip_concediu as tip_CO, a.Data_inceput as Data_inceput, a.Data_sfarsit as Data_sfarsit, 
	    a.Zile_CO as Zile_CO, a.Introd_manual as Introd_manual,a.Indemnizatie_CO as Indemnizatie_CO, a.Zile_prima_vacanta as Zile_prima_vacanta,
		a.Prima_vacanta as nDataInreg, '01/01/1901' as dDataInreg, isnull(j.Tip_sal,'') as Tip_sal, isnull(j.RL,8) as RL, 
		p.Loc_de_munca as Loc_de_munca, p.Grupa_de_munca as Grupa_de_munca, p.Salar_de_incadrare as Salar_de_incadrare, 
		p.Salar_de_baza as Salar_de_baza,p.Tip_salarizare as Tip_salarizare, p.Somaj_1 as Somaj_1, p.As_sanatate as CASS, 
		p.Zile_concediu_de_odihna_an as Zile_concediu_de_odihna, p.Data_angajarii_in_unitate as Data_angajarii_in_unitate, 
		p.Tip_colab as Tip_colab, isnull(p.detalii.value('(/row/@functpublic)[1]','int'),convert(int,ip.Actionar)) as Funct_public, i.Salar_de_baza as Salar_de_baza_istpers, 
		isnull(c.Data,'') as Data_primei, isnull(c.Suma_corectie,0) as Prima_vacanta, isnull(d.Data_inceput,'') as Data_inceput_CO, 
		isnull(c1.Data,'') as Data_primei_datainc, isnull(c1.Suma_corectie,0) as Prima_vacanta_datainc,isnull(pv.contor,0) as Gasit_prima_ant,
		(case when isnull(ol.Val_numerica,0)=0 then dbo.zile_lucratoare(dbo.bom(a.Data),a.Data)*8 else isnull(ol.val_numerica,0) end) as Ore_luna,
		convert(float,0) as media_zilnica_co, convert(datetime,'01/01/1901',101) as DataModifSalar, 0 as Suma_CO,
		row_number() over (partition by a.marca order by a.Data) as ordine, 0 as Ore_CO,0 as venit_net, 0 as deducere_pers, 0 as venit_baza,
		0 as impozit, 0 as retineri_CO, 0 as vPrimaVacanta, 
		0 as baza_stagiu_luna, 0 as zile_stagiu_luna, 0 as baza_stagiu1, 0 as zile_stagiu1, 0 as baza_stagiu2, 0 as zile_stagiu2, 
		0 as baza_stagiu3, 0 as zile_stagiu3, 
		(case when (not(a.tip_concediu in ('7','8') and year(a.Data_inceput)=year(@dataJos) and month(a.Data_inceput)=month(@dataJos)) or @Recalc_CO_luniant=1) and a.Introd_manual=0 then 1 else 0 end), 
		(case when (a.tip_concediu in ('1','3','4','6','7','8') or @COEV_macheta=1 and a.tip_concediu='2') and  
			(not(a.tip_concediu in ('7','8') and year(a.Data_inceput)=year(@DataJos) and month(a.Data_inceput)=month(@DataJos)) or @Recalc_CO_luniant=1) then 1 else 0 end)
	from concodih a 
		inner join #personalCO p on a.marca=p.marca
		left outer join infopers ip on ip.Marca=a.Marca
		left outer join istpers i on a.Data-1=i.Data and a.marca=i.marca
		left outer join #tmpPontaj j on a.Marca=j.Marca
		left outer join #tmpCorectie c on c.Data=a.Data and c.Marca=a.Marca
		left outer join concodih d on a.Data=d.Data and a.Marca=d.Marca and c.Data=d.Data_inceput and d.tip_concediu between '1' and '4'
		left outer join corectii c1 on a.Data_inceput=c1.Data and a.Marca=c1.Marca and c1.tip_corectie_venit='O-'
		left outer join #primaVacanta pv on a.marca=pv.marca 
		left outer join par_lunari ol on a.data=ol.data and ol.tip='PS' and ol.parametru='ORE_LUNA'
	where /*a.data between @dataJos and @dataSus and*/ 
		(@pData_inceput='01/01/1901' or a.Data_inceput=@pData_inceput) and (@lData_op=0 or a.Prima_vacanta=@nData_op)
		and a.Tip_concediu not in ('9','C','P','V') and (a.Data=@dataSus and a.Tip_concediu in ('1','2','3','4','5','6','7','8','E') 
			or a.Data>@dataSus and a.Tip_concediu in ('7','8') and a.Prima_vacanta in 
			(select co.Prima_vacanta from concodih co where co.data=@dataSus and co.marca=a.Marca and co.tip_concediu in ('1','4')))
	order by a.marca, a.data 
		
-- sfarsit generat #tempCO

-- Update la zile_CO si ore_CO pentru specifice
	if exists (select * from sys.objects WHERE object_id = OBJECT_ID(N'zile_lucratoareSP') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		update #tempCO
		set Zile_CO=dbo.zile_lucratoareSP(Data_inceput, Data_sfarsit, Marca)
	if exists (select * from sys.objects WHERE object_id = OBJECT_ID(N'ore_lucratoareSP') and type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		update #tempCO
		set Ore_CO=dbo.ore_lucratoareSP(Data_inceput, Data_sfarsit, Marca)

-- calculam zilele si orele pe marca
	select marca, 
			sum((case when Tip_CO in ('1','4','5') or Tip_CO in ('7','8') and year(Data_inceput)=year(@dataJos) and month(Data_inceput)=month(@dataJos) 
			then (case when Tip_CO='5' then -1 else 1 end)* Zile_CO else 0 end)) as zileCoMarca, 
			sum((case when Tip_CO in ('1','4','5') or Tip_CO in ('7','8') and year(Data_inceput)=year(@dataJos) and month(Data_inceput)=month(@dataJos) 
			then (case when Tip_CO='5' then -1 else 1 end)* Ore_CO else 0 end)) as oreCoMarca
	into #tempSumePontaj
	from #tempCO tm
	group by marca
	order by marca

	select po.marca, po.Numar_curent, max(convert(int,po.loc_munca_pentru_stat_de_plata)) as LMStat 
	into #tempLM
	from pontaj po
		inner join #personalCO p on p.marca=po.marca
	where po.data between @dataJos and @dataSus and loc_munca_pentru_stat_de_plata=1
	group by po.marca, po.Numar_curent

-- update la pontaj cu orele de concediu de odihna
	update po
	set po.ore_concediu_de_odihna=isnull((case when t.oreCoMarca<>0 then t.oreCoMarca else t.zileCoMarca*po.regim_de_lucru end),po.ore_concediu_de_odihna)
	from pontaj po
		inner join #personalCO p on p.marca=po.marca
		left outer join #tempSumePontaj t on t.marca=po.marca 
		left outer join #tempLM lm on lm.marca=po.marca and lm.Numar_curent=po.Numar_curent
	where @Pun_ore_in_pontaj=1 and @Pontaj_zilnic=0	-- tratat sa nu se faca actualizarea orelor in pontaj daca Pontaj zilnic (ar trebui actualizata fiecare zi din pontaj nu doar ultima zi)
		and (po.data between @dataJos and @dataSus)
		and lm.LMStat is not null
		and @pData_inceput='01/01/1901' 

	-- se calculeaza indemnizatia de concediu
	if exists (select * from sys.objects WHERE object_id = OBJECT_ID(N'calcul_indemnizatie_COSP') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		update #tempCO
			set Indemnizatie_CO=dbo.calcul_indemnizatie_COSP (@dataJos, @dataSus, data, marca, Tip_CO, Zile_CO, RL, Data_inceput, Data_sfarsit)
		where condCalcul=1
	else
	begin 
		if object_id('tempdb..#modifSalar') is not null
		drop table #modifSalar

		select marca,  max(data_inf) as modif_salar, Data_inf
		into #modifSalar
		from Extinfop
		where Cod_inf='SALAR' and Procent>1 and (@pMarca='' or marca=@pMarca)
		group by marca,data_inf

		update tm
		set DataModifSalar=m.modif_salar
		from #tempCO tm
		inner join #modifSalar m on tm.marca=m.Marca and m.Data_inf between dbo.bom(tm.data) and tm.data

		if object_id('tempdb..#modifSalar') is not null
		drop table #modifSalar
	--	inserez salariul si zilele pt. perioada pana la schimbarea salarului
		update tm
		set tm.Salar_de_incadrare=(case when tm.DataModifSalar between dbo.bom(tm.data) and tm.data
				then (case when day(tm.DataModifSalar)<>1 and (tm.DataModifSalar between tm.Data_inceput and tm.Data_sfarsit or tm.DataModifSalar>tm.Data_sfarsit) 
					then isnull((case when @lBuget=1 then i.Salar_de_baza else i.Salar_de_incadrare end),(case when @lBuget=1 then p.Salar_de_baza else p.Salar_de_incadrare end)) 
			else (case when @lBuget=1 then p.Salar_de_baza else p.Salar_de_incadrare end) end) else (case when @lBuget=1 then p.salar_de_baza else p.salar_de_incadrare end) end)
			,tm.Zile_CO=(case when day(tm.DataModifSalar)<>1 and tm.DataModifSalar between tm.Data_inceput and tm.Data_sfarsit 
				then dbo.zile_lucratoare(tm.Data_inceput,tm.DataModifSalar-1) else tm.Zile_CO end)
		from #tempCO tm
			left outer join istPers i on isnull(i.Data,0)=DateAdd(DAY,-1,@dataJos) and i.Marca=tm.Marca 
			left outer join personal p on tm.marca=p.marca
		where (not(tm.Tip_CO in ('7','8') and year(tm.Data_inceput)=year(@dataJos) and month(tm.Data_inceput)=month(@dataJos))
				or @Recalc_CO_luniant=1) and tm.Introd_manual=0

		/*	Apelare procedura ce va calcul media zilnica finala si indemnizatia de CO, tinand cont de setari, etc.*/
		exec pCalculCO @dataJos, @dataSus, @pMarca, @Recalc_CO_luniant
	end 

	update co 
	Set co.Indemnizatie_CO=round(tm.Indemnizatie_CO,@RotIndCO), co.Zile_CO=(case when co.Zile_CO<>tm.Zile_CO then tm.Zile_CO else co.Zile_CO end)
	from concodih co
	inner join #tempCO tm on co.marca=tm.marca and co.data=tm.data and co.Tip_concediu=tm.tip_CO and co.Data_inceput=tm.Data_inceput

	-- calculam prima de vacanta
	if @pCalcul_prima=1 and @Baza_calcul_prima='1'
		update #tempCO set vPrimaVacanta=0
		where condCalcul=1

	if @pCalcul_prima=1 and @Sindrom=1
		update #tempCO 
		Set vPrimaVacanta=Indemnizatie_CO*(case when @Ani_vechime<3 then 0.5 
			when @Ani_vechime<5 then 0.55 when @Ani_vechime<10 then 0.6     -- trebuie tratata problema cu @Ani_vechime nu se initializeaza nicaieri
			when @Ani_vechime<15 then 0.65 else 0.7 end)
		where condCalcul=1

	if (@Stoehr=1 or @pCalcul_prima=1 and @Baza_calcul_prima='1') and @Sindrom=0
		update #tempCO
		Set vPrimaVacanta=Prima_vacanta+(case when tip_CO in ('1','3','4') 
			then Indemnizatie_CO*(case when @pCalcul_prima=1 and @Procent_prima<>0 then @Procent_prima/100 else 1 end) else 0 end)
		where condCalcul=1

	if @Spicul=1 or @pCalcul_prima=1 and @Baza_calcul_prima='2' 
		update #tempCO
		Set vPrimaVacanta=(case when @lBuget=1 or @lInstitutie=1 
			then (case when Funct_public=1 then Salar_de_baza_istpers else Salar_de_baza end) 
			else Salar_de_incadrare end)*@Procent_prima/100*(case when Data_angajarii_in_unitate<dbo.boy(@DataSus) then 12 
			else 12-month(Data_angajarii_in_unitate)+(case when day(Data_angajarii_in_unitate)=1 then 1 else 0 end) end)/12
		where condCalcul=1 and Gasit_prima_ant=0

	if @pCalcul_prima=1 and @Baza_calcul_prima='5' 
		update #tempCO
			Set vPrimaVacanta=(case when Media_zilnica_co=0 then Indemnizatie_CO/Zile_CO else Media_zilnica_co end)*Zile_concediu_de_odihna*@Procent_prima/100
		where condCalcul=1 and Gasit_prima_ant=0

	If @Spicul=1
		update #tempCO
			Set vPrimaVacanta=round(vPrimaVacanta*Zile_prima_vacanta/12,0)
		where condCalcul=1

	if @pCalcul_prima=1 and @Baza_calcul_prima='3' 
		update #tempCO
			Set vPrimaVacanta=@Procent_prima
		where condCalcul=1 and Gasit_prima_ant=0

	if @pCalcul_prima=1 and @Baza_calcul_prima='6' 
		update #tempCO
			Set vPrimaVacanta=round(vPrimaVacanta*Zile_CO/Zile_concediu_de_odihna,0)
		where condCalcul=1 and Gasit_prima_ant=0

	if @pCalcul_prima=1
		update #tempCO
			Set vPrimaVacanta=round(vPrimaVacanta,0)
		where condCalcul=1
-- sfarsit prima de vacanta

	update #tempCO
	set Suma_CO=Indemnizatie_CO+(case when @pCalcul_COnet_prima=1 then (case when @pCalcul_prima=0 then 
			(case when Data_primei=Data_inceput_CO and Prima_vacanta<>0 then Prima_vacanta_datainc 
				else (case when ordine=1 then Prima_vacanta else 0 end) end) 
			else (case when @lCalcul_prima=1 and @Baza_calcul_prima=1 or @lCalcul_prima=0 or ordine=1 then Prima_vacanta else 0 end) end) else 0 end)
	where condCalcul=1

	If @StergCONetAnt=1
		delete co
		from ConcOdih co
		left join #tempCO tm on co.data=tm.data and co.marca=tm.marca and co.Data_inceput=tm.Data_inceput
		where Tip_concediu='9' and condCalcul=1

	If @pCalcul_CO_net=1
	begin
		update #tempCO 
			set Venit_net=Suma_CO-round(Suma_CO*(case when somaj_1=1 then @nSomaj/100 else 0 end),0)-
				round(Suma_CO*CASS/1000,0)-round(Suma_CO*@nCasindiv/100,0)
		where condCalculNet=1
     
		------------    deducere -------------
		create table #deduceri (marca varchar(6))
		exec CreeazaDiezsalarii @numeTabela='#deduceri'
		insert into #deduceri (marca, data, deducere_pers, venitBrut, oreJustificate, grupaMunca, regimLucru)
		select marca, data_inceput, deducere_pers, suma_co, 0, Grupa_de_munca, RL
		from #tempCO
		exec pCalculDeducere @datajos=@dataJos, @dataSus=@dataSus
		update co set co.deducere_pers=d.deducere_pers
		from #tempCO co
		inner join #deduceri d on d.data=co.data_inceput and d.marca=co.marca
		where co.Grupa_de_munca not in ('O','P') and co.Tip_colab<>'FDP' and @Calcul_CO_net_FDP=0

		update #tempCO
		set venit_baza=(case when Venit_net-Deducere_pers<0 then 0 else Venit_net-Deducere_pers end)
		where condCalculNet=1

		update #tempCO
		set impozit=dbo.fCalcul_impozit_salarii(venit_baza,0,impozit)
		where condCalculNet=1

		/*	Pentru inceput va exista un SP pentru Salubris. */	
		if exists (select * from sysobjects where name ='CalculConcediiDeOdihnaRetineriSP')
			exec CalculConcediiDeOdihnaRetineriSP @sesiune=@sesiune, @parXML=@parXML

--	 inserarare in ConcOdih
		update co set 
			co.Data_sfarsit=(case when co.Data_sfarsit>tm.Data then tm.Data else co.Data_sfarsit end), co.Zile_CO=tm.Zile_CO, 
			co.Indemnizatie_CO=(case when co.Tip_concediu='9' then tm.venit_net-tm.impozit-tm.retineri_CO when co.Introd_manual=1 then co.Indemnizatie_CO else tm.Indemnizatie_co end)
		from concodih co 
		inner join #tempCO tm on co.data=tm.data and co.marca=tm.marca and co.Data_inceput=tm.Data_inceput and tm.Tip_co!='9'
		where co.Tip_concediu='9'

		insert into ConcOdih
			(Data, Marca, Tip_concediu, Data_inceput, Data_sfarsit, Zile_CO, Introd_manual, Indemnizatie_CO, Zile_prima_vacanta, Prima_vacanta)
		Select tm.Data, tm.Marca, '9', tm.Data_inceput, (case when tm.Data_sfarsit>tm.Data then tm.Data else tm.Data_sfarsit end),
			tm.Zile_CO, 0, tm.venit_net-tm.impozit-tm.retineri_CO, 0, tm.nDataInreg
		from #tempCO tm 
		left outer join concodih co	on co.data=tm.data and co.marca=tm.marca and co.Data_inceput=tm.Data_inceput and co.Tip_concediu='9'
		where co.marca is null
	end	

	-- scriere in corectii
	update cor
	set Suma_corectie=tm.vPrimaVacanta, Suma_neta=0, Procent_corectie=0
	from corectii cor
	left outer join #tempCO tm on cor.data=tm.data and cor.marca=tm.marca and cor.loc_de_munca=tm.Loc_de_munca and Tip_corectie_venit='O-'
	where cor.Data=(case when tm.Prima_vacanta=0 or tm.Prima_vacanta_datainc<>0 then tm.Data_inceput else tm.Data end) 
		and cor.Marca=tm.marca and cor.Loc_de_munca=tm.Loc_de_munca and Tip_corectie_venit='O-' 
		and tm.vPrimaVacanta<>0 and @pCalcul_prima=1 and @Baza_calcul_prima='1'

	insert into Corectii 
		(Data, Marca, Loc_de_munca, Tip_corectie_venit, Suma_corectie, Procent_corectie, Suma_neta)
	Select (case when tm.Prima_vacanta=0 or tm.Prima_vacanta_datainc<>0 then tm.Data_inceput else tm.Data end), tm.Marca, tm.Loc_de_munca, 'O-', tm.vPrimaVacanta, 0, 0
	from #tempCO tm
	left outer join corectii cor on cor.data=(case when tm.Prima_vacanta=0 or tm.Prima_vacanta_datainc<>0 then tm.Data_inceput else tm.Data end) and cor.marca=tm.marca and cor.loc_de_munca=tm.Loc_de_munca and cor.Tip_corectie_venit='O-'
	where cor.Marca is null and tm.vPrimaVacanta<>0 and @pCalcul_prima=1 and @Baza_calcul_prima='1'

	update cor
	set Suma_corectie=(case when @Baza_calcul_prima<>'6' then tm.vPrimaVacanta else 0 end), Suma_neta=(case when @Baza_calcul_prima='6' then tm.vPrimaVacanta else 0 end), Procent_corectie=0
	from corectii cor
	left outer join #tempCO tm on cor.data=tm.data and cor.marca=tm.marca and cor.loc_de_munca=tm.Loc_de_munca and Tip_corectie_venit='O-'
	where cor.Data=(case when tm.Prima_vacanta=0 or tm.Prima_vacanta_datainc<>0 then tm.Data_inceput else tm.Data end) 
		and cor.Marca=tm.marca and cor.Loc_de_munca=tm.Loc_de_munca and Tip_corectie_venit='O-' 
		and tm.vPrimaVacanta<>0 and @pCalcul_prima=1 and @Baza_calcul_prima<>'1'

	insert into Corectii 
		(Data, Marca, Loc_de_munca, Tip_corectie_venit, Suma_corectie, Procent_corectie, Suma_neta)
	Select (case when tm.Prima_vacanta=0 or tm.Prima_vacanta_datainc<>0 then tm.Data_inceput else tm.Data end), 
		tm.Marca, tm.Loc_de_munca, 'O-', (case when @Baza_calcul_prima<>'6' then tm.vPrimaVacanta else 0 end), 0, (case when @Baza_calcul_prima='6' then tm.vPrimaVacanta else 0 end)
	from #tempCO tm
	left outer join corectii cor on cor.data=(case when tm.Prima_vacanta=0 or tm.Prima_vacanta_datainc<>0 then tm.Data_inceput else tm.Data end) and cor.marca=tm.marca and cor.loc_de_munca=tm.Loc_de_munca and cor.Tip_corectie_venit='O-'
	where cor.Marca is null and tm.vPrimaVacanta<>0 and @pCalcul_prima=1 and @Baza_calcul_prima<>'1'

	if exists (select * from sysobjects where name ='calcul_concedii_de_odihnaSP2')
		exec calcul_concedii_de_odihnaSP2 @dataJos=@dataJos, @dataSus=@dataSus, @pMarca=@pMarca, @pData_inceput=@pData_inceput, @pZile_lucratoare=@pZile_lucratoare, 
			@pIndemnizatie_CO=@pIndemnizatie_CO, @pLocm=@pLocm, @pCalcul_prima=@pCalcul_prima, @Procent_prima=@Procent_prima, @pCalcul_CO_net=@pCalcul_CO_net, 
			@pCalcul_COnet_prima=@pCalcul_COnet_prima, @lData_op=@lData_op, @dData_op=@dData_op, @Calcul_CO_net_FDP=@Calcul_CO_net_FDP, @Recalc_CO_luniant=@Recalc_CO_luniant,
			@StergCONetAnt=@StergCONetAnt
end try

begin catch
	declare @mesaj varchar(1000)
	set @mesaj = ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror (@mesaj, 11, 1)
end catch