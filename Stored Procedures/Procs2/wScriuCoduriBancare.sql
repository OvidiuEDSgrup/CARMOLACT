--***
create procedure wScriuCoduriBancare @sesiune varchar(50), @parXML XML  
--> procedura de scriere/modificare date pentru macheta de banci (ASiSRia --> Configurari --> Banci (meniu banci, nu cel vechi, B))
as  

declare @eroare varchar(4000)
select @eroare=''
BEGIN TRY
	
	declare @cod varchar(200), @denumire varchar(2000), @swift varchar(200), @update bit
			, @o_cod varchar(200)
	select @cod=@parxml.value('(row/@cod)[1]','varchar(200)')
		,@denumire=@parxml.value('(row/@denumire)[1]','varchar(2000)')
		,@swift=@parxml.value('(row/@swift)[1]','varchar(200)')
		,@update=isnull(@parxml.value('(row/@update)[1]','bit'),0)
		,@o_cod=@parxml.value('(row/@o_cod)[1]','varchar(200)')
	
	--> validari
		if len(@cod)<>4 raiserror('Lungimea codului bancar trebuie sa fie strict de 4 caractere!',16,1)
		if isnull(@swift,'')<>'' and len(@swift)<>8 raiserror('Lungimea codului swift trebuie sa fie strict de 8 caractere!',16,1)
		
		if @update=1 and @cod<>@o_cod raiserror('Nu este permisa schimbarea codului bancii! Pentru un alt cod operati o noua banca!',16,1)	
	
	--> scriere
		if @update=0
		insert into coduribancare(cod, denumire, swift)
		select @cod, @denumire, @swift
	--> modificare
		else
		update c set denumire=@denumire, swift=@swift from coduribancare c where c.cod=@cod

END TRY
BEGIN CATCH
	SET @eroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	RAISERROR(@eroare, 11, 1)
END CATCH
