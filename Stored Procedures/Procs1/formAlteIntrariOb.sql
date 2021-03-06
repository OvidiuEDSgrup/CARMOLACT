﻿/**
	Formularul este folosit pentru a lista Alte intrari obiecte inventar din macheta Intrari/Iesiri -> Alte intrari ob inv. 
				@tip		-	tipul documentului
				@numar - numarul intrarii
				@data - data iesirii

**/
CREATE PROCEDURE formAlteIntrariOb @sesiune VARCHAR(50), @parXML XML, @numeTabelTemp VARCHAR(100)
OUTPUT AS
begin try 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	DECLARE @unitate VARCHAR(100), @tip varchar(2), @numar varchar(20), 
	        @data datetime, @utilizator varchar(20),@cTextSelect nvarchar(max),@debug bit,@mesaj varchar(1000),
			@subunitate varchar(20)
	
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output
	/*Filtre*/
	select	@tip=@parXML.value('(/*/@tip)[1]', 'varchar(2)'),
			@numar=@parXML.value('(/*/@numar)[1]', 'varchar(20)'),
			@data=@parXML.value('(/*/@data)[1]', 'datetime')
			
	EXEC luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate OUTPUT
			
	/** Pragatire prefiltrare din tabela pz pentru a nu lucra cu toata, decat ceea ce este de interes dupa filtre**/
	CREATE TABLE [dbo].[#pzFiltr] ([Numar] [varchar](20) NOT NULL, [Cod] [varchar](20) NOT NULL, [Data] [datetime] NOT NULL, 
		[Gestiune] [varchar](9) NOT NULL, [Cantitate] [float] NOT NULL, [Pret_valuta] [float] NOT NULL, [Pret_de_stoc] [float] NOT NULL, 
		[Adaos] [real] NOT NULL, [Pret_vanzare] [float] NOT NULL, [Pret_cu_amanuntul] [float] NOT NULL, [TVA_deductibil] [float] NOT NULL, 
		[Cota_TVA] [real] NOT NULL, [Cod_intrare] [varchar](13) NOT NULL, [Locatie] [varchar](30) NOT NULL, [Data_expirarii] [datetime] NOT NULL, 
		[Loc_de_munca] [varchar](9) NOT NULL, [Comanda] [varchar](40) NOT NULL, [Barcod] [varchar](30) NOT NULL, 
		[Discount] [real] NOT NULL, [Tert] [varchar](13) NOT NULL, [Factura] [varchar](20) NOT NULL, 
		[Gestiune_primitoare] [varchar](40) NOT NULL, [Numar_DVI] [varchar](25) NOT NULL, [Valuta] [varchar](3) NOT NULL, [Curs] [float] NOT NULL, 
		[Data_facturii] [datetime] NOT NULL, [Data_scadentei] [datetime] NOT NULL, [Contract] [varchar](20) NOT NULL
		)

	INSERT INTO #pzFiltr (
		Numar, Cod, Data, Gestiune, Cantitate, Pret_valuta, Pret_de_stoc, Adaos, Pret_vanzare, Pret_cu_amanuntul, 
		TVA_deductibil, Cota_TVA, Cod_intrare, Locatie, Data_expirarii, Loc_de_munca, Comanda, Barcod, Discount, Tert, 
		Factura, Gestiune_primitoare, Numar_DVI, Valuta, Curs, Data_facturii, Data_scadentei, Contract
		)
	SELECT rtrim(Numar), rtrim(Cod), Data data, max(rtrim(Gestiune)), sum(Cantitate), max(Pret_valuta), max(Pret_de_stoc), 
		MAX(Adaos), max(Pret_vanzare), max(Pret_cu_amanuntul), sum(TVA_deductibil), max(Cota_TVA), MAX(rtrim(Cod_intrare)), 
		MAX(rtrim(Locatie)), max(Data_expirarii), max(Loc_de_munca), max(rtrim(Comanda)), max(rtrim(Barcod)), 
		max(Discount), max(rtrim(pz.Tert)), max(rtrim(Factura)), max(rtrim(Gestiune_primitoare)), max(Numar_DVI), max(Valuta), 
		max(Curs), max(Data_facturii), max(Data_scadentei), MAX(rtrim(Contract))
	FROM pozdoc pz
	
	WHERE pz.subunitate = @subunitate
		AND pz.tip = @tip
		AND pz.data = @data
		AND pz.numar = @numar
	group by pz.numar, pz.data, pz.cod

	create index IX1 on #pzfiltr(numar,data)
	create index IX2 on #pzfiltr(cod)
	--create index IX3 on #pzfiltr(cantitate, pret_valuta)
	
	SELECT @unitate = rtrim(val_alfanumerica) FROM par WHERE tip_parametru = 'GE' AND parametru = 'NUME'
			
	/** Selectul principal	**/
	SELECT 
	@unitate UNITATE,
	convert(CHAR(10),pz.data,103) as DATA,
	pz.numar as DOC,
	ltrim(pz.gestiune) as PRED,
	pz.loc_de_munca as LM,
	row_number() OVER(ORDER BY pz.cod) as NR,
	rtrim(pz.cod) as COD,
	n.denumire as DENUMIRE,
	n.um as UM,
	rtrim(pz.cod_intrare) as CODI,
	left(convert(char(14),convert(money,round(pz.cantitate,3)),2),13) as CANT,
	left(convert(char(17),convert(money,round(pz.pret_de_stoc,2)),2),16) as PRET,
	ltrim(convert(char(16),convert(money,round(pz.cantitate*pz.pret_de_stoc,2)),1)) as VALOARE,
	convert(char(17),convert(money,round((select (sum(p.pret_de_stoc*p.cantitate)) from #pzFiltr p ),2)),1) as TOTAL


	into #selectMare
	FROM 
	#pzFiltr pz
	LEFT JOIN nomencl n on n.Cod=pz.Cod

	select * from #selectMare
	
	SET @cTextSelect = '
	SELECT *
	into ' + @numeTabelTemp + '
	from #selectMare
	ORDER BY Data,DOC,cod
	'

	EXEC sp_executesql @statement = @cTextSelect

	/** 
		Daca sunt lucruri specifice de tratat ele vor fi evidentiate in procedura formFacturaSP1
		prin interventie asupra tabelului @numeTabelTemp (fie alterari ale datelor, fie coloane noi, samd )
	**/
	if exists (select 1 from sysobjects where type='P' and name='formAlteIntrariObSP1')
	begin
		exec formAlteIntrariObSP1 @sesiune=@sesiune, @parXML=@parXML, @numeTabelTemp=@numeTabelTemp output
	end

	IF @debug = 1
	BEGIN
		SET @cTextSelect = 'select * from ' + @numeTabelTemp

		EXEC sp_executesql @statement = @cTextSelect
	END
end try
begin catch
	set @mesaj=ERROR_MESSAGE()+ ' (formAlteIntrariOb)'
	raiserror(@mesaj, 11, 1)
end catch
