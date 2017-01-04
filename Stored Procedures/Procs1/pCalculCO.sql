--***
/**	procedura de calcul indemnizatie concediu de odihna (aducere stagiu pe ultimele X/3 luni, calcul medie zilnica finala).	*/
Create procedure pCalculCO
	@datajos datetime, @datasus datetime, @marca as varchar(6), @recalc_CO_luniant int
As
Begin try
	declare @MachetaCO int, @COEV_macheta int, @OUG65 int, @OUG65_SI varchar(200), @CO_MVB int, @Nr_luni_MVB int, @Spv_co int,@Spfs_co int,@Spspec_co int,@Spspp_co int, 
	@Indcond_co int, @Sp1_co int,@Sp2_co int,@Sp3_co int, @Sp4_co int,@Sp5_co int,@Sp6_co int,@Sp7_co int, 
	@Spspec_suma int, @Sp1_suma int,@Sp2_suma int,@Sp3_suma int, @Sp4_suma int,@Sp5_suma int, @Sp6_suma int, @Spfs_suma int,@Indcond_suma int, 
	@lProcfix_co int,@nProcfix_co float, @Suma_comp_co int,@Comp_co int, @Suma_comp float, @Spv_indcond int,
	@nOre_luna int,@nOre_luna_tura int, @Nrm_ore_luna int, @nButon_calcul int,@Zile_calcul_co float,@Ore_calcul_co float,
	@lRegimLV int, @Spspec_proc_suma int, @Baza_spspec float, @Spspec_pers int, @Spspec_co_baza_suma int, @Spspec_co_nu_baza_suma int, 
	@Data1 datetime, @Data2 datetime, @Medie_zilnica float, @ExistaModifSalarLuna int, @Salubris int,
	@SpElcond int, @SpDafora int, @Remarul int, @gOre_luna int, @gOre_luna_tura int, @gNrm_ore_luna int, @nNrm_ore_luna int, @lBuget int

	select 
		@MachetaCO=max(case when parametru='OPZILECOM' then Val_logica else 0 end),
		@COEV_macheta=max(case when parametru='COEVMCO' then Val_logica else 0 end), 
		@OUG65=max(case when parametru='CO-OUG65' then Val_logica else 0 end),
		@OUG65_SI=max(case when parametru='CO-OUG65' then Val_alfanumerica else '' end),	--	calcul medie pe ultimele 3 luni functie de salariile de baza+sporuri
		@CO_MVB=max(case when parametru='MEDVB_CO' then Val_logica else 0 end),
		@Nr_luni_MVB=max(case when parametru='MEDVB_CO' then Val_numerica else 0 end),
		@Spv_co=max(case when parametru='CO-SP-V' then Val_logica else 0 end),
		@Spfs_co=max(case when parametru='CO-F-SPL' then Val_logica else 0 end),
		@Spspec_co=max(case when parametru='CO-SPEC' then Val_logica else 0 end),
		@Spspp_co=max(case when parametru='CO-S-PR' then Val_logica else 0 end),
		@Indcond_co=max(case when parametru='CO-IND' then Val_logica else 0 end),
		@Sp1_co=max(case when parametru='CO-SP1' then Val_logica else 0 end),
		@Sp2_co=max(case when parametru='CO-SP2' then Val_logica else 0 end),
		@Sp3_co=max(case when parametru='CO-SP3' then Val_logica else 0 end),
		@Sp4_co=max(case when parametru='CO-SP4' then Val_logica else 0 end),
		@Sp5_co=max(case when parametru='CO-SP5' then Val_logica else 0 end),
		@Sp6_co=max(case when parametru='CO-SP6' then Val_logica else 0 end),
		@Sp7_co=max(case when parametru='CO-SP7' then Val_logica else 0 end),
		@Spspec_suma=max(case when parametru='SSP-SUMA' then Val_logica else 0 end),
		@Sp1_suma=max(case when parametru='SC1-SUMA' then Val_logica else 0 end),
		@Sp2_suma=max(case when parametru='SC2-SUMA' then Val_logica else 0 end),
		@Sp3_suma=max(case when parametru='SC3-SUMA' then Val_logica else 0 end),
		@Sp4_suma=max(case when parametru='SC4-SUMA' then Val_logica else 0 end),
		@Sp5_suma=max(case when parametru='SC5-SUMA' then Val_logica else 0 end),
		@Sp6_suma=max(case when parametru='SC6-SUMA' then Val_logica else 0 end),
		@Spfs_suma=max(case when parametru='SPFS-SUMA' then Val_logica else 0 end),
		@Indcond_suma=max(case when parametru='INDC-SUMA' then Val_logica else 0 end),
		@lProcfix_co=max(case when parametru='CO-SPFIX' then Val_logica else 0 end),
		@nProcfix_co=max(case when parametru='CO-SPFIX' then Val_numerica else 0 end),
		@Comp_co=max(case when parametru='CO-COMP' then Val_logica else 0 end),
		@Suma_comp=max(case when parametru='SUMACOMP' then Val_numerica else 0 end),
		@Spv_indcond=max(case when parametru='SP-V-INDC' then Val_logica else 0 end),
		@nButon_calcul=max(case when parametru='CALCUL-CO' then Val_numerica else 0 end),
		@Zile_calcul_co=max(case when parametru='CO-NRZILE' then Val_numerica else 0 end),
		@Spspec_proc_suma=max(case when parametru='SSPEC' then Val_logica else 0 end),
		@Baza_spspec=max(case when parametru='SSPEC' then Val_numerica else 0 end),
		@lRegimLV=max(case when parametru='REGIMLV' then Val_logica else 0 end),
		@lBuget=max(case when parametru='UNITBUGET' then Val_logica else 0 end),
		@Salubris=max(case when tip_parametru='SP' and parametru='SALUBRIS' then Val_logica else 0 end),
		@SpElcond=max(case when tip_parametru='SP' and parametru='ELCOND' then Val_logica else 0 end),
		@SpDafora=max(case when tip_parametru='SP' and parametru='DAFORA' then Val_logica else 0 end),
		@Remarul=max(case when tip_parametru='SP' and parametru='REMARUL' then Val_logica else 0 end),
		@gOre_luna=max(case when tip_parametru='PS' and parametru='ORE_LUNA' then Val_numerica else 0 end),
		@gOre_luna_tura=max(case when tip_parametru='PS' and parametru='ORET_LUNA' then Val_numerica else 0 end),
		@gNrm_ore_luna=max(case when tip_parametru='PS' and parametru='NRMEDOL' then Val_numerica else 0 end)
	from par where tip_parametru in ('PS','SP') 
		and parametru in ('OPZILECOM','COEVMCO','CO-OUG65','MEDVB_CO','CO-SP-V','CO-F-SPL','CO-SPEC','CO-S-PR','CO-IND',
			'CO-SP1','CO-SP2','CO-SP3','CO-SP4','CO-SP5','CO-SP6','CO-SP7','SSP-SUMA','SC1-SUMA','SC2-SUMA','SC3-SUMA','SC4-SUMA','SC5-SUMA','SC6-SUMA',
			'SPFS-SUMA','INDC-SUMA','CO-SPFIX','CO-COMP','SUMACOMP','SP-V-INDC','CALCUL-CO','CO-NRZILE','SSPEC',
			'REGIMLV','UNITBUGET','SALUBRIS','ELCOND','DAFORA','REMARUL','ORE_LUNA','ORET_LUNA','NRMEDOL')

	if @CO_MVB=1 and @Nr_luni_MVB=0
		select @Nr_luni_MVB=max(case when parametru='NRLUNI_CO' then Val_numerica else 0 end)
		from par where tip_parametru in ('PS') and parametru in ('NRLUNI_CO')

	if @CO_MVB=1 and @Nr_luni_MVB=0
        set @Nr_luni_MVB=3

	set @Data1=dbo.eom(dateadd(month,(case when @CO_MVB=1 then -@Nr_luni_MVB else -3 end),@dataJos))
	set @Data2=dbo.eom(dateadd(month,-1,@dataJos))

	if isnull(@marca,'')=''
		set @marca=''

	select @Suma_comp=(case when @Comp_co=1 then @Suma_comp else 0 end),
		--@Ore_calcul_co=(case when @nButon_calcul=1 then 8*@Zile_calcul_co when @nButon_calcul=2 then (case when @nOre_luna=0 then @gOre_luna else @nOre_luna end) else (case when @nNrm_ore_luna=0 then @gNrm_ore_luna else @nNrm_ore_luna end) end),
		@Spspec_pers=(case when @Spspec_co=1 and @Spspec_proc_suma=0 and @Spspec_suma=0 then 1 else 0 end),
		@Spspec_co_baza_suma=(case when @Spspec_co=1 and @Spspec_proc_suma=1 then 1 else 0 end),
		@Spspec_co_nu_baza_suma=(case when @Spspec_co=1 and @Spspec_proc_suma=0 then 1 else 0 end)

	if object_id('tempdb..#tmpParLunari') is not null
		drop table #tmpParLunari
			
	/*	Tabela #stagiuCO va fi creata si populata in procedurile ce apeleaza procedura pCalculCO. Prin procedura curenta se vor completa. */
	if object_id('tempdb..#stagiuCO') is not null
		drop table #stagiuCO
	create table #stagiuCO 
		(marca varchar(6), media_zilnica float, baza_stagiu_luna float, zile_stagiu_luna int,
		baza_stagiu1 float, zile_stagiu1 decimal(6,2), baza_stagiu2 float, zile_stagiu2 decimal(6,2), baza_stagiu3 float, zile_stagiu3 decimal(6,2), ore_stagiu int not null default 0)

	if object_id('tempdb..#tmpStagiu') is not null
		drop table #tmpStagiu
	create table #tmpStagiu (marca varchar(6), data datetime, baza_stagiu float, zile_stagiu float, ore_stagiu int not null default 0)

	/*	Aducere date din par_lunari pe o singura linie/data. */
	select Data, 
		max(case when parametru='ORE_LUNA' then Val_numerica else 0 end) as oreluna, 
		max(case when parametru='ORET_LUNA' then Val_numerica else 0 end) as oretura,
		max(case when parametru='NRMEDOL' then Val_numerica else 0 end) as nrmedol
	into #tmpParLunari
	from par_lunari
	where tip='PS' and parametru in ('ORET_LUNA','ORE_LUNA','NRMEDOL')
	group by data

	/*	calcul baza si zile stagiu pentru luna curenta, calcul medie zilnica luna curenta + indemnizatie. */
	select tm.marca, sum(tm.Salar_de_incadrare*(100+@Spv_co*b.spor_vechime
			+@Spfs_co*(case when @Spfs_suma=1 then 0 else b.spor_de_functie_suplimentara end)
			+@Spspec_pers*b.spor_specific+@Spspp_co*b.spor_sistematic_peste_program
			+@Sp1_co*(case when @Sp1_suma=1 then 0 else b.spor_conditii_1 end) 
			+@Sp2_co*(case when @Sp2_suma=1 then 0 else b.spor_conditii_2 end)
			+@Sp3_co*(case when @Sp3_suma=1 then 0 else b.spor_conditii_3 end)
			+@Sp4_co*(case when @Sp4_suma=1 then 0 else b.spor_conditii_4 end)
			+@Sp5_co*(case when @Sp5_suma=1 then 0 else b.spor_conditii_5 end)
			+@Sp6_co*(case when @Sp6_suma=1 then 0 else b.spor_conditii_6 end)+@Sp7_co*isnull(isnull(b.Spor_cond_7,ip.spor_cond_7),0)	--aici trebuie de adus spor_cond_7 din personal.
			+(case when @Indcond_suma=0 then @Indcond_co*b.indemnizatia_de_conducere else 0 end)
			+@lProcfix_co*@nProcfix_co)/100+@Spspec_co_baza_suma*@Baza_spspec*b.spor_specific/100
			+@Spspec_co_nu_baza_suma*(case when @Spspec_suma=1 then b.spor_specific else 0 end)
			+@Spv_co*b.spor_vechime/100*@Spv_indcond*(case when @lBuget=1 then 0 else 1 end)*b.indemnizatia_de_conducere*
				(case when @Indcond_suma=0 then b.salar_de_incadrare/100 else 1 end)
				+(case when @Indcond_suma=1 then @Indcond_co*b.indemnizatia_de_conducere else 0 end)
				+@Suma_comp+@Spfs_co*(case when @Spfs_suma=1 then b.spor_de_functie_suplimentara else 0 end)
				+@Sp1_co*(case when @Sp1_suma=1 then b.spor_conditii_1 else 0 end)
				+@Sp2_co*(case when @Sp2_suma=1 then b.spor_conditii_2 else 0 end)
				+@Sp3_co*(case when @Sp3_suma=1 then b.spor_conditii_3 else 0 end)
				+@Sp4_co*(case when @Sp4_suma=1 then b.spor_conditii_4 else 0 end)
				+@Sp5_co*(case when @Sp5_suma=1 then b.spor_conditii_5 else 0 end)
				+@Sp6_co*(case when @Sp6_suma=1 then b.spor_conditii_6 else 0 end)) as baza_stagiu,
				sum(case when @lRegimLV=1 and (case when pl.oretura=0 then @gOre_luna_tura else pl.oretura end)<>0 and b.salar_lunar_de_baza<>0 then 
				(case when pl.oretura=0 then @gOre_luna_tura else pl.oretura end) when @nButon_calcul=4 and b.tip_salarizare in ('1','2') or @nButon_calcul=2 then 
				(case when pl.oreluna=0 then dbo.Zile_lucratoare(dbo.bom(tm.Data),tm.Data)*8 else pl.oreluna end) 
				when @nButon_calcul=4 and b.tip_salarizare not in ('1','2') or @nButon_calcul=3 then 
				(case when pl.nrmedol=0 then @gNrm_ore_luna else pl.nrmedol end) else 8*@Zile_calcul_co end)/8 as zile_stagiu
	into #stagiuCOLuna
	from #tempCO tm
		left outer join personal b on tm.marca=b.Marca
		left outer join infopers ip on ip.marca=tm.Marca
		left outer join #tmpParLunari pl on pl.data=tm.data
	where (not(tm.Tip_CO in ('7','8') and year(tm.Data_inceput)=year(@dataJos) and month(tm.Data_inceput)=month(@dataJos))
		or @Recalc_CO_luniant=1) and tm.Introd_manual=0
	group by tm.marca, tm.data
	
	update tm
	set tm.Indemnizatie_CO=round(convert(decimal(17,5),baza_stagiu*tm.zile_CO/zile_stagiu),2)
	from #tempCO tm
	inner join #stagiuCOLuna t on tm.marca=t.marca 

	--	calcul medie zilnica CO conform OUG 65/2005 (ultimele 3 luni) functie de ore lucrate in regim normal + sporuri gata calculate
	if @OUG65=1 and @Salubris=0 and @CO_MVB=0 and (@OUG65_SI='' or @OUG65_SI<>'1')	
	begin
		insert into #tmpStagiu (marca, data, baza_stagiu, zile_stagiu, ore_stagiu)
		select old.marca, old.data, 
		isnull(sum(ind_regim_normal+@Spv_co*spor_vechime+@Spfs_co*spor_de_functie_suplimentara
			+round(@Spspec_co*spor_specific,0)+@Spspp_co*spor_sistematic_peste_program+@Indcond_co*ind_nemotivate
			+round(@Sp1_co*spor_cond_1,0)+round(@Sp2_co*spor_cond_2,0)+round(@Sp3_co*spor_cond_3,0)+round(@Sp4_co*spor_cond_4,0)
			+round(@Sp5_co*spor_cond_5,0)+round(@Sp6_co*spor_cond_6,0)+round(@Sp7_co*spor_cond_7,0)+
			ind_obligatii_cetatenesti+(case when @SpElcond=0 then ind_concediu_de_odihna else 0 end)
			+(case when @Remarul=1 then Ind_intrerupere_tehnologica+Ind_invoiri else 0 end)),0) as Baza_stagiu, 
		round(sum((ore_lucrate_regim_normal+ore_obligatii_cetatenesti+(case when @SpElcond=0 then ore_concediu_de_odihna else 0 end)
			+(case when @Remarul=1 then Ore_intrerupere_tehnologica else 0 end))
				/(case when old.spor_cond_10=0 then 8.00 else old.spor_cond_10 end)),2) as zile_stagiu, 
		sum((case when @MachetaCO=0 
			then ore_lucrate_regim_normal+ore_obligatii_cetatenesti+(case when @SpElcond=0 then ore_concediu_de_odihna else 0 end)
				+(case when @Remarul=1 then Ore_intrerupere_tehnologica else 0 end) 
			else 0 end)) as ore_stagiu 
		from brut old 
		inner join #stagiuCOLuna s on s.marca=old.marca
		where data between @data1 and @data2
		group by old.marca, old.data

		insert into #stagiuCO 
			(marca, media_zilnica, baza_stagiu_luna, zile_stagiu_luna, baza_stagiu1, zile_stagiu1, baza_stagiu2, zile_stagiu2, baza_stagiu3, zile_stagiu3, ore_stagiu)
		select marca, 0, 0, 0,
		sum(case when data=dbo.eom(@data1) then baza_stagiu else 0 end) as baza_stagiu1,
		sum(case when data=dbo.eom(@data1) then zile_stagiu else 0 end) as zile_stagiu1,
		sum(case when data=dbo.eom(dateadd(month,1,@data1)) then baza_stagiu else 0 end) as baza_stagiu2,
		sum(case when data=dbo.eom(dateadd(month,1,@data1)) then zile_stagiu else 0 end) as zile_stagiu2,
		sum(case when data=dbo.eom(dateadd(month,2,@data1)) then baza_stagiu else 0 end) as baza_stagiu3,
		sum(case when data=dbo.eom(dateadd(month,2,@data1)) then zile_stagiu else 0 end) as zile_stagiu3, 
		sum(ore_stagiu) as ore_stagiu
		from #tmpStagiu
		group by marca
	end

--	calcul medie zilnica CO conform OUG 65/2005 (ultimele 3 luni) functie de salarul de incadrare + sporurile permanente cuvenite.
	if @OUG65=1 and @Salubris=0 and @CO_MVB=0 and @OUG65_SI='1'
	begin
		insert into #tmpStagiu (marca, data, baza_stagiu, zile_stagiu)
		select old.marca, old.data, 
		sum((old.Salar_de_incadrare*(100+@Spv_co*old.spor_vechime+@Spfs_co*(case when @Spfs_suma=1 then 0 else old.spor_de_functie_suplimentara end)
			+@Spspec_co*old.spor_specific+@Spspp_co*old.spor_sistematic_peste_program+@Indcond_co*(case when @Indcond_suma=0 then @Indcond_co*old.indemnizatia_de_conducere else 0 end)
			+@Sp1_co*(case when @Sp1_suma=1 then 0 else old.spor_conditii_1 end)+@Sp2_co*(case when @Sp2_suma=1 then 0 else old.spor_conditii_2 end)
			+@Sp3_co*(case when @Sp3_suma=1 then 0 else old.spor_conditii_3 end)+@Sp4_co*(case when @Sp4_suma=1 then 0 else old.spor_conditii_4 end)
			+@Sp5_co*(case when @Sp5_suma=1 then 0 else old.spor_conditii_5 end)+@Sp6_co*(case when @Sp6_suma=1 then 0 else old.spor_conditii_6 end)/*+@Sp7_co*p.spor_cond_7*/+@lProcfix_co*@nProcfix_co)/100)
			+@Spspec_co_baza_suma*@Baza_spspec*old.spor_specific/100
			+@Spspec_co_nu_baza_suma*(case when @Spspec_suma=1 then old.spor_specific else 0 end)
			+@Spv_co*old.spor_vechime/100*@Spv_indcond*(case when @lBuget=1 then 0 else 1 end)*old.indemnizatia_de_conducere*
				(case when @Indcond_suma=0 then old.salar_de_incadrare/100 else 1 end)
				+(case when @Indcond_suma=1 then @Indcond_co*old.indemnizatia_de_conducere else 0 end)
				+@Suma_comp+@Spfs_co*(case when @Spfs_suma=1 then old.spor_de_functie_suplimentara else 0 end)
				+@Sp1_co*(case when @Sp1_suma=1 then old.spor_conditii_1 else 0 end)
				+@Sp2_co*(case when @Sp2_suma=1 then old.spor_conditii_2 else 0 end)
				+@Sp3_co*(case when @Sp3_suma=1 then old.spor_conditii_3 else 0 end)
				+@Sp4_co*(case when @Sp4_suma=1 then old.spor_conditii_4 else 0 end)
				+@Sp5_co*(case when @Sp5_suma=1 then old.spor_conditii_5 else 0 end)
				+@Sp6_co*(case when @Sp6_suma=1 then old.spor_conditii_6 else 0 end)) as Baza_stagiu, 
			sum(ol.val_numerica)/8 as zile_stagiu
		from istpers old 
		inner join #stagiuCOLuna s on s.marca=old.marca
		left outer join par_lunari ol on old.data=ol.data and ol.tip='PS' and ol.parametru='ORE_LUNA'
		where old.data between @data1 and @data2
		group by old.marca, old.data

		insert into #stagiuCO
			(marca, media_zilnica, baza_stagiu_luna, zile_stagiu_luna, baza_stagiu1, zile_stagiu1, baza_stagiu2, zile_stagiu2, baza_stagiu3, zile_stagiu3)
		select marca, 0, 0, 0,
		sum(case when data=dbo.eom(@data1) then baza_stagiu else 0 end) as baza_stagiu1,
		sum(case when data=dbo.eom(@data1) then zile_stagiu else 0 end) as zile_stagiu1,
		sum(case when data=dbo.eom(dateadd(month,1,@data1)) then baza_stagiu else 0 end) as baza_stagiu2,
		sum(case when data=dbo.eom(dateadd(month,1,@data1)) then zile_stagiu else 0 end) as zile_stagiu2,
		sum(case when data=dbo.eom(dateadd(month,2,@data1)) then baza_stagiu else 0 end) as baza_stagiu3,
		sum(case when data=dbo.eom(dateadd(month,2,@data1)) then zile_stagiu else 0 end) as zile_stagiu3
		from #tmpStagiu
		group by marca
	end

--	calcul medie zilnica specific Salubris (din istoric personal)
	if @OUG65=1 and @Salubris=1 and @CO_MVB=0
	begin
		insert into #tmpStagiu (marca, data, baza_stagiu, zile_stagiu)
		select b.marca, b.data, 
		sum(round(((case when @lBuget=1 then b.salar_de_baza else b.salar_de_incadrare end)*
			(100+@Spv_co*b.spor_vechime+@Spfs_co*(case when @Spfs_suma=1 then 0 else b.spor_de_functie_suplimentara end)
			+@Spspec_pers*b.spor_specific+@Spspp_co*b.spor_sistematic_peste_program
			+@Sp1_co*(case when @Sp1_suma=1 then 0 else b.spor_conditii_1 end) 
			+@Sp2_co*(case when @Sp2_suma=1 then 0 else b.spor_conditii_2 end)
			+@Sp3_co*(case when @Sp3_suma=1 then 0 else b.spor_conditii_3 end)
			+@Sp4_co*(case when @Sp4_suma=1 then 0 else b.spor_conditii_4 end)
			+@Sp5_co*(case when @Sp5_suma=1 then 0 else b.spor_conditii_5 end)
			+@Sp6_co*(case when @Sp6_suma=1 then 0 else b.spor_conditii_6 end)+@Sp7_co*isnull(p.spor_cond_7,ip.spor_cond_7)
			+(case when @Indcond_suma=0 then @Indcond_co*b.indemnizatia_de_conducere else 0 end)
			+@lProcfix_co*@nProcfix_co)/100+@Spspec_co_baza_suma*@Baza_spspec*b.spor_specific/100
			+@Spspec_co_nu_baza_suma*(case when @Spspec_suma=1 then b.spor_specific else 0 end)
			+@Spv_co*b.spor_vechime/100*@Spv_indcond*(case when @lBuget=1 then 0 else 1 end)*b.indemnizatia_de_conducere*
			(case when @Indcond_suma=0 then b.salar_de_incadrare/100 else 1 end)
			+(case when @Indcond_suma=1 then @Indcond_co*b.indemnizatia_de_conducere else 0 end)
			+@Suma_comp+@Spfs_co*(case when @Spfs_suma=1 then b.spor_de_functie_suplimentara else 0 end)
			+@Sp1_co*(case when @Sp1_suma=1 then b.spor_conditii_1 else 0 end)
			+@Sp2_co*(case when @Sp2_suma=1 then b.spor_conditii_2 else 0 end)
			+@Sp3_co*(case when @Sp3_suma=1 then b.spor_conditii_3 else 0 end)
			+@Sp4_co*(case when @Sp4_suma=1 then b.spor_conditii_4 else 0 end)
			+@Sp5_co*(case when @Sp5_suma=1 then b.spor_conditii_5 else 0 end)
			+@Sp6_co*(case when @Sp6_suma=1 then b.spor_conditii_6 else 0 end)),0)) as Baza_stagiu, 
			sum(dbo.Zile_lucratoare(dbo.bom(b.Data),b.Data)) as zile_stagiu
		from istpers b 
		inner join #stagiuCOLuna s on s.marca=b.marca
		left outer join personal p on p.marca = b.marca
		left outer join infopers ip on ip.marca = b.marca
		where b.data between @Data1 and @Data2
		group by b.marca,b.data

		insert into #stagiuCO
			(marca, media_zilnica, baza_stagiu_luna, zile_stagiu_luna, baza_stagiu1, zile_stagiu1, baza_stagiu2, zile_stagiu2, baza_stagiu3, zile_stagiu3)
		select marca, 0, 0, 0,
		sum(case when data=dbo.eom(@data1) then baza_stagiu else 0 end) as baza_stagiu1,
		sum(case when data=dbo.eom(@data1) then zile_stagiu else 0 end) as zile_stagiu1,
		sum(case when data=dbo.eom(dateadd(month,1,@data1)) then baza_stagiu else 0 end) as baza_stagiu2,
		sum(case when data=dbo.eom(dateadd(month,1,@data1)) then zile_stagiu else 0 end) as zile_stagiu2,
		sum(case when data=dbo.eom(dateadd(month,2,@data1)) then baza_stagiu else 0 end) as baza_stagiu3,
		sum(case when data=dbo.eom(dateadd(month,2,@data1)) then zile_stagiu else 0 end) as zile_stagiu3
		from #tmpStagiu
		group by marca
	end

--	calcul medie zilnica dupa media venitului brut pe ultimele 3 luni (setare ASiSplus)
	if @CO_MVB=1
	begin
		insert into #tmpStagiu (marca, data, baza_stagiu, zile_stagiu)
		select old.marca, old.data, sum(venit_total) as baza_stagiu,
			round(sum(((case when 1=1 then ore_lucrate_regim_normal else ore_lucrate__regie+ore_lucrate_acord end)+ore_concediu_de_odihna+ore_concediu_medical+ore_obligatii_cetatenesti
			+ore_intrerupere_tehnologica+ore_concediu_fara_salar+ore_invoiri+ore_nemotivate)/
			(case when old.spor_cond_10=0 then 8.0 else convert(float,old.spor_cond_10) end)),2)  as zile_stagiu
		from brut old 
		inner join #stagiuCOLuna s on s.marca=old.marca
		left outer join personal on old.marca=personal.marca 
			and ((case when 1=1 then ore_lucrate_regim_normal else ore_lucrate__regie+ore_lucrate_acord end)+ore_concediu_de_odihna+ore_concediu_medical
			+ore_obligatii_cetatenesti+ore_intrerupere_tehnologica+ore_concediu_fara_salar+ore_invoiri+ore_nemotivate<>0 or venit_total<>0)
		where old.data between @Data1  and @Data2
		group by old.marca,old.data	
				
		insert into #stagiuCO
			(marca, media_zilnica, baza_stagiu_luna, zile_stagiu_luna, baza_stagiu1, zile_stagiu1, baza_stagiu2, zile_stagiu2, baza_stagiu3, zile_stagiu3)
		select marca, 0, 0, 0,
		sum(case when data=dbo.eom(@data1) then baza_stagiu else 0 end) as baza_stagiu1,
		sum(case when data=dbo.eom(@data1) then zile_stagiu else 0 end) as zile_stagiu1,
		sum(case when data=dbo.eom(dateadd(month,1,@data1)) then baza_stagiu else 0 end) as baza_stagiu2,
		sum(case when data=dbo.eom(dateadd(month,1,@data1)) then zile_stagiu else 0 end) as zile_stagiu2,
		sum(case when data=dbo.eom(dateadd(month,2,@data1)) then baza_stagiu else 0 end) as baza_stagiu3,
		sum(case when data=dbo.eom(dateadd(month,2,@data1)) then zile_stagiu else 0 end) as zile_stagiu3
		from #tmpStagiu
		group by marca			
	end

	if exists (select * from sysobjects where name ='pCalculCOSP1')
		exec pCalculCOSP1 @datajos=@datajos, @datasus=@datasus, @marca=@marca, @Recalc_CO_luniant=@Recalc_CO_luniant

--  calcul medie zilnica dupa valorile obtinute din istoric
	update cm
	set media_zilnica=(baza_stagiu1+baza_stagiu2+baza_stagiu3)/(case when @MachetaCO=0 and ore_stagiu<>0 then ore_stagiu
		when round(zile_stagiu1+zile_stagiu2+zile_stagiu3,0)=0 then 1 else round(zile_stagiu1+zile_stagiu2+zile_stagiu3,0) end),
		baza_stagiu_luna=t.baza_stagiu, zile_stagiu_luna=t.zile_stagiu
	from #stagiuCO cm
	inner join #stagiuCOLuna t on cm.marca=t.marca

	update tm set 
		tm.baza_stagiu_luna=t.baza_stagiu_luna, 
		tm.zile_stagiu_luna=t.zile_stagiu_luna, 
		tm.baza_stagiu1=t.baza_stagiu1, tm.zile_stagiu1=round(t.zile_stagiu1,0), 
		tm.baza_stagiu2=t.baza_stagiu2, tm.zile_stagiu2=round(t.zile_stagiu2,0), 
		tm.baza_stagiu3=t.baza_stagiu3, tm.zile_stagiu3=round(t.zile_stagiu3,0), 
		tm.media_zilnica=round(t.media_zilnica*(case when @MachetaCO=0 and t.ore_stagiu<>0 then tm.rl else 1 end),3)
	from #tempCO tm
	inner join #stagiuCO t on tm.marca=t.marca 		
	
--	compar media zilnica din istoric cu media zilnica a lunii curente si se stabileste indemnizatia de concediu de odihna.
	If @OUG65=1 or @CO_MVB=1
	begin
		update #tempCO
			Set Indemnizatie_CO=(case when round(abs(Zile_CO)*Media_zilnica,0)>round(abs(Indemnizatie_CO),0) and not (@COEV_macheta=1 and Tip_CO in ('2','E'))
				then round(convert(decimal(12,2),Zile_CO*Media_zilnica),2) else Indemnizatie_CO end)
		from #tempCO
	end
	update #tempCO set Indemnizatie_CO=round(Zile_CO*RL*Salar_de_incadrare/convert(float,RL*Ore_luna/8),2)
	where tip_co='E'

	if object_id('tempdb..#tmpParLunari') is not null
		drop table #tmpParLunari
end try

begin catch
	declare @mesaj varchar(2000)
	set @mesaj = ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror (@mesaj, 11, 1)
end catch


