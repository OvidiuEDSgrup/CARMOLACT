--***
Create procedure wScriuTipuriCorectii @sesiune varchar(50), @parXML xml
as 

if exists (select 1 from sys.objects where name='wScriuTipuriCorectiiSP' and type='P')  
	exec wScriuTipuriCorectiiSP @sesiune, @parXML
else  
begin try  

	Declare @tipcor varchar(2), @denumire varchar(80), @eroare xml, @mesajeroare varchar(100)

	set @tipcor = @parXML.value('(/row/@tipcor)[1]','varchar(2)')
	set @denumire = @parXML.value('(/row/@denumire)[1]','varchar(30)')

	select @mesajeroare = (case when @tipcor is null then 'Tip corectie necompletat!' 
			when @denumire is null then 'Denumire subtip necompletata!' else '' end)

	if @mesajeroare=''
	Begin
		if exists (select * from tipcor where tip_corectie_venit = @tipcor)
		Begin
			update tipcor set Denumire = @denumire
			where tip_corectie_venit = @tipcor
		End
		else
		Begin
			insert into tipcor (tip_corectie_venit, denumire)
			values (@tipcor, @denumire)  
		End  
	End
end try  

BEGIN CATCH  
	declare @mesaj varchar(254)
	set @mesaj=ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@mesaj, 11, 1)
END CATCH  

