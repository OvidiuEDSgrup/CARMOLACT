create procedure yso_wACProdLapte @sesiune varchar(50), @parXML xml
as
declare @searchText varchar(80)
select @searchText=ISNULL(@parXML.value('(/row/@searchText)[1]', 'varchar(80)'), '')

select Cod_producator as cod, Denumire as denumire
from ProdLapte
where denumire like @searchText+'%' or Cod_producator like @searchText+'%'
for xml raw