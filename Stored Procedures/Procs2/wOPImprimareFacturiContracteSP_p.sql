
CREATE PROCEDURE wOPImprimareFacturiContracteSP_p @sesiune varchar(50), @parXML xml
AS

DECLARE @utilizator varchar(50), @datajos datetime, @datasus datetime,
		@factura varchar(20), @idContract int, @formular varchar(50), @tipContract varchar(2),
		@caleFormular varchar(500), @nrFacturi int, @mesajeXml xml
		,@valuta VARCHAR(20), @punct_livrare VARCHAR(20), @tert VARCHAR(20), @lm VARCHAR(20), @gestiune VARCHAR(20)
		,@idContractFiltrat int

SET @tipContract = isnull(@parXML.value('(/*/@tip)[1]', 'varchar(2)'),'') -- filtrare dupa tip contract
SET @factura = isnull(@parXML.value('(/*/@factura)[1]', 'varchar(20)'),'') -- filtrare dupa factura
SET @idContractFiltrat = isnull(@parXML.value('(/*/@idContract)[1]', 'int'),0) -- filtrare un contract
SET @dataJos = isnull(@parXML.value('(/*/@datajos)[1]', 'datetime'),'1901-01-01') -- data inferioara pt. filtrare
SET @dataSus = isnull(@parXML.value('(/*/@datasus)[1]', 'datetime'),'2999-01-01') -- data superioara pt. filtrare
SET @tert = isnull(@parXML.value('(/*/@tert)[1]', 'varchar(20)'),'') -- filtru tert
SET @punct_livrare = isnull(@parXML.value('(/*/@punct_livrare)[1]', 'varchar(20)'),'') -- filtru punct livrare in cadrul tertului
SET @lm = ISNULL(@parXML.value('(/*/@lm)[1]', 'varchar(20)'),'') 
SET @gestiune = ISNULL(@parXML.value('(/*/@gestiune)[1]', 'varchar(20)'),'')
SET @valuta = ISNULL(@parXML.value('(/*/@valuta)[1]', 'varchar(20)'),'') -- filtru valuta
SET @formular = ISNULL(@parXML.value('(/*/@formular)[1]', 'varchar(50)'), '')

--IF OBJECT_ID('tempdb.dbo.#facturi') IS NOT NULL DROP TABLE #facturi
create table #facturi (factura varchar(20), data_facturii datetime, tert varchar(20)
	, subunitate varchar(10), tip varchar(2), numar varchar(20), data datetime
	, idContract int, numar_contract varchar(20))

if @parXML.exist('(/*/facturi)[1]')=1
	insert into #facturi
	select   
		xFact.row.value('@factura', 'varchar(20)') as factura,
		try_convert(datetime,xFact.row.value('@data_facturii', 'varchar(10)'),101) as data_facturii,
		xFact.row.value('@tert', 'varchar(20)') as tert,
		xFact.row.value('@subunitate', 'varchar(10)') as subunitate,
		xFact.row.value('@tip', 'varchar(2)') as tip,
		xFact.row.value('@numar', 'varchar(20)') as numar,
		xFact.row.value('@data', 'datetime') as data,
		xFact.row.value('@idContract', 'int') as idContract,
		xFact.row.value('@numar_contract', 'varchar(20)') as numar_contract
	--into #facturi
	from @parXML.nodes('/*/facturi/row') as xFact(row)
else
	insert into #facturi
	SELECT Factura=max(p.Factura), Data_facturii=max(p.Data_facturii), Tert=max(p.Tert)
		, p.Subunitate, p.Tip, p.Numar, p.Data
		, idContract=max(c.idContract), numar_contract=max(c.numar)--, pc.idPozContract
	--INTO #facturi
	FROM pozdoc p
	INNER JOIN LegaturiContracte lc ON lc.idPozDoc = p.idPozDoc
	INNER JOIN PozContracte pc ON pc.idPozContract = lc.idPozContract
	INNER JOIN Contracte c ON c.idContract = pc.idContract
	WHERE c.tip = @tipContract
		AND (p.Data BETWEEN @datajos AND @datasus)
		AND (@factura = '' OR p.Factura = @factura)
		and (@idContractFiltrat=0 or c.idContract = @idContractFiltrat)
		and (@tert='' or c.tert = @tert)
		and (@punct_livrare='' or c.punct_livrare = @punct_livrare)
		and (@lm='' or c.loc_de_munca = @lm)
		and (@gestiune='' or c.gestiune = @gestiune)
		and (@valuta='' and isnull(c.valuta,'')='' or c.valuta = @valuta)
	GROUP BY p.Subunitate, p.Tip, p.Numar, p.Data
if @sesiune='' select * from #facturi
IF (SELECT COUNT(1) FROM #facturi) = 0
	RAISERROR('Nu exista contracte facturate in aceste conditii!', 16, 1)

/** Unele autocomplete-uri tin cont de aceste atribute,
	de aceea trimitem blank. */
	--date pentru form
	SET @parXML.modify('insert attribute formular {"FPDF"} into (/*[1])')
	SET @parXML.modify('insert attribute separate {"1"} into (/*[1])')

	select --@parXML 
		convert(varchar(10),@dataJos,101) as datajos ,convert(varchar(10),@dataSus,101)  datasus
		, convert(decimal(17,5),0) as curs, @valuta as valuta ,@factura as factura, nullif(@idContractFiltrat,0) as idContract, @tert as tert, @punct_livrare as punct_livrare, @lm as lm
		,@gestiune as gestiune
		, 'FPDF' as formular, 0 as separate
	for xml raw, root('Date')	
	
	--date pentru grid
	SELECT (   
		SELECT p.tip,p.numar,p.data,
			p.idContract, --p.idPozContract,
			p.numar_contract,
			p.tert, RTRIM(t.Denumire) as dentert,
			p.factura, convert(varchar(10),p.Data_facturii,103) as data_facturii,
			ales=1
		FROM  #facturi p
			inner join terti t on t.subunitate='1' and t.Tert=p.tert
		order by p.factura--t.Denumire,p.idContract,row_number() over (partition by p.idContract order by p.factura)
		FOR XML RAW, TYPE  
		)  
	FOR XML PATH('DateGrid'), ROOT('Mesaje')