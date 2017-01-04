--***
Create procedure wACFunctii @sesiune varchar(50), @parXML XML
as
if exists(select * from sysobjects where name='wACFunctiiSP' and type='P')
	exec wACFunctiiSP @sesiune, @parXML
else      
Begin
	declare @utilizator varchar(20), @lista_lm int, @searchText varchar(100)

	exec wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT
	set @lista_lm=dbo.f_areLMFiltru(@utilizator)

	set @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%')

	if OBJECT_ID('tempdb..#ACFunctii') is not null drop table #ACFunctii

	select *, nullif(detalii.value('(/row/@lm)[1]','varchar(20)'),'') as lm
	into #ACFunctii
	from functii
	where (cod_functie like @searchText+'%' or denumire like '%'+@searchText+'%')

	select top 100 rtrim(f.cod_functie) as cod, rtrim(f.denumire) as denumire, 'Cod COR: '+rtrim(isnull(fc.val_inf,'')) as info
	from #ACFunctii f
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=f.lm
		left outer join extinfop fc on fc.Marca=f.Cod_functie and fc.Cod_inf='#CODCOR'
	where (@lista_lm=0 or f.lm is null or lu.cod is not null)
		and isnull(fc.Val_inf,'') like @searchText+'%'
	order by cod_functie
	for xml raw
end