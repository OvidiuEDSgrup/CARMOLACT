--***
/**	functie concedii de odihna	
	@dataJos -> prima zi din an
	@dataSus -> ultima zi din luna de lucru

	exec rapConcediiOdihnaPeAn @datajos='01/01/2015', @datasus='11/30/2015', @primavacantacorD=0, @tipzileramase=0, @ordonare='', @marca='R109'

*/
Create procedure rapConcediiOdihnaPeAn
	(@dataJos datetime, @dataSus datetime, @marca char(6)=null, @locm char(9)=null, @strict int=0, @functie char(6)=null, @grupamunca char(1)=null, @grupaexceptata int=0, 
	@tippersonal char(1)=null, @tipstat varchar(30)=null, @primavacantacorD int, @ordonare char(1), @alfabetic int=0, @tipzileramase int)
as
begin try
	declare @Zile_co_ramase bit, @Dataj12_anant datetime, @Datas12_anant datetime, @Subtipcor int, @ZileCOVechUnit int, 
	@dreptConducere int, @areDreptCond int, @lista_drept char(1)


	select @dreptConducere=max(case when Parametru='DREPTCOND' then val_logica else 0 end), 
		   @Zile_co_ramase = max(case when Parametru='ZILECORAM' then val_logica else 0 end),
		   @Subtipcor = max(case when Parametru='SUBTIPCOR' then val_logica else 0 end),
		   @ZileCOVechUnit = max(case when Parametru='ZICOVECHU' then val_logica else 0 end)
	from par where tip_parametru = 'PS' and parametru in ('DREPTCOND','ZILECORAM','SUBTIPCOR','ZICOVECHU')
	Set @Dataj12_anant=dbo.bom(dateadd(day,-1,@dataJos))
	Set @Datas12_anant=dateadd(day,-1,@dataJos)

	declare @utilizator varchar(20)
	SET @utilizator = dbo.fIaUtilizator('')

--	verific daca utilizatorul are/nu are dreptul de Salarii conducere (SALCOND)
	set @lista_drept='T'
	set @areDreptCond=0
	if  @dreptConducere=1 
	begin
		set @areDreptCond=isnull((select dbo.verificDreptUtilizator(@utilizator,'SALCOND')),0)
		if @areDreptCond=0
			set @lista_drept='S'
	end 

	if OBJECT_ID('tempdb..#personal') is not null
		drop table #personal
	if OBJECT_ID('tempdb..#marci') is not null
		drop table #marci
	if OBJECT_ID('tempdb..#zileCOcuv') is not null
		drop table #zileCOcuv
	if OBJECT_ID('tempdb..#zileCOcuvAn') is not null
		drop table #zileCOcuvAn
	if OBJECT_ID('tempdb..#zileCOcuvLuna') is not null
		drop table #zileCOcuvLuna
	if OBJECT_ID('tempdb..#tmpBrutCO') is not null
		drop table #tmpBrutCO
	if OBJECT_ID('tempdb..#tmpConcCO') is not null
		drop table #tmpConcCO
	-- aplicam filtrele cat mai repede
	select p.*
	into #personal
	from personal p
		left outer join lm on p.loc_de_munca=lm.cod 
		left outer join istpers i on i.data=@dataSus and i.marca=p.marca 
		left outer join infopers ip on ip.marca=p.marca 
	where (@marca is null or p.marca=@marca) 
		and (@locm is null or p.loc_de_munca like rtrim(@locm)+(case when @strict=1 then '' else '%' end)) 
		and (@grupamunca is null or (@grupaexceptata=0 and p.grupa_de_munca=@grupamunca or @grupaexceptata=1 and p.grupa_de_munca<>@grupamunca)) 
		and (p.loc_ramas_vacant=0 and p.Data_angajarii_in_unitate<=dbo.EOM(@dataSus) 
			or p.Data_plec>=dbo.bom(@dataSus) or p.Data_angajarii_in_unitate>=dbo.BOM(@dataSus))
		and exists (select i.Marca from istpers i where data between @dataJos and @dataSus and Marca=p.marca) 
		and (@functie is null or p.Cod_functie=@functie) 
		and (@tippersonal is null or (@tippersonal='T' and isnull(i.tip_salarizare,p.Tip_salarizare) in ('1','2')) or (@tipPersonal='M' and isnull(i.tip_salarizare,p.Tip_salarizare) in ('3','4','5','6','7')))
		and (@tipstat is null or isnull(p.tip_stat,ip.Religia)=@tipstat)
		and (dbo.f_areLMFiltru(@utilizator)=0 or exists (select 1 from lmfiltrare l where l.utilizator=@utilizator and l.cod=p.Loc_de_munca))
		and (@dreptConducere=0 or (@dreptConducere=1 and @areDreptCond=1 and (@lista_drept='T' or @lista_drept='C' and p.pensie_suplimentara=1 or @lista_drept='S' and p.pensie_suplimentara<>1)) 
		or (@dreptConducere=1 and @areDreptCond=0 and @lista_drept='S' and p.pensie_suplimentara<>1))
	order by p.marca,p.cod_functie

	/*	Populam tabela #marci si pe baza ei se va face calculul zilelor de CO cuvenite doar pentru aceste marci. */
	select marca into #marci from #personal
	/*	Calculam prin procedura pZileCOcuvenite, numarul de zile de CO cuvenite pe An. */
	create table #zileCOcuv (marca varchar(6), zile int)
	exec pZileCOcuvenite @marca=null, @data=@dataSus, @Calcul_pana_la_luna_curenta=0
	select marca, zile into #zileCOcuvAn
	from #zileCOcuv

	/*	Calculam prin procedura pZileCOcuvenite, numarul de zile de CO cuvenite pana la luna de lucru (luna urmatoare lunii inchise)*/
	delete from #zileCOcuv
	exec pZileCOcuvenite @marca=null, @data=@DataSus, @Calcul_pana_la_luna_curenta=1
	select marca, zile into #zileCOcuvLuna
	from #zileCOcuv
	-- selectam pe aceeasi linie zilele si indemnizatia CO pe luna si pe an din brut
	select b.marca,
		   sum(case when b.data between dbo.bom(@dataSus) and @dataSus then b.ore_concediu_de_odihna/(case when b.spor_cond_10=0 then 8 else b.spor_cond_10 end) else 0 end) as Zile_co_efectuat_in_luna,
		   round(sum(case when b.data between dbo.bom(@dataSus) and @dataSus then b.ind_concediu_de_odihna else 0 end),0) as Indemnizatie_CO_luna,
		   sum(case when b.data between @dataJos and @dataSus then b.ore_concediu_de_odihna/(case when b.spor_cond_10=0 then 8 else b.spor_cond_10 end) else 0 end) as Zile_co_efectuat_an,
		   round(sum(case when b.data between @dataJos and @dataSus then b.ind_concediu_de_odihna else 0 end),0) as Indemnizatie_CO_an
	into #tmpBrutCO
	from brut b
	inner join #personal p on p.marca=b.marca
	group by b.marca	

	-- selectam pe linie zilele din CO
	select c.marca, 
		   sum(case when (c.tip_concediu='3' or c.tip_concediu='6') then c.zile_co else 0 end) as zile_co_sum, 
		   sum(case when (c.tip_concediu='4' or c.tip_concediu='6' or c.tip_concediu='8' or c.tip_concediu='5' and (h.marca is not null)) then (case when c.tip_concediu='5' then -1 else 1 end)*c.zile_co else 0 end) as zile_co_efectuat_din_an_ant
	into #tmpConcCO 
	from concOdih c
	left outer join concodih h on c.marca=h.marca and h.data=c.data and h.tip_concediu in ('4','8') and c.data_inceput>=h.data_inceput and c.data_inceput<=h.data_sfarsit
	inner join #personal p on p.marca=c.marca
	where (@marca is null or c.marca=@marca) and (c.Data between @dataJos and @dataSus)
	group by c.marca   

	-- selectam pe linie incasarile de CO din net
	select net.marca, 
		   sum(case when data between dbo.bom(@dataSus) and @dataSus then co_incasat else 0 end) as co_incasat
	into #tmpNet
	from net
	inner join #personal p on p.marca=net.marca
	where (@marca is null or net.marca=@marca)
	group by net.marca 

	-- selectam pe marca sumele din corectii cu proprietatile D- si O-
	select c.marca, 
		sum(c.suma_corectie) as suma_corectie
	into #tmpCor
	from corectii c
	left outer join subtipcor sd on c.Tip_corectie_venit=sd.Subtip and sd.tip_corectie_venit='D-'
	left outer join subtipcor so on c.Tip_corectie_venit=so.Subtip and so.tip_corectie_venit='O-'
	inner join #personal p on p.marca=c.marca
	where (@marca is null or c.marca=@marca) and (c.data between @dataJos and @dataSus) and 
		  (@primavacantacorD=1 and (@Subtipcor=0 and c.tip_corectie_venit='D-' or @Subtipcor=1 and (sd.subtip is not null)) or
		   @primavacantacorD=0 and (@Subtipcor=0 and c.tip_corectie_venit='O-' or @Subtipcor=1 and (so.subtip is not null)))
	group by c.marca 
	
	if object_id('tempdb..#tmpSel') is not null 
		drop table #tmpSel
	-- selectul principal	  		
	select @dataSus as data, p.marca, p.nume, p.loc_de_munca as lm, lm.denumire as den_lm, p.grupa_de_munca, p.vechime_totala, 
	(case when @ZileCOVechUnit=0 then left(dbo.fVechimeAALLZZ(p.vechime_totala),2) else convert(int,left(isnull(p.Vechime_la_intrare,ip.Vechime_la_intrare),2)) end) as vechime_in_ani,
	p.data_angajarii_in_unitate as data_angajarii, convert(int,p.loc_ramas_vacant) as loc_ramas_vacant, p.data_plec as data_plecarii, 
	p.zile_concediu_de_odihna_an as zile_co_an, p.zile_concediu_efectuat_an as zile_co_suplim_an, isnull(ia.coef_invalid,0) as zile_co_neefectuat_an_ant, isnull(bl.Zile_co_efectuat_in_luna,0) as zile_co_efectuat_in_luna,
	isnull(co.zile_co_efectuat_din_an_ant,0) as zile_co_efectuat_din_an_ant,isnull(bl.Zile_co_efectuat_an,0) + isnull(co.zile_co_sum,0) as zile_co_efectuat_an,	isnull(tc.suma_corectie,0) as prima_de_concediu, 
	isnull(bl.Indemnizatie_CO_an,0) as indemnizatie_co_an, isnull(bl.Indemnizatie_CO_luna,0) as indemnizatie_co_luna_curenta,isnull(tn.co_incasat,0) as co_incasat, isnull(zcan.zile,0) as zile_co_cuvenite_an, 
	isnull(zcl.zile,0) as zile_co_cuvenite_la_luna, (case when @tipzileramase=1 then isnull(zcl.zile,0) else isnull(zcan.zile,0) end) as zile_co_cuvenite, 
	isnull(ia.coef_invalid,0)+(case when @tipzileramase=1 then isnull(zcl.zile,0) else isnull(zcan.zile,0) end)-(isnull(bl.Zile_co_efectuat_an,0)+ isnull(co.zile_co_sum,0)) as zile_co_ramase,
	(case when @Ordonare='2' then p.loc_de_munca else '' end) as grupare
	into #tmpSel
	from #personal p
		left join #zileCOcuvAn zcan on zcan.marca=p.marca
		left join #zileCOcuvLuna zcl on zcl.marca=p.marca
		left outer join lm on p.loc_de_munca=lm.cod 
		left outer join istpers ia on ia.data=@Datas12_anant and ia.marca=p.marca and @Zile_co_ramase=1
		left outer join istpers i on i.data=@dataSus and i.marca=p.marca 
		left outer join infopers ip on ip.marca=p.marca 
		left outer join #tmpBrutCO bl on bl.Marca=p.Marca
		left outer join #tmpConcCO co on p.marca=co.marca
		left outer join #tmpNet tn on p.marca=tn.marca
		left outer join #tmpCor tc on tc.marca=p.marca
	order by Grupare, (case when @Alfabetic=1 then p.nume else p.marca end)

	if object_id('tempdb..#rapCOAn') is not null
		insert into #rapCOAn
		select * from #tmpSel
	else
		select * from #tmpSel
		order by grupare,(case when @Alfabetic=1 then nume else marca end)
end try 

begin catch
	declare
		@mesaj varchar(1000)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
end catch