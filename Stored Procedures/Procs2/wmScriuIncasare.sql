--***  
/* procedura care afisaza facturile neincasate pe un tert si perimite alegerea facturilor care se vor incasa. */
CREATE procedure wmScriuIncasare @sesiune varchar(50), @parXML xml as  
if exists(select * from sysobjects where name='wmScriuIncasareSP' and type='P')
begin
	exec wmScriuIncasareSP @sesiune, @parXML 
	return 0
end

declare @utilizator varchar(100), @subunitate varchar(9), @tert varchar(30), @serie varchar(50), @numar varchar(50), @suma decimal(12,2), 
		@actiune varchar(50), @msgEroare varchar(1000),  @data datetime, @xml xml, @factura varchar(20), @valoareFactura float, @raspuns varchar(max),
		@contPlata varchar(50), @incasareSuma bit, @listaFacturi varchar(2000),@dData datetime

begin try
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output 

	--citesc date din xml
	select	@incasareSuma=@parXML.exist('(/row/@suma)[1]'), -- verific daca se incaseaza suma sau lista facturi
			@tert=@parXML.value('(/row/@tert)[1]','varchar(20)'),
			@serie=@parXML.value('(/row/@serie)[1]','varchar(100)'),
			@numar=@parXML.value('(/row/@numar)[1]','varchar(100)'),
			@suma=@parXML.value('(/row/@suma)[1]','decimal(12,2)'),
			@actiune=@parXML.value('(/row/@wmScriuIncasare.actiune)[1]','decimal(12,2)'), -- in caz ca se vrea alta actiune...
			@listaFacturi=@parXML.value('(/row/@listaFacturi)[1]','varchar(2000)'),
			@data=@parXML.value('(/row/@data)[1]','datetime')
		
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate output	
	
	select @contPlata = rtrim(dbo.wfProprietateUtilizator('CONTPLIN', @utilizator))

	if isnull(@contPlata,'')=''
	begin
		raiserror('Cont casa nu este configurat pentru utilizatorul curent!',11,1)
	end
	
	/* validari si procesari inainte de luare numar din plaja */
	if @incasareSuma=1
	begin -- validari la incasare suma
		create table #listaFacturi(id int identity primary key, factura varchar(50), suma float)
		
		-- creez cursor facturi pentru a distribui suma pe factura
		-- Curosrul poate fi format in 2 feluri: din total facturi sau doar dintre cele selectate (daca exista)
		declare listaFacturi cursor for
		select rtrim(f.Factura),  f.Valoare+f.TVA_22-f.Achitat,f.data
		from facturi f
		where @listaFacturi is null --dintre toate facturile
		and f.Subunitate=@subunitate and tip=0x46 and tert=@tert and ABS(sold)>0.05
		union all
		select rtrim(f.Factura),  f.Valoare+f.TVA_22-f.Achitat,f.data
		from dbo.Split(@listaFacturi,';') s
		inner join facturi f on s.Item=f.Factura and f.Tip=0x46 and f.Tert=@tert and f.Subunitate=@subunitate
		where @listaFacturi is not null --doar dintre facturile selectate daca exista asa ceva
		order by 3

			
		open listaFacturi
		fetch next from listaFacturi into @factura, @valoareFactura,@dData
		while @@FETCH_STATUS=0 and @suma>0
		begin 
			if @valoareFactura>@suma
				set @valoareFactura=@suma
			set @suma = @suma - @valoareFactura
			
			insert #listaFacturi(factura, suma)
			select rtrim(@factura), @valoareFactura
				
			fetch next from listaFacturi into @factura, @valoareFactura,@dData
		end

		-- verific daca au mai ramas de incasat bani, si nu mai sunt facturi pe sold.
		if @suma>0
			raiserror('Suma depaseste soldul tertului!',11,1)
		
		-- verific daca am gasit cel putin o factura pe care sa fac incasari
		if not exists(select 1 from #listaFacturi)
			raiserror('Tertul nu are facturi scadente!!',11,1)
	end
	else -- validari la incasare lista facturi
		if isnull(@listaFacturi,'')=''
			raiserror('Nici o factura selectata. Alegeti cel putin o factura pentru generare incasare!',11,1)
	
	if @numar is null -- daca nu e completat numarul de chitanta in xml, il iau din plaja de IB
	begin
		declare @serieTMP varchar(50)
		
		set @xml= (select 'IB' tip, @utilizator utilizator for xml raw)
		exec wIauNrDocFiscale @parXML=@xml, @NrDoc=@numar output
	
		if @serie is null set @serie=isnull(@serieTMP,'')
	end
	
	if LEN(@numar)=0
	begin
		raiserror('Numar chitanta nu este completat sau plaja neconfigurata!',11,1)
	end
	set @raspuns=''
	
	-- formare XML pt wScriuPozplin
	if @incasareSuma=1 
	begin -- formez xml pt. incasare suma
		set @raspuns=
			(select 'RE' tip, @contPlata cont, convert(varchar,@data,101) data,
				(select 'IB' '@subtip', l.factura '@factura', @numar '@numar', CONVERT(decimal(12,2),l.suma) '@suma', @tert '@tert'
					from #listaFacturi l for xml path('row'),type)
			  for xml raw)
		if OBJECT_ID('#listaFacturi') is not null
			drop table #listaFacturi
	end
	else -- incasare lista facturi
	begin
		set @raspuns=(
			select 'RE' '@tip', @contPlata '@cont', convert(varchar,getdate(),101) '@data', 
				(select 'IB' '@subtip', rtrim(f.Factura) '@factura', @numar '@numar',
					CONVERT(decimal(12,2),f.Valoare+f.TVA_22-f.Achitat) '@suma', @tert '@tert'
					from dbo.Split(@listaFacturi,';') s
					inner join facturi f on s.Item=f.Factura and f.Tip=0x46 and f.Tert=@tert and f.Subunitate=@subunitate
					for xml path('row'),type
				)
			for xml path('row'))
			
		select '' as listaFacturi for xml raw('atribute'),root('Mesaje')
	end

	-- generare incasare propriu-zisa
	set @xml=convert(xml,@raspuns)
	exec wScriuPozplin @sesiune=@sesiune, @parXML=@xml
	
	declare @formularIncasare varchar(20)
	select @formularIncasare = rtrim(dbo.wfProprietateUtilizator('FORMPLIN', @utilizator))
	if isnull(@formularIncasare,'')<>''
	begin
		-- tiparire chitanta
		set @xml=(select @contPlata cont, convert(varchar(10), GETDATE(),120) data, @numar numar, @tert tert for xml raw )
		exec wmTiparesteChitanta @sesiune=@sesiune, @parXML=@xml
	end
	
	select 'Incasare facturi' as titlu, 'back(2)' as actiune,0 as areSearch  
	for xml raw,Root('Mesaje')

end try
begin catch
		set @msgEroare=ERROR_MESSAGE()+'(wmScriuIncasare)'
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
if OBJECT_ID('#listaFacturi') is not null
	drop table #listaFacturi

-- daca au fost erori, le trimit mai departe aici, dupa inchidere cursor...
if @msgEroare is not null
	raiserror(@msgEroare,11,1)