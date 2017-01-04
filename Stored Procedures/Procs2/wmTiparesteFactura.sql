--***

create procedure [dbo].[wmTiparesteFactura] @sesiune varchar(50), @parXML xml
as
if exists(select * from sysobjects where name='wmTiparesteFacturaSP' and type='P')
begin
	exec wmTiparesteFacturaSP @sesiune, @parXML 
	return 0
end

set transaction isolation level READ UNCOMMITTED  
begin try
	declare @utilizator varchar(100),@subunitate varchar(9), @tert varchar(30), @stareBkFacturabil varchar(20),
			@idpunctlivrare varchar(100), @comanda varchar(100), @eroare varchar(4000), @data datetime,
			@xml xml, @numarDoc varchar(10), @stare varchar(20), @gestiune varchar(20), @lm varchar(20), @numedelegat varchar(80),
			@codFormular varchar(100)

	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output  

	select	@data=isnull(@parXML.value('(/row/@data)[1]','datetime'),GETDATE()),
			@numarDoc=@parXML.value('(/row/@numar)[1]','varchar(20)')

	select @codFormular= isnull(rtrim(dbo.wfProprietateUtilizator('FormAP', @utilizator)),'')
	if @codFormular=''
		raiserror('Formularul folosit la tiparire factura nu este configurat! Verificati proprietatea FormAP pe utilizatorul curent.',11,1)
	
	-- daca formularul nu contine '/', generez fisier cu wTipFormular; alfel consider ca e formular-raport 
	if charindex('/',@codFormular)=0
	begin 
		set @xml = (select @codFormular nrform, 'AP' tip, @numarDoc numar, convert(varchar,isnull(@data,getdate()),101) data, @tert tert, @gestiune gestiune, '0' debug
				for xml raw)
		exec wTipFormular @sesiune=@sesiune, @parXML=@xml
	end
	else
	begin
		-- generare formular din raport
		set @xml = (select @numarDoc+'.pdf' numeFisier, @codFormular caleRaport, DB_NAME() BD,
			'AP' tip, @numarDoc numar, convert(varchar(10), @data,120) data, '1' nrExemplare
					for xml raw)
		exec wExportaRaport @sesiune=@sesiune, @parXML=@xml
	end
end try
begin catch
	set @eroare=ERROR_MESSAGE() 
	raiserror(@eroare, 16, 1) 
end catch	

-- nu mai trimit mesaj, trimite wTipFormular
--select 'Facturare comanda '+@comanda as titlu, 'wmComandaDeFacturatHandler' as detalii,0 as areSearch, 'back(1)' actiune
--for xml raw,Root('Mesaje')   

