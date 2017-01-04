--***
Create procedure rapAnchetaSalarii2 
	(@dataJos datetime, @dataSus datetime, @setlm varchar(20)=null, @filtrutimplucrat int=0, @salariatiactivi int=0)
as
/*
	@salariatiactivi = 0 -> salariati activi in perioada 
	@salariatiactivi = 1 -> salariati activi la sfarsit de perioada 
	exec rapAnchetaSalarii2 @dataJos='09/01/2015', @dataSus='09/30/2015', @setlm=null, @filtrutimplucrat=1, @salariatiactivi=0
*/
declare @eroare varchar(2000)
begin try
	set transaction isolation level read uncommitted
	if object_id('tempdb..#flutcent') is not null 
		drop table #flutcent
	create table #flutcent (data datetime)
	exec CreeazaDiezSalarii @numeTabela='#flutcent'

	exec rapFluturasCentralizat @dataJos=@datajos, @dataSus=@datasus, @Grupare='MARCA', @setlm=@setlm

	select isnull((case when len(fc.Cod_functie)=1 then 'GM '+rtrim(fc.Cod_functie)+':' else '' end)+max(fc.denumire),'   ') as Ocupatie, 
	fc.Cod_functie as Cod_COR, 'Ambele' as Sex,
	sum(case when ore_lucrate_regim_normal+ore_concediu_de_odihna+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti>=
		l.val_numerica/8*(case when i.salar_lunar_de_baza<>0 then i.salar_lunar_de_baza else 8 end) or @filtrutimplucrat=1  then 1 else 0 end) as Salariati_cu_luna_completa,
	sum((case when ore_lucrate_regim_normal+ore_concediu_de_odihna+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti>=
		l.val_numerica/8*(case when i.salar_lunar_de_baza<>0 then i.salar_lunar_de_baza else 8 end) or @filtrutimplucrat=1
		then (a.venit_total-a.indemnizatie_ore_supl_1-a.indemnizatie_ore_supl_2-a.indemnizatie_ore_supl_3-a.indemnizatie_ore_supl_4
		-a.ind_c_medical_unitate-a.ind_c_medical_cas-a.cmfambp) else 0 end)) as Fond_salarii,
	sum((case when ore_lucrate_regim_normal+ore_concediu_de_odihna+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti>=
		l.val_numerica/8*(case when i.salar_lunar_de_baza<>0 then i.salar_lunar_de_baza else 8 end) or @filtrutimplucrat=1 
		then a.indemnizatie_ore_supl_1+a.indemnizatie_ore_supl_2+a.indemnizatie_ore_supl_3+a.indemnizatie_ore_supl_4+a.ore_spor_100 else 0 end)) as Ore_suplimentare, 
	0 as Alte_fonduri, max(l.val_numerica) as Ore_normate,
	round(sum(case when ore_lucrate_regim_normal+ore_concediu_de_odihna+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti>=
		l.val_numerica/8*(case when i.salar_lunar_de_baza<>0 then i.salar_lunar_de_baza else 8 end) or @filtrutimplucrat=1 then
		(a.ore_lucrate_regim_normal+a.ore_concediu_de_odihna+a.ore_intrerupere_tehnologica
		+a.ore_obligatii_cetatenesti+a.ore_suplimentare_1+a.ore_suplimentare_2+a.ore_suplimentare_3+a.ore_suplimentare_4) else 0 end)/
		count(case when ore_lucrate_regim_normal+ore_concediu_de_odihna+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti>=l.val_numerica/8*
		(case when i.salar_lunar_de_baza<>0 then i.salar_lunar_de_baza else 8 end) or @filtrutimplucrat=1 then 1 else 0 end),0) as Ore_remunerate
	from #flutcent a
		inner join istpers i on a.marca=i.marca and a.data=i.data
		left outer join personal p on a.marca=p.marca
		left outer join extinfop e on i.cod_functie=e.marca and e.Cod_inf='#CODCOR'
		left outer join functii_cor f on e.val_inf=f.Cod_functie
		left outer join par_lunari l on l.Data=a.Data and l.parametru='ORE_LUNA'
		left outer join functii_cor fc on fc.cod_functie=left(f.cod_functie,len(fc.cod_functie)) 
			and (len(fc.cod_functie)=1 or fc.cod_functie=f.Cod_functie /*and f.numar_curent=fc.numar_curent*/)
	where (i.grupa_de_munca in ('N','D','S') or @filtrutimplucrat=1 and i.grupa_de_munca='C')
		and (@salariatiactivi=0 or @salariatiactivi=1 and p.Data_angajarii_in_unitate<=@dataSus and (p.Loc_ramas_vacant=0 or p.Data_plec>@dataSus))
	--and a.marca='5927'
	group by fc.Cod_functie

	union all

	select isnull((case when len(fc.Cod_functie)=1 then 'GM '+rtrim(fc.Cod_functie)+':' else '' end)+max(fc.denumire),'   ') as Ocupatie, 
	fc.Cod_functie as Cod_COR, 'Femei' as Sex,
	sum(case when ore_lucrate_regim_normal+ore_concediu_de_odihna+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti>=
		l.val_numerica/8*(case when i.salar_lunar_de_baza<>0 then i.salar_lunar_de_baza else 8 end) or @filtrutimplucrat=1  then 1 else 0 end) as Salariati_cu_luna_completa,
	sum((case when ore_lucrate_regim_normal+ore_concediu_de_odihna+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti>=
		l.val_numerica/8*(case when i.salar_lunar_de_baza<>0 then i.salar_lunar_de_baza else 8 end) or @filtrutimplucrat=1 
		then (a.venit_total-a.indemnizatie_ore_supl_1-a.indemnizatie_ore_supl_2-a.indemnizatie_ore_supl_3-a.indemnizatie_ore_supl_4
		-a.ind_c_medical_unitate-a.ind_c_medical_cas-a.cmfambp) else 0 end)) as Fond_salarii,
	sum((case when ore_lucrate_regim_normal+ore_concediu_de_odihna+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti>=
		l.val_numerica/8*(case when i.salar_lunar_de_baza<>0 then i.salar_lunar_de_baza else 8 end) or @filtrutimplucrat=1 
		then a.indemnizatie_ore_supl_1+a.indemnizatie_ore_supl_2+a.indemnizatie_ore_supl_3+a.indemnizatie_ore_supl_4+a.ore_spor_100 else 0 end)) as Ore_suplimentare, 
	0 as Alte_fonduri, max(l.val_numerica) as Ore_normate,
	round(sum(case when ore_lucrate_regim_normal+ore_concediu_de_odihna+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti>=
		l.val_numerica/8*(case when i.salar_lunar_de_baza<>0 then i.salar_lunar_de_baza else 8 end) or @filtrutimplucrat=1 
		then (a.ore_lucrate_regim_normal+a.ore_concediu_de_odihna+a.ore_intrerupere_tehnologica
		+a.ore_obligatii_cetatenesti+a.ore_suplimentare_1+a.ore_suplimentare_2+a.ore_suplimentare_3+a.ore_suplimentare_4) else 0 end)/
		count(case when ore_lucrate_regim_normal+ore_concediu_de_odihna
		+ore_intrerupere_tehnologica+ore_obligatii_cetatenesti>=l.val_numerica/8*
		(case when i.salar_lunar_de_baza<>0 then i.salar_lunar_de_baza else 8 end) or @filtrutimplucrat=1 then 1 else 0 end),0) as Ore_remunerate
	from #flutcent a
		inner join istpers i on a.marca=i.marca and a.data=i.data
		left outer join personal p on a.marca=p.marca
		left outer join extinfop e on i.cod_functie=e.marca and e.Cod_inf='#CODCOR'
		left outer join functii_cor f on e.val_inf=f.Cod_functie
		left outer join par_lunari l on l.Data=a.Data and l.parametru='ORE_LUNA'
		left outer join functii_cor fc on fc.cod_functie=left(f.cod_functie,len(fc.cod_functie)) 
		and (len(fc.cod_functie)=1 or fc.cod_functie=f.Cod_functie /*and f.numar_curent=fc.numar_curent*/)
	where (i.grupa_de_munca in ('N','D','S','C') or @filtrutimplucrat=1 and i.grupa_de_munca='C') and p.Sex=0
		and (@salariatiactivi=0 or @salariatiactivi=1 and p.Data_angajarii_in_unitate<=@dataSus and (p.Loc_ramas_vacant=0 or p.Data_plec>@dataSus))
	group by fc.Cod_functie, p.Sex
	order by fc.Cod_functie, Sex

end try

begin catch
	set @eroare='Procedura rapAnchetaSalarii2 (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
	