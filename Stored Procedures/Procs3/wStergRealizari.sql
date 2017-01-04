
CREATE procedure wStergRealizari @sesiune varchar(50), @parXML xml  
as
	declare @id int
	
	set @id=@parXML.value('(/row/@id)[1]','int')
	
	if exists(select 1 from pozRealizari where idRealizare=@id)
	begin
		raiserror('(wStergRealizari)Documentul are pozitii!',11,1)
		return 
	end	
	
	delete from Realizari where id=@id