--***
-------------Procedura care creaza un fisier pe disk------------------
------ primeste ca parametrii textul continut al fisierului, calea de salvare pe disk, si numele fisierului care va fi creat----------
create procedure salvareFisier @codXML Varchar(max), @caleFisier VARCHAR(255), @numeFisier VARCHAR(100), @numeTabelDate varchar(5000)='', @faraMesaj int=0
AS
declare  @objFileSystem int, @objTextStream int, @objErrorObject int, @strErrorMessage Varchar(1000),
         @hr int, @fileAndPath varchar(500), @mesajeroare varchar(500)
set nocount on 
begin try
	
	if len(isnull(@codXML,''))=0 -- parametrul @codXML nu se mai foloseste...
	begin
		-- tentativa de inlocuire caractere speciale si diacritice, trebuie bucla... dar ceva nu merge... 
		--declare @cmdSQL varchar(4000), @chr varchar(10)='&'
		--set @cmdSQL='update '+@numeTabelDate+' set valoare=replace(valoare,'''+@chr+''','''')'
		--exec (@cmdSQL) 
		--set @chr='+'
		--set @cmdSQL='update '+@numeTabelDate+' set valoare=replace(valoare,'''+@chr+''','''')'
		--exec (@cmdSQL) 
		--select valoare from ##D394outputTXT where valoare like '%Babu%Gygy%'

		declare @nServer varchar(1000), @cmdShellCommand nvarchar(4000), @raspunsCmd int, @extensia varchar(20)
		set @extensia=substring(@numeFisier, len(@numeFisier)-charindex('.',reverse(@numeFisier))+1,len(@numeFisier))
		select	@nServer=convert(varchar(1000),serverproperty('ServerName')),
				@cmdShellCommand='bcp "select valoare from '+@numeTabelDate+' order by id" queryout "'+@caleFisier+'\'+@numeFisier+'" -T -c  -t -C UTF-8 -S '+@nServer+
					+(case when @extensia='.txt' then '' else ' -r ' end /*la txt, pastrez separatorul de linie*/)

		exec @raspunsCmd = xp_cmdshell @cmdShellCommand
					
		if @raspunsCmd != 0 /* xp_cmdshell returneaza 0 daca nu au fost erori, sau altfel, codul de eroare la OLE e 0 daca nu au fost erori */
		begin
			set @mesajeroare='Eroare la scrierea formularului pe hard-disk in locatia: '+rtrim(@caleFisier)+'!'
			raiserror (@mesajeroare,11 ,1)
		end
	end
	else
	begin
		select @strErrorMessage='opening the File System Object'
		EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT 

		Select @FileAndPath=rtrim(@caleFisier)+(case when right(rtrim(@caleFisier),1)='\' then '' else '\' end)+rtrim(@numeFisier)

		if @HR=0 
			Select @objErrorObject=@objFileSystem , @strErrorMessage='Se creaza fisierul... "'+@FileAndPath+'"'
		if @HR=0 
			execute @hr = sp_OAMethod @objFileSystem,'CreateTextFile',@objTextStream OUT,@FileAndPath,2,True

		if @HR=0 
			Select @objErrorObject=@objTextStream, @strErrorMessage='Se scrie in fisierul... "'+@FileAndPath+'"'
		if @HR=0 
			execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @codXML

		if @HR=0 
			Select @objErrorObject=@objTextStream, @strErrorMessage='Se inchide fisierul... "'+@FileAndPath+'"'
		if @HR=0 
			execute @hr = sp_OAMethod  @objTextStream, 'Close'

		if @hr<>0
		begin
			Declare  @Source varchar(255), @Description Varchar(255),@Helpfile Varchar(255),@HelpID int
    
			execute sp_OAGetErrorInfo  @objErrorObject,@source output,@Description output,@Helpfile output,@HelpID output

			Select @strErrorMessage='Error whilst ' +coalesce(@strErrorMessage,'doing something')+', '+coalesce(@Description,'')
			raiserror (@strErrorMessage,11,1)
		end

		EXECUTE  sp_OADestroy @objTextStream
		EXECUTE sp_OADestroy @objTextStream   
	end

	if @faraMesaj=0
		select /*@codXML as document,*/ @numeFisier as fisier, 'wTipFormular' as numeProcedura for xml raw,root('Mesaje') 

end try

begin catch
	set @mesajeroare = ERROR_MESSAGE()
	raiserror(@mesajeroare, 11, 1)
end catch     
