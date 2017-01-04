--***
Create procedure wScriuSubtipuriCorectii @sesiune varchar(50), @parXML xml
as 

if exists (select 1 from sys.objects where name='wScriuSubtipuriCorectiiSP' and type='P')  
	exec wScriuSubtipuriCorectiiSP @sesiune, @parXML
else  
begin try  

	Declare @subtip varchar(20), @dentipcor varchar(80), @tipcor varchar(2), @eroare xml, @mesajeroare varchar(100)

	set @subtip = @parXML.value('(/row/@subtipcor)[1]','varchar(13)')
	set @dentipcor = @parXML.value('(/row/@densubtipcor)[1]','varchar(30)')
	set @tipcor = @parXML.value('(/row/@tipcor)[1]','varchar(2)')

	select @mesajeroare = (case when @subtip is null then 'Subtip necompletat!'
	when @dentipcor is null then 'Denumire subtip necompletata!'
	when @tipcor is null then 'Tip corectie necompletat!' else '' end)

	if @mesajeroare=''
	Begin
		if exists (select * from subtipcor where subtip = @subtip)
		Begin
			update subtipcor set tip_corectie_venit = @tipcor, Denumire = @DenTipcor
			where subtip = @subtip
		End
		else
		Begin
			declare @subtip_par varchar(20)
			if (@subtip is null)
				exec wmaxcod 'subtip','subtipcor',@subtip_par output
			else
				set @subtip_par=@subtip

			insert into subtipcor (subtip, denumire, tip_corectie_venit)
			values (@subtip_par,@dentipcor,@tipcor)  
		End  
	End
	--Select @mesajeroare as mesajeroare for xml raw  
end try  

BEGIN CATCH  
	declare @mesaj varchar(254)
	set @mesaj=ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@mesaj, 11, 1)
	--SELECT  ERROR_MESSAGE() AS mesajeroare FOR XML RAW  
END CATCH  

