﻿create procedure wStergLansare @sesiune varchar(50), @parXML XML  
as

	declare @comanda varchar(20),@idp int
	set @comanda=@parXML.value('(/row/@comanda)[1]', 'varchar(80)')
	
	delete from dependenteLans where comanda=@comanda
	select @idp=id from pozTehnologii where tip='L' and cod=@comanda
	
	delete from pozTehnologii where parinteTop=@idp
	
	delete from comenzi where Comanda=@comanda
