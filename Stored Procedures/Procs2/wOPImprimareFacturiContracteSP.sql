
CREATE PROCEDURE wOPImprimareFacturiContracteSP @sesiune varchar(50) = NULL, @parXML xml = NULL, @idRulare int = 0
AS

IF @idRulare = 0 -- procedura e apelata din frame
BEGIN
	EXEC wOperatieLunga @sesiune = @sesiune, @parXML = @parXML, @procedura = 'wOPImprimareFacturiContracteSP'
	RETURN
END

BEGIN TRY
	
	DECLARE @utilizator varchar(50), @datajos datetime, @datasus datetime,
		@factura varchar(20), @idContract int, @formular varchar(50), @tipContract varchar(2),
		@caleFormular varchar(500), @nrFacturi int, @mesajeXml xml, @detalii xml, @iDoc int, @separate int

	SELECT @parXML = p.parXML, @sesiune = p.sesiune
	FROM asisria.dbo.ProceduriDeRulat p
	WHERE p.idRulare = @idRulare

	SELECT @datajos = @parXML.value('(/*/@datajos)[1]', 'datetime'),
		@datasus = @parXML.value('(/*/@datasus)[1]', 'datetime'),
		@factura = ISNULL(@parXML.value('(/*/@factura)[1]', 'varchar(20)'), ''),
		@idContract = ISNULL(@parXML.value('(/*/@idContract)[1]', 'int'), 0),
		@tipContract = @parXML.value('(/*/@tip)[1]', 'varchar(2)'),
		@formular = ISNULL(@parXML.value('(/*/@formular)[1]', 'varchar(50)'), ''),
		@separate = ISNULL(@parXML.value('(/*/@separate)[1]', 'int'), '')

	EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT
	
	IF @formular = ''
		RAISERROR('Alegeti unul din formularele asociate facturilor!', 16, 1)

	SELECT @caleFormular = RTRIM(CLWhere) FROM antform WHERE Numar_formular = @formular

		if @parXML.exist('(/*/detalii)[1]')=1
		SET @detalii = @parXML.query('(/*/detalii/row)[1]')

	--citire date din gridul de operatii
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @parXML
	IF OBJECT_ID('tempdb..#xmlPozitii') IS NOT NULL
		DROP TABLE #xmlPozitii
	
	SELECT tip,numar,data,
		isnull(idContract,idContractAntet) as idContract, 
		idPozContract, 
		numar_contract,
		factura,
		datafacturii as data_facturii, 
		tert,
		gestiune,
		ales,
		detalii
	INTO #facturi
	FROM OPENXML(@iDoc, '/*/DateGrid/row')
	WITH
	(
		detalii xml 'detalii/row',
		idContractAntet int '../../@idContract',
		idContract int '@idContract',
		idPozContract	int '@idPozContract',
		numar_contract varchar(20) '@numar_contract',
		tip varchar(2) '@tip',
		numar varchar(20) '@numar',
		data datetime '@data',
		factura varchar(20) '@factura',
		datafacturii datetime '@datafacturii',
		tert varchar(20) '@tert',
		gestiune varchar(20) '@gestiune',
		dengestiune varchar(20) '@dengestiune',
		ales bit '@ales'
	)
	
	EXEC sp_xml_removedocument @iDoc 

	/** Daca numarul de facturi in functie de tip, numar si data este 1, nu se mai face concatenarea si, in cazul acesta,
		va trebui sa afisam factura generata. */
	SELECT @nrFacturi = COUNT(*) FROM #facturi

	/** Imprimare facturi concatenate */
	DECLARE @facturaJos varchar(50), @facturaSus varchar(50), @crs cursor, @numar varchar(50), @data_facturii datetime, @data datetime,
	@tert varchar(50), @tipdoc varchar(20), @cmdShellCommand nvarchar(4000), @cTextSelect nvarchar(4000),
	@dentert varchar(200), @numeFisier varchar(2000), @counter int, @pathPdfConcat varchar(5000), @numeFisierCuCaleSiExt varchar(5000),
	@numeTabel varchar(500), @nServer varchar(500), @xml xml, @cale varchar(max)

	SELECT @cale = RTRIM(val_alfanumerica) FROM par WHERE Tip_parametru = 'AR' AND Parametru = 'CALEFORM'

	/** In cazul in care CALEFORM nu are backslash la sfarsit, punem ca sa se poata afisa PDF-ul in browser. */
	IF RIGHT(@cale, 1) <> '\'
		SELECT @cale = @cale + '\'

	IF OBJECT_ID('tempdb..#fisiere') IS NOT NULL DROP TABLE #fisiere
	CREATE TABLE #fisiere (numeFisier varchar(500))

	UPDATE p
		SET statusText = 'Generez facturile PDF...'
	FROM asisria.dbo.ProceduriDeRulat p
	WHERE p.idRulare = @idRulare

	/** Identificare facturi */
	SELECT @facturaJos = MIN(RTRIM(Factura)), @facturaSus = MAX(RTRIM(Factura))
	FROM #facturi

	SET @crs = CURSOR LOCAL FAST_FORWARD FOR
	SELECT d.Tip, d.Numar, d.Data, d.Cod_tert, d.Factura, d.Data_facturii, ROW_NUMBER() OVER (ORDER BY d.Factura,d.Numar)
	FROM doc d
		INNER JOIN #facturi p ON d.Subunitate='1' AND d.Tip=p.tip AND p.Numar = d.Numar AND p.Data = d.Data and p.ales=1
			--and d.factura=p.factura and d.data_facturii=p.data_facturii and d.Cod_tert=p.tert
	WHERE d.Factura between @facturaJos and @facturaSus
	ORDER BY d.Factura,d.Numar
	
	OPEN @crs
	WHILE 1 = 1
	BEGIN
		FETCH NEXT FROM @crs INTO @tipdoc, @numar, @data, @tert, @factura, @data_facturii, @counter
		IF (@@FETCH_STATUS <> 0) 
			BREAK 
		
		SET @dentert = ISNULL((SELECT TOP 1 RTRIM(denumire) FROM terti WHERE tert = @tert AND subunitate = '1'), '')
		SET @dentert = RTRIM((CASE WHEN CHARINDEX(' ', @dentert) > 0 THEN LEFT(@dentert, CHARINDEX(' ', @dentert)) ELSE @dentert END))
		
		SET @numeFisier = RTRIM(@numar) + '_' + ltrim(@dentert)

		UPDATE p
			SET statusText = 'Generez formularul ' + CONVERT(varchar, @counter) + ' din ' + CONVERT(varchar, @nrFacturi)
		FROM asisria.dbo.ProceduriDeRulat p
		WHERE p.idRulare = @idRulare

		SET @xml = (
			SELECT @numeFisier AS numeFisier, @caleFormular AS caleRaport, DB_NAME() AS BD
				,@tipdoc AS tip, @numar AS numar, convert(varchar(10), @data, 120) AS data
				,1 AS nrExemplare,	(CASE WHEN @nrFacturi = 1 THEN 0 ELSE 1 END) AS faraMesaje
				-- 0 = o singura factura ==> se va afisa aceasta factura; altfel, se va face concatenarea.
			FOR XML RAW
		)
		EXEC wExportaRaport @sesiune = @sesiune, @parXML = @xml

		INSERT INTO #fisiere(numeFisier) VALUES (@numeFisier + '.pdf')
	END

	CLOSE @crs
	DEALLOCATE @crs

	IF @nrFacturi > 1
	BEGIN
		UPDATE p
			SET statusText = 'Concatenez facturile intr-un PDF mai mare...'
		FROM asisria.dbo.ProceduriDeRulat p
		WHERE p.idRulare = @idRulare

		IF OBJECT_ID('tempdb.dbo.#raspCmdShell') IS NOT NULL DROP TABLE #raspCmdShell
		CREATE TABLE #raspCmdShell (raspunsCmdShell varchar(max))

		SET @pathPdfConcat = REPLACE(@cale, '\formulare\', '\mobria\')
		SET @numeTabel = '##rap_' + REPLACE(NEWID(), '-', '')
		SET @numeFisier =
			'FacturiContracte' + LEFT(REPLACE(CONVERT(varchar(100), NEWID()), '-', ''), 7)

		SET @cTextSelect = 'IF OBJECT_ID(''tempdb.dbo.' + @numeTabel + ''') IS NOT NULL DROP TABLE ' + @numeTabel
		EXEC sp_executesql @statement = @cTextSelect
	
		SET @cTextSelect = 'CREATE TABLE ' + @numeTabel + ' (valoare varchar(max))
		INSERT INTO ' + @numeTabel + '(valoare)
		SELECT ''' + @cale + ''' + numeFisier FROM #fisiere'
		EXEC sp_executesql @statement = @cTextSelect
	
		IF OBJECT_ID('tempdb.dbo.#fisiere') IS NOT NULL DROP TABLE #fisiere
	
		SELECT @nServer = CONVERT(varchar(1000), SERVERPROPERTY('ServerName')),
			@cmdShellCommand = 'bcp "select valoare from ' + @numeTabel + '" queryout "' + @cale + @numeFisier + '.txt" -T -c -t -C UTF-8 -S' + @nServer
	
		INSERT #raspCmdShell
		EXEC xp_cmdshell @cmdShellCommand

		----------------------------------- arhivare zip(daca este cazul) -----------------------------------
		if @separate=1
		begin
			declare @cale7z varchar(1000), @raspunsCmd int, @msgeroare varchar(500)
			-- arhivez fisierul generat
			--print convert(varchar,datediff(millisecond, @dataStart, getdate()))+'Arhivez fisier docx generat...'
			select	@Cale7z=isnull((select rtrim(val_alfanumerica) from par where tip_parametru='AR' and Parametru='Cale7z')
				,'C:\"Program Files"\7-Zip\')
			set @numeFisierCuCaleSiExt=@cale+@numeFisier+'.zip'
			set @cmdShellCommand = @Cale7z+'7z.exe a "'+@numeFisierCuCaleSiExt+'" "@'+@cale + @numeFisier + '.txt"'
			
			truncate table #raspCmdShell
			insert #raspCmdShell
			exec @raspunsCmd = xp_cmdshell @cmdShellCommand
			if @raspunsCmd != 0 /* xp_cmdshell returneaza 0 daca nu au fost erori, sau altfel, codul de eroare 
									la OLE e 0 daca nu au fost erori */
			begin
				set @msgeroare = 'Eroare la scrierea formularului pe hard-disk in locatia: '+ ( 
						case len(@numeFisierCuCaleSiExt) when 0 then 'NEDEFINIT' else @numeFisierCuCaleSiExt end )
				raiserror (@msgeroare ,11 ,1)
			end
			if @sesiune=''
				select * from #raspCmdShell
			set @mesajeXML=(SELECT @numeFisier + '.zip' AS fisier,'wTipFormular' AS numeProcedura, null as dialogSalvare FOR XML RAW, ROOT('Mesaje'))
		end
		----------------------------------- end arhivare zip(daca este cazul) -----------------------------------
		else
		begin
			-- formare comanda pt generare raport
			SET @cmdShellCommand = '' + @pathPdfConcat + 'PdfConcat.exe "' + @cale + @numeFisier + '.txt" "' + @cale + @numeFisier + '.pdf"'

			--select @cmdShellCommand
			INSERT into #raspCmdShell
			EXEC xp_cmdshell @statement = @cmdShellCommand

			/** Afisam formularul concatenat */
			set @mesajeXML=(SELECT @numeFisier + '.pdf' AS fisier, 'wTipFormular' AS numeProcedura FOR XML RAW, ROOT('Mesaje'))
		end

		SET @cTextSelect = 'IF OBJECT_ID(''tempdb.dbo.' + @numeTabel + ''') IS NOT NULL DROP TABLE ' + @numeTabel
			EXEC sp_executesql @statement = @cTextSelect

		IF OBJECT_ID('tempdb.dbo.#raspCmdShell') IS NOT NULL DROP TABLE #raspCmdShell
	END
	ELSE
		SET @mesajeXML = (SELECT @numeFisier + '.pdf' AS fisier, 'wTipFormular' AS numeProcedura FOR XML RAW, ROOT('Mesaje'))

	UPDATE p
		SET statusText = 'Finalizare operatie', mesaje = @mesajeXml
	FROM asisria.dbo.ProceduriDeRulat p
	WHERE p.idRulare = @idRulare

	SELECT @mesajeXML

END TRY
BEGIN CATCH
	DECLARE @mesajEroare varchar(500)
	SET @mesajEroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	RAISERROR(@mesajEroare, 16, 1)
END CATCH