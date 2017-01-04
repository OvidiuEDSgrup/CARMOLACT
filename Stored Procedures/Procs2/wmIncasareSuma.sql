--***  
/* Permite operarea chitantelor. */
CREATE procedure wmIncasareSuma @sesiune varchar(50), @parXML xml as  
--set transaction isolation level READ UNCOMMITTED  a se lasa cu read commited
if exists(select * from sysobjects where name='wmIncasareSumaSP' and type='P')
begin
	exec wmIncasareSumaSP @sesiune, @parXML 
	return 0
end

declare @utilizator varchar(100),@subunitate varchar(9),@stare varchar(10), @tert varchar(30), @raspuns varchar(max),
		@facturaDeIncasat varchar(100), @idPunctLivrare varchar(50), @serie varchar(50), @numar varchar(50), @suma decimal(12,2),
		@actiune varchar(50), @codAles varchar(50), @msgEroare varchar(1000), @dataStr varchar(50), @faraSelect bit

begin try
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output 

	--citesc date din xml
	select	@tert=@parXML.value('(/row/@tert)[1]','varchar(20)'),
			@idPunctLivrare=@parXML.value('(/row/@pctliv)[1]','varchar(100)'),
			@codAles=@parXML.value('(/row/@wmIncasareSuma.cod)[1]','varchar(100)'),
			@serie=@parXML.value('(/row/@serie)[1]','varchar(100)'),
			@numar=@parXML.value('(/row/@numar)[1]','varchar(100)'),
			@suma=@parXML.value('(/row/@suma)[1]','decimal(12,2)'),
			@faraSelect=isnull(@parXML.value('(/row/@faraSelect)[1]','bit'),0), -- la prima intrare in view, auto-selectez linia pt operare suma.
			@dataStr=@parXML.value('(/row/@data)[1]','varchar(10)') -- tratez ca varchar: data nu se prelucreaza aici...
	
	/* Ajung aici dupa operarea serie+numar+suma in macheta tip form; 
	nu genrez direct incasare pentru a permite confirmare suma inainte de tiparire. */
	if @codAles ='.OperareSuma.'
	begin 
		delete from proprietati where Tip='U' and Cod=@utilizator and Cod_proprietate in ('SerieChitMobile', 'UltNumarChitMobile')
		-- in mod normal seria si numarul se da din plaja IB, dar se poate si opera, si atunci se salveaza aici.
		-- se poate folosi daca se incaseaza cu chitanta de mana, dar vrem sa se vada in timp real incasarile pe server.
		if @serie is not null	
			insert proprietati(Tip, Cod, Cod_proprietate, Valoare, Valoare_tupla)
			values ('U', @utilizator, 'SerieChitMobile', @serie, '')
		
		if @numar is not null	
			insert proprietati(Tip, Cod, Cod_proprietate, Valoare, Valoare_tupla)
			values ('U', @utilizator, 'UltNumarChitMobile', @numar, '')
		
		-- returnez atribute spre frame - se salveaza la intoarcere din macheta tip form.
		select @serie serie, @numar numar, @suma suma, @dataStr data, '1' faraSelect for xml raw('atribute'),root('Mesaje')
		
		set @actiune='back(1)'
	end
	else
	if @faraSelect=0
	begin
		-- doar la prima intrare vreau autoselect
		select '1' faraSelect for xml raw('atribute'),root('Mesaje')
		
		select	@actiune='autoSelect',
				@suma=0
		
		select	@serie=(case when p.Cod_proprietate='SerieChitMobile' then rtrim(Valoare) else @serie end ),
				@numar=(case when p.Cod_proprietate='UltNumarChitMobile' then rtrim(Valoare) else @numar end )
		from proprietati p where Tip='U' and Cod=@utilizator and Cod_proprietate in ('SerieChitMobile', 'UltNumarChitMobile')
		
		-- incrementez numarul salvat cu 1. Probabil nu ar trebui salvat ultimul numar decat 
		-- la generare chitanta, nu la operare suma - de schimbat daca va trebui
		if ISNUMERIC(@numar)=1 and @numar>0
			set @numar=convert(varchar,CONVERT(int,@numar)+1)
		
		--set @raspuns=(select @suma suma, @serie serie, @numar numar for xml raw)
	end

	-- formez lista optiuni afisate
	set @raspuns='<Date>' +CHAR(13)+
		(select '.OperareSuma.' cod, isnull(convert(varchar, @suma)+'RON','<Introduc suma>') denumire, 
			'Chitanta:'+@serie+' '+@numar+' din '+convert(char(10),convert(datetime,@dataStr),103) info, 
			@serie serie, @numar numar, @suma suma, @dataStr data,
			'0x000000' as culoare, 'refresh' actiune, 'D' as tipdetalii 
		 for xml raw)+CHAR(13)

	-- daca a completat suma, afisez linie pentru incasare
	if isnull(@suma,0)>0
		set @raspuns=@raspuns+
			( select @suma cod, '@suma' numeatr,'Incasare suma' denumire, 'wmScriuIncasare' procdetalii, 
			'assets/Imagini/Meniu/incasari.png' as poza, '0x0000ff' culoare, 'C' as tipdetalii for xml raw)+CHAR(13)

	-- inchid xml-ul generat si il trimit pe net
	set @raspuns=@raspuns+'</Date>'
	select convert(xml,@raspuns)

	select 'Incasare suma' as titlu, 'wmIncasareSuma' as detalii,0 as areSearch, @actiune actiune,
		'D' tipdetalii, dbo.f_wmIaForm('CH') form
	for xml raw,Root('Mesaje')   

	--select * from tmp_facturi_de_listat
end try
begin catch
		set @msgEroare=ERROR_MESSAGE()
		--raiserror(@msgEroare,11,1)
end catch


-- inchid cursor
begin try
declare @cursorStatus smallint
set @cursorStatus=(select is_open from sys.dm_exec_cursors(0) where name='listaFacturi' and session_id=@@SPID )
if @cursorStatus=1 
	close listaFacturi 
if @cursorStatus is not null 
	deallocate listaFacturi 
end try begin catch end catch

-- daca au fost erori, le trimit mai departe aici, dupa inchidere cursor...
if @msgEroare is not null
	raiserror(@msgEroare,11,1)