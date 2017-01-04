
create procedure wStergScadenteFacturi @sesiune varchar(50), @parXML xml
as

declare
	@mesaj varchar(max), @id int

begin try
	select @id = @parXML.value('(/row/row/@id)[1]','int')
	delete from scadentefacturi where id=@id
end try

begin catch
	set @mesaj = error_message() + ' (' + object_name(@@procid) + ')'
	raiserror(@mesaj,16,1)
end catch
