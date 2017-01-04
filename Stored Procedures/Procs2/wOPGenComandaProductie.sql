create procedure [dbo].[wOPGenComandaProductie]  @sesiune varchar(50), @parXML XML  
as
	declare @codP varchar(20), @cantitate float,@par xml,@id int,@codSemifabricat varchar(20),@poz bit	
	set @poz= @parXML.exist('/parametri/row/comanda')
	
	if @poz=0
	begin
			
		set @codP=ISNULL(@parXML.value('(/parametri/@cod)[1]', 'varchar(20)'),'')
		set @cantitate=ISNULL(@parXML.value('(/parametri/@cantitate)[1]', 'varchar(20)'),'')
		set @par= (select @codP as codP, @cantitate as cantitate, 'CP' as tipL,'M' as tipFundamentare, 
						@parXML.value('(/parametri/@dataJos)[1]', 'datetime') as dataJos, @parXML.value('(/parametri/@dataSus)[1]', 'datetime') as dataSus
					for xml raw)
		--scriere si in dependenteLans in functie de dataSus, dataJos, cod 
		select @par
		exec wScriuPozLansari @sesiune, @par
	end
	else 
		if @poz=1
		begin
			set @codP=ISNULL(@parXML.value('(/parametri/@cod)[1]', 'varchar(20)'),'')
			set @cantitate=ISNULL(@parXML.value('(/parametri/row/@cantitate)[1]', 'varchar(20)'),'')
			set @par= (select @codP as codP, @cantitate as cantitate, 'CP' as tipL,'L' as tipFundamentare,@parXML.value('(/parametri/row/@comanda)[1]', 'varchar(20)') as comandaSingle
						for xml raw)
			--scriere si in dependenteLans in functie de comanda
			select @par
			exec wScriuPozLansari @sesiune, @par
		end
