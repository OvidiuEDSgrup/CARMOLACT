--***
create procedure wACCodCaenD394 @sesiune varchar(50), @parXML XML
as
begin
	declare @searchText varchar(100),@tip varchar(2)
	set @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%')
	set @tip=isnull(@parXML.value('(/row/@tip)[1]','varchar(2)'),'')

	-- tabela coduri CAEN sectiunea I7 din declaratia 394
	if object_id('tempdb..#codCaen394') is not null 
		drop table #codCaen394
	create table #codCaen394 (cod varchar(10), denumire varchar(250))
	exec pCoduriCaenD394
	
	select rtrim(cod) as cod, rtrim(denumire) as denumire, '' as info	
	from #codCaen394
	where cod like '%'+@searchText+'%' or denumire like @searchText+'%'
	for xml raw
end
