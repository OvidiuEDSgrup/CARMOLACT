--***  
/* adauga/sterge facturi din lista facturilor de incasat, si genereaza incasari facturi  */
CREATE procedure wmIncasareFacturiHandler @sesiune varchar(50), @parXML xml as	
--set transaction isolation level READ UNCOMMITTED  

if exists(select * from sysobjects where name='wmIncasareFacturiHandlerSP' and type='P')
begin
	exec wmIncasareFacturiHandlerSP @sesiune, @parXML 
	return 0
end

declare @utilizator varchar(100), @stare varchar(10), @tert varchar(30), @xmlFinal xml, @linieXML xml, @facturaDeIncasat varchar(100), 
		@msgEroare varchar(500), @idpunctlivrare varchar(100), @listaFacturi varchar(2000), @listaNoua varchar(2000)

begin try
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output 
	
	-- identificare tert din par xml
	select @tert=f.tert, @idPunctLivrare=f.idPunctLivrare
	from dbo.wmfIaDateTertDinXml(@parXML) f

	select	@facturaDeIncasat=@parXML.value('(/row/@factura)[1]','varchar(100)'),
			@listaFacturi=@parXML.value('(/row/@listaFacturi)[1]','varchar(100)')

	-- verific selectarea unei linii din lista.
	if @facturaDeIncasat is null
	begin
		raiserror('Nu ati ales nici o factura din lista!',11,1)
		return -1
	end
	
	-- setez null pt. ca sa nu pun ';' in plus...
	if @listaFacturi = ''
		set @listaFacturi=null
	
	if exists (select 1 from dbo.Split(@listaFacturi,';') s where s.Item=@facturaDeIncasat)
		select @listaNoua=ISNULL(@listaNoua+';','')+s.Item  from dbo.Split(@listaFacturi,';') s where s.Item<>'' and s.Item<>@facturaDeIncasat
	else
		set @listaNoua=ISNULL(@listaFacturi+';','')+@facturaDeIncasat
	
	if @listaNoua is null
		set @listaNoua=''
	
	select @listaNoua as listaFacturi for xml raw('atribute'),root('Mesaje')
	
end try
begin catch
	set @msgEroare='(wmIncasareFacturiHandler)'+ERROR_MESSAGE()
	raiserror(@msgEroare,11,1)
end catch

--select 'Incasare facturi' as titlu, 'back(1)' as actiune,0 as areSearch  
--for xml raw,Root('Mesaje') 
--exec wmIncasareFacturi @sesiune=@sesiune, @parXML= @parXML  


