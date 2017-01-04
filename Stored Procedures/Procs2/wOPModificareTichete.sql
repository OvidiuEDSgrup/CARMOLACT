-- procedura folosita pentru generarea de facturi din contracte.
create procedure wOPModificareTichete @sesiune VARCHAR(50), @parXML XML
AS
begin try
	declare @iDoc int, @utilizator varchar(20), @xml xml, @tip varchar(2), @lmantet varchar(40), @denlmantet varchar(13), @data datetime, @mesaj varchar(1000)
	
	set @lmantet = isnull(@parXML.value('(/*/@lmantet)[1]', 'varchar(40)'),'')
	set @denlmantet = isnull(@parXML.value('(/*/@denlmantet)[1]', 'varchar(40)'),'')
	set @data = isnull(@parXML.value('(/*/@data)[1]', 'datetime'),'')

	exec wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

-->	citire date din gridul de operatii
	exec sp_xml_preparedocument @iDoc OUTPUT, @parXML
	if OBJECT_ID('tempdb..#xmlTichete') IS NOT NULL
		drop table #xmlTichete
	
	SELECT marca, nrtichetecuv, nrtichetesupl, nrtichetestoc, nrticheteret
	INTO #xmlTichete
	FROM OPENXML(@iDoc, '/parametri/DateGrid/row')
	WITH
	(
		marca varchar(20) '@marca'
		,data datetime '@data'
		,nrtichetecuv int '@nrtichetecuv' 
		,nrtichetesupl int '@nrtichetesupl' 
		,nrtichetestoc int '@nrtichetestoc' 
		,nrticheteret int '@nrticheteret' 
	)
	
	EXEC sp_xml_removedocument @iDoc 	

	set @xml = 
		(
		SELECT 
			@lmantet as lmantet, CONVERT(varchar(10),@data,101) as data, 'TC' as tip, 
			(
				SELECT 'TC' as subtip, 
					rtrim(t.marca) as marca,
					--Tichetele suplimentare se vor scrie doar din macheta detaliata pe tipuri, intrucat valoarea tichetului suplimentara poate diferi de cea a tichetului de masa.
					nrtichetecuv, /*nrtichetesupl,*/ nrtichetestoc, nrticheteret	
				from #xmlTichete t
				where abs(t.nrtichetecuv)>0.001 or abs(t.nrtichetestoc)>0.001 or abs(t.nrticheteret)>0.001
				for xml raw,type
				)
			for xml raw,type)

	exec wScriuTichete @sesiune=@sesiune, @parXML=@xml

	/* apelare procedura specifica */
	if exists (select 1 from sysobjects where [type]='P' and [name]='wOPModificareTicheteSP2')
		exec wOPModificareTicheteSP2 @sesiune=@sesiune, @parXML=@parXML
	
end try

begin catch
	set @mesaj = ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror (@mesaj, 11, 1)
end catch
