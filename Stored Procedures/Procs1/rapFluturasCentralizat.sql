--***
/**	procedura pentru fluturas centralizat **/
Create procedure rapFluturasCentralizat
	(@dataJos datetime, @dataSus datetime, @MarcaJ char(6)=null, @MarcaS char(6)=null, @LocmJ char(9)=null, @LocmS char(9)=null, @grupaMunca char(1)=null,
	@lTipSal int=0, @cTipSalJos char(1)='1', @cTipSalSus char(1)='7', @tipPersonal char(1)=null, @functie char(6)=null, @mandatar char(6)=null,
	@card char(30)=null, @Sex int=null, @tipStat char(200)=null, @areDreptCond int=1, @cListaCond char(1)='T', @tipAngajati char(1)=null,
	@sirMarci char(200)=null, @LmExcep char(9)=null, @StrictLmExcep int=0, @grupaMExcep int=0, @grupare char(20)='LUNA',
	@exclLM varchar(20) = null, @setlm varchar(20)=null, @activitate varchar(20)=null)
as
/*
	@tipPersonal C=Contractual, N=Necontractual.
	@tipAngajati P=Permanenti, O=ocazionali
	exec rapFluturasCentralizat
		@dataJos='09/01/2015',@dataSus='09/30/2015',@MarcaJ='',@MarcaS='',@LocmJ='',@LocmS='', @grupaMunca=null,
		@lTipSal=0,@cTipSalJos='1',@cTipSalSus='7',@tipPersonal=null, @functie=null, @mandatar=null,
		@card='', @Sex=null, @tipStat='', @areDreptCond=1, @cListaCond='T', @tipAngajati=null,
		@sirMarci=null, @LmExcep=null, @StrictLmExcep=0, @lGrupaMExcep=0, @grupare='',
		@exclLM=null,@setlm=null,@activitate=null

	select * from fluturascentralizat ('01/01/2015','09/30/2015','','','','',0,'N',0,'1','7',0,'',0,'',0,'',0,'',0,0,0,'',1,'T',0,'',0,'','',0,0,'',null,null,null)
*/
begin try
	set transaction isolation level read uncommitted
	/*	Apelat SP pentru diverse validari. */
	if exists (select 1 from sysobjects where name='rapFluturasCentralizatSP' and xtype='P')
		exec rapFluturasCentralizatSP
			@dataJos=@dataJos, @dataSus=@dataSus, @MarcaJ=@MarcaJ, @MarcaS=@MarcaS, @LocmJ=@LocmJ, @LocmS=@LocmS, @grupaMunca=@grupaMunca,
			@lTipSal=@lTipSal, @cTipSalJos=@cTipSalJos, @cTipSalSus=@cTipSalSus, @tipPersonal=@tipPersonal, @functie=@functie, @mandatar=@mandatar,
			@card=@card, @Sex=@Sex, @tipStat=@tipStat, @areDreptCond=@areDreptCond, @cListaCond=@cListaCond, @tipAngajati=@tipAngajati,
			@sirMarci=@sirMarci, @LmExcep=@LmExcep, @StrictLmExcep=@StrictLmExcep, @grupaMExcep=@grupaMExcep, @grupare=@grupare,
			@exclLM=@exclLM, @setlm=@setlm, @activitate=@activitate

	declare @utilizator varchar(20), @lDreptCond int, @SubtipCor int, @den_intr3 char(30), @rc int, @CalculCASCorU int, @Ore_luna float,	
		@ajdecunit bit, @Buget int, @CMunitSomaj int, @CMunitCASS int, @CMunitITM int, @CMstatFG int, @CMunitFG int, @coefCCI float,
		@NuCAS_H int,@NuCASS_H int,@Cassimps_K int, 
		@lOPTICHINM int, @lNC_tichete int, @lTichete_personalizate int, @nTabela int, @cTabela char(1), 
		@ImpozitTichete int, @DataTicJ datetime, @DataTicS datetime, 
		@NCCnph int, @ContributieNPH decimal(12,2), @Numar_mediu_cnph decimal(10,2), @Dafora int, @Colas int, @Grup7 int, @existaTabela int, @lista_lm int

	select	@MarcaJ=isnull(@MarcaJ,''), @LocmJ=isnull(@LocmJ,''), @LmExcep=isnull(@LmExcep,''), @functie=isnull(@functie,''), 
			@grupaMunca=isnull(@grupaMunca,''), /*@card=isnull(@card,''),*/ @mandatar=isnull(@mandatar,''), @tipPersonal=isnull(@tipPersonal,''), 
			@tipStat=isnull(@tipStat,''), @tipAngajati=isnull(@tipAngajati,''), @sirMarci=isnull(@sirMarci,'')
	set @utilizator = dbo.fIaUtilizator(null)
	set @lista_lm = dbo.f_areLMFiltru(@utilizator)
	set @rc=(case when @grupare='MARCA' then 2 else 0 end)

	set @existaTabela=0
	if object_id('tempdb..#flutcent') is not null 
		set @existaTabela=1
	else 
	begin
		create table #flutcent (data datetime)
		exec CreeazaDiezSalarii @numeTabela='#flutcent'
	end

	--	Citire parametrii
	select	@SubtipCor = max(case when Parametru='SUBTIPCOR' then Val_logica else 0 end)
			,@ajdecunit = max(case when Parametru='AJDUNIT-R' then Val_logica else 0 end)
			,@lDreptCond = max(case when Parametru='DREPTCOND' then Val_logica else 0 end)
			,@Buget = max(case when Parametru='UNITBUGET' then Val_logica else 0 end)
			,@Buget = max(case when Parametru='UNITBUGET' then Val_logica else 0 end)
			,@CMunitSomaj = max(case when Parametru='CM-SC-S5%' then Val_logica else 0 end)
			,@CMunitCASS = max(case when Parametru='CM-SC-F7%' then Val_logica else 0 end)
			,@CMunitITM = max(case when Parametru='CM-SC-CM1' then Val_logica else 0 end)
			,@CMunitFG = max(case when Parametru='CM-SC-FG' then Val_logica else 0 end)
			,@CMstatFG = max(case when Parametru='CM-ST-FG' then Val_logica else 0 end)
			,@NuCAS_H = max(case when Parametru='NUCAS-H' then Val_logica else 0 end)
			,@NuCASS_H = max(case when Parametru='NUASS-H' then Val_logica else 0 end)
			,@Cassimps_K = max(case when Parametru='ASSIMPS-K' then Val_logica else 0 end)
			,@lOPTICHINM = max(case when Parametru='OPTICHINM' then Val_logica else 0 end)
			,@lNC_tichete = max(case when Parametru='NC-TICHM' then Val_logica else 0 end)
			,@lTichete_personalizate = max(case when Parametru='TICHPERS' then Val_logica else 0 end)
			,@nTabela =  max(case when Parametru='NC-TICHM' then Val_numerica else 0 end)
			,@NCCnph = max(case when Parametru='NC-CPHAND' then Val_logica else 0 end) 
			,@Dafora = max(case when Parametru='DAFORA' then Val_logica else 0 end)
			,@Colas = max(case when Parametru='COLAS' then Val_logica else 0 end)
			,@Grup7 = max(case when Parametru='GRUP7' then Val_logica else 0 end)
			,@den_intr3 = max(case when Parametru='PROC3INT' then Val_alfanumerica else '' end)
			,@CalculCASCorU = max(case when Parametru='CALCAS-U' then Val_logica else 0 end)
	from par 
	where tip_parametru='PS' and parametru in ('SUBTIPCOR','AJDUNIT-R','DREPTCOND','UNITBUGET','CM-SC-S5%','CM-SC-F7%','CM-SC-CM1','CM-ST-FG','CM-SC-FG'
		,'NUCAS-H','NUASS-H','ASSIMPS-K','OPTICHINM','NC-TICHM','TICHPERS','NC-CPHAND','CALCAS-U','PROC3INT')
		or tip_parametru='SP' and parametru in ('DAFORA','COLAS','GRUP7')
	Set @coefCCI=isnull((select val_numerica from par where tip_parametru='PS' and parametru='COEFCCI')/1000000,1)

	Set @cTabela = (case when convert(char(2),@nTabela)>1 then right(rtrim(convert(char(2),@nTabela)),1) else '' end)
	
	--	Citire parametrii lunari
	Set @ImpozitTichete=dbo.iauParLL(@dataSus,'PS','DJIMPZTIC')
	Set @DataTicJ=dbo.iauParLD(@dataSus,'PS','DJIMPZTIC')
	Set @DataTicS=dbo.iauParLD(@dataSus,'PS','DSIMPZTIC')
	Set @DataTicJ=(case when @DataTicJ='01/01/1901' then @dataJos else @DataTicJ end)
	Set @DataTicS=(case when @DataTicS='01/01/1901' then @dataSus else @DataTicS end)

	if @NCCnph=1 and dbo.eom(@dataJos)=@dataSus 
		select @ContributieNPH=isnull((select sum(c.Val_numerica) from par c where c.tip_parametru='PS' and c.parametru like 'CPH'+'%'
				and (substring(c.parametru,6,4)+substring(c.parametru,4,2) between '200101' and '205012') 
				and (@grupare in ('AN','LUNA','MARCA') and dbo.eom(convert(datetime,substring(c.parametru,4,2)+'/01/'+substring(c.parametru,6,4),102))=@dataSus or @grupare='' 
				and dbo.eom(convert(datetime,substring(c.parametru,4,2)+'/01/'+substring(c.parametru,6,4),102)) between @dataJos and @dataSus)),0)
	if @NCCnph=1 and @LocmJ<>'' and dbo.eom(@dataJos)=@dataSus 
		and @ContributieNPH<>0	-- doar daca s-a calculat contributia per total unitate are sens sa o calculam si la filtrare pe loc de munca
		select @ContributieNPH=Suma_cnph, @Numar_mediu_cnph=Numar_mediu_cnph
			from dbo.fCalcul_cnph (@dataJos, @dataSus, '', @LocmJ, @LocmS, '', null, null)
	Select @ContributieNPH=ISNULL(@ContributieNPH,0), @Numar_mediu_cnph=ISNULL(@Numar_mediu_cnph,0)

--	verific daca utilizatorul are/nu are dreptul de Salarii conducere (SALCOND)
	if isnull(@cListaCond,'')=''
		set @cListaCond='T'
	set @areDreptCond=0
	if  @lDreptCond=1 
	begin
		set @areDreptCond=isnull((select dbo.verificDreptUtilizator(@utilizator,'SALCOND')),0)
		if @areDreptCond=0
			set @cListaCond='S'
	end

	IF OBJECT_ID('tempdb..#par_lunari') is not null drop table #par_lunari
	IF OBJECT_ID('tempdb..#par_cnph') is not null drop table #par_cnph
	IF OBJECT_ID('tempdb..#istpers') is not null drop table #istpers
	IF OBJECT_ID('tempdb..#pontaj') is not null drop table #pontaj
	IF OBJECT_ID('tempdb..#conmed') is not null drop table #conmed
	IF OBJECT_ID('tempdb..#corectiiLM') is not null drop table #corectiiLM
	IF OBJECT_ID('tempdb..#corectiiMarca') is not null drop table #corectiiMarca
	IF OBJECT_ID('tempdb..#resal') is not null drop table #resal
	IF OBJECT_ID('tempdb..#perTich') is not null drop table #perTich
	IF OBJECT_ID('tempdb..#tichete') is not null drop table #tichete
	IF OBJECT_ID('tempdb..#ptichete') is not null drop table #ptichete
	IF OBJECT_ID('tempdb..#tabtichete') is not null drop table #tabtichete
	IF OBJECT_ID('tempdb..#CMUnit30Zile') is not null drop table #CMUnit30Zile
	IF OBJECT_ID('tempdb..#impozitIpotetic') is not null drop table #impozitIpotetic
	IF OBJECT_ID('tempdb..#flutcent_brut') is not null drop table #flutcent_brut
	IF OBJECT_ID('tempdb..#flutcent_net1') is not null drop table #flutcent_net1
	IF OBJECT_ID('tempdb..#flutcent_net') is not null drop table #flutcent_net

	select * into #par_lunari
	from par_lunari 
	where data between @datajos and @datasus and parametru in ('ORE_LUNA','VALTICHET','DSIMPZTIC')

	select parametru, Val_numerica, convert(datetime,substring(parametru,4,2)+'/01/'+substring(parametru,6,4),102) as data
	into #par_cnph
	from par
	where Tip_parametru='PS' and (parametru like 'CPH' or parametru like 'NRM')

	--	Fac la inceput selectul pe istpers si aici fac toate filtrele.
	select i.* into #istpers
	from istpers i 
		left outer join personal p on p.marca=i.marca
		left outer join infoPers ip on ip.marca=i.marca
		left outer join net n on n.data=i.data and n.marca=i.marca  
		left outer join mandatar m on m.loc_munca=n.loc_de_munca 
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=isnull(n.Loc_de_munca,i.loc_de_munca)
	where i.data between @dataJos and @dataSus 
		and (@MarcaJ='' or i.marca between @MarcaJ and @MarcaS) 
		and (@LocmJ='' or n.loc_de_munca between @LocmJ and @LocmS or p.Loc_ramas_vacant=1 and p.Data_plec=dbo.bom(i.Data) and i.loc_de_munca between @LocmJ and @LocmS) 
		and (@grupaMunca='' or (@grupaMExcep=0 and i.grupa_de_munca=@grupaMunca or @grupaMExcep=1 and i.grupa_de_munca<>@grupaMunca)) 
		and (@lTipSal=0 or i.tip_salarizare between @cTipSalJos and @cTipSalSus) 
		and (@tipPersonal='' or @tipPersonal='N' and isnull(p.detalii.value('(/row/@functpublic)[1]','int'),convert(int,ip.Actionar))=1 
			or @tipPersonal='C' and isnull(p.detalii.value('(/row/@functpublic)[1]','int'),convert(int,ip.Actionar))=0) 
		and (@functie='' or i.cod_functie=@functie) 
		and (@mandatar='' or m.mandatar=@mandatar) and (@card is null or p.banca=@card) 
		and (@Sex is null or p.sex=@Sex) and (@tipStat='' or isnull(p.tip_stat,ip.Religia)=@tipStat) 
		and (@lDreptCond=0 or (@AreDreptCond=1 and (@cListaCond='T' or @cListaCond='C' and p.pensie_suplimentara=1 or @cListaCond='S' and p.pensie_suplimentara<>1)) 
			or (@AreDreptCond=0 and p.pensie_suplimentara<>1)) 
		and (@tipAngajati='' or @tipAngajati='P' and i.grupa_de_munca in ('N','D','S') or @tipAngajati='O' and i.grupa_de_munca in ('O','C')) 
		and (@sirMarci='' or charindex(','+rtrim(ltrim(i.marca))+',',@sirMarci)>0) 
		and (@LmExcep='' or n.loc_de_munca not like rtrim(@LmExcep)+(case when @StrictLmExcep=1 then '' else '%' end))
		and (@lista_lm=0 or lu.cod is not null)
		and (@exclLM is null or not exists(select 1 from proprietati p where p.tip='LM' and p.Cod_proprietate='NUSTAT' and valoare=@exclLM and n.loc_de_munca=p.Cod))
		and (@setlm is null or exists(select 1 from proprietati p where p.Cod_proprietate='TIPBALANTA' and p.Tip='LM' and valoare=@setlm and rtrim(n.Loc_de_munca) like rtrim(p.cod)+'%'))
		and (@activitate is null or isnull(i.Activitate,p.Activitate)=@activitate)

	select ss.* into #ScutiriSomaj
	from dbo.fScutiriSomaj (@dataJos, @dataSus, @MarcaJ, @MarcaS, @LocmJ, @LocmS) ss
	inner join #istpers i on i.data=ss.data and i.marca=ss.marca 

	select dbo.eom(pt.data) as data, pt.marca, --pt.loc_de_munca, 
		sum(pt.ore_intrerupere_tehnologica) as ore_intr_tehn_1, sum(pt.ore) as ore_intr_tehn_2, sum(pt.spor_cond_8) as ore_intr_tehn_3, 
		sum(pt.spor_cond_10) as ore_deplasari_RN, sum(pt.ore__cond_6) as nr_tichete
	into #pontaj
	from pontaj pt
		inner join #istpers i on i.data=dbo.eom(pt.data) and i.Marca=pt.Marca
	where pt.data between @datajos and @datasus
	group by dbo.eom(pt.data), pt.marca--, pt.loc_de_munca

	select cm.data, cm.marca, sum(case when cm.tip_diagnostic in ('2-','3-','4-') then cm.indemnizatie_unitate else 0 end) as Baza_CASS_AMBP, 
		sum(case when cm.tip_diagnostic='0-' then zile_lucratoare*8 else 0 end) as ore_ingr_copil, 
		sum(case when cm.tip_diagnostic='0-' and day(Data_inceput)=1 then zile_lucratoare*8 else 0 end) as ore_ingr_copil_01,
		sum(case when cm.tip_diagnostic='0-' and Data_sfarsit=dbo.EOM(cm.data) then zile_lucratoare*8 else 0 end) as ore_ingr_copil_31
	into #conmed
	from conmed cm
		inner join #istpers i on i.data=cm.data and i.Marca=cm.Marca
	where cm.data between @datajos and @datasus
	group by cm.data, cm.marca
	
	select * into #corectiiLM
	from dbo.fSumeCorectie (@dataJos, @dataSus, '', @MarcaJ, @LocmJ, 1)

	select * into #corectiiMarca
	from dbo.fSumeCorectie (@dataJos, @dataSus, '', @MarcaJ, @LocmJ, 0)

	select r.data, r.marca, 
		sum(case when r.cod_beneficiar='11' then r.retinut_la_avans+r.retinut_la_lichidare else 0 end) as Prime_avans_dafora,
		sum(case when r.cod_beneficiar='10' then r.retinut_la_avans+r.retinut_la_lichidare else 0 end) as Avans_CO_dafora
	into #resal
	from resal r
		inner join #istpers i on i.data=r.data and i.marca=r.marca
	where r.Data between @datajos and @datasus and r.cod_beneficiar in ('11','10')
	group by r.data, r.marca

	select Data, Marca, Sum(Indemnizatie_unitate) as Indemnizatie_unitate into #CMUnit30Zile
	from dbo.concedii_medicale(@MarcaJ,@MarcaS,@dataJos,@dataSus,'  ','9-',0,'0-',@LocmJ,@LocmS,0,0,'1',0,0,'',1,6) 
	Group by Data, Marca

	--	Selectare date din tabela tichete
	select t.Data_lunii, t.Marca,
		sum((case when t.tip_operatie='R' then -1 else 1 end)*t.nr_tichete) as nr_tichete,
		sum((case when t.tip_operatie='R' then -1 else 1 end)*t.nr_tichete*t.valoare_tichet) as Val_tichete,
		sum(case when t.tip_operatie='S' then t.nr_tichete else 0 end) as nr_tichete_supl,
		sum(case when t.tip_operatie='S' then t.nr_tichete*t.valoare_tichet else 0 end) as Val_tichete_supl 
	into #tabtichete
	from tichete t
		inner join #istpers i on i.data=t.data_lunii and i.marca=t.marca
	where t.Data_lunii between @dataJos and @dataSus 
		and (@lTichete_personalizate=1 and t.tip_operatie in ('C','S','R') 
			or @lTichete_personalizate=0 and (t.tip_operatie in ('P','S') or t.tip_operatie='R' and valoare_tichet<>0)) 
	group by t.Data_lunii, t.Marca
	--	selectare tichete de masa functie de perioada de impozitare
	CREATE TABLE #ptichete (data datetime)
	EXEC CreeazaDiezSalarii @numeTabela='#ptichete'

	create table #perTich (datalunii datetime, datajos datetime, datasus datetime)
	insert into #perTich
	select data_lunii, dbo.iauParLD(fc.data_lunii,'PS','DJIMPZTIC'), dbo.iauParLD(fc.data_lunii,'PS','DSIMPZTIC')
	from fCalendar (@dataJos, @datasus) fc where data=data_lunii
	create table #tichete (marca varchar(6), data_salar datetime, data datetime, numar_tichete int, valoare_tichete float)
	declare @datalunii datetime, @dataImpozJos datetime, @dataImpozSus datetime
	declare tmpTich cursor for
	select datalunii, datajos, datasus
	from #perTich

	open tmpTich
	fetch next from tmpTich into @Datalunii, @dataImpozJos, @dataImpozSus
	While @@fetch_status = 0 
	Begin
		delete from #ptichete
		exec pTichete @dataJos=@dataImpozJos, @dataSus=@dataImpozSus, @marca=@MarcaJ, @DeLaCalculLichidare=1

		insert into #tichete (marca, data_salar, data, numar_tichete, valoare_tichete)
		select marca, @Datalunii, data, numar_tichete, valoare_tichete from #ptichete

		fetch next from tmpTich into @Datalunii, @dataImpozJos, @dataImpozSus
	End

	--	Tichete cuvenite in perioada (nu acordate, impozitate).
	delete from #ptichete
	exec pTichete @dataJos=@dataJos, @dataSus=@dataSus, @marca=@MarcaJ, @DeLaCalculLichidare=1

	create table #impozitIpotetic (data datetime, marca varchar(6), impozitIpotetic varchar(100))
-->	selectez din extinfop, pozitia pentru salariatii care au impozit ipotetic (HG84/2013) valabila la data declaratiei. Acest impozit ipotetic nu trebuie cuprins in D112.
	insert into #impozitIpotetic
	select a.data, a.marca, a.impozitIpotetic 
	from dbo.fSalariatiCuImpozitIpotetic (@dataJos, @dataSus, @LocmJ, @MarcaJ) a
		inner join #istpers i on i.data=a.data and i.marca=a.marca

	--	Selectare date din brut	
	select a.data, a.marca, sum(a.Total_ore_lucrate) as Total_ore_lucrate, sum(a.Ore_lucrate__regie) as Ore_lucrate__regie, 
	sum(round(a.Realizat__regie,0)) as Realizat__regie, sum(a.Ore_lucrate_acord) as Ore_lucrate_acord, sum(a.Realizat_acord) as Realizat_acord, 
	sum(a.Ore_suplimentare_1) as Ore_supl_1, sum(round(a.Indemnizatie_ore_supl_1,0)) as Ind_ore_supl_1, 
	sum(a.Ore_suplimentare_2) as Ore_supl_2, sum(round(a.Indemnizatie_ore_supl_2,0)) as Ind_ore_supl_2, 
	sum(a.Ore_suplimentare_3) as Ore_supl_3, sum(round(a.Indemnizatie_ore_supl_3,0)) as Ind_ore_supl_3, 
	sum(a.Ore_suplimentare_4) as Ore_supl_4, sum(round(a.Indemnizatie_ore_supl_4,0)) as Ind_ore_supl_4, 
	sum(a.Ore_spor_100) as Ore_spor_100, sum(round(a.Indemnizatie_ore_spor_100,0)) as Indemnizatie_ore_spor_100, 
	sum(a.Ore_de_noapte) as Ore_de_noapte, sum(round(a.Ind_ore_de_noapte,0)) as Ind_ore_de_noapte, 
	sum(a.Ore_lucrate_regim_normal) as Ore_lucrate_regim_normal, sum(round(a.Ind_regim_normal,0)) as Ind_regim_normal, 
	sum(a.Ore_intrerupere_tehnologica) as Ore_intrerupere_tehnologica, sum(round(a.Ind_intrerupere_tehnologica,0)) as Ind_intrerupere_tehnologica, 
	sum(a.Ore_obligatii_cetatenesti) as Ore_obligatii_cetatenesti, sum(round(a.Ind_obligatii_cetatenesti,0)) as Ind_obligatii_cetatenesti, 
	sum(a.Ore_concediu_fara_salar) as Ore_concediu_fara_salar, sum(round(a.Ind_concediu_fara_salar,0)) as Ind_concediu_fara_salar, 
	sum(a.Ore_concediu_de_odihna) as Ore_concediu_de_odihna, sum(round(a.Ind_concediu_de_odihna,0)) as Ind_concediu_de_odihna, 
	sum(a.Ore_concediu_medical) as Ore_concediu_medical, sum(a.Ind_c_medical_unitate) as Ind_c_medical_unitate, 
	sum(a.Ind_c_medical_CAS) as Ind_c_medical_CAS, sum(a.spor_cond_9) as CMFAMBP, sum(a.Ore_invoiri) as Ore_invoiri, 
	sum(round(a.Ind_invoiri,0)) as Ind_intrerupere_tehnologica_2, sum(a.Ore_nemotivate) as Ore_nemotivate, 
	sum(a.Ind_nemotivate) as Ind_conducere, sum(a.Salar_categoria_lucrarii) as Salar_categoria_lucrarii, 
	sum(a.CMCAS) as CMCAS, sum(a.CMunitate) as CMunitate, sum(a.CO-isnull(z.Suma_corectie,0)) as CO, sum(a.Restituiri) as Restituiri, 
	sum(a.Diminuari) as Diminuari, sum(a.Suma_impozabila) as Suma_impozabila, sum(a.Premiu-isnull(x.Suma_corectie,0)) as Premiu, sum(a.Diurna-isnull(y.Suma_corectie,0)) as Diurna, 
	sum(a.Cons_admin) as Cons_admin, sum(a.Sp_salar_realizat) as Sp_salar_realizat, sum(a.Suma_imp_separat) as Suma_imp_separat, 
	sum(isnull(x.Suma_corectie,0)) as Premiu2, sum(isnull(y.Suma_corectie,0)) as Diurna2, sum(isnull(z.Suma_corectie,0)) as CO2, 
	sum(isnull(q.Suma_corectie,0)) as Avantaje_materiale, sum(isnull(ai.Suma_corectie,0)) as Avantaje_impozabile, 
	sum(a.Spor_vechime) as Spor_vechime, sum(a.Spor_de_noapte) as Spor_de_noapte, 
	sum(a.Spor_sistematic_peste_program) as Spor_sistematic_peste_program, sum(a.Spor_de_functie_suplimentara) as Spor_de_functie_suplimentara, 
	sum(round(a.Spor_specific,0)) as Spor_specific, sum(round(a.Spor_cond_1,0)) as Spor_cond_1, sum(round(a.Spor_cond_2,0)) as Spor_cond_2, sum(round(a.Spor_cond_3,0)) as Spor_cond_3, 
	sum(round(a.Spor_cond_4,0)) as Spor_cond_4, sum(round(a.Spor_cond_5,0)) as Spor_cond_5, sum(round(a.Spor_cond_6,0)) as Spor_cond_6, sum(a.Compensatie) as Aj_deces, 
	sum(a.VENIT_TOTAL) as Venit_total, sum(round(a.Spor_cond_7,0)) as Spor_cond_7, sum(round(a.Spor_cond_8,0)) as Spor_cond_8, 
	max(isnull(pt.ore_intr_tehn_1,0)) as ore_intr_tehn_1, max(isnull(pt.ore_intr_tehn_2,0)) as ore_intr_tehn_2, 
	(case when @Colas=1 or @den_intr3<>'' then max(isnull(pt.ore_intr_tehn_3,0)) else 0 end) as ore_intr_tehn_3, 
	sum(isnull(u.Suma_corectie,0)) as Cor_U, sum(isnull(w.Suma_corectie,0)) as Cor_W, 
	round(max(isnull(pt.ore_deplasari_RN,0))*max(a.salar_orar),0) as Deplasari_RN,
	sum(a.Ore_lucrate_regim_normal+a.Ore_concediu_de_odihna)/max(pl.val_numerica) as Numar_mediu_salariati,
	isnull(max(cm.Baza_CASS_AMBP),0) as Baza_CASS_AMBP, sum(i.salar_de_incadrare) as salar_de_incadrare
	into #flutcent_brut
	from brut a
		inner join #istpers i on i.data=a.data and i.marca=a.marca  
		left outer join #pontaj pt on pt.data=a.data and pt.marca=a.marca --and pt.loc_de_munca=a.loc_de_munca
		left outer join #conmed cm on cm.data=a.data and cm.marca=a.marca
		left outer join #par_lunari pl on pl.data=a.data and pl.tip='PS' and pl.Parametru='ORE_LUNA'
		left outer join #corectiiLM q on q.Data=a.Data and q.Marca=a.Marca and q.Loc_de_munca=a.Loc_de_munca and q.Tip_corectie_venit='Q-'
		left outer join #corectiiLM x on x.data=a.data and x.marca=a.marca and x.loc_de_munca=a.loc_de_munca and x.Tip_corectie_venit='X-'
		left outer join #corectiiLM y on y.data=a.data and y.marca=a.marca and y.loc_de_munca=a.loc_de_munca and y.Tip_corectie_venit='Y-'
		left outer join #corectiiLM z on z.data=a.data and z.marca=a.marca and z.loc_de_munca=a.loc_de_munca and z.Tip_corectie_venit='Z-'
		left outer join #corectiiLM u on u.data=a.data and u.marca=a.marca and u.loc_de_munca=a.loc_de_munca and u.Tip_corectie_venit='U-' and @Grup7=0
		left outer join #corectiiLM w on w.data=a.data and w.marca=a.marca and w.loc_de_munca=a.loc_de_munca and w.Tip_corectie_venit='W-'
		left outer join #corectiiLM ai on ai.data=a.data and ai.marca=a.marca and ai.loc_de_munca=a.loc_de_munca and ai.Tip_corectie_venit='AI'
	where a.data between @dataJos and @dataSus 
	group by a.marca, a.data

	select a.data, a.marca,
		(case when max(isnull(cm.ore_ingr_copil,0))=0 then 0 else 1 end) as Ingrij_copil, 
		(case when max(isnull(cm.ore_ingr_copil_01,0))=0 then 0 else 1 end) as Ingrij_copil_01, 
		(case when max(isnull(cm.ore_ingr_copil_31,0))=0 then 0 else 1 end) as Ingrij_copil_31, 
		max(case when (i.mod_angajare='N' or i.mod_angajare='') and i.grupa_de_munca<>'O' then 1 else 0 end) as SPNedet,
		max(case when i.mod_angajare in ('D','R') and i.grupa_de_munca<>'O' then 1 else 0 end) as SPDet, 
		max(case when i.grupa_de_munca='O' then 1 else 0 end) as ocazional, 
		(case when @NCCnph=1 and @LocmJ<>'' and dbo.eom(@dataJos)=@dataSus then @ContributieNPH 
			else isnull((select sum(c.Val_numerica) from par c where c.tip_parametru='PS' and c.parametru like 'CPH'+'%'
				and (substring(c.parametru,6,4)+substring(c.parametru,4,2) between '200101' and '205012') 
				and (@grupare in (/*'AN',*/'LUNA','MARCA') and dbo.eom(convert(datetime,substring(c.parametru,4,2)+'/01/'+substring(c.parametru,6,4),102))=a.data 
					or @grupare in ('','AN') and dbo.eom(convert(datetime,substring(c.parametru,4,2)+'/01/'+substring(c.parametru,6,4),102)) between @dataJos and @dataSus)),0) end) as Cotiz_hand, 
		(case when @NCCnph=1 and @LocmJ<>'' and dbo.eom(@dataJos)=@dataSus then @Numar_mediu_cnph 
			else isnull((select sum(c.Val_numerica) from par c where c.tip_parametru='PS' and c.parametru like 'NRM'+'%'
				and (substring(c.parametru,6,4)+substring(c.parametru,4,2) between '200101' and '205012') 
				and (@grupare in (/*'AN',*/'LUNA','MARCA') and dbo.eom(convert(datetime,substring(c.parametru,4,2)+'/01/'+substring(c.parametru,6,4),102))=a.data 
					or @grupare in ('','AN') and dbo.eom(convert(datetime,substring(c.parametru,4,2)+'/01/'+substring(c.parametru,6,4),102)) between @dataJos and @dataSus)),0) end) as Nrms_cnph
	into #flutcent_net1
	from net a
		inner join #istpers i on i.data=a.data and i.marca=a.marca   
		left outer join avexcep x on x.data=a.data and x.marca=a.marca   
		left outer join #conmed cm on cm.data=a.data and cm.marca=a.marca
	where a.data between @dataJos and @dataSus and a.data=dbo.eom(a.data)
	group by a.Data,a.Marca

	select a.data,a.marca,sum(a.CM_incasat) as CM_incasat, sum((case when @Dafora=1 then isnull(r.Avans_CO_dafora,0) else a.CO_incasat end)) as CO_incasat, 
	sum(a.Suma_incasata-(case when @Dafora=1 then isnull(cs.suma_corectie,0) else 0 end)) as suma_incasata, sum(a.Suma_neimpozabila) as suma_neimpozabila, 
	sum(a.Diferenta_impozit) as Diferenta_impozit,sum(a.Impozit) as Impozit,sum(case when upper(isnull(ii.impozitIpotetic,''))='DA' then a.Impozit else 0 end) as Impozit_ipotetic,
	sum(a.Pensie_suplimentara_3) as Pensie_suplimentara_3, sum((case when a.somaj_1<>0 then a.asig_sanatate_din_cas else 0 end)) as Baza_somaj_1,
	sum(a.Somaj_1) as Somaj_1, sum(a.Asig_sanatate_din_impozit) as Asig_sanatate_din_impozit, sum(a.Asig_sanatate_din_net) as Asig_sanatate_din_net,
	0 as Asig_sanatate_din_CAS, sum(a.VENIT_NET) as VENIT_NET, 
	sum(a.Avans-(case when a.Premiu_la_avans<>0 then 0 else isnull(x.Premiu_la_avans,0) end)) as Avans, 
	sum(case when @Dafora=1 then isnull(r.Prime_avans_dafora,0) else (case when a.Premiu_la_avans<>0 then a.Premiu_la_avans else isnull(x.Premiu_la_avans,0) end) end) as Premiu_la_avans,
	sum(a.Debite_externe) as Debite_externe, sum(a.Rate) as Rate, sum(a.Debite_interne-(case when @Dafora=1 then isnull(r.Prime_avans_dafora,0)+isnull(r.Avans_CO_dafora,0) else 0 end)) as Debite_interne, 
	sum(a.Cont_curent) as Cont_curent, sum(a.REST_DE_PLATA) as REST_DE_PLATA,
	sum(a.CAS+isnull(d.CAS,0)) as CAS_unitate, sum(a.Somaj_5) as Somaj_5, sum(a.Fond_de_risc_1) as Fond_de_risc_1, sum(a.Camera_de_Munca_1) as Camera_de_Munca_1,
	sum(a.Asig_sanatate_pl_unitate) as Asig_sanatate_pl_unitate, sum(a.Ded_suplim) as CCI, 
	sum(a.VEN_NET_IN_IMP) as VEN_NET_IN_IMP, sum(a.Ded_baza) as Ded_personala, sum(isnull(d.ded_baza,0)) as Ded_pens_fac, 
	sum(a.VENIT_BAZA) as Venit_baza_imp, sum((case when i.tip_impozitare='3' or (i.grad_invalid='1' or i.grad_invalid='2') then a.VENIT_BAZA else 0 end)) as Venit_baza_imp_scutit,
	sum(a.Baza_CAS) as Baza_CAS_ind, sum(a.Baza_CAS_cond_norm+isnull(d.Baza_CAS_cond_norm,0)) as Baza_CAS_cond_norm, sum(a.Baza_CAS_cond_deoseb+isnull(d.Baza_CAS_cond_deoseb,0)) as Baza_CAS_cond_deoseb,
	sum(a.Baza_CAS_cond_spec+isnull(d.Baza_CAS_cond_spec,0)) as Baza_CAS_cond_spec, 
	sum((case when (p.coef_invalid=2 or p.coef_invalid=3 or p.coef_invalid=4) then a.chelt_prof else 0 end)) as Subv_somaj_art8076,
	sum((case when p.coef_invalid=1 or p.coef_invalid=9 then a.chelt_prof else 0 end)) as Subv_somaj_art8576, sum((case when p.coef_invalid=7 then a.chelt_prof else 0 end)) as Subv_somaj_art172,
	sum((case when p.coef_invalid=8 then a.chelt_prof else 0 end)) as Subv_somaj_legea116,
	sum((case when a.somaj_5<>0 and not(@Buget=1 and convert(char(1),isnull(p.detalii.value('(/row/@functpublic)[1]','int'),convert(int,ip.Actionar)))='1') then a.asig_sanatate_din_cas else 0 end)) as Baza_somaj_5,
	sum((case when a.somaj_5<>0 and @Buget=1 and convert(char(1),isnull(p.detalii.value('(/row/@functpublic)[1]','int'),convert(int,ip.Actionar)))='1' then a.asig_sanatate_din_cas else 0 end)) as Baza_somaj_5_FP,
	sum((case when a.asig_sanatate_pl_unitate<>0 then b.venit_total-1*(b.Ind_c_medical_CAS+b.CMCAS+b.CMFAMBP)-@CMunitCASS*(b.Ind_c_medical_unitate+b.cmunitate)
		-@NuCASS_H*b.suma_impozabila-(case when dbo.iauParLL(a.data,'PS','STOUG28')=1 then b.Ind_intrerupere_tehnologica_2 else 0 end) else 0 end)) as Baza_CASS_unitate,
	sum((case when a.ded_suplim<>0 then d.Baza_CAS else 0 end))*@coefCCI as Baza_CCI,
	sum((case when a.Camera_de_munca_1<>0 then b.venit_total-1*(b.Ind_c_medical_CAS+b.CMCAS+b.CMFAMBP)-@CMunitITM*(b.Ind_c_medical_unitate+b.cmunitate)
		-@NuCAS_H*b.suma_impozabila-@Cassimps_K*b.cons_admin else 0 end)) as Baza_Camera_de_munca_1,
	sum((case when p.coef_invalid=5 then a.venit_total-(b.Ind_c_medical_CAS+b.CMCAS+b.CMFAMBP) else 0 end)) as Venit_pensionari_scutiri_somaj,
	sum(isnull(d.ded_suplim,0)) as CCI_Fambp, 
	sum(isnull(d.Baza_CAS_cond_norm,0)) as Baza_CAS_cond_norm_CM, sum(isnull(d.Baza_CAS_cond_deoseb,0)) as Baza_CAS_cond_deoseb_CM,
	sum(isnull(d.Baza_CAS_cond_spec,0)) as Baza_CAS_cond_spec_CM, sum(isnull(d.CAS,0)) as CAS_CM, 
	sum((case when d.somaj_5<>0 then (case when YEAR(a.Data)<=2011 then isnull(a.asig_sanatate_din_cas,0) 
		when d.CM_incasat<>0 then d.CM_incasat else a.VENIT_TOTAL-(b.Ind_c_medical_CAS+b.CMCAS+b.CMFAMBP) end) else 0 end)) as Baza_fgarantare,
	sum(isnull(d.somaj_5,0)) as Fond_garantare, sum(isnull(d.asig_sanatate_din_cas,0)) as Baza_fambp_CM, 
	sum((case when i.grupa_de_munca='O' then a.venit_total else 0 end)) as ven_ocazO, sum((case when i.grupa_de_munca='P' then a.venit_total else 0 end)) as ven_ocazP, 
	sum(cm.ore_ingr_copil) as Ore_ingr_copil, sum(cm.ore_ingr_copil_01) as Ore_ingr_copil_01, sum(cm.ore_ingr_copil) as Ore_ingr_copil_31,
	sum((case	when a.Data>'06/30/2010' then isnull(ti.numar_tichete,0) 
			when not(@lOPTICHINM=1 or @lNC_tichete=1 and @cTabela='2') then isnull(pt.nr_tichete,0) else isnull(tt.Nr_tichete,0) end))-sum(isnull(tt.nr_tichete_supl,0)) as nr_tichete, 
	round(sum((case when a.Data>'06/30/2010' then isnull(ti.Valoare_tichete,0)
		when not(@lOPTICHINM=1 or @lNC_tichete=1 and @cTabela='2') then isnull(pt.nr_tichete,0)*isnull(l.Val_numerica,0) else isnull(tt.Val_tichete,0) end)),2)
		-sum(isnull(tt.val_tichete_supl,0)) as val_tichete, 
	sum(isnull(tt.nr_tichete_supl,0)) as nr_tichete_supl, sum(isnull(tt.val_tichete_supl,0)) as val_tichete_supl, 
	sum((case when dt.data<>a.Data then isnull(tc.Numar_tichete,0) else 0 end)) as nr_tichete_acordate, sum((case when dt.data<>a.Data then isnull(tc.Valoare_tichete,0) else 0 end)) as val_tichete_acordate, 
	sum(isnull(cs.suma_corectie,0)) as Ajutor_ridicat_dafora, sum(isnull(cs.suma_corectie,0)+isnull(cf.suma_corectie,0)) as Ajutor_cuvenit_dafora, 
	sum(isnull(r.Prime_avans_dafora,0)) as Prime_avans_dafora, sum(isnull(r.Avans_CO_dafora,0)) as Avans_CO_dafora,
	sum(e.SPNedet-(case when e.SPNedet=1 then e.Ingrij_copil_31 else 0 end)) as SPNedet, sum(e.SPDet-(case when e.SPDet=1 then e.Ingrij_copil_31 else 0 end)) as SPDet, 
	max(case when i.grupa_de_munca='O' then 1 else 0 end) as Ocazional, max(case when i.grupa_de_munca='P' then 1 else 0 end) as Ocaz_P, 
	max(case when i.grupa_de_munca='P' and i.Tip_colab='AS2' then 1 else 0 end) as Ocaz_P_AS2,
	max(case when i.grupa_de_munca='C' then 1 else 0 end) as Cm_t_part, max(case when i.grad_invalid in ('1','2','3') and i.grupa_de_munca<>'O' then 1 else 0 end) as Handicap, 
	max(case when year(p.Data_angajarii_in_unitate)=year(a.Data) and month(p.Data_angajarii_in_unitate)=month(a.Data) and i.grupa_de_munca<>'O' then 1 else 0 end) as Angajat, 
	max(case when convert(char(1),p.Loc_ramas_vacant)='1' and year(p.Data_plec)=year(a.Data) and month(p.Data_plec)=month(a.Data) and i.grupa_de_munca<>'O' then 1 else 0 end) as Plecat, 
	max(case when convert(char(1),p.Loc_ramas_vacant)='1' and year(p.Data_plec)=year(a.Data) and month(p.Data_plec)=month(a.Data) and day(p.Data_plec)=1 
		and i.grupa_de_munca<>'O' then 1 else 0 end) as Plecat_01, 
	sum(e.Ingrij_copil+e.Ocazional) as NuSalariat, sum(e.Ingrij_copil_01+e.Ocazional) as NuSalariat_01, sum(e.Ingrij_copil_31+e.Ocazional) as NuSalariat_31, 0 as Zilier,
	round(sum(isnull(ss.Scutire_art80,0)),0) as Scut_art_80, round(sum(isnull(ss.Scutire_art85,0)),0) as Scut_art_85, 
	max(e.Cotiz_hand) as Cotiz_hand, max(d.Asig_sanatate_din_impozit) as CASS_AMBP, max(e.Nrms_cnph) as Nrms_cnph,
	sum(a.Pensie_suplimentara_3)+sum(a.Somaj_1)+sum(a.Diferenta_impozit+(case when upper(isnull(ii.impozitIpotetic,''))='DA' then 0 else a.Impozit end))+sum(a.Asig_sanatate_din_net)+
		sum(a.Asig_sanatate_pl_unitate)+sum(isnull(d.somaj_5,0))+sum(a.Camera_de_Munca_1) as Virament_partial,
	sum(a.CAS+isnull(d.CAS,0)-(case when @ajdecunit=1 then 0 else isnull(b.Aj_deces,0) end)) as cas_de_virat,
	sum(a.Fond_de_risc_1)-sum(b.CMFAMBP)-sum(a.Asig_sanatate_din_impozit)-sum(isnull(d.ded_suplim,0)) as fondrisc_de_virat, isnull(sum(s.indemnizatie_unitate),0) as CMUnit30Z, 
	0 as VenitZilieri, 0 as ImpozitZilieri, 0 as RestPlataZilieri
	into #flutcent_net
	from net a 
		inner join #istpers i on i.data=a.data and i.marca=a.marca  
		left outer join #flutcent_brut b on b.data=a.data and b.marca=a.marca 
		left outer join net d on d.marca=a.marca and d.data=dbo.bom(a.data)
		left outer join personal p on p.marca=a.marca
		left outer join infoPers ip on ip.marca=a.marca
		left outer join #flutcent_net1 e on e.data=a.data and e.marca=a.marca
		left outer join avexcep x on x.data=a.data and x.marca=a.marca   
		left outer join #tabtichete tt on tt.Data_lunii=a.Data and tt.Marca=a.Marca 
		left outer join #ptichete tc on tc.Data=a.Data and tc.Marca=a.Marca
		left outer join #tichete ti on ti.data_salar=a.Data and ti.Marca=a.Marca
		left outer join #par_lunari l on l.data=a.data and l.tip='PS' and l.parametru='VALTICHET'
		left outer join #par_lunari dt on dt.data=a.data and dt.tip='PS' and dt.parametru='DSIMPZTIC'
		left outer join #ScutiriSomaj ss on ss.data=a.data and ss.marca=a.marca
		left outer join #resal r on r.data=a.data and r.marca=a.marca
		left outer join #conmed cm on cm.data=a.data and cm.marca=a.marca
		left outer join #pontaj pt on pt.data=a.data and pt.marca=a.marca
		left outer join #corectiiMarca cs on cs.data=a.data and cs.marca=a.marca and cs.Tip_corectie_venit='S-' and @Dafora=1
		left outer join #corectiiMarca cf on cf.data=a.data and cf.marca=a.marca and cf.Tip_corectie_venit='F-' and @Dafora=1	
		left outer join #CMUnit30Zile s on s.Data=a.Data and s.Marca=a.Marca 
		left outer join #impozitIpotetic ii on ii.Marca=a.Marca
	where a.data between @dataJos and @dataSus and a.data=dbo.eom(a.data)
	group by a.Data,a.Marca
--	adaug si personele din istpers plecate cu data de 01 a lunii si care nu au pozitie in net 
--	pentru contorizare salariati plecati si corelatie in nr. salariati la finalul lunii si nr. salariati la inceputul lunii urmatoare
	union all
	select i.Data, i.Marca,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 as Plecat,1 as Plecat_01,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0
	from #istPers i 
		left outer join personal p on i.Marca=p.Marca
		left outer join net n on n.marca=i.marca and n.data=i.data
	where i.Data between @dataJos and @dataSus and p.Loc_ramas_vacant=1 and p.Data_plec=dbo.bom(i.Data) and i.grupa_de_munca<>'O' and n.Marca is null
--	adaug si veniturile/impozitul zilierilor
	union all
	select dbo.eom(s.Data), s.marca,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 as Zilier,0,0,0,0,0,
	sum(Impozit) as Virament_partial,0,0,0,sum(Venit_total) as VenitZilieri, sum(Impozit) as ImpozitZilieri, sum(Rest_de_plata) as RestPlataZilieri
	from SalariiZilieri s 
		left outer join Zilieri z on z.marca=s.marca  
		left outer join mandatar m on m.loc_munca=s.Loc_de_munca 
	where s.data between @dataJos and @dataSus 
		and (@MarcaJ='' or s.marca between @MarcaJ and @MarcaS) 
		and (@LocmJ='' or s.loc_de_munca between @LocmJ and @LocmS) 
		and (@functie='' or z.Cod_functie=@functie) 
		and (@mandatar='' or m.mandatar=@mandatar) and (@card='' or z.Banca=@card) and (@Sex is null or z.Sex=@Sex) 
		and (@sirMarci='' or charindex(','+rtrim(ltrim(z.Marca))+',',@sirMarci)>0) 
		and (@LmExcep='' or z.Loc_de_munca not like rtrim(@LmExcep)+(case when @StrictLmExcep=1 then '' else '%' end))
		and (dbo.f_areLMFiltru(@utilizator)=0 or exists (select 1 from lmfiltrare l where l.utilizator=@utilizator and l.cod=z.Loc_de_munca))
		and (@exclLM is null or not exists(select 1 from proprietati p where p.tip='LM' and p.Cod_proprietate='NUSTAT' and valoare=@exclLM and z.Loc_de_munca=p.Cod))
		and (@setlm is null or exists(select 1 from proprietati p where p.Cod_proprietate='TIPBALANTA' and p.Tip='LM' and valoare=@setlm and rtrim(z.Loc_de_munca) like rtrim(p.cod)+'%'))
		and @tipStat=''	-- tratat ca daca se face filtru dupa tip stat plata sa nu aduca sumele zilierilor (acestia nu au informatia privind tipul de stat de plata).
	group by dbo.eom(s.Data), s.Marca

	insert into #flutcent
	select max((case when @grupare='AN' then convert(char(10),year(a.data),101) 
		else (case when @grupare='LUNA' or @grupare='MARCA' then convert(char(10),a.data,101) else convert(char(10),a.data,101) end) end)) as data,
	sum(b.Total_ore_lucrate) as Total_ore_lucrate, sum(b.Ore_lucrate__regie) as Ore_lucrate__regie, sum(b.Realizat__regie) as Realizat__regie,
	sum(b.Ore_lucrate_acord) as Ore_lucrate_acord, sum(b.Realizat_acord) as Realizat_acord,
	sum(b.Ore_supl_1) as ore_suplimentare_1, sum(b.Ind_ore_supl_1) as indemnizatie_ore_supl_1, sum(b.Ore_supl_2) as ore_suplimentare_2, sum(b.Ind_ore_supl_2) as indemnizatie_ore_supl_2, 
	sum(b.Ore_supl_3) as ore_suplimentare_3, sum(b.Ind_ore_supl_3) as indemnizatie_ore_supl_3, sum(b.Ore_supl_4) as ore_suplimentare_4, sum(b.Ind_ore_supl_4) as indemnizatie_ore_supl_4,
	sum(b.Ore_spor_100) as ore_spor_100, sum(b.Indemnizatie_ore_spor_100) as indemnizatie_ore_spor_100, sum(b.Ore_de_noapte) as ore_de_noapte, sum(b.Ind_ore_de_noapte) as ind_ore_de_noapte, 
	sum(b.Ore_lucrate_regim_normal) as ore_lucrate_regim_normal, sum(b.Ind_regim_normal) as ind_regim_normal,
	sum(b.Ore_intrerupere_tehnologica) as ore_intrerupere_tehnologica, sum(b.Ind_intrerupere_tehnologica) as ind_intrerupere_tehnologica, 
	sum(b.Ore_obligatii_cetatenesti) as ore_obligatii_cetatenesti, sum(b.Ind_obligatii_cetatenesti) as ind_obligatii_cetatenesti, 
	sum(b.Ore_concediu_fara_salar) as ore_concediu_fara_salar, sum(b.Ind_concediu_fara_salar) as ind_concediu_fara_salar, 
	sum(b.Ore_concediu_de_odihna) as ore_concediu_de_odihna, sum(b.Ind_concediu_de_odihna) as ind_concediu_de_odihna, 
	sum(b.Ore_concediu_medical) as ore_concediu_medical, sum(a.Ore_ingr_copil) as ore_ingr_copil,
	sum(b.Ind_c_medical_unitate) as ind_c_medical_unitate, sum(b.Ind_c_medical_CAS) as ind_c_medical_CAS, sum(b.CMFAMBP) as CMFAMBP, sum(a.CMUnit30Z) as CMUnit30Z, 
	sum(b.Ore_invoiri) as ore_invoiri, sum(Ind_intrerupere_tehnologica_2) as ind_intrerupere_tehnologica_2, sum(b.Ore_nemotivate) as ore_nemotivate,
	sum(b.Ind_conducere) as ind_conducere, sum(b.Salar_categoria_lucrarii) as salar_categoria_lucrarii, sum(b.CMCAS) as CMCAS, sum(b.CMunitate) as CMunitate, sum(b.CO) as CO, 
	sum(b.Restituiri) as restituiri, sum(b.Diminuari) as diminuari, sum(b.Suma_impozabila) as suma_impozabila,
	sum(b.Premiu) as premiu, sum(b.Diurna) as diurna, sum(b.Cons_admin) as cons_admin, sum(b.Sp_salar_realizat) as sp_salar_realizat, sum(b.Suma_imp_separat) as suma_imp_separat, 
	sum(b.Premiu2) as premiu2, sum(b.Diurna2) as diurna2, sum(b.CO2) as CO2, sum(b.Avantaje_materiale) as avantaje_materiale, sum(b.Avantaje_impozabile) as avantaje_impozabile,
	sum(b.Spor_vechime) as spor_vechime, sum(b.Spor_de_noapte) as spor_de_noapte, sum(b.Spor_sistematic_peste_program) as spor_sistematic_peste_program, 
	sum(b.Spor_de_functie_suplimentara) as spor_de_functie_suplimentara, sum(b.Spor_specific) as spor_specific, 
	sum(b.Spor_cond_1) as spor_cond_1, sum(b.Spor_cond_2) as spor_cond_2, sum(b.Spor_cond_3) as spor_cond_3, sum(b.Spor_cond_4) as spor_cond_4, sum(b.Spor_cond_5) as spor_cond_5, 
	sum(b.Spor_cond_6) as spor_cond_6, sum(b.Aj_deces) as aj_deces,
	sum(b.VENIT_TOTAL) as venit_total, sum(b.Spor_cond_7) as spor_cond_7, sum(b.Spor_cond_8) as spor_cond_8, sum(a.CM_incasat) as CM_incasat, sum(a.CO_incasat) as CO_incasat, 
	sum(a.Suma_incasata) as suma_incasata,sum(a.Suma_neimpozabila) as suma_neimpozabila,
	sum(a.Diferenta_impozit) as diferenta_impozit, sum(a.Impozit) as impozit, sum(a.Impozit_ipotetic) as impozit_ipotetic, 
	sum(a.Impozit+a.Diferenta_impozit+a.ImpozitZilieri-a.Impozit_ipotetic) as impozit_de_virat,
	sum(a.Pensie_suplimentara_3) as pensie_suplimentara_3, sum(a.Baza_somaj_1) as baza_somaj_1, sum(a.Somaj_1) as somaj_1, sum(a.Asig_sanatate_din_impozit) as asig_sanatate_din_impozit, 
	sum(a.Asig_sanatate_din_net) as asig_sanatate_din_net, sum(a.Asig_sanatate_din_CAS) as asig_sanatate_din_CAS, sum(a.VENIT_NET) as VENIT_NET, 
	sum(a.Avans) as avans, sum(a.Premiu_la_avans) as premiu_la_avans, sum(a.Debite_externe) as debite_externe, sum(a.Rate) as rate, sum(a.Debite_interne) as debite_interne, 
	sum(a.Cont_curent) as cont_curent, sum(b.Cor_U) as Cor_U, sum(b.Cor_W) as Cor_W,
	sum(a.REST_DE_PLATA) as REST_DE_PLATA, round(sum(a.CAS_unitate),@rc) as CAS_unitate, round(sum(a.Somaj_5),@rc) as Somaj_5, round(sum(a.Fond_de_risc_1),@rc) as Fond_de_risc_1, 
	round(sum(a.Camera_de_Munca_1),@rc) as Camera_de_Munca_1, round(sum(a.Asig_sanatate_pl_unitate),@rc) as Asig_sanatate_pl_unitate, round(sum(a.CCI),@rc) as CCI, 
	sum(a.VEN_NET_IN_IMP) as VEN_NET_IN_IMP, sum(a.Ded_personala) as Ded_personala, sum(a.Ded_pens_fac) as Ded_pensie_facultativa, 
	sum(a.Venit_baza_imp) as venit_baza_impozit, sum(a.Venit_baza_imp_scutit) as venit_baza_impozit_scutit, sum(a.Baza_CAS_ind) as baza_CAS_ind, 
	sum(a.Baza_CAS_cond_norm) as Baza_CAS_CN, sum(a.Baza_CAS_cond_deoseb) as Baza_CAS_CD, sum(a.Baza_CAS_cond_spec) as Baza_CAS_CS, 
	sum(a.Subv_somaj_art8076) as subventii_somaj_art8076, sum(a.Subv_somaj_art8576) as subventii_somaj_art8576, sum(a.Subv_somaj_art172) as subventii_somaj_art172, 
	sum(Subv_somaj_legea116) as subventii_somaj_legea116,
	(case when @grupare='AN' then count(distinct a.Marca) else count(a.Marca) end)-sum(a.Ocazional+(case when a.Ore_ingr_copil_31<>0 then 1 else 0 end))-sum(a.Zilier) as Total_angajati, 
	sum(b.ore_intr_tehn_1) as ore_intrerupere_tehnologica_1, sum(b.ore_intr_tehn_2) as ore_intrerupere_tehnologica_2, sum(b.ore_intr_tehn_3) as Ore_intr_tehn_3, 
	sum(a.Baza_somaj_5) as Baza_somaj_5, sum(a.Baza_somaj_5_FP) as Baza_somaj_5_FP, sum(a.Baza_CASS_unitate) as Baza_CASS_unitate, sum(a.Baza_CCI) as Baza_CCI,
	sum(a.Baza_Camera_de_munca_1) as Baza_Camera_de_munca_1, sum(a.Venit_pensionari_scutiri_somaj) as Venit_pensionari_scutiri_somaj, sum(a.CCI_Fambp) as CCI_Fambp, 
	sum(a.Baza_CAS_cond_norm_CM) as Baza_CAS_cond_norm_CM, sum(a.Baza_CAS_cond_deoseb_CM) as Baza_CAS_cond_deoseb_CM, sum(a.Baza_CAS_cond_spec_CM) as Baza_CAS_cond_spec_CM, 
	sum(a.CAS_CM) as CAS_CM, sum(a.Baza_fgarantare) as Baza_fond_garantare, round(sum(a.Fond_garantare),@rc) as Fond_garantare, 
	sum(a.Ven_ocazO) as venit_ocazO, sum(a.Ven_ocazP) as venit_ocazP, sum(b.Deplasari_RN) as deplasari_RN,
	sum(a.Nr_tichete) as nr_tichete, sum(a.Val_tichete) as val_tichete, sum(a.nr_tichete_supl) as NrTichSupl, sum(a.val_tichete_supl) as ValTichSupl, 
	sum(a.Nr_tichete_acordate) as nr_tichete_acordate, sum(a.Val_tichete_acordate) as val_tichete_acordate,
	sum(a.Ajutor_ridicat_dafora) as ajutor_ridicat_dafora, sum(a.Ajutor_cuvenit_dafora) as Ajutor_cuvenit_dafora, 
	sum(a.Prime_avans_dafora) as Prime_avans_dafora, sum(a.Avans_CO_dafora) as Avans_CO_dafora, 
	sum(a.SPNedet) as Nr_sal_per_nedeterminata, sum(a.SPDet) as Nr_sal_per_determinata,	sum(a.Ocazional) as Nr_ocazionali, sum(a.Ocaz_P) as Nr_ocazP, sum(a.Ocaz_P_AS2) as Nr_ocazP_AS2, 
	sum(a.Cm_t_part) as Nr_cm_t_part, sum(a.Handicap) as Nr_pers_handicap, sum(case when a.Ore_ingr_copil<>0 then 1 else 0 end) as Ingr_copil, 
	sum((case when 1-a.Angajat-a.Plecat_01-a.NuSalariat_01-a.Zilier<0 then 0 else 1-a.Angajat-a.Plecat_01-a.NuSalariat_01-a.Zilier end)) as Nr_salariati_inceput_luna,
	sum(a.Angajat) as Nr_angajati, sum(a.Plecat) as Nr_plecati, sum(a.Plecat_01) as nr_plecati_01, 
	sum((case when 1-a.Plecat-a.Plecat_01-a.NuSalariat_31-a.Zilier<0 then 0 else 1-a.Plecat-a.Plecat_01-a.NuSalariat_31-a.Zilier end)) as Salariati_finalul_lunii,
	(case when max(a.Nrms_cnph)<>0 then max(a.Nrms_cnph) else sum(b.Numar_mediu_salariati) end) as Numar_mediu_salariati, round(sum(a.cas_de_virat),0) as cas_de_virat,
	sum(a.scut_art_80) as scut_art_80, sum(a.scut_art_85) as Scut_art_85, max(a.Cotiz_hand) as Cotiz_hand, sum(b.Baza_CASS_AMBP) as Baza_CASS_AMBP, sum(a.CASS_AMBP) as CASS_AMBP,
	sum((case when a.Fond_de_risc_1<>0 then a.Baza_CAS_cond_norm+a.Baza_CAS_cond_deoseb+a.Baza_CAS_cond_spec-(a.Baza_CAS_cond_norm_CM+a.Baza_CAS_cond_deoseb_CM+a.Baza_CAS_cond_spec_CM)
		-(case when @CalculCASCorU=1 then b.Cor_U else 0 end) else 0 end)) as Baza_Fambp,
	sum((case when year(a.Data)>=2011 then a.Baza_fambp_CM else a.Baza_CAS_cond_norm_CM+a.Baza_CAS_cond_deoseb_CM+a.Baza_CAS_cond_spec_CM end)) as Baza_Fambp_CM,
	sum(a.Virament_partial)+sum(a.cas_de_virat)+round(sum(a.Somaj_5),0)-sum(a.Subv_somaj_art8076)-sum(a.Subv_somaj_art8576)- sum(a.Subv_somaj_art172)-sum(a.Scut_art_80)- sum(a.Scut_art_85)
		+round(sum(a.CCI),0)-sum(b.Ind_c_medical_CAS)-sum(b.CMCAS)+sum(a.Asig_sanatate_din_impozit)
		+round(sum(a.CCI_fambp),0)+sum(a.fondrisc_de_virat)+round(sum(a.CASS_AMBP),0)+round(max(a.Cotiz_hand),0) as total_contributii,
	sum(a.Virament_partial)+(case when sum(a.cas_de_virat)>0 then sum(a.cas_de_virat) else 0 end)
		+(case when (round(sum(a.Somaj_5),0)-sum(a.Subv_somaj_art8076)-sum(a.Subv_somaj_art8576)-sum(a.Subv_somaj_art172)-sum(a.Scut_art_80)- sum(a.Scut_art_85))>0 
		then round(sum(a.Somaj_5),0)-sum(a.Subv_somaj_art8076)-sum(a.Subv_somaj_art8576)-sum(a.Subv_somaj_art172)- sum(a.Scut_art_80)-sum(a.Scut_art_85) else 0 end)
		+(case when (round(sum(a.CCI),0)+round(sum(a.CCI_fambp),0)-sum(b.Ind_c_medical_CAS)-sum(b.CMCAS))>0 then round(sum(a.CCI),0)+round(sum(a.CCI_fambp),0)
		-sum(b.Ind_c_medical_CAS)-sum(b.CMCAS) else 0 end)+
		+sum(a.Asig_sanatate_din_impozit)+(case when sum(a.fondrisc_de_virat)>0 then sum(a.fondrisc_de_virat) else 0 end)+max(a.Cotiz_hand)+round(sum(a.CASS_AMBP),0) as total_viramente,
	max(case when @grupare='MARCA' then a.marca else '' end) as marca, round(sum(b.salar_de_incadrare),0) as salar_de_incadrare,
	round(sum(a.VenitZilieri),0) as VenitZilieri, round(sum(ImpozitZilieri),0) as ImpozitZilieri, round(sum(RestPlataZilieri),0) as RestPlataZilieri
	from #flutcent_net a 
		left outer join #flutcent_brut b on b.data=a.data and b.marca=a.marca and a.Zilier=0
	group by (case when @grupare='AN' then year(a.data) else (case when @grupare='LUNA' or @grupare='MARCA' then a.data else '' end) end),(case when @grupare='MARCA' then a.Marca else '' end)

	if @existaTabela=0
		select convert(char(10),data,101) as data, total_ore_lucrate, ore_lucrate__regie, realizat__regie, ore_lucrate_acord, realizat_acord, 
		ore_suplimentare_1, indemnizatie_ore_supl_1, ore_suplimentare_2, indemnizatie_ore_supl_2, ore_suplimentare_3, indemnizatie_ore_supl_3,
		ore_suplimentare_4, indemnizatie_ore_supl_4, ore_spor_100, indemnizatie_ore_spor_100, ore_de_noapte,ind_ore_de_noapte,
		ore_lucrate_regim_normal,ind_regim_normal,ore_intrerupere_tehnologica, ind_intrerupere_tehnologica, ore_obligatii_cetatenesti, ind_obligatii_cetatenesti,
		ore_concediu_fara_salar, ind_concediu_fara_salar, ore_concediu_de_odihna, ind_concediu_de_odihna,
		ore_concediu_medical, ore_ingr_copil, ind_c_medical_unitate, ind_c_medical_CAS, CMFAMBP, CMUnit30Z,
		ore_invoiri, ind_intrerupere_tehnologica_2, ore_nemotivate, ind_conducere, salar_categoria_lucrarii,
		CMCAS, CMunitate, CO, restituiri, diminuari, suma_impozabila, premiu, diurna, 
		cons_admin, sp_salar_realizat, suma_imp_separat, premiu2, diurna2, CO2, avantaje_materiale, avantaje_impozabile, 
		spor_vechime, spor_de_noapte, spor_sistematic_peste_program, spor_de_functie_suplimentara, spor_specific,  
		spor_cond_1, spor_cond_2, spor_cond_3, spor_cond_4, spor_cond_5, spor_cond_6, Aj_deces,  
		Venit_total, spor_cond_7, spor_cond_8, CM_incasat, CO_incasat, suma_incasata, suma_neimpozabila,  
		diferenta_impozit, impozit, impozit_ipotetic, impozit_de_virat, pensie_suplimentara_3, baza_somaj_1, somaj_1, 
		asig_sanatate_din_impozit, asig_sanatate_din_net, asig_sanatate_din_CAS, 
		VENIT_NET, avans, premiu_la_avans, debite_externe, rate, debite_interne, cont_curent, Cor_U, Cor_W, REST_DE_PLATA, 
		CAS_unitate, somaj_5, Fond_de_risc_1,  Camera_de_Munca_1, Asig_sanatate_pl_unitate, CCi, VEN_NET_iN_iMP, Ded_personala, 
		ded_pensie_facultativa, venit_baza_impozit, venit_baza_impozit_scutit, baza_CAS_ind, baza_CAS_CN, baza_CAS_CD, baza_CAS_CS, 
		subventii_somaj_art8076, subventii_somaj_art8576, subventii_somaj_art172,  subventii_somaj_legea116,  
		total_angajati, ore_intrerupere_tehnologica_1, ore_intrerupere_tehnologica_2,ore_intr_tehn_3,
		baza_somaj_5, baza_somaj_5_FP, baza_CASS_unitate, baza_CCi, baza_Camera_de_munca_1, venit_pensionari_scutiri_somaj, CCI_Fambp, 
		Baza_CAS_cond_norm_CM, Baza_CAS_cond_deoseb_CM, Baza_CAS_cond_spec_CM, CAS_CM, baza_fond_garantare, fond_garantare,  
		venit_ocazO, venit_ocazP, deplasari_RN, 
		nr_tichete, val_tichete, nrTichsupl, ValTichsupl, nr_tichete_acordate, val_tichete_acordate,  
		ajutor_ridicat_dafora, ajutor_cuvenit_dafora, prime_avans_dafora, avans_CO_dafora,  
		nr_sal_per_nedeterminata, nr_sal_per_determinata, nr_ocazionali, nr_ocazP, nr_ocazP_As2, nr_cm_t_part, nr_pers_handicap, 
		ingr_copil, nr_salariati_inceput_luna, nr_angajati, nr_plecati, nr_plecati_01, salariati_finalul_lunii,
		numar_mediu_salariati, cas_de_virat, scut_art_80, scut_art_85, Cotiz_hand, baza_CASS_AMBP, 
		CASS_AMBP, Baza_Fambp, Baza_Fambp_CM, total_contributii, total_viramente, marca, salar_de_incadrare, 
		VenitZilieri, impozitZilieri, RestPlataZilieri
		from #flutcent

end try

begin catch
	declare @mesaj varchar(1000)
	set @mesaj = ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror (@mesaj, 11, 1)
end catch