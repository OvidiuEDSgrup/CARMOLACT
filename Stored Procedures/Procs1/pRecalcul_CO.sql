--***
/**	procedura pentru recalcul indemnizatie CO functie de media zilnica pe ultimele X luni */
Create procedure pRecalcul_CO
	@dataJos datetime, @dataSus datetime, @MarcaJos char(6), @MarcaSus char(6), @LocmJos char(9), @LocmSus char(9) 
As
Begin try
	declare @Ore_luna float, @OreM_luna float, @lBuget int, @OUG65_SI varchar(200), @Spv_CO int,@Spfs_CO int,@Spsp_CO int,@Spspp_CO int, @Indc_CO int, 
		@Sp1_CO int, @Sp2_CO int,@Sp3_CO int, @Sp4_CO int,@Sp5_CO int,@Sp6_CO int, @Sp7_CO int, @Spv_indcond int, 
		@Spspec_suma int, @Spspec_co_baza_suma int, @Spspec_co_nu_baza_suma int, @Spspec_pers int, @Spspec_proc_suma int, @Baza_spspec float, 
		@Spfs_suma int, @Indcond_suma int, @Sp1_suma int,@Sp2_suma int,@Sp3_suma int, @Sp4_suma int,@Sp5_suma int, @Sp6_suma int, @lProcfix_co int,@nProcfix_co float, @Comp_co int, @Suma_comp float, 
		@dataJos_CO datetime, @dataSus_CO datetime, @Elcond int, @Term char(8)

	Set @Ore_luna=dbo.iauParLN(@dataSus,'PS','ORE_LUNA')
	Set @OreM_luna=dbo.iauParLN(@dataSus,'PS','NRMEDOL')
	Set @lBuget=dbo.iauParL('PS','UNITBUGET')
	Set @OUG65_SI=dbo.iauParA('PS','CO-OUG65')
	Set @Spv_co=dbo.iauParL('PS','CO-SP-V')
	Set @Spfs_co=dbo.iauParL('PS','CO-F-SPL')
	Set @Spsp_co=dbo.iauParL('PS','CO-SPEC')
	Set @Spspp_co=dbo.iauParL('PS','CO-S-PR')
	Set @Indc_co=dbo.iauParL('PS','CO-IND')
	Set @Sp1_co=dbo.iauParL('PS','CO-SP1')
	Set @Sp2_co=dbo.iauParL('PS','CO-SP2')
	Set @Sp3_co=dbo.iauParL('PS','CO-SP3')
	Set @Sp4_co=dbo.iauParL('PS','CO-SP4')
	Set @Sp5_co=dbo.iauParL('PS','CO-SP5')
	Set @Sp6_co=dbo.iauParL('PS','CO-SP6')
	Set @Sp7_co=dbo.iauParL('PS','CO-SP7')
	Set @Spv_indcond=dbo.iauParL('PS','SP-V-INDC')
	Set @Spspec_suma=dbo.iauParL('PS','SSP-SUMA')
	Set @Spspec_proc_suma=dbo.iauParL('PS','SSPEC')
	Set @Baza_spspec=dbo.iauParN('PS','SSPEC')
	Set @Spfs_suma=dbo.iauParL('PS','SPFS-SUMA')
	Set @Indcond_suma=dbo.iauParL('PS','INDC-SUMA')
	Set @Sp1_suma=dbo.iauParL('PS','SC1-SUMA')
	Set @Sp2_suma=dbo.iauParL('PS','SC2-SUMA')
	Set @Sp3_suma=dbo.iauParL('PS','SC3-SUMA')
	Set @Sp4_suma=dbo.iauParL('PS','SC4-SUMA')
	Set @Sp5_suma=dbo.iauParL('PS','SC5-SUMA')
	Set @Sp6_suma=dbo.iauParL('PS','SC6-SUMA')
	Set @lProcfix_co=dbo.iauParL('PS','CO-SPFIX')
	Set @nProcfix_co=dbo.iauParN('PS','CO-SPFIX')
	Set @Comp_co=dbo.iauParL('PS','CO-COMP')
	Set @Suma_comp=dbo.iauParN('PS','SUMACOMP')
	Set @dataJos_CO=dbo.eom(dateadd(month,-3,@dataJos))
	Set @dataSus_CO=dbo.eom(dateadd(month,-1,@dataJos))
	Set @Elcond=dbo.iauParL('SP','ELCOND')
	Set @Term=isnull((select convert(char(8), abs(convert(int, host_id())))),'')

	update brut set 
	ind_obligatii_cetatenesti=round(convert(decimal(15,5),(case when @Elcond=0 then ind_obligatii_cetatenesti when ore_obligatii_cetatenesti*
		isnull((select sum(ind_regim_normal+@Spv_CO*spor_vechime+@Spfs_CO*spor_de_functie_suplimentara+@Spsp_CO*spor_specific+@Spspp_CO*spor_sistematic_peste_program
		+@Indc_CO*ind_nemotivate+@Sp1_CO*spor_cond_1+ @Sp2_CO*spor_cond_2+@Sp3_CO*spor_cond_3+@Sp4_CO*spor_cond_4+@Sp5_CO*spor_cond_5+@Sp6_CO*spor_cond_6
		+ind_intrerupere_tehnologica+ind_invoiri+ind_obligatii_cetatenesti+(case when @Elcond=0 then ind_concediu_de_odihna else 0 end))/
		(case when sum(ore_lucrate_regim_normal+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti+(case when @Elcond=0 then ore_concediu_de_odihna else 0 end))=0 then 1 
			else sum(ore_lucrate_regim_normal+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti+(case when @Elcond=0 then ore_concediu_de_odihna else 0 end)) end)
		from brut old where old.marca=brut.marca and old.data between @dataJos_CO and @dataSus_CO),0) 
		>ind_obligatii_cetatenesti then ore_obligatii_cetatenesti*isnull((select sum(ind_regim_normal+@Spv_CO*spor_vechime+@Spfs_CO*spor_de_functie_suplimentara+@Spsp_CO*spor_specific
		+@Spspp_CO*spor_sistematic_peste_program+@Indc_CO*ind_nemotivate+@Sp1_CO*spor_cond_1+@Sp2_CO*spor_cond_2+ @Sp3_CO*spor_cond_3+@Sp4_CO*spor_cond_4+@Sp5_CO*spor_cond_5+@Sp6_CO*spor_cond_6
		+ind_intrerupere_tehnologica+ind_invoiri+ind_obligatii_cetatenesti+(case when @Elcond=0 then ind_concediu_de_odihna else 0 end))/
			(case when sum(ore_lucrate_regim_normal+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti+(case when @Elcond=0 then ore_concediu_de_odihna else 0 end))=0 then 1 
			else sum(ore_lucrate_regim_normal+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti+(case when @Elcond=0 then ore_concediu_de_odihna else 0 end)) end)
		from brut old where old.marca=brut.marca and old.data between @dataJos_CO and @dataSus_CO),0) 
		else ind_obligatii_cetatenesti end)),0) 
	from personal 
	where brut.data=@dataSus and brut.marca between @MarcaJos and @MarcaSus 
		and personal.loc_de_munca between @LocmJos and @LocmSus and brut.marca=personal.marca

	/*	Calcul indemnizatie concediu de odihna conform mediei pe ultimele 3 luni (OUG65/2005) 
		utilizand procedura pCalculCO care este apelata si dinspre calcul concedii de odihna (daca se lucreaza cu macheta de CO). */
	if object_id('tempdb..#tempCO') is not null
		drop table #tempCO 
	create table #tempCO (data datetime)
	exec CreeazaDiezSalarii @numeTabela='#tempCO'
	insert into #tempCO (data, marca, tip_CO, Data_inceput, Zile_CO, introd_manual, Indemnizatie_CO, RL, Loc_de_munca, Salar_de_incadrare, 
		media_zilnica, Ore_luna, baza_stagiu_luna, zile_stagiu_luna, baza_stagiu1, zile_stagiu1, baza_stagiu2, zile_stagiu2, baza_stagiu3, zile_stagiu3)
	select b.data, p.marca as marca, '1' as tip_CO, b.data as Data_inceput,
		   b.Ore_concediu_de_odihna/isnull(nullif(b.Spor_cond_10,0),8) as Zile_CO, 0 as Introd_manual,convert(decimal(6,2),0) as Indemnizatie_CO,
		   isnull(nullif(b.Spor_cond_10,0),8) as RL, b.loc_de_munca, p.Salar_de_incadrare as Salar_de_incadrare, convert(float,0) as media_zilnica_co,
		   (case when isnull(ol.Val_numerica,0)=0 then dbo.zile_lucratoare(dbo.bom(b.Data),b.Data)*8 else isnull(ol.val_numerica,0) end) as Ore_luna, 
		   0 as baza_stagiu_luna, 0 as zile_stagiu_luna, 0 as baza_stagiu1, 0 as zile_stagiu1, 0 as baza_stagiu2, 0 as zile_stagiu2, 0 as baza_stagiu3, 0 as zile_stagiu3
	from brut b
	inner join personal p on b.marca=p.marca
	left outer join par_lunari ol on b.data=ol.data and ol.tip='PS' and ol.parametru='ORE_LUNA'
	where b.data=@dataSus and b.marca between @MarcaJos and @MarcaSus 
		and p.loc_de_munca between @LocmJos and @LocmSus

	exec pCalculCO @datajos=@dataJos, @dataSus=@dataSus, @marca=@MarcaJos, @recalc_CO_luniant=0

	--script de verificare
	--select tm.marca,tm.data,tm.indemnizatie_CO, b.ind_concediu_de_odihna
	--from #tempCO tm
	--inner join brut b on tm.marca=b.marca and tm.data=b.data
	--where b.ind_concediu_de_odihna<>round(tm.indemnizatie_CO,0)
	update brut
		set ind_concediu_de_odihna=round(tm.indemnizatie_CO,0)
	from #tempCO tm
	where brut.marca=tm.marca and brut.data=tm.data and brut.loc_de_munca=tm.loc_de_munca

End try

Begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura pRecalcul_CO (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
End catch

