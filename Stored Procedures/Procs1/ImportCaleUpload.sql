
Create procedure ImportCaleUpload @sesiune varchar(50), @parXML XML 
as

if exists (select 1 from sysobjects where [type]='P' and [name]='ImportCaleUploadSP')
begin 
	declare @returnValue int -- variabila salveaza return value de la procedura specifica
	-- momentan nu tratam return value de la proceduri, dar poate sa fie de folos pe viitor 
	-- recomand folosirea ei, impreuna cu return -1 daca au fost erori...
	exec @returnValue = ImportCaleUploadSP @sesiune, @parXML output
	return @returnValue
end

declare @mesaj varchar(max), @userAsis varchar(50)

begin try
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS output
	select '\:*"\<>|c:\/:*"<>|di|r1\d>ir<2\*a' as _caleUpload for xml raw, root('Date');
end try
	
begin catch
	set @mesaj = '(ImportCaleUpload)'+ERROR_MESSAGE()
end catch

if LEN(@mesaj)>0
	raiserror(@mesaj, 11, 1)

-- exec importcaleupload
--sp_helptext	wiaterti
