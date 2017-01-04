--***
CREATE procedure wACZoneSP @sesiune varchar(50), @parXML XML
as

declare @searchText varchar(100)
set @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%')

select top 100 rtrim(v.Zona) as cod,rtrim(v.Denumire_zona) as denumire
from Zone v
where (v.Zona like @searchText+'%' or v.Denumire_zona like @searchText+'%' or v.Localitate like '%'+@searchText+'%')
order by rtrim(v.Zona)
for xml raw