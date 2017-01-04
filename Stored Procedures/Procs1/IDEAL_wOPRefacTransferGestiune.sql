--***
create procedure IDEAL_wOPRefacTransferGestiune @sesiune varchar(50)=null, @parXML xml=null, @idRulare int=0
as

if @idRulare=0 -- procedura e apelata din frame
begin		--> aici "se inregistreaza" procedura ca fiind cu operatie lunga; @idrulare e identificator unic al procedurii si se foloseste mai jos
	declare @numeProcedura varchar(500), @procentFinalizat int

	set @numeProcedura = object_name(@@procid)
	set @procentFinalizat=isnull(@parXML.value('(/*/@procentFinalizat)[1]','int') ,0)
	set @idRulare=isnull(@parXML.value('(/*/@idRulare)[1]','int') ,0)

	update asisria.dbo.ProceduriDeRulat set procent_finalizat = isnull(procent_Finalizat,@procentFinalizat) + 2
	where idRulare = @idRulare

	if @parXML.value('(/*/@secundeRefresh)[1]','int') is null
		set @parXML.modify('insert attribute secundeRefresh {"2"} as first into (/*)[1]')

	exec wOperatieLunga @sesiune=@sesiune, @parXML=@parXML, @procedura=@numeProcedura
	return	--> procedura e reapelata automat de job si va sari peste acest "if" deoarece exista deja @idrulare<>0
end

BEGIN TRY

	select @sesiune=p.sesiune, @parXML=p.parXML
	from asisria..ProceduriDeRulat p
	where idRulare=@idrulare  
					--> in continuare are loc partea de lucru efectiv; pentru exemplificare se face o bucla
				-->	in care se demonstreaza cum se poate schimba statusul afisat de frame al operatiei

	declare @datacomanda date, @gestiune varchar(10), @mesajeXml xml

	select @datacomanda = @parXML.value('(/*/@datacomanda)[1]','date'),
		@gestiune = @parXML.value('(/*/@gestiune)[1]','varchar(10)')

	update asisria..ProceduriDeRulat 
		set procent_finalizat=0, statusText='Lucrez...' 
	where idRulare=@idrulare 

	EXECUTE [IDEALCARMOLACT].dbo.[00_REFAC_TRANSFER_GESTIUNE] @datacomanda = @datacomanda, @gestiune = @gestiune

	set @mesajeXml = 
		(select 
			'Operatia s-a finalizat cu succes!' as textMesaj,
			'Finalizare operatie' as titluMesaj
		for xml raw, root('Mesaje'))

	UPDATE p
		SET procent_finalizat=0, statusText = 'Finalizare operatie', mesaje = @mesajeXml
	FROM asisria.dbo.ProceduriDeRulat p
	WHERE p.idRulare = @idRulare
END TRY
BEGIN CATCH
	DECLARE @mesajEroare varchar(500)
	SET @mesajEroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	RAISERROR(@mesajEroare, 16, 1)
END CATCH