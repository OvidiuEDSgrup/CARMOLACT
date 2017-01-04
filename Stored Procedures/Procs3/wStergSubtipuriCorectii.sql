--***
Create procedure wStergSubtipuriCorectii @sesiune varchar(50), @parXML xml
as
begin try

	declare @subtipcorectie varchar(13), @mesaj varchar(254), @mesajEroare varchar(254), @subtipcor int
	set @subtipcorectie = @parXML.value('(/row/@tipcor)[1]','varchar(13)')

	set @subtipcor=dbo.iauParL('PS','SUBTIPCOR')
	select @mesaj='', @mesajEroare=''

	select @mesajEroare=
		(case when @subtipcor=1 and exists (select 1 from corectii r where tip_corectie_venit=@subtipcorectie) then 'Subtipul de corectie selectat este folosit in corectii!' else '' end)
	if @mesajEroare=''	
		delete from subtipcor where subtip=@subtipcorectie
	else 
		raiserror(@mesajEroare, 16, 1)

end try
begin catch
	set @mesaj=ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror(@mesaj, 16, 1)
end catch