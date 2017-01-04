--***
/*	procedura pentru determinarea istoricului (baza de calcul) concediilor de de odihna */
Create procedure rapIstoricConcediiOdihna
	(@dataJos datetime, @dataSus datetime, @locm char(9)=null, @strict int=0, @marca char(6)=null, @functie char(6)=null, @grupamunca char(1)=null, @grupaexceptata int=0, 
	@tippersonal char(1)=null, @tipStat varchar(30)=null, @ordonare char(2)='', @alfabetic int=1, 
	@istoric_pt_zile_co_ramase int=0, @zile_ramase_fct_cuvenite_la_luna int=0, @listadreptCond char(1)='T') 																				
as
/*
	exec rapIstoricConcediiOdihna @datajos='01/01/2015', @datasus='11/30/2015', @istoric_pt_zile_co_ramase=1 , @marca='R102'   @null, 0, null, null, null, 0, null, null, '1', 0, 0, 0, 'T'
*/
begin try
	declare @ProcCasGr3 float, @ProcCasIndiv float, @ProcCCI float, @ProcCASSUnit float, @ProcSomajUnit float, @ProcFondGar float, @ProcFambp float, @ProcITM float, 
			@ProcChelt float, @Recalc_CO_luniant int, @Zile_co_ramase bit, @data1_an datetime, @Datas12_anant datetime, @data1 datetime, @dreptConducere int
	set @Recalc_CO_luniant=0
	
	select @ProcCasGr3=max(case when Parametru='CASGRUPA3' then val_numerica else 0 end), 
		   @ProcCasIndiv = max(case when Parametru='CASINDIV' then val_numerica else 0 end),
		   @ProcCCI = max(case when Parametru='COTACCI' then val_numerica else 0 end),
		   @ProcCASSUnit = max(case when Parametru='CASSUNIT' then val_numerica else 0 end),
		   @ProcSomajUnit = max(case when Parametru='3.5%SOMAJ' then val_numerica else 0 end),
		   @ProcFondGar = max(case when Parametru='FONDGAR' then val_numerica else 0 end),
	       @ProcFambp = max(case when Parametru='0.5%ACCM' then val_numerica else 0 end),
	       @ProcITM = max(case when Parametru='1%-CAMERA' then val_numerica else 0 end)
	from par_lunari where Data = @dataSus and tip = 'PS' and parametru in ('CASGRUPA3','CASINDIV','COTACCI','CASSUNIT','3.5%SOMAJ','FONDGAR','0.5%ACCM','1%-CAMERA')
	set @ProcChelt=@ProcCasGr3-@ProcCasIndiv+@ProcCCI+@ProcCASSUnit+@ProcSomajUnit+@ProcFondGar+@ProcFambp+@ProcITM
	
		select @dreptConducere=max(case when Parametru='DREPTCOND' then val_logica else 0 end), 
			   @Zile_co_ramase = max(case when Parametru='ZILECORAM' then val_logica else 0 end)
		from par where tip_parametru = 'PS' and parametru in ('DREPTCOND','ZILECORAM')

	declare @aredreptCond int, @lista_drept char(1), @utilizator varchar(20)	-- pt filtrare pe Proprietatea LOCMUNCA a utilizatorului (daca e definita)
	set @utilizator = dbo.fiaUtilizator('')
--	verific daca utilizatorul are/nu are dreptul de Salarii Conducere (SALCOND)
	set @lista_drept=@listadreptCond
	set @areDreptCond=0
	Set @Datas12_anant=dateadd(day,-1,@dataJos)
	if  @dreptConducere=1 
	begin
		set @areDreptCond=isnull((select dbo.verificDreptUtilizator(@utilizator,'SALCOND')),0)
		if @aredreptCond=0
			set @lista_drept='S'
	end
	set @data1_an=dbo.boy(@datasus)
	
--	stabilesc pentru ce zile se doreste calculul istoricului
/*
	@istoric_pt_zile_co_ramase=1 - determinare istoric pentru zilele de concediu de odihna ramase de efectuat
	@istoric_pt_zile_co_ramase=0 - determinare istoric pentru zilele de concediu de odihna efectuate in luna
*/
	--curatenie
	if object_id('tempdb..#tmpBrut') is not null
		drop table #tmpBrut
	if object_id('tempdb..#tmpConc') is not null
		drop table #tmpConc
	if object_id('tempdb..#ZileCO') is not null
		drop table #ZileCO
	if object_id('tempdb..#tempCO') is not null
		drop table #tempCO 
	if object_id('tempdb..#rapCOAn') is not null
		drop table #rapCOAn 

--	se creeaza tabela filtrata
	create table #ZileCO (data datetime, marca char(6), zile_co int, RL decimal(6,2), indemnizatie_co float, indemnizatie_co_an float, zile_co_efectuat_an int)
	--selectam datele din concedii de odihna pe linie dupa marca
	select marca, 
		   sum(isnull(case when data between @data1_an and @dataSus and tip_concediu='C' then Indemnizatie_co+Prima_vacanta else 0 end,0)) as provizion,
		   sum(isnull(case when data between @dataJos and @dataSus and (tip_concediu='3' or tip_concediu='6') then zile_co else 0 end,0)) as zile_co_an  
	into #tmpConc
	from concOdih co
	where data between @datajos and @datasus and (@marca is null or marca=@marca)
	group by marca
	
	-- se selecteaza datele din brut pe linie dupa marca
	select b.marca,
		   sum(case when b.data=@datasus then b.ind_concediu_de_odihna else 0 end) as ind_co, 
		   sum(case when b.data between @data1_an and @datasus then b.ind_concediu_de_odihna else 0 end) as ind_co_an,
		   sum(case when b.data between @dataJos and @dataSus then b.ore_concediu_de_odihna/(case when b.spor_cond_10=0 then 8 else b.spor_cond_10 end) else 0 end)+max(isnull(tm.zile_co_an,0)) as Zile_co_efectuat_an, 
		   round(sum(case when b.data between @dataJos and @dataSus then isnull(b.ind_concediu_de_odihna,0) else 0 end),0) as Indemnizatie_CO_an 
	into #tmpBrut
	from brut b
		left join #tmpConc tm on tm.marca=b.marca
	where b.data between @datajos and @datasus
		and (@marca is null or b.marca=@marca)
	group by b.marca
	
	if @istoric_pt_zile_co_ramase=0
	begin
		if object_id('tempdb..#tmpZileCO') is null
			create table #tmpZileCO (data datetime, marca char(6), zile_co int, RL decimal(6,2))
		else 
			delete #tmpZileCO
		insert into #tmpZileCO
		select dbo.eom(a.data) as data, a.marca as marca, sum(a.ore_concediu_de_odihna/a.regim_de_lucru) as zile_co,max(a.regim_de_lucru) as RL
		from pontaj a 
		where a.data between @datajos and @datasus and a.ore_concediu_de_odihna<>0
			and (@marca is null or a.marca=@marca) 
		group by dbo.eom(a.data), a.marca
		union all
		select co.data, co.Marca, sum(Zile_CO) as zile_co , 0 as RL
		from concodih co
		where co.data between @datajos and @datasus and co.Zile_CO<>0 and co.Tip_concediu in ('3','6')
			and (@marca is null or co.marca=@marca) 
		group by co.data, co.marca

		insert into #zileCO
		select dbo.eom(a.data), a.marca as marca, sum(a.zile_co) as zile_co, max(isnull(nullif(a.RL,0),isnull(nullif(i.salar_lunar_de_baza,0),8))),
			sum(isnull(b.ind_co,0)) as indemnizatie_co, 
			sum(isnull(b.ind_co_an,0)) as indemnizatie_co_an, 0 as zile_co_efectuat_an
		from #tmpzileco a 
			left outer join personal p on a.marca=p.marca
			left outer join istpers i on a.data=i.data and a.marca=i.marca 
			left outer join lm on lm.COd = p.loc_de_munca 
			left outer join #tmpBrut b on a.marca=b.marca
		where @istoric_pt_zile_co_ramase=0 
			and (@locm is null or i.loc_de_munca like rtrim(@locm)+(case when @strict=0 then '%' else '' end)) 
			and (@functie is null or i.Cod_functie = @Functie)
			and (@grupamunca is null or (@grupaexceptata=0 and p.grupa_de_munca=@grupamunca or @grupaexceptata=1 and p.grupa_de_munca<>@grupamunca)) 
			and (@tippersonal is null or (@tippersonal='T' and isnull(i.tip_salarizare,p.Tip_salarizare) in ('1','2')) or (@tipPersonal='M' and isnull(i.tip_salarizare,p.Tip_salarizare) in ('3','4','5','6','7')))		
			and (@tipStat is null or p.tip_stat=@tipStat)
			and (@dreptCOnducere=0 or (@dreptCOnducere=1 and @aredreptCOnd=1 and (@lista_drept='t' or @lista_drept='C' and p.pensie_suplimentara=1 or @lista_drept='S' and p.pensie_suplimentara<>1)) 
			or (@dreptCOnducere=1 and @aredreptCOnd=0 and @lista_drept='S' and p.pensie_suplimentara<>1))
			and (dbo.f_arelmFiltru(@utilizator)=0 or exists (select 1 from lmfiltrare lu where lu.utilizator=@utilizator and lu.Cod=isnull(i.loc_de_munca,p.loc_de_munca)))			
		group by dbo.eom(a.data), a.marca
	end

	if @istoric_pt_zile_co_ramase=1
	begin
	-- folosim rapConcediiOdihnaPeAn o singura data
		if object_id('tempdb..#rapCOAn') is null
		begin
			create table #rapCOAn (data datetime)
			exec CreeazaDiezSalarii @numeTabela='#rapCOAn'
		end
		exec rapConcediiOdihnaPeAn @data1_an, @datasus, @marca, @locm, @strict, @functie, @grupamunca, @grupaexceptata, @tippersonal, @tipStat, 0, '', 0, @zile_ramase_fct_cuvenite_la_luna
	

		insert into #zileco
		select a.data, a.marca, sum(a.zile_co_neefectuat_an_ant+(case when @zile_ramase_fct_cuvenite_la_luna=1 then zile_co_cuvenite_la_luna else a.zile_co_cuvenite_an end)-a.zile_co_efectuat_an), 
		max(isnull(nullif(i.salar_lunar_de_baza,0),8)) as RL, 0 as indemnizatie_co,  
		isnull((select sum(r.ind_concediu_de_odihna) from brut r where r.data between @data1_an and @datasus and r.marca = a.marca),0) as indemnizatie_co_an, sum(zile_co_efectuat_an) as zile_co_efectuat_an
		from #rapCOAn a
		left join istpers i on i.marca=a.marca and i.data=a.data
		where a.zile_co_neefectuat_an_ant+(case when @zile_ramase_fct_cuvenite_la_luna=1 then zile_co_cuvenite_la_luna else a.zile_co_cuvenite_an end)-a.zile_co_efectuat_an<>0
		group by a.data, a.marca
	end

	create table #tempCO (data datetime)
	exec CreeazaDiezSalarii @numeTabela='#tempCO'
	
	insert into #tempCO
		(data, marca, tip_CO, Data_inceput, Zile_CO, introd_manual, Indemnizatie_CO, RL, Salar_de_incadrare, media_zilnica, 
		Ore_luna, baza_stagiu_luna, zile_stagiu_luna, baza_stagiu1, zile_stagiu1, baza_stagiu2, zile_stagiu2, baza_stagiu3, zile_stagiu3)
	select a.data, a.marca, '1' as tip_CO, a.data as Data_inceput, a.Zile_CO as Zile_CO, 0 as Introd_manual, a.Indemnizatie_CO,
		   isnull(a.RL,8) as RL, i.Salar_de_incadrare as Salar_de_incadrare, convert(float,0) as media_zilnica,
		   (case when isnull(ol.Val_numerica,0)=0 then dbo.zile_lucratoare(dbo.bom(a.Data),a.Data)*8 else isnull(ol.val_numerica,0) end) as Ore_luna, 
		   0 as baza_stagiu_luna, 0 as zile_stagiu_luna, 0 as baza_stagiu1, 0 as zile_stagiu1, 0 as baza_stagiu2, 0 as zile_stagiu2, 0 as baza_stagiu3, 0 as zile_stagiu3
	from #zileCO a
		left outer join istpers i on a.marca=i.marca and i.Data=@dataSus
		left outer join par_lunari ol on a.data=ol.data and ol.tip='PS' and ol.parametru='ORE_LUNA'
	order by a.marca, a.data 
	set @data1=dbo.BOM(@dataSus)

	exec pCalculCO @data1, @dataSus, @marca, @Recalc_CO_luniant
	update t
		set indemnizatie_co=(case when t.zile_co<0 and tb.zile_co_efectuat_an<>0 then convert(decimal(10),convert(decimal(6,2),t.zile_co)*convert(decimal(12,2),tb.indemnizatie_co_an)/convert(decimal(6,2),tb.zile_co_efectuat_an)) 
		else indemnizatie_co end) 
	from #tempCO t
	inner join #tmpBrut tb on tb.marca=t.marca

-- selectul principal in cursorul #tmpSel
	if object_id('tempdb..#tmpSel') is not null 
		drop table #tmpSel
	select a.data, a.marca, max(isnull(i.nume,p.nume)) as nume, max(isnull(i.loc_de_munca,p.loc_de_munca)) as lm, max(lm.denumire) as den_lm, 
		sum(a.zile_co) as zile_co, 
		max(t.indemnizatie_CO) as indemnizatie_co, max(a.indemnizatie_co_an) as indemnizatie_co_an,
		max(baza_stagiu1) as baza_calcul_3, max(baza_stagiu2) as baza_calcul_2, max(baza_stagiu3) as baza_calcul_1,
		max(convert(int,zile_stagiu1)) as zile_calcul_3, max(convert(int,zile_stagiu2)) as zile_calcul_2, max(convert(int,zile_stagiu3)) as zile_calcul_1, 
		max(convert(int,zile_stagiu1+zile_stagiu2+zile_stagiu3)) as zile_3luni,	max(t.baza_stagiu_luna) as baza_calcul_luna,max(t.zile_stagiu_luna) as zile_calcul_luna, 
		sum(case when t.zile_stagiu_luna<>0 then round(t.baza_stagiu_luna/t.zile_stagiu_luna,3) else 0 end) as media_luna_curenta, 
		max(t.media_zilnica) as media_ultimelor_3_luni, sum((case when (case when t.zile_stagiu_luna<>0 then round(t.baza_stagiu_luna/t.zile_stagiu_luna,3) else 0 end)>t.media_zilnica then 
		(case when t.zile_stagiu_luna<>0 then round(t.baza_stagiu_luna/t.zile_stagiu_luna,3) else 0 end) else t.media_zilnica end)) as media_zilnica_co, 
		sum(round(t.indemnizatie_co*@ProcChelt/100,0)) as taxe_unitate, sum(t.indemnizatie_co+round(t.indemnizatie_co*@ProcChelt/100,0)) as total_chelt, 
		sum(isnull(tm.provizion,0)-Indemnizatie_co_an) as provizion, (case when @ordonare='2' then max(isnull(i.loc_de_munca,p.loc_de_munca)) else '' end) as ordonare
	into #tmpSel
	from #zileCO a 
		left outer join personal p on a.marca=p.marca
		left outer join istpers i on a.data=i.data and a.marca=i.marca 
		left outer join lm on lm.COd = isnull(i.Loc_de_munca,p.loc_de_munca)
		left outer join #tempCO t on a.marca=t.marca and a.data=t.data
		left outer join #tmpConc tm on a.marca=tm.marca
	where a.data between @datajos and @datasus and a.zile_co<>0
	group by a.data, a.marca
	order by ordonare,(case when @Alfabetic=1 then max(p.nume) else a.marca end)

	if object_id('tempdb..#IstoricCO') is not null
		insert into #IstoricCO
		select * from #tmpSel
	else
		select * from #tmpSel
		order by ordonare,(case when @Alfabetic=1 then nume else marca end)

end try

begin catch
	declare @mesaj varchar(2000)
	set @mesaj = ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror (@mesaj, 11, 1)
end catch

