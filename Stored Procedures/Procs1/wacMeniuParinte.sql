--***

create procedure wacMeniuParinte(@sesiune varchar(50), @parXML XML)
as
begin
	declare @searchText varchar(100)
	select @searchText='%'+replace(isnull(@parXML.value('(row/@searchText)[1]','varchar(100)'),' '),' ','%')+'%'
	select w.id as cod, w.Nume as denumire from webconfigmeniu w 
		where w.idParinte is null and w.Nume like @searchText
	for xml raw
end