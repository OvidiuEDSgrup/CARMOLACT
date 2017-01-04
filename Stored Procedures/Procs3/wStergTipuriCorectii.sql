--***
Create procedure wStergTipuriCorectii @sesiune varchar(50), @parXML xml
as
begin try

	declare @tipcor varchar(13), @mesaj varchar(254), @mesajEroare varchar(254), @subtipcor int
	set @tipcor = @parXML.value('(/row/@tipcor)[1]','varchar(13)')
	set @subtipcor=dbo.iauParL('PS','SUBTIPCOR')
	select @mesaj='', @mesajEroare=''

	select @mesajEroare=
		(case	when @subtipcor=1 and exists (select 1 from subtipcor where tip_corectie_venit=@tipcor) then 'Tipul de corectie selectat este folosit in subtipuri corectii!'
				when @subtipcor=0 and exists (select 1 from corectii r where tip_corectie_venit=@tipcor) then 'Tipul de corectie selectat este folosit in corectii!' else '' end)
	if @mesajEroare=''	
		delete from tipcor where Tip_corectie_venit=@tipcor
	else 
		raiserror(@mesajEroare, 16, 1)

end try
begin catch
	set @mesaj=ERROR_MESSAGE()
	raiserror(@mesaj, 11, 1)
end catch