--***

create procedure wmStornareCod @sesiune varchar(50), @parXML xml
as
	declare 
		@input xml,@idPozDoc int, @cantitate float, @cod varchar(20), @comanda int

	select 
		@comanda=@parXML.value('(/*/@comanda)[1]','int'),
		@idPozDoc=@parXML.value('(/*/@idPozDoc)[1]','int'),
		@cantitate=@parXML.value('(/*/@cantitate)[1]','float')

	select @cod = rtrim(cod) from pozdoc where idPozDoc=@idPozDoc
	
	set @input=
		(
			select 
				c.idContract, c.tip,c.numar,c.data,c.tert,c.gestiune,c.loc_de_munca,c.explicatii,c.punct_livrare,1 fara_luare_date,
				(
				select 
					@cod as cod,convert(char(10),convert(decimal(12,3),-@cantitate)) cantitate,@comanda idContract,
					(select @idPozDoc idSursaStorno for xml raw,type) detalii
				for xml raw,type
				)
			from Contracte c where c.idContract=@comanda
			for xml RAW, type
		)

	exec wScriuPozContracte @sesiune=@sesiune,@parXML=@input

	select 'back(3)' as actiune 
	for xml raw,Root('Mesaje')