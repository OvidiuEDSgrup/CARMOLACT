--***
create procedure wStergCategorii @sesiune varchar(50), @parXML xml
as
begin try

declare @cod varchar(20)
Set @cod = @parXML.value('(/row/@codCat)[1]','varchar(20)')


declare @mesajeroare varchar(100)
set @mesajeroare=''

select @mesajeroare=
  (case	--when exists (select 1 from compcategorii s where s.Cod_Categ=@cod) then 'Categoria are indicatori configurati in ea!'	-->	in loc de eroare se sterge din compcategorii
		when @cod is null then 'Nu a fost trimis codul'
		else '' end)

if @mesajeroare=''
begin
	delete from compcategorii where Cod_Categ=@cod
	delete from categorii where Cod_categ=@cod
end
else 
	raiserror(@mesajeroare, 11, 1)
end try
begin catch
	set @mesajeroare = ERROR_MESSAGE()
	raiserror(@mesajeroare, 11, 1)	
end catch