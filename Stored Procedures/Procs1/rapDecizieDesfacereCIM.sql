--***
Create procedure rapDecizieDesfacereCIM
	@dataJos datetime, @dataSus datetime, @marca varchar(6)=null, @locm char(9)=null, @dataset char(9)='FIRMA'
as
begin try
	set transaction isolation level read uncommitted
	declare @eroare varchar(200)
	begin
	--selectare date firma pt subreport
	IF OBJECT_ID('tempdb.dbo.#dateFirma') IS NOT NULL DROP TABLE #dateFirma
	CREATE TABLE #dateFirma(locm varchar(50))
	exec wDateFirma_tabela
	EXEC wDateFirma @locm = @locm
	alter table #dateFirma add codunitdm varchar(20)
	update #dateFirma
		set codunitdm=(select val_alfanumerica from par where parametru='CODUNITDM' and tip_parametru='PS')
		   -- fdirgen=(select val_alfanumerica from par where parametru='FDIRGEN' and tip_parametru='GE')
	if @dataset='FIRMA'
		select * from #dateFirma
	--selectare date salariat dupa marca pentru subreport
	select *
	into #tmpDSalariat 
	from fDateSalariati(@marca,@dataSus)

	alter table #tmpDSalariat add clauzaA int, clauzaB int, clauzaC int

	IF OBJECT_ID('tempdb.dbo.#tmpExt') IS NOT NULL DROP TABLE #tmpExt
	select marca,
		   max(case when cod_inf='RTEMEIINCET' then val_inf else '' end) as rtemeiinch,
		   max(case when cod_inf='TXTTEMEIINCET' then val_inf else '' end) as txttemeiinch,
		   max(case when cod_inf='DATAINCH' then data_inf else '01/01/1901' end) as datainch
	into #tmpExt
	from extinfop
	where cod_inf in ('RTEMEIINCET','TXTTEMEIINCET','DATAINCH')
	group by marca

	IF OBJECT_ID('tempdb.dbo.#tmpBrut') IS NOT NULL DROP TABLE #tmpBrut
	select marca, 
		   sum(convert(int,ore_concediu_fara_salar/(case when convert(int,spor_cond_10)=0 then 8 else spor_cond_10 end))) as CFS,
		   sum(convert(int,ore_nemotivate)%convert(int,(case when convert(int,spor_cond_10)=0 then 8 else spor_cond_10 end))) as ore_nem_ramase,
		   sum(convert(int,ore_nemotivate/(case when convert(int,spor_cond_10)=0 then 8 else spor_cond_10 end))) as ore_nem
	into #tmpBrut
	from brut
	group by marca
	update t 
		set clauzaA=(case when p.mod_angajare='D' 
							  then (case when datediff(month,data_angajarii,t.data_plec)<3 then 5
										 when datediff(month,data_angajarii,t.data_plec)<7 then 15
										 else (case when p.indemnizatia_de_conducere=0 then 30 else 45 end) end)
							  else 60 end),
			clauzaB=(case when p.mod_angajare='N' then 20 else null end),
			clauzaC=(case when p.mod_angajare='N' then 20 else null end)
	from #tmpDSalariat t
	inner join personal p on p.marca=t.marca
	inner join lm on lm.cod=p.loc_de_munca 

	if @dataset='SALAR'
		select t.*,e.datainch,e.rtemeiinch,e.txttemeiinch, b.CFS, b.ore_nem_ramase,b.ore_nem, isnull(p.detalii.value('(/row/@nrdecinc)[1]','int'),0) as nrdecinc from #tmpDSalariat t
		inner join personal p on p.marca=t.marca
		inner join lm on lm.cod=p.loc_de_munca 
		inner join #tmpExt e on t.marca=e.marca
		left outer join #tmpBrut b on b.marca=t.marca
		where (lm.cod=@locm or isnull(@locm,'')='') 
	end
	if @dataset='REPORT'
		select t.marca, lm.cod from #tmpDSalariat t
		inner join personal p on p.marca=t.marca
		inner join lm on lm.cod=p.loc_de_munca 
		where (lm.cod=@locm or isnull(@locm,'')='') and t.data_plec between @datajos and @datasus
end try

begin catch
	set @eroare='Procedura rapDecizieDesfacereCIM (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch


/*
	exec rapDecizieDesfacereCIM '03/01/2015', '03/31/2015', null, '00101','report'
*/