
CREATE procedure  wOPCopiereTehnNomencl @sesiune varchar(50),@parXML xml
as
	
	--Operatia se va folosi de pe macheta de tehnologii: se introduc date pentru noul cod de nomenclator, iar procedura va asocia si tehnologie
	--acestui cod (pornind de la tehnologia sursa)
	declare
		@codIntrodus varchar(20), @denIntrodus varchar(80), @grupaIntrodus varchar(20),@codTehnSursa varchar(20),
		@docNomencl xml,@docCopiereTehn xml,@mesaj varchar(254),@idTehnologie int, @tipTehnologie varchar(1)
		
	set @codIntrodus= @parXML.value('(/parametri/@cod)[1]','varchar(20)')
	set @denIntrodus= @parXML.value('(/parametri/@cod)[1]','varchar(80)')
	set @grupaIntrodus= @parXML.value('(/parametri/@grupa)[1]','varchar(20)')
	
	set @codTehnSursa= @parXML.value('(/parametri/@cod_tehn)[1]','varchar(20)')
	set @idTehnologie= @parXML.value('(/parametri/@id)[1]','int')
	set @tipTehnologie= @parXML.value('(/parametri/@tip_tehn)[1]','varchar(1)')
	
	
	-- Daca nu se introduce denumire ea va fi indentica cu codul
	
	if isnull(@codIntrodus,'')='' or isnull(@grupaIntrodus,'')='' 
	begin
		raiserror('(wOPCopiereTehnNomencl)Cod sau grupa necompletate!',11,1)
		return 
	end		
	
	if exists(select * from nomencl where cod=@codIntrodus)
	begin
		raiserror('(wOPCopiereTehnNomencl)Codul introdus exista in nomenclator!',11,1)
		return 
	end	
	
	if isnull(@denIntrodus,'')=''
		set @denIntrodus=@codIntrodus
		
	
	set @docNomencl= 
	(
		select 
			@denIntrodus as denumire, @codIntrodus as cod, @grupaIntrodus as grupa,cont as cont,um as um, Cota_TVA as cotatva ,
			pret_vanzare as pretvanznom,pret_stoc as pret_stocn		
		from nomencl where cod=@codTehnSursa
		for xml raw
	)
	
	begin try
		exec wScriuNomenclator @sesiune=@sesiune, @parXML =@docNomencl
	end try
	begin catch
		set @mesaj = ERROR_MESSAGE()
		raiserror(@mesaj, 11, 1)	
	end catch 
	
	set @docCopiereTehn=
	(
		select 
			@codIntrodus as '@codNou',@codTehnSursa as '@codNomencl',@idTehnologie as '@id',@denIntrodus as '@descriereNou',
			@codIntrodus as '@codTehnNou', @tipTehnologie as '@tip_tehn'		
		for xml path('parametri')
	)
	
	begin try
	exec wOPCopiereTehn @sesiune=@sesiune, @parXML =@docCopiereTehn
	end try
	begin catch
		set @mesaj = ERROR_MESSAGE()
		raiserror(@mesaj, 11, 1)	
	end catch