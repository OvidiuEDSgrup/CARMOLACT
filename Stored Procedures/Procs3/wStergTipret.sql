--***
Create procedure wStergTipret @sesiune varchar(50), @parXML xml
as
begin try

	declare @subtipretinere varchar(13), @mesaj varchar(1000), @mesajEroare varchar(1000), @subtipret int
	set @subtipretinere = @parXML.value('(/row/@subtipret)[1]','varchar(13)')

	set @subtipret=dbo.iauParL('PS','SUBTIPRET')
	select @mesaj='', @mesajEroare=''

	select @mesajEroare=
		(case when @subtipret=1 and exists (select 1 from benret br where br.tip_retinere=@subtipretinere) then 'Subtipul de retinere selectat este folosit in Beneficiar retineri!' else '' end)
	if @mesajEroare=''	
		delete from tipret where subtip=@subtipretinere
	else 
		raiserror(@mesajEroare, 16, 1)

end try
begin catch
	set @mesaj=ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror(@mesaj, 11, 1)
end catch