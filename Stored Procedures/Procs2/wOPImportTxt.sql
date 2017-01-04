
Create procedure wOPImportTxt @sesiune varchar(50), @parXML xml
/**
	Procedura care importa continutul unui fisier (text) in tabelxml.date (de tip xml)
	Calea este cea default  - a formularelor - iar numele fisierului se primeste prin @parxml.row.fisier sau @parxml.row.cale_fisier
	
	se apeleaza astfel: exec wOPImportTxt @sesiune=@sesiune, @parxml=@parxml
		cu @parxml continand denumriea fisierului + extensie, in atributele row/@cale_fisier sau row/@fisier
*/
as

declare @mesaj varchar(500), @cale_fisier varchar(2000),
		@importXML xml

begin try
	select	@cale_fisier =
		isnull(
			isnull(
				@parXML.value('(/*/@fisier)[1]','varchar(2000)'),
			@parXML.value('(/*/@cale_fisier)[1]','varchar(2000)')
			)
		,'')

	if @cale_fisier = ''
	begin
		set @mesaj = 'Nu s-a ales niciun fisier pentru import!'
		raiserror(@mesaj,16,1)
	end

	declare @caleform varchar(1000)
	select @caleform=rtrim(val_alfanumerica)+(case when left(reverse(rtrim(val_alfanumerica)),1)='\' then '' else '\' end)+'uploads\'
		from par where tip_parametru='AR' and parametru='caleform'

	declare @comanda nvarchar(4000)
	select @comanda='SELECT @importXML = convert(XML
		,replace(
			replace(
					replace(x,''>'',''&gt;'')
				,''<'',''&lt;'')
			,''&'',''&amp;''))
	FROM OPENROWSET
     (BULK '''+@caleform+@cale_fisier+''',
      SINGLE_BLOB) AS T(X)'
      
    EXEC sp_executesql @comanda, N'@importXML XML OUTPUT', @importXML OUTPUT;
    insert into tabelxml(sesiune, date)
    select @sesiune, @importXML
end try

begin catch
	set @mesaj=ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@mesaj, 11, 1)
end catch
