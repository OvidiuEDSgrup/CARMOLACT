CREATE procedure wOPDefinitivareDocument @parXML xml, @sesiune varchar(50)
as
begin try 
	if exists (select 1 from sysobjects where [type]='P' and [name]='wOPDefinitivareDocumentSP')
	begin 
		declare @returnValue int -- variabila salveaza return value de la procedura specifica
		exec @returnValue = wOPDefinitivareDocumentSP @sesiune=@sesiune, @parXML=@parXML
		return @returnValue
	end	

	declare 
		@tip varchar(2), @numar varchar(20), @data datetime, @explicatii varchar(200), @detalii xml,
		@docJurnal xml	

	SET @tip = @parXML.value('(/*/@tip)[1]', 'varchar(2)')
	SET @numar = @parXML.value('(/*/@numar)[1]', 'varchar(20)')
	SET @data = @parXML.value('(/*/@data)[1]', 'datetime')
	SET @explicatii = @parXML.value('(/*/@explicatii)[1]', 'varchar(200)')
	if @parXML.exist('(/*/detalii)[1]')=1
		SET @detalii = @parXML.query('(/*/detalii/row)[1]')

	--jurnalizare operare document
	SELECT @docJurnal = 
		( SELECT @numar numar, 1 as stare , @data data, @tip tip, 'Definitivare document' explicatii
		FOR XML raw,root('Date') )
	EXEC wScriuJurnalDocument @sesiune = @sesiune, @parXML = @docJurnal OUTPUT

end try        
begin catch 
	declare @eroare varchar(200) 
	set @eroare='(wOPDefinitivareDocument) '+ERROR_MESSAGE()
	raiserror(@eroare, 16, 1) 
end catch

