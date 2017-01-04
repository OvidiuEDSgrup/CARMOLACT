--***
/**	functie concedii de odihna	
	@dataJos -> prima zi din an
	@dataSus -> ultima zi din luna de lucru
*/
Create
function concedii_de_odihna 
	(@dataJos datetime, @dataSus datetime, @Prima_vacanta_corD int, @lMarca int, @pMarca char(6), @lLocm int, @pLocm char(9), @lStrict int, 
	@lCod_functie int, @pCod_functie char(6), @lGrupa_munca int, @cGrupa_munca char(1), @lGrupa_exceptata int, @lTipstat int, @pTipstat char(10), @Ordonare char(1), @Alfabetic int)
returns @concedii_odihna table
	(Data datetime, Marca char(6), Nume char(50), Loc_de_munca char(9), Denumire_lm char(30), Grupa_de_munca char(1), 
	Vechime_totala datetime, Vechime_in_ani int, Data_angajarii_in_unitate datetime, Loc_ramas_vacant int, Data_plecarii datetime, 
	Zile_co_an int, Zile_co_suplim_an int, Zile_co_neefectuat_an_ant int, Zile_co_efectuat_in_luna int, Zile_co_efectuat_din_an_ant int, Zile_co_efectuat_an int, 
	Prima_de_concediu float, Indemnizatie_co_an int, Indemnizatie_co_luna_curenta float, CO_incasat float, Zile_co_cuvenite_an int, Zile_co_cuvenite_la_luna int, Grupare char(50))
as
begin
	declare @Zile_co_ramase bit, @Dataj12_anant datetime, @Datas12_anant datetime, @Subtipcor int, @ZileCOVechUnit int

	Set @Dataj12_anant=dbo.bom(dateadd(day,-1,@dataJos))
	Set @Datas12_anant=dateadd(day,-1,@dataJos)
	Set @Zile_co_ramase=dbo.iauParL('PS','ZILECORAM')
	Set @Subtipcor=dbo.iauParL('PS','SUBTIPCOR')
	Set @ZileCOVechUnit=dbo.iauParL('PS','ZICOVECHU')

	declare @utilizator varchar(20)
	SET @utilizator = dbo.fIaUtilizator('')

	insert into @concedii_odihna
	select @dataSus, p.marca, p.nume, p.loc_de_munca, d.denumire, p.grupa_de_munca, p.vechime_totala, 
	(case when @ZileCOVechUnit=0 then (case when right(convert(char(8),vechime_totala,1),2)=99 then 0 
	else convert(int,right(convert(char(8),vechime_totala,1),2))+(case when MONTH(p.Vechime_totala)=12 then 1 else 0 end) end)
	else convert(int,left(ip.Vechime_la_intrare,2)) end),
	p.data_angajarii_in_unitate, convert(int,p.loc_ramas_vacant) as Loc_ramas_vacant, p.data_plec, 
	p.zile_concediu_de_odihna_an, p.zile_concediu_efectuat_an, isnull(i.coef_invalid,0) as Zile_co_neefectuat_an_ant, isnull(bl.Zile_co_efectuat_in_luna,0) as Zile_co_efectuat_in_luna,
	isnull((select sum((case when c.tip_concediu='5' then -1 else 1 end)*c.zile_co) from concodih c where c.data between @dataJos and @dataSus and p.marca=c.marca 
		and (c.tip_concediu='4' or c.tip_concediu='6' or c.tip_concediu='8' or c.tip_concediu='5' and exists (select marca from concodih h where h.data=c.data and h.marca=c.marca and h.tip_concediu in ('4','8') and c.data_inceput>=h.data_inceput and c.data_inceput<=h.data_sfarsit))),0) as Zile_co_efectuat_din_an_ant,
	isnull(ba.Zile_co_efectuat_an,0) + isnull((select sum(c.zile_co) from concodih c where c.data between @dataJos and @dataSus and p.marca=c.marca and (c.tip_concediu='3' or c.tip_concediu='6')),0) as zile_co_efectuat_an, 
	isnull((select sum(e.suma_corectie) from corectii e where e.data between @dataJos and @dataSus and p.marca=e.marca 
		and (@Prima_vacanta_corD=1 and (@Subtipcor=0 and e.tip_corectie_venit='D-' 
		or @Subtipcor=1 and e.tip_corectie_venit in (select subtip from subtipcor where tip_corectie_venit='D-')) 
		or @Prima_vacanta_corD=0 and (@Subtipcor=0 and e.tip_corectie_venit='O-' 
		or @Subtipcor=1 and e.tip_corectie_venit in (select subtip from subtipcor where tip_corectie_venit='O-')))),0) as Prima_de_concediu, 
	isnull(ba.Indemnizatie_CO_an,0) as Indemnizatie_co_an,  
	isnull(bl.Indemnizatie_CO_luna,0) as Indemnizatie_co_luna_curenta,
	(select sum(g.co_incasat) from net g where g.data between dbo.bom(@dataSus) and @dataSus and p.marca=g.marca) as Co_incasat, 
	/*isnull(dbo.zile_co_cuvenite(p.marca, @dataSus, 0),0) as Zile_co_cuvenite_an, 
	isnull(dbo.zile_co_cuvenite(p.marca, @dataSus, 1),0) as Zile_co_cuvenite_pana_la_luna_crt, --*/
	isnull(zc_an.zile,0) as Zile_co_cuvenite_an, 
	isnull(zc_anc.zile,0) as Zile_co_cuvenite_pana_la_luna_crt, 
	(case when @Ordonare='2' then p.loc_de_munca else '' end) as Grupare
	from personal p
		left join dbo.ls_zile_CO_cuvenite(@pMarca,@dataSus,0) zc_an on zc_an.marca=p.marca
		left join dbo.ls_zile_CO_cuvenite(@pMarca,@dataSus,1) zc_anc on zc_anc.marca=p.marca
		left outer join lm d on p.loc_de_munca=d.cod 
		left outer join infopers ip on ip.marca=p.marca 
		left outer join istpers i on i.data=@Datas12_anant and i.marca=p.marca and @Zile_co_ramase=1
		left outer join (select Marca, sum(ore_concediu_de_odihna/(case when spor_cond_10=0 then 8 else spor_cond_10 end)) as Zile_co_efectuat_in_luna, 
			round(sum(ind_concediu_de_odihna),0) as Indemnizatie_CO_luna from brut where data between dbo.bom(@dataSus) and @dataSus Group by Marca) bl on bl.Marca=p.Marca
		left outer join (select Marca, sum(ore_concediu_de_odihna/(case when spor_cond_10=0 then 8 else spor_cond_10 end)) as Zile_co_efectuat_an, 
			round(sum(ind_concediu_de_odihna),0) as Indemnizatie_CO_an from brut where data between @dataJos and @dataSus Group by Marca) ba on ba.Marca=p.Marca
	where (@lMarca=0 or p.marca=@pMarca) 
		and (@lLocm=0 or @lStrict=1 and p.loc_de_munca=@pLocm or p.loc_de_munca like rtrim(@pLocm)+'%') 
		and (@lGrupa_munca=0 or (@lGrupa_exceptata=0 and p.grupa_de_munca=@cGrupa_munca or @lGrupa_exceptata=1 and p.grupa_de_munca<>@cGrupa_munca)) 
		and (p.loc_ramas_vacant=0 or p.Data_plec>=dbo.bom(@dataSus) or p.Data_angajarii_in_unitate>=dbo.bom(@dataSus))
		and exists (select i.Marca from istpers i where data between @dataJos and @dataSus and Marca=p.marca) 
		and (@lCod_functie=0 or p.Cod_functie=@pCod_functie) and (@lTipstat=0 or ip.religia=@pTipstat)
		and (dbo.f_areLMFiltru(@utilizator)=0 or exists (select 1 from lmfiltrare l where l.utilizator=@utilizator and l.cod=p.Loc_de_munca))
	order by Grupare, (case when @Alfabetic=1 then p.nume else p.marca end)
	return
end
