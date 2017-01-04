--***
Create procedure wACTipStatPlata @sesiune varchar(50), @parXML XML
as
Begin
	declare @searchText varchar(100)
	set @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%')

	select distinct top 100 rtrim(Tip_stat_plata) as cod, rtrim(denumire) as denumire 
	from TipStatPlata
	where Tip_stat_plata like '%'+@searchText+'%' 
	for xml raw
End	