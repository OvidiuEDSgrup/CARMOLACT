--***
CREATE procedure wmAlegCodStornare @sesiune varchar(50), @parXML xml
as--***

	declare 
		@utilizator varchar(50),@idComanda int, @mesaj varchar(5000), @cod varchar(20), @tert varchar(20)
	set transaction isolation level READ UNCOMMITTED

	begin try
		exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output  
		if @utilizator is null 
			return -1

		select
			@cod= @parXML.value('(/row/@cod)[1]', 'varchar(20)'),
			@idComanda=@parXML.value('(/row/@comanda)[1]', 'int')

		select top 1 
			@tert=tert from Contracte where idContract=@idComanda

		if @idComanda=0
				raiserror('Comanda nu poate fi identificata.', 11, 1)
	
		if @cod is null -- pentru alegere cod apelam wmNomenclator, care apeleaza iar aceasta procedura.
		begin
			if @parXML.exist('(/row/@wmNomenclator.procdetalii)[1]')=1
				set @parXML.modify('replace value of (/row/@wmNomenclator.procdetalii)[1] with "wmAlegCodStornare"')                     
			else           
				set @parXML.modify ('insert attribute wmNomenclator.procdetalii {"wmAlegCodStornare"} into (/row)[1]') 

			if @parXML.exist('(/row/@wmNomenclator.tipdetalii)[1]')=1
				set @parXML.modify('replace value of (/row/@wmNomenclator.tipdetalii)[1] with "C"')                     
			else           
				set @parXML.modify ('insert attribute wmNomenclator.tipdetalii {"C"} into (/row)[1]') 

			exec wmNomenclator @sesiune=@sesiune,@parXML=@parXML
		
			return 0
		end
	
		select
			d.idPozDoc cod,d.idPozDoc idPozDoc, 'Factura '+RTRIM(d.numar)+' / Data facturii; '+ CONVERT(varchar(10), d.Data, 103) denumire, 
			 ' Cod intrare: '+rtrim(d.cod_intrare) + ' / Cantitate '+ convert(varchar(10),convert(decimal(15,2),d.cantitate))  info, 
			convert(decimal(15,2),d.cantitate) cantitate
		from pozdoc d
		where d.Subunitate='1' and d.Tip in ('AS','AP') and d.tert=@tert and d.Cod=@cod
		for xml raw, ROOT('Date')

		select 
			'wmStornareCod' as detalii,0 as areSearch, 'Alege factura' as titlu,
			'D' as tipdetalii, 1 as _toateAtr,
			dbo.f_wmIaForm('MD')  as 'form'
		for xml raw,Root('Mesaje')
	
	end try
	begin catch
		set @mesaj = ERROR_MESSAGE()+' (wmAlegCodStornare)'
	end catch

	if LEN(@mesaj)>0
		raiserror(@mesaj, 16, 1)
