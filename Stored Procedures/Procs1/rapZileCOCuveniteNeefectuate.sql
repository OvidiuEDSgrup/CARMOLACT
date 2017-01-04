--***
/*	procedura pentru determinarea istoricului (baza de calcul) concediilor de de odihna */
Create procedure rapZileCOCuveniteNeefectuate
	(@dataJos datetime, @dataSus datetime, @locm char(9)=null, @strict int=0, @marca char(6)=null, @functie char(6)=null, @grupamunca char(1)=null, @grupaexceptata int=0, 
	@tippersonal char(1)=null, @tipstat varchar(30)=null, @ordonare char(2)='', @alfabetic int=1, 
	@istoric_pt_zile_co_ramase int=0, @zile_ramase_fct_cuvenite_la_luna int=0, @listadreptCond char(1)='T')
as
/*
	exec rapZileCOCuveniteNeefectuate @datajos='01/01/2015', @dataSus='11/30/2015', @istoric_pt_zile_co_ramase=1, @marca='R102', null, 0, null, null, null, 0, null, null, '1', 0, 0, 0, 'T'
	exec rapZileCOCuveniteNeefectuate @datajos='01/01/2015', @dataSus='11/30/2015', @istoric_pt_zile_co_ramase=1, @marca='R160'
*/
begin try
	if object_id('tempdb..#IstoricCO') is not null
		drop table #istoricCO
	create table #IstoricCO (data datetime)
	exec CreeazaDiezSalarii @numeTabela='#IstoricCO'
	exec rapIstoricConcediiOdihna @datajos, @datasus, @locm, @strict, @marca, @functie, @grupamunca, @grupaexceptata, @tippersonal, @tipstat, @ordonare, @alfabetic, 1, @zile_ramase_fct_cuvenite_la_luna, 'T'

	if object_id('tempdb..#rapCOAn') is not null
		drop table #rapCOAn
	create table #rapCOAn (data datetime)
	exec CreeazaDiezSalarii @numeTabela='#rapCOAn'
	exec rapConcediiOdihnaPeAn @datajos, @datasus, @marca, @locm, @strict, @functie, @grupamunca, @grupaexceptata, @tippersonal, @tipstat, 0, @ordonare, @alfabetic, @zile_ramase_fct_cuvenite_la_luna

	select a.data, a.marca, a.nume, a.lm, a.den_lm, a.grupa_de_munca, a.zile_co_neefectuat_an_ant, zile_co_cuvenite, 
			a.zile_co_efectuat_din_an_ant, a.zile_co_efectuat_an, zile_co_efectuat_an-zile_co_efectuat_din_an_ant as zile_co_efect_din_co_an_crt, 
			zile_co_neefectuat_an_ant-zile_co_efectuat_din_an_ant as zile_co_ramase_de_efectuat_an_ant, zile_co_cuvenite-(zile_co_efectuat_an-zile_co_efectuat_din_an_ant) as zile_co_ramase_de_efectuat_an_crt, 
			zile_co_neefectuat_an_ant+zile_co_cuvenite-zile_co_efectuat_an as zile_co_ramase_de_efectuat, b.indemnizatie_co
	from #rapCOAn a
	left outer join #IstoricCO b on b.data=a.data and b.marca=a.marca
	order by Grupare, (case when @Alfabetic=1 then a.nume else a.marca end)
end try

begin catch
	declare @mesaj varchar(2000)
	set @mesaj = ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror (@mesaj, 11, 1)
end catch

