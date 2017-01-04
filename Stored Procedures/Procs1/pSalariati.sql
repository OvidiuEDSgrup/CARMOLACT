--***
/**	procedura pentru stabilire date de personal la luna ..., necesare pentru calcul lichidare.	*/
Create procedure pSalariati
	(@dataJos datetime, @dataSus datetime, @marca char(6)='', @locm char(9)='')
As
/*
	exec pSalariati @dataJos='05/01/2015', @dataSus='05/31/2015', @marca='', @locm='101'
*/
Begin try

	if object_id('tempdb..#modificari') is not null 
		drop table #modificari
	if object_id('tempdb..#extinfop') is not null 
		drop table #extinfop
	if object_id('tempdb..#personalFlt') is not null 
		drop table #personalFlt
	if object_id('tempdb..#salariati') is null
	begin
		Create table #salariati (marca varchar(6) not null)
		exec CreeazaDiezSalariati @numeTabela='#salariati'
	end

	select * into #personalFlt 
	from personal 
	where (isnull(@locm,'')='' or Loc_de_munca like rtrim(@locm)+'%') 
			and (isnull(@marca,'')='' or  Marca=@marca)
	/*	Citim ultima pozitie anterioara lunii curente pentru fiecare tip de modificare din tabela extinfop. */
	select *, convert(varchar(100),'') as valoare into #extinfop from 
		(select e.Marca, e.Cod_inf, e.Val_inf, e.Procent, RANK() over (partition by e.Marca, e.Cod_inf order by e.Data_inf Desc) as ordine
		from extinfop e 
			inner join #personalFlt p on p.Marca=e.Marca
		where e.Data_inf<=@DataSus 
			and e.cod_inf in ('DATAMFCT','DATAMDCTR','CONDITIIM','SALAR','DATAMRL')) a
	where Ordine=1

	update #extinfop set valoare=(case when cod_inf in ('SALAR','DATAMRL') then convert(varchar(20),procent) else val_inf end)

--	mut informatia de pe verticala pe orizontala (prin pivotare)
	select marca, 
		ISNULL(SALAR,0) as salar, ISNULL(DATAMFCT,'') as cod_functie, ISNULL(DATAMLM,'') as loc_de_munca, ISNULL(DATAMDCTR,'') as Data_sfarsit, 
		ISNULL(CONDITIIM,'') as grupa_de_munca, ISNULL(DATAMRL,0) as regim_de_lucru
	into #modificari
	from (
		select marca, cod_inf as camp, isnull(valoare,'') as valoare from #extinfop) a
			pivot (max(valoare) for camp in 
				([SALAR],[DATAMFCT],[DATAMDCTR],[CONDITIIM],[DATAMRL],[DATAMLM])) b

	insert into #salariati (marca, nume, cod_functie, loc_de_munca, categoria_de_salarizare, grupa_de_munca, salar_de_incadrare, salar_de_baza,
		tip_salarizare, tip_impozitare, somaj_1, as_sanatate, indemnizatia_de_conducere, spor_vechime, spor_de_noapte, spor_sistematic_peste_program, spor_de_functie_suplimentara,
		spor_specific, spor_conditii_1, spor_conditii_2, spor_conditii_3, spor_conditii_4, spor_conditii_5, spor_conditii_6, sindicalist, salar_lunar_de_baza, 
		localitate, judet, strada, numar, cod_postal, bloc, scara, etaj, apartament, sector, zile_concediu_de_odihna_an, vechime_totala, mod_angajare, data_plec, tip_colab)
	select p.marca, p.nume, isnull(nullif(m.cod_functie,''),p.cod_functie), isnull(nullif(m.loc_de_munca,''),p.loc_de_munca), p.categoria_salarizare, 
		isnull(nullif(m.grupa_de_munca,''),p.grupa_de_munca), isnull(nullif(m.salar,0),p.salar_de_incadrare), p.salar_de_baza,
		p.tip_salarizare, p.tip_impozitare, p.somaj_1, p.as_sanatate, p.indemnizatia_de_conducere, p.spor_vechime, p.spor_de_noapte, p.spor_sistematic_peste_program, p.spor_de_functie_suplimentara,
		p.spor_specific, p.spor_conditii_1, p.spor_conditii_2, p.spor_conditii_3, p.spor_conditii_4, p.spor_conditii_5, p.spor_conditii_6, p.sindicalist, p.salar_lunar_de_baza, 
		p.localitate, p.judet, p.strada, p.numar, p.cod_postal, p.bloc, p.scara, p.etaj, p.apartament, p.sector, p.zile_concediu_de_odihna_an, p.vechime_totala, p.mod_angajare, p.data_plec, p.tip_colab
	from #personalFlt p
		left outer join #modificari m on m.marca=p.marca

--	calcul salar de baza in tabela temporara. 
	if object_id('tempdb..#personalSalBaza') is not null
		drop table #personalSalBaza
	Create table #personalSalBaza (marca varchar(6) not null)
	exec CreeazaDiezPersonal @numeTabela='#personalSalBaza'
	insert into #personalSalBaza
	select marca, salar_de_incadrare, salar_de_baza, indemnizatia_de_conducere, spor_specific, 
		spor_conditii_1, spor_conditii_2, spor_conditii_3, spor_conditii_4, spor_conditii_5, spor_conditii_6
	from #salariati
	exec calculSalarDeBaza @sesiune=null, @parXML=null
	update #salariati set salar_de_baza=isnull(nullif(#personalSalBaza.salar_de_baza,0),#salariati.salar_de_baza)
	from #personalSalBaza 
	where #personalSalBaza.marca=#salariati.marca

End try

begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura pSalariati (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
