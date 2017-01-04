--***
Create procedure rapActAditionalCIM
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
	IF OBJECT_ID('tempdb.dbo.#tmpDSalariat') IS NOT NULL DROP TABLE #tmpDSalariat
	select *
	into #tmpDSalariat 
	from fDateSalariati(@marca,@dataSus)
	--selectare date acte aditionale dupa marca si data pentru subreport	
	if @dataset='MODIF'
	select *
	from fActeAditionale(@marca,@dataSus,dbo.eom(@datasus),0)

	alter table #tmpDSalariat add clauzaA int, clauzaB int, clauzaC int

	if @dataset='SALAR'
		select t.*
		from #tmpDSalariat t
		inner join personal p on p.marca=t.marca
		inner join lm on lm.cod=p.loc_de_munca 
		where (lm.cod=@locm or isnull(@locm,'')='') 
	end
	if @dataset='REPORT'
		select t.marca, e.data_inf, p.loc_de_munca, e.cod_inf
		from #tmpDSalariat t
		inner join extinfop e on t.marca=e.marca and cod_inf in ('CONDITIIM','DATAMDCTR','DATAMRL','DATAMFCT','DATAMLM','SALAR') and dbo.eom(data_inf)=dbo.eom(@datasus)
		inner join personal p on t.marca=p.marca and (p.loc_de_munca=@locm or isnull(@locm,'')='')
		order by marca
end try

begin catch
	set @eroare='Procedura rapActAditionalCIM (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch


/*
	exec rapActAditionalCIM '03/01/2012', '03/31/2012', null, null,'salar'
	exec rapActAditionalCIM '03/01/2012', '03/31/2015', null, '00101','report'

*/