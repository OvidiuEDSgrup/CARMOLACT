

create procedure wStergOperatiiResursa @sesiune varchar(50), @parXML XML
as
	declare @idRes int, @codOp varchar(20)
	
	set @idRes=isnull(@parXML.value('(/row/@id)[1]','int'),-1)
	set @codOp=isnull(@parXML.value('(/row/row/@cod)[1]','varchar(20)'),'')
	
	delete from OpResurse where idRes=@idRes and cod=@codOp