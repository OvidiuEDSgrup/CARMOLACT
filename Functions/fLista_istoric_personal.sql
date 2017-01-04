--***
/**	functia lista istoric personal	*/
Create 
function fLista_istoric_personal
	(@DataJos datetime, @DataSus datetime, @MarcaJos char(6), @MarcaSus char(6), @LocmJos char(9), @LocmSus char(9),
	@Ordonare int, @Filtru_grupa int, @Grupa char(1), @Filtru_sex int, @Sex int, @lTip_salarizare int, @Tip_salarizare char(1), 
	@l_drept char(1), @User char(30), @User_windows int)
returns @date_istoric table
	(data datetime,marca char(6),loc_de_munca char(9),denumire_loc_munca char(30),ore_concediu_fara_salar int, 
	zile_concediu_fara_salar int, ore_concediu_medical int, zile_concediu_medical int, ore_concediu_de_odihna int, 
	zile_concediu_de_odihna int, nume char(50), cod_functie char(6), grupa_de_munca char(1), data_angajarii_in_unitate char(10), 
	categoria_salarizare char(4), salar_de_incadrare_pers int, denumire_functie char(30), regim_de_lucru int, salar_de_incadrare_ist int,
	spor_vechime int, zile_lucratoare_cm int,data_plec char(10),loc_munca_grupare char(30),ordonare1 char(50),ordonare2 char(50)) 
As 
Begin
	declare @drept_conducere int, @liste_drept char(1), @drept int
	Set @drept_conducere=dbo.iauParL('PS','DREPTCOND')
	if  @drept_conducere=1 
	begin
		set @drept=isnull((select dbo.verifica_dreptul(@user,@user_windows,'SALCOND')),0)
		if @drept=1
			set @liste_drept=@l_drept
		else
		begin
			set @liste_drept=@l_drept
			if @liste_drept='T'
				set @liste_drept='S'
		end
	end
	else
	begin
		set @liste_drept=@l_drept
		set @drept=0
	end

	declare @utilizator varchar(20)  -- pt filtrare pe proprietatea LOCMUNCA a utilizatorului (daca e definita)
	set @utilizator = dbo.fIaUtilizator(null)

	insert into @date_istoric
	select b.data, b.marca, max(b.loc_de_munca), max(lm.denumire), sum(b.ore_concediu_fara_salar), 
		(case when isnull(max(ca.Zile_CFS),0)<>0 and max(b.Spor_cond_10)<1 then isnull(max(ca.Zile_CFS),0) else round(sum(b.ore_concediu_fara_salar/(case when b.spor_cond_10=0 then 8 else b.spor_cond_10 end)),0) end), 
		sum(b.ore_concediu_medical), round(sum(b.ore_concediu_medical/(case when b.spor_cond_10=0 then 8 else b.spor_cond_10 end)),0),
		sum(b.ore_concediu_de_odihna), round(sum(b.ore_concediu_de_odihna/(case when b.spor_cond_10=0 then 8 else b.spor_cond_10 end)),0), max(isnull(i.Nume,p.nume)) as Nume, 
		max(i.cod_functie), max(p.grupa_de_munca), max(convert(char(10),p.data_angajarii_in_unitate,104)), max(p.categoria_salarizare), max(p.salar_de_incadrare), 
		max(f.denumire), (case when max(b.spor_cond_10)=0 then 8 else max(b.spor_cond_10) end) as regim_de_lucru, max(i.salar_de_incadrare), max(i.spor_vechime), 
		(select sum(h.zile_lucratoare) from conmed h where b.data=h.data and b.marca=h.marca)  as zile_lucratoare_cm, 
		(case when max(convert(int,p.loc_ramas_vacant))=1 and max(p.data_plec)<>'01/01/1901' and max(isnull(p.data_plec,''))<>'' and(max(p.mod_angajare)='D' or (month(b.data)=month(max(p.data_plec)) and year(b.data)=year(max(p.data_plec))))then max(convert(char(10),p.data_plec,104)) else '' end ),
		(case when @ordonare=3 then b.loc_de_munca else '' end),
		(case when @ordonare=2 then max(p.nume) when @ordonare=1 then b.marca else max(b.loc_de_munca) end) as Ordonare_1,
		(case when @ordonare=3 then b.marca else '' end) as Ordonare_2
	from brut b
		left outer join personal p on p.marca=b.marca
		inner join istpers i on i.data=b.data and i.marca=b.marca 
		left outer join functii f on i.cod_functie=f.cod_functie
		left outer join lm on lm.cod=b.loc_de_munca
		left outer join (select data, marca, sum(Zile) as Zile_CFS from conalte where data between @DataJos and @DataSus and Tip_concediu='1' group by data, marca) ca on b.data=ca.data and b.marca=ca.marca
	where b.data between @DataJos and @DataSus and b.marca between @MarcaJos and @MarcaSus 
		and	b.loc_de_munca between @LocmJos and @LocmSus and (@Filtru_grupa=0 or p.grupa_de_munca=@Grupa) 
		and (@Filtru_sex=0 or p.sex=@Sex) and (@ltip_salarizare=0 or (@tip_salarizare='T' and p.tip_salarizare in ('1','2')) 
		or (@tip_salarizare='M' and p.tip_salarizare in ('3','4','5','6','7'))) 
		and (@drept_conducere=0 or (@drept_conducere=1 and @drept=1 and (@liste_drept='T' or @liste_drept='C' and p.pensie_suplimentara=1 or @liste_drept='S' and p.pensie_suplimentara<>1)) 
		or (@drept_conducere=1 and @drept=0 and @liste_drept='S' and p.pensie_suplimentara<>1))
		and (dbo.f_areLMFiltru(@utilizator)=0 or exists (select 1 from lmfiltrare l where l.utilizator=@utilizator and l.cod=b.Loc_de_munca))
	group by (case when @ordonare=3 then b.loc_de_munca else '' end), b.marca, b.data
	order by Ordonare_1, Ordonare_2, b.data

	Return 
End