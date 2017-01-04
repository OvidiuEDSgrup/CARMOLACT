--***
Create procedure wACTehnologii @sesiune varchar(50), @parXML XML
as

declare @searchText varchar(100)
set @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%')

select top 100 rtrim(Cod_tehn) as cod, 'Tip tehn: '+rtrim(Tip_tehn) as info,  
rtrim(Denumire) as denumire
from tehn
where (Cod_tehn like @searchText+'%' or Denumire like '%'+@searchText+'%')
order by Cod_tehn
for xml raw
