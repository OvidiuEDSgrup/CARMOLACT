--***
/**	procedura pentru lista de evidentiere ore suplimentare salarii */
Create procedure rapOreSuplimentareSalarii
	(@dataJos datetime, @dataSus datetime, 
	@marca char(6), @locm char(9)=null, @strict int=0, @tipSalarizare char(1)=null, @grupamunca char(1)=null, 
	@ordonare char(1), @listaDreptCond char(1)='T', @alfabetic int=0, @afisarecnp int=0, @filtraredepasiri int=0)
as
/*
	=dateadd("d",1-day(today()),today())
	Ordonare=0 -> Locuri de munca, salariati
	Ordonare=1 -> Salariati
	Filtrare ore -> null=Lista integrala, 1=doar salariati cu ore depasire
	Exemplu de apel.
	exec rapOreSuplimentareSalarii @dataJos='07/01/2015', @dataSus='07/31/2015', @marca=null, @locm=null, @strict=0, @tipSalarizare=null, @grupamunca=null, 
		@ordonare='1', @listaDreptCond='T', @alfabetic=0, @afisarecnp=0
*/
declare @eroare varchar(2000)
begin try
	set transaction isolation level read uncommitted
	declare @utilizator char(10), @dreptConducere int, @areDreptCond int, @zile_lucratoare int, @dataSus_1 datetime

--	pt filtrare pe proprietatea LOCMUNCA a utilizatorului (daca e definita)
	set @utilizator=dbo.fIaUtilizator(null)
	set @dreptConducere=dbo.iauParL('PS','DREPTCOND')
	set @zile_lucratoare=dbo.zile_lucratoare(@datajos, @datasus)

	set @dataSus_1=dbo.BOM(@dataSus)

--	verific daca utilizatorul are/nu are dreptul de Salarii conducere (SALCOND)
	set @areDreptCond=0
	if  @dreptConducere=1 
	begin
		set @areDreptCond=isnull((select dbo.verificDreptUtilizator(@utilizator,'SALCOND')),0)
		if @areDreptCond=0 -- daca utilizatorul nu are drept conducere atunci are acces doar la cei de tip salariat
			set @listaDreptCond='S'
	end

	if object_id('tempdb.dbo.#oresupl') is not null
		drop table #oresupl

	select max(b.data) as data, b.marca, max(rtrim(isnull(i.Nume,p.Nume))) as nume, max(p.cod_numeric_personal) as cnp,
		max(isnull(i.loc_de_munca,n.loc_de_munca)) as lm, max(rtrim(lm.denumire)) as denlm, 
		max(isnull(i.cod_functie,p.cod_functie)) as functie, max(rtrim(f.denumire)) as denfunctie, 
		max(p.data_angajarii_in_unitate) as data_angajarii, max(convert(int,p.loc_ramas_vacant)) as plecat, max(p.data_plec) as data_plec, 
		sum(b.Ore_lucrate__regie+b.Ore_lucrate_acord) as ore_lucrate, 
		sum(b.Ore_suplimentare_1) as oresupl1, sum(b.Indemnizatie_ore_supl_1) as indoresupl1, sum(b.Ore_suplimentare_2) as oresupl2, sum(b.Indemnizatie_ore_supl_2) as indoresupl2, 
		sum(b.Ore_suplimentare_3) as oresupl3, sum(b.Indemnizatie_ore_supl_3) as indoresupl3, sum(b.Ore_suplimentare_4) as oresupl4, sum(b.Indemnizatie_ore_supl_4) as indoresupl4, 
		sum(b.Ore_suplimentare_1+b.Ore_suplimentare_2+b.Ore_suplimentare_3+b.Ore_suplimentare_4) as total_ore_supl, 
		sum(b.ore_concediu_de_odihna+b.ore_concediu_medical+b.ore_intrerupere_tehnologica+b.ore_obligatii_cetatenesti+b.Ore_concediu_fara_salar+b.Ore_invoiri+b.Ore_nemotivate) as ore_nelucrate, 
		max(case when p.data_angajarii_in_unitate>@datajos then p.data_angajarii_in_unitate else @datajos end) as data_ini_calcul, 
		max(case when p.loc_ramas_vacant=1 and p.data_plec<@datasus then p.data_plec else @datasus end) as data_sf_calcul,
		convert(decimal(12,2),0) as zile_lucratoare, 0 as oresupllegale, 0 as oresupl_depasire, convert(decimal(10,2),0) as ore_lucrate_saptamina, 
		(case when @ordonare='2' then '' else max(n.loc_de_munca) end)+(case when @alfabetic=1 then max(p.nume) else b.marca end) as ordonare
	into #oresupl
	from brut b 
		left outer join personal p on p.marca=b.marca
		left outer join istpers i on i.data=b.data and i.marca=b.marca
		left outer join net n on n.data=b.data and n.marca=b.marca
		left outer join lm on lm.cod=b.loc_de_munca
		left outer join functii f on f.cod_functie=isnull(i.cod_functie,p.cod_functie)
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=isnull(i.Loc_de_munca,p.loc_de_munca)
	where b.data between @datajos and @dataSus 
		and (nullif(@marca,'') is null or n.marca=@marca) 
		and (nullif(@locm,'') is null or n.loc_de_munca like RTRIM(@locm)+(case when @strict=1 then '' else '%' end))
		and (@tipSalarizare is null or isnull(i.tip_salarizare,p.tip_salarizare)=@tipSalarizare) 
		and (@grupaMunca is null  or isnull(i.Grupa_de_munca,p.grupa_de_munca)=@grupaMunca) 
		and (@dreptConducere=0 or (@AreDreptCond=1 and (@ListaDreptCond='T' or @ListaDreptCond='C' and p.pensie_suplimentara=1 or @ListaDreptCond='S' and p.pensie_suplimentara<>1)) 
			or (@AreDreptCond=0 and p.pensie_suplimentara<>1)) 
		and (dbo.f_areLMFiltru(@utilizator)=0 or lu.cod is not null)
		and (p.Loc_ramas_vacant=0 or p.Data_plec>@dataSus_1)
	group by b.Marca

	/*	Calcul ore suplimentare legale conform perioadei de angajare. Trebuie acordate maxim 8 ore suplimentare / saptamina. Calculez cu functie doar unde este cazul, ca sa mearga mai repede. */
	update #oresupl set zile_lucratoare=(case when data_angajarii>@datajos or plecat=1 and data_plec<@datasus then dbo.zile_lucratoare(data_ini_calcul,data_sf_calcul) else @zile_lucratoare end)

	update #oresupl set oresupllegale=round(zile_lucratoare*8/5.00,0)

	/*	Calcul ore suplimentare depasite fata de norma legala. */
	update #oresupl set oresupl_depasire=oresupl1+oresupl2+oresupl3+oresupl4-oresupllegale
	update #oresupl set oresupl_depasire=(case when oresupl_depasire<0 then 0 else oresupl_depasire end)

	/*	Calcul zile lucrate in medie per/saptamina. */
	update #oresupl set ore_lucrate_saptamina=(ore_lucrate+ore_nelucrate)/zile_lucratoare*5.00

	if exists (select * from sysobjects where name ='rapOreSuplimentareSalariiSP' and xtype='P')
		exec rapOreSuplimentareSalariiSP @dataJos=@dataJos, @dataSus=@dataSus, 
			@marca=@marca, @locm=@locm, @strict=@strict, @tipSalarizare=@tipSalarizare, @grupamunca=@grupamunca, @ordonare=@ordonare, @listaDreptCond=@listaDreptCond, @alfabetic=@alfabetic

	select	data, marca, nume, cnp, lm, denlm, functie, denfunctie, 
			ore_lucrate, oresupl1, indoresupl1, oresupl2, indoresupl2, oresupl3, indoresupl3, oresupl4, indoresupl4, total_ore_supl, zile_lucratoare, oresupllegale, oresupl_depasire, 
			ore_nelucrate, ore_lucrate_saptamina, ordonare 
	from #oresupl
	where (@filtraredepasiri=0 or @filtraredepasiri=1 and oresupl_depasire>0 or @filtraredepasiri=2 and ore_lucrate_saptamina>48)
	order by ordonare
end try

begin catch
	set @eroare='Procedura rapOreSuplimentareSalarii (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch