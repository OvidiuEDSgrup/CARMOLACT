--***
Create procedure wACActivitatiPers @sesiune varchar(50), @parXML XML
as
begin
	declare @searchText varchar(100)
	set @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%')

	select distinct top 100 rtrim(activitate) as cod, rtrim(activitate) as denumire 
	from personal
	where activitate like '%'+@searchText+'%' and activitate<>''
	union all
	select null as cod,' Toate' as denumire
	union all
	select '' as cod,' Necompletat' as denumire
	order by cod
	for xml raw
end