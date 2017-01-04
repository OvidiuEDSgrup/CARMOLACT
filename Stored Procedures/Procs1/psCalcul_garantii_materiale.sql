--***
/**	procedura pentru calcul garantii materiale conform setarilor **/
Create procedure psCalcul_garantii_materiale
	@dataJos datetime, @dataSus datetime, @marca varchar(6)=null, @lm varchar(9)=null, @Cu_stergere int=0
As
Begin try 
	declare @Cod_benef_gm char(13), @Calcul_garantii_materiale int, @cBaza_garantii char(1), @dataJos_1 datetime, @dataSus_1 datetime 

	set @Cod_benef_gm=dbo.iauParA('PS','CODBGMAT')
	set @Calcul_garantii_materiale=dbo.iauParL('PS','CALCGMAT')
	set @cBaza_garantii=dbo.iauParA('PS','CALCGMAT')
	set @dataJos_1=dbo.bom(@dataJos-1)
	set @dataSus_1=dbo.eom(@dataJos-1)
	
	if @marca is null set @marca=''
	if @lm is null set @lm=''

	if object_id('tempdb..#Garantii') is not null 
		drop table #Garantii
	if object_id('tempdb..#personalGM') is not null 
		drop table #personalGM
	if object_id('tempdb..#garantiiLunaAnt') is not null 
		drop table #garantiiLunaAnt

	select p.marca, p.nume, p.Salar_de_incadrare, 
		p.detalii.value('(/row/@nrsalgm)[1]','int') as nrsalgm,
		p.detalii.value('(/row/@procentgm)[1]','int') as procentgm
	into #personalGM
	from personal p
	where (isnull(@marca,'')='' or p.marca=@marca) 
		and (isnull(@lm,'')='' or p.Loc_de_munca like rtrim(@lm)+'%') 
		and (p.Loc_ramas_vacant=0 or p.Data_plec>@dataJos)

--	selectare garantii din luna anterioara lunii de lucru.
	select * into #garantiiLunaAnt 
	from (select r.data, r.marca, r.cod_beneficiar, r.data_document, r.numar_document, r.Valoare_totala_pe_doc, r.valoare_retinuta_pe_doc, RANK() over (partition by r.Marca order by r.Data Desc) as ordine
		from resal r 
		inner join #personalGM p on p.Marca=r.Marca
		where r.Data between @dataJos_1 and @dataSus_1 and r.cod_beneficiar=@Cod_benef_gm and r.numar_document='GARANTII') a
	where Ordine=1

	if @Cu_stergere=1
		delete r 
		from resal r
			inner join #personalGM p on p.Marca=r.Marca
		where r.data between @dataJos and @dataSus and r.Cod_beneficiar=@Cod_benef_gm and r.Numar_document='GARANTII'
			and isnull(r.detalii.value('(/row/@retinutsep)[1]','decimal(12,2)'),0)=0

	create table #Garantii 
		(marca varchar(6), nume varchar(50), valoare_totala_garantie float, valoare_lunara_garantie float,procent_nrluni_suma decimal(6), salar_de_incadrare decimal(10))

	/*	Citim mai intai din personal (pastrare date garantii in personal.detalii). */
	insert into #Garantii
	select 
		p.marca, p.nume, isnull(convert(int,p.nrsalgm)*p.Salar_de_incadrare,0) as Valoare_totala_garantie, 
		isnull(round((case when @cBaza_garantii='1' then p.procentgm/100.00*p.Salar_de_incadrare when @cBaza_garantii='2' then convert(int,p.nrsalgm)*p.Salar_de_incadrare/p.procentgm 
		else p.procentgm end),0),0) as Valoare_lunara_garantie,
		p.procentgm as Procent_nrluni_suma, isnull(p.salar_de_incadrare,0) as salar_de_incadrare
	from #personalGM p
	where (rtrim(p.nrsalgm)<>'' or p.procentgm<>0)

	/*	Stilul vechi (poate foloseste cineva) cu extinfop. */
	if not exists (select 1 from #Garantii)
	begin
		insert into #Garantii
		select a.marca, isnull(p.nume,'') as Nume, isnull(convert(int,a.val_inf)*p.Salar_de_incadrare,0) as Valoare_totala_garantie, 
		isnull(round((case when @cBaza_garantii='1' then a.procent/100.00*p.Salar_de_incadrare when @cBaza_garantii='2' then convert(int,a.Val_inf)*p.Salar_de_incadrare/a.Procent 
			else a.Procent end),0),0) as Valoare_lunara_garantie,
		a.procent as Procent_nrluni_suma, isnull(p.salar_de_incadrare,0) as salar_de_incadrare
		from extinfop a
			left outer join personal p on p.marca=a.marca 
		where a.cod_inf='GARANTII' and (@marca='' or a.marca=@marca) and (rtrim(a.Val_inf)<>'' or a.Procent<>0)
			and (p.Loc_ramas_vacant=0 or p.Data_plec>@dataJos)
	end

	update resal 
		set Valoare_totala_pe_doc=a.Valoare_totala_garantie, Retinere_progr_la_lichidare=Valoare_lunara_garantie
	from #Garantii a
	where resal.marca=a.Marca and resal.data between @dataJos and @dataSus and resal.cod_beneficiar=@Cod_benef_gm and resal.numar_document='GARANTII' and a.Nume<>''

	insert into resal 
		(Data, Marca, Cod_beneficiar, Numar_document, Data_document, Valoare_totala_pe_doc, Valoare_retinuta_pe_doc, Retinere_progr_la_avans, Retinere_progr_la_lichidare, 
		Procent_progr_la_lichidare, Retinut_la_avans, Retinut_la_lichidare, detalii) 
	select @dataSus, a.Marca, @Cod_benef_gm, 'GARANTII', (case when gla.marca is not null then gla.data_document else @dataSus end), a.Valoare_totala_garantie, 
		0, 0, a.Valoare_lunara_garantie, 0, 0, 0, (select '1' as genGM for xml raw)
	from #Garantii a 
		left outer join #garantiiLunaAnt gla on gla.marca=a.marca
	where a.Nume<>'' 
		and not exists (select r.marca from resal r where r.marca=a.Marca and r.data between @dataJos and @dataSus and r.cod_beneficiar=@Cod_benef_gm and r.numar_document='GARANTII') 

	if object_id('tempdb..#Garantii') is not null 
		drop table #Garantii
	if object_id('tempdb..#personalGM') is not null 
		drop table #personalGM
	if object_id('tempdb..#garantiiLunaAnt') is not null 
		drop table #garantiiLunaAnt
End try

Begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura psCalcul_garantii_materiale (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
End catch

