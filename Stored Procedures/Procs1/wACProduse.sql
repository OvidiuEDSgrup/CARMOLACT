--***
CREATE procedure [dbo].[wACProduse] @sesiune varchar(50), @parXML XML
as

declare @searchText varchar(100)
set @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%')

select top 100 rtrim(COd) as cod,rtrim(denumire) as denumire
from nomencl
where Tip='P' and (Cod like @searchText+'%' or denumire like '%'+@searchText+'%')

order by rtrim(denumire)
for xml raw