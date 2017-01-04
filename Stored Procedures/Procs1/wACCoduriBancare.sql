--***
create procedure wACCoduriBancare @sesiune varchar(50), @parXML XML  
	--> procedura de autocomplete pentru alegerea bancii; se foloseste, de exemplu, in detalierea Terti --> Banci
as  

declare @eroare varchar(4000)
select @eroare=''
BEGIN TRY
	
	declare @searchText varchar(100),@tert varchar(13)

	select @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%')
	
	select cod, denumire from coduribancare c
	where (c.cod like @searchText+'%' or c.denumire like '%'+@searchText+'%')
	for xml raw

END TRY
BEGIN CATCH
	SET @eroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	RAISERROR(@eroare, 11, 1)
END CATCH
