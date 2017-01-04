--***
create procedure wIaCoduriBancare @sesiune varchar(50), @parXML XML  
--> procedura de scriere/modificare date pentru macheta de banci (ASiSRia --> Configurari --> Banci (meniu banci, nu cel vechi, B))
as  

declare @eroare varchar(4000)
select @eroare=''
BEGIN TRY
	
	declare @cod varchar(200), @denumire varchar(2000)
	select @cod=@parxml.value('(row/@cod)[1]','varchar(200)')
		,@denumire='%'+replace(@parxml.value('(row/@denumire)[1]','varchar(2000)'),' ','%')+'%'
	
	select cod, denumire, swift from coduribancare c
	where (@cod is null or c.cod like @cod)
		and(@denumire is null or c.denumire like @denumire)
		order by cod
	for xml raw

END TRY
BEGIN CATCH
	SET @eroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	RAISERROR(@eroare, 11, 1)
END CATCH
