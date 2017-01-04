--***
Create procedure rapContractDeMunca
	@dataJos datetime, @dataSus datetime, @marca varchar(6)=null, @locm char(9)=null, @dataset char(9)='FIRMA'
as
begin try
	set transaction isolation level read uncommitted
	declare @eroare varchar(200)
	begin
	IF OBJECT_ID('tempdb.dbo.#dateFirma') IS NOT NULL DROP TABLE #dateFirma
	CREATE TABLE #dateFirma(locm varchar(50))
	exec wDateFirma_tabela
	EXEC wDateFirma @locm = @locm

	if @dataset='FIRMA'
		select * from #dateFirma
	select *
	into #tmpDSalariat 
	from fDateSalariati(@marca,@dataSus)

	update t
	set t.nr_contract=(case when isnull(t.nr_contract,'')='' 
							then ltrim(left(i.nr_contract,(case when charindex('/',i.nr_contract)<>0 then charindex('/',i.nr_contract)-1 end))) end)
	from #tmpDSalariat t
	inner join infopers i on t.marca=i.marca
	alter table #tmpDSalariat add salar_brut decimal(10,2), loc_activitate varchar(30), zile_conc_odih int, 
						          clauzaA int, clauzaB int, clauzaC int, CCMunca varchar(20),DiffLuni int, schimburi varchar(20)


	update t 
		set t.salar_brut=p.salar_de_baza, loc_activitate=isnull(lm.detalii.value('(/row/@adresa)[1]','varchar(30)'),(select top 1 d.adresa from #datefirma d )),
			zile_conc_odih=p.zile_concediu_de_odihna_an,
		    clauzaA=(case when p.mod_angajare='D' 
							  then (case when datediff(month,data_angajarii,t.data_plec)<3 then 5
										 when datediff(month,data_angajarii,t.data_plec)<7 then 15
										 else (case when p.indemnizatia_de_conducere=0 then 30 else 45 end) end)
							  else 60 end),
			clauzaB=(case when p.mod_angajare='N' then 20 else null end),
			clauzaC=(case when p.mod_angajare='N' then 20 else null end),
			DiffLuni=(case when p.mod_angajare='D' then datediff(month,data_angajarii,t.data_plec) else 0 end)

	from #tmpDSalariat t
	inner join personal p on p.marca=t.marca
	inner join lm on lm.cod=p.loc_de_munca 


	if @dataset='SALAR'
		select t.* from #tmpDSalariat t
		inner join personal p on p.marca=t.marca
		inner join lm on lm.cod=p.loc_de_munca 
		where plecat=0 and (lm.cod=@locm or isnull(@locm,'')='')
	end
end try

begin catch
	set @eroare='Procedura rapContractDeMunca (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch


/*
	exec rapContractDeMunca '03/01/2012', '03/31/2012', null, null,'salar'
*/