--***
Create procedure wACFormaProprietate @sesiune varchar(50), @parXML XML
as
Begin
	declare @searchText varchar(100)
	select @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%')

	select top 100 rtrim(cod) as cod, rtrim(descriere) as denumire, rtrim(CodParinte) as info
	from CatalogRevisal
	where TipCatalog='FormaProprietate' and (cod like @searchText+'%' or descriere like '%'+@searchText+'%')
	order by cod
	for xml raw
End	