--***
/**	procedura pentru raportul web Evidenta fortei de munca	*/
Create procedure rapEvolutiaForteiDeMunca
	(@dataJos datetime, @dataSus datetime, @marca varchar(6)=null, @locm varchar(9)=null, @tipsalarizare char(1)=null, @functie varchar(6)=null, @tipstat varchar(30)=null) 
as
begin try
	set transaction isolation level read uncommitted
	if object_id('tempdb..#evolutie_fm') is not null drop table #evolutie_fm
	if object_id('tempdb..#flutcent') is not null drop table #flutcent
	
	declare @q_marcaJos char(6), @q_marcaSus char(6), @q_locmJos char(9), @q_locmSus char(9),
			@q_ltipsalarizare bit, @q_tipsalJos char(1), @q_tipsalSus char(1), @q_functie char(6), @q_tipstat char(200)

	select	@q_marcaJos=isnull(@marca,''),
			@q_marcaSus=isnull(@marca,'ZZZ'),
			@q_locmJos=(case when @locm is null then '' else @locm end),
			@q_locmSus=(case when @locm is null then '' else rtrim(@locm) end)+'ZZZZ',
			@q_ltipsalarizare=(case when @tipsalarizare is null then 0 else 1 end),
			@q_tipsalJos=isnull(@tipsalarizare,''),
			@q_tipsalSus=isnull(@tipsalarizare,''),
			@q_functie=isnull(@functie,''), 
			@q_tipstat=isnull(@tipstat,'')

	create table #flutcent (data datetime)
	exec CreeazaDiezSalarii @numeTabela='#flutcent'
	exec rapFluturasCentralizat @dataJos=@datajos, @dataSus=@datasus, @MarcaJ=@q_marcaJos, @MarcaS=@q_marcaSus, @LocmJ=@q_locmJos, @LocmS=@q_locmSus, 
		@lTipSal=@q_ltipsalarizare, @cTipSalJos=@q_tipsalJos, @cTipSalSus=@q_tipsalSus, @functie=@q_functie, @tipStat=@q_tipstat, @Grupare='MARCA'

	create table #evolutie_fm (data datetime, marca varchar(6), tip_personal char(30), cod_functie char(6), den_functie char(80), numar_salariati int, cheltuieli float)

	insert into #evolutie_fm
	select a.Data, a.Marca, 
	isnull((select top 1 val_inf from extinfop e where e.marca=a.marca 
		and e.Cod_inf='TIPPERS' and e.data_inf<=a.Data order by e.Data_inf desc),'NECOMPLETAT') as tip_personal,
	i.cod_functie, rtrim(f.denumire) as den_functie, count(i.cod_functie) as numar_salariati,
	sum(round(a.Venit_total-a.ind_c_medical_cas-a.CMFAMBP+a.CAS_unitate+a.Somaj_5+a.Fond_garantare+a.Asig_sanatate_pl_unitate+a.Fond_de_risc_1+a.Camera_de_Munca_1+a.CCI+CASS_AMBP,0))
		+round(max(Cotiz_hand)*count(i.Cod_functie)/(select count(1) from net n where n.data=a.data and n.Venit_total<>0),0) as Cheltuieli_1
	from #flutcent a
		inner join istpers i on a.marca = i.marca and a.data = i.data
		inner join functii f on i.cod_functie = f.cod_functie
	where a.ingr_copil=0
	group by i.cod_functie, a.data, f.denumire, a.Marca
	order by a.data

	select data, tip_personal, cod_functie, den_functie, sum(Numar_salariati) as numar_salariati, sum(cheltuieli) as cheltuieli
	from #evolutie_fm
	group by data, tip_personal, cod_functie, den_functie
	order by data

end try

begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura rapEvolutiaForteiDeMunca (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch

if object_id('tempdb..#evolutie_fm') is not null drop table #evolutie_fm
if object_id('tempdb..#flutcent') is not null drop table #flutcent

/*
	exec rapEvolutiaForteiDeMunca '09/01/2015', '09/30/2015', null, null, null, null, null
*/	