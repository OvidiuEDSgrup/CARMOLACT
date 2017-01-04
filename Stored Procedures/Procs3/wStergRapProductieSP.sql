
CREATE procedure [dbo].[wStergRapProductieSP] @sesiune varchar(50), @parXML xml  
as
	declare @id int,@data datetime,@nrPP varchar(10)
	
	set @id=@parXML.value('(/row/@idRealizare)[1]','int')
	set @data=@parXML.value('(/row/@data)[1]','datetime')
	set @nrPP=@parXML.value('(/row/@nrPP)[1]','varchar(10)')
	
	if exists(select 1 from pozdoc where tip='CM' and DATA=@data and Numar=@nrPP)
	begin
		raiserror('(wStergRapProductie)Documentul are generat consumul!',11,1)
		return 
	end	
	/*
	if exists(select 1 from pozRealizari where idRealizare=@id)
	begin
		raiserror('(wStergRapProductie)Documentul are pozitii!',11,1)
		return 
	end	
	*/
	
	delete from Realizari where id=@id
	delete from pozRealizari where idRealizare=@id
	delete from pozdoc where tip='PP' and DATA=@data and Numar=@nrPP
	
