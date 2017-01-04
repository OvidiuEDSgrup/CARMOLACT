--***
Create procedure wScriuTipret @sesiune varchar(50), @parXML xml
as 
begin try  

	Declare @subtipretinere varchar(20), @o_subtipretinere varchar(20), @dentipret varchar(80), @tipret varchar(1), 
			@eroare xml, @mesajeroare varchar(100), @subtipret int, @ptUpdate int

	set @subtipret=dbo.iauParL('PS','SUBTIPRET')
	Set @subtipretinere = @parXML.value('(/row/@subtipret)[1]','varchar(13)')
	Set @o_subtipretinere = isnull(@parXML.value('(/row/@o_subtipret)[1]','varchar(13)'),'')
	Set @dentipret = @parXML.value('(/row/@densubtipret)[1]','varchar(30)')
	Set @tipret = @parXML.value('(/row/@tipret)[1]','varchar(1)')
	Set @ptUpdate = isnull(@parXML.value('(/row/@update)[1]','int'),0)

	if exists (select 1 from sys.objects where name='wScriuTipretSP' and type='P')  
		exec wScriuTipretSP @sesiune, @parXML
	else  
		select @mesajeroare = (case 
			when @subtipretinere is null then 'Subtip necompletat!' 
			when @dentipret is null then 'Denumire subtip necompletata!' 
			when @tipret is null then 'Tip retinere necompletat!' 
			when @subtipret=1 and @subtipretinere<>@o_subtipretinere and @ptUpdate=1 
				and exists (select 1 from benret br where br.tip_retinere=@o_subtipretinere) then 'Subtipul de retinere selectat este folosit in Beneficiar retineri!'
			when len(rtrim(@subtipretinere))>1 then 'Subtipul de retinere trebuie sa fie codificat pe un caracter!'
			else '' end)

	if @mesajeroare=''	
	Begin
		if exists (select * from tipret where subtip = @subtipretinere)
		Begin  
			update tipret set tip_retinere = @tipret, Denumire = @DenTipret
			where subtip = @o_subtipretinere
		End  
		else   
		Begin    
			declare @subtip_par varchar(20)    
			if (@subtipretinere is null)  	
				exec wmaxcod 'subtip','tipret',@subtip_par output
			else 
				set @subtip_par=@subtipretinere    
			insert into tipret (subtip, denumire, tip_retinere, obiect_subtip_retinere)  
			values (@subtip_par,@dentipret,@tipret,'')  
		End  
	End
	else
		raiserror(@mesajEroare, 16, 1)

end try  

begin catch
	declare @mesaj varchar(1000)
	set @mesaj=ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror(@mesaj, 16, 1)
end catch
