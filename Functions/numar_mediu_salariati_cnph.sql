Create
function dbo.numar_mediu_salariati_cnph(@DataJos datetime, @DataSus datetime, @pFunctie char(6), @pLmjos char(9), 
@pLmsus char(9), @pTip_stat char(10))
Returns float
As
Begin
	Declare @DataIncr datetime, @DataFiltru datetime, @numar_mediu float, @zile_cal float, @OreS_RN bit, @Ore100_RN bit, @ore_int_rn bit, @Pontaj_zilnic bit, @STOUG28 int
	Set @OreS_RN = dbo.iauParL('PS','OSNRN')
	Set @Ore100_RN = dbo.iauParL('PS','O100NRN')
	Set @ore_int_rn = dbo.iauParL('PS','OINTNRN')
	Set @pontaj_zilnic = dbo.iauParL('PS','PONTZILN')
	Set @STOUG28 = dbo.iauParLL(@DataSus,'PS','STOUG28')	
	Set @numar_mediu = 0
	Set @zile_cal = datediff(day,@DataJos,@DataSus)+1
	Set @DataIncr = @DataJos
--	calcul pentru cazul in care se lucreaza cu pontaj zilnic
	if @pontaj_zilnic=1
	Begin
	while @DataSus >= @DataIncr
	Begin
		if not(datename(WeekDay, @DataIncr) in ('Sunday','Saturday') or @DataIncr in (select data from calendar))
		Begin
			Set @numar_mediu=@numar_mediu+isnull((select sum(a.ore_regie+a.ore_acord
			-(case when @OreS_RN=1 then a.ore_suplimentare_1+
			a.ore_suplimentare_2+a.ore_suplimentare_3+a.ore_suplimentare_4 else 0 end)
			-(case when @Ore100_RN=1 then a.ore_spor_100 else 0 end)
			+(case when @ore_int_rn=1 then 0 else a.ore_intrerupere_tehnologica end)+a.ore_concediu_de_odihna 				+a.ore_obligatii_cetatenesti+(case when @STOUG28=1 then 0 else ore end))/8.0
			from pontaj a
			left outer join istpers b on b.data=@DataSus and b.Marca=a.Marca
			left outer join infopers c on c.Marca=a.Marca
			where a.data=@DataIncr and (@pFunctie='' or b.Cod_functie=@pFunctie) 
			and (@pLmjos='' or b.Loc_de_munca between @pLmjos and @pLmsus) 
			and (@pTip_stat='' or c.Religia=@pTip_stat)),0)
		End
		else
		Begin
			Set @DataFiltru=@DataIncr
			while datename(WeekDay, @DataFiltru) in ('Sunday','Saturday') or @DataFiltru in (select data from calendar)
			Begin
				Set @DataFiltru=@DataFiltru-1
			End
			Set @numar_mediu=@numar_mediu+isnull((select 
			sum((case when p.loc_ramas_vacant=0 or p.data_plec>@DataFiltru 
			then a.ore_regie+a.ore_acord-(case when @OreS_RN=1 then a.ore_suplimentare_1+
			a.ore_suplimentare_2+a.ore_suplimentare_3+a.ore_suplimentare_4 else 0 end)
			-(case when @Ore100_RN=1 then a.ore_spor_100 else 0 end)
			+(case when @ore_int_rn=1 then 0 else a.ore_intrerupere_tehnologica end)+a.ore_concediu_de_odihna
			+a.ore_obligatii_cetatenesti+(case when @STOUG28=1 then 0 else ore end) else 0 end))/8.0
			from pontaj a
			left outer join istpers b on b.data=@DataSus and b.Marca=a.Marca
			left outer join infopers c on c.Marca=a.Marca
			left outer join personal p on p.Marca=a.Marca
			where a.data=@DataFiltru and (@pFunctie='' or b.Cod_functie=@pFunctie) 
			and (@pLmjos='' or b.Loc_de_munca between @pLmjos and @pLmsus) 
			and (@pTip_stat='' or c.Religia=@pTip_stat)),0)
		End
		Set @DataIncr = dateadd(day, 1, @DataIncr)
	End
	End
--	calcul pentru cazul in care NU se lucreaza cu pontaj zilnic
	If @pontaj_zilnic=0
	Begin 
		Set @numar_mediu=@numar_mediu+isnull((select sum(a.ore_regie+a.ore_acord
		-(case when @OreS_RN=1 then a.ore_suplimentare_1+
		a.ore_suplimentare_2+a.ore_suplimentare_3+a.ore_suplimentare_4 else 0 end)
		-(case when @Ore100_RN=1 then a.ore_spor_100 else 0 end)
		+(case when @ore_int_rn=1 then 0 else a.ore_intrerupere_tehnologica end)
		+a.ore_concediu_de_odihna+a.ore_obligatii_cetatenesti+(case when @STOUG28=1 then 0 else ore end))/8.0
		from pontaj a 
		left outer join istpers b on b.data=@DataSus and b.Marca=a.Marca
		left outer join infopers c on c.Marca=a.Marca
		where a.data between @DataJos and @DataSus and (@pFunctie='' or b.Cod_functie=@pFunctie) 
		and (@pLmjos='' or b.Loc_de_munca between @pLmjos and @pLmsus) 
		and (@pTip_stat='' or c.Religia=@pTip_stat)),0)
		while @DataSus >= @DataIncr
		Begin
			if datename(WeekDay, @DataIncr) in ('Sunday','Saturday') or @DataIncr in (select data from calendar)
			Begin
			Set @DataFiltru=@DataIncr
			while datename(WeekDay, @DataFiltru) in ('Sunday','Saturday') or @DataFiltru in (select data from calendar)
				Begin
					Set @DataFiltru=@DataFiltru-1
				End
				Set @numar_mediu=@numar_mediu+isnull((select sum(a.regim_de_lucru/8) 
				from (select distinct dbo.eom(data) as Data, marca, max(regim_de_lucru) as regim_de_lucru from 					pontaj where data between @DataJos and @DataSus group by dbo.eom(data), marca) a 
				left outer join istpers b on b.data=@DataSus and b.Marca=a.Marca
				left outer join infopers c on c.Marca=a.Marca
				left outer join personal p on p.Marca=a.Marca
				where a.data between @DataJos and @DataSus and (@pFunctie='' or b.Cod_functie=@pFunctie) 
				and (@pLmjos='' or b.Loc_de_munca between @pLmjos and @pLmsus) 
				and (@pTip_stat='' or c.Religia=@pTip_stat) and p.Data_angajarii_in_unitate<=@DataFiltru and
				(p.loc_ramas_vacant=0 or p.data_plec>=@DataFiltru) and
				(a.marca not in (select marca from conmed where data between @DataJos-1 and @DataSus
				and @DataFiltru>=Data_inceput and @DataFiltru<=Data_sfarsit)) and
				(a.marca not in (select marca from conalte where data between @DataJos-1 and @DataSus
				and @DataFiltru>=Data_inceput and @DataFiltru<=Data_sfarsit))),0)
			End
			Set @DataIncr = dateadd(day, 1, @DataIncr)
		End
	End
	Set @numar_mediu=round(@numar_mediu/convert(float,@zile_cal),2)
	Return (@numar_mediu)
End
