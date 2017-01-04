
create procedure rapFormChitanta (@sesiune varchar(50), @cont varchar(20) = null, @data datetime = null, 
	@numar_pozitie varchar(20) = null, @numar varchar(20) = null, @nrExemplare int = 2, @parXML xml,
	@numeTabelTemp varchar(100) = null output)
as

if object_id('tempdb..#rapFormChitanta') is not null
	drop table #rapFormChitanta

set transaction isolation level read uncommitted

declare @subunitate varchar(20), @utilizatorASiS varchar(50), @facturi varchar(2000), @cate_facturi int, @comandaSQL nvarchar(max),
		@contF varchar(20), @dataF datetime, @numarF varchar(20), @tert varchar(50), @idpozplin int

exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizatorASiS output
exec luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate OUTPUT

if len(@numeTabelTemp) > 0 --## nu se poate trimite in URL 
	set @numeTabelTemp = '##' + @numeTabelTemp
	
if exists (select 1 from tempdb.sys.objects where name = @numeTabelTemp)
begin 
	set @comandaSQL = 'select @parXML = convert(xml, parXML) from ' + @numeTabelTemp + '
	--drop table ' + @numeTabelTemp
	exec sp_executesql @statement = @comandaSQL, @params = N'@parXML as xml output', @parXML = @parXML output
end

begin try
	if exists (select 1 from sysobjects o where o.name='rapFormChitantaSP')
	begin
		exec rapFormChitantaSP @sesiune=@sesiune, @cont=@cont, @data=@data, @numar_pozitie=@numar_pozitie, @numar=@numar, @nrExemplare=@nrExemplare, @parXML=@parXML
		return
	end

	if (@nrExemplare > 4) set @nrExemplare = 4

	select	@contF = @parXML.value('(/row/@cont)[1]','varchar(20)'),
			@dataF = @parXML.value('(/row/@data)[1]','datetime'),
			@numar_pozitie = isnull(@numar_pozitie, @parXML.value('(/row/row/@numar_pozitie)[1]','varchar(20)')),
			@idPozPlin = isnull(@idPozPlin, @parXML.value('(/row/row/@idPozPlin)[1]','int')),
			@numarF = isnull(@parXML.value('(/row/row/@numar)[1]','varchar(20)'), ''),
			@nrExemplare = isnull(@nrExemplare, @parXML.value('(/row/@nrExemplare)[1]','int')),
			@tert = ''
	
	if @numarF = ''
		raiserror('Formularul trebuie apelat pentru o singura pozitie, nu din antet!', 16, 1)

	/** Datele despre firma se vor stoca de acuma incolo in tabela #dateFirma */
	IF OBJECT_ID('tempdb.dbo.#dateFirma') IS NOT NULL DROP TABLE #dateFirma
	
	CREATE TABLE #dateFirma (locm varchar(50))
	EXEC wDateFirma_tabela

	INSERT INTO #dateFirma (locm)
	SELECT ISNULL(d.Loc_de_munca, '') FROM pozplin d WHERE d.idPozPlin = @idPozPlin
	
	EXEC wDateFirma


	select @tert = tert from pozplin p where p.idPozPlin = @idPozPlin

	select @facturi = null, @cate_facturi = 0
	select @facturi = isnull(@facturi, '') + rtrim(isnull(p.factura, '')) + isnull(' din ' + convert(varchar(20), max(f.data), 103), '') + ', ',
			@cate_facturi = @cate_facturi + 1
	from pozplin p 
	left join facturi f on f.Factura = p.factura and p.tert = f.tert and f.tip = 0x46
	where p.Subunitate = @subunitate 
		and p.Cont = @contF 
		and p.data = @dataF 
		and p.numar = @numarF
		and (@tert = '' or p.tert = @tert)
	group by p.factura, f.Data


	select @facturi = left(@facturi, len(@facturi) - 1)
	declare @nr int
	set @nr = 0

	declare @numarator table (nr int)
	while (@nr < @nrExemplare)
	begin
		set @nr = @nr + 1
		insert into @numarator values (@nr)
	end


	select 
		row_number() over (partition by 1 order by max(df.firma)) as nrcrt,
		max(df.firma) as FIRMA, max(df.codFiscal) AS CUI,
		max(df.ordreg) AS ORDREG, max(df.cont) AS CONTBC,
		max(df.banca) AS BANCA, max(df.judet) AS JUDET,
		max(df.adresa) AS ADRESA, max(df.capitalSocial) AS CAPITALS,
		max(rtrim(t.Denumire)) as denTert,
		max(rtrim(t.Adresa)) as adresaTert,
		rtrim(p.Numar) as nrchit,
		p.data, RTRIM(MAX(p.Valuta)) AS valuta,
		SUM(p.Suma) as suma,
		SUM(p.Suma_valuta) AS suma_valuta,
		dbo.Nr2Text(SUM(p.suma)) as sumaStr,
		REPLACE(REPLACE(dbo.Nr2Text(SUM(p.Suma_valuta)), 'Lei', RTRIM(MAX(p.Valuta))), 'Bani', '%') as sumaStrValuta,
		(case when isnull(@facturi, '') = '' then MAX(RTRIM(p.Explicatii)) else 'c. v. fact. ' end) as CE,
		@facturi as factura,
		CONVERT(decimal(12,4), MAX(p.curs)) AS curs,
		max(isnull(rtrim(l.oras), rtrim(t.Localitate))) as localitate,
		max(isnull(rtrim(j.denumire), rtrim(t.Judet))) as judetTert,
		max(rtrim(t.Cod_fiscal)) as cuiTert,
		(select max(rtrim(BANCA3)) from infotert WHERE max(t.Tert) = infotert.Tert AND infotert.Subunitate = @subunitate and infotert.identificator = '') as bancaTert,
		floor((nr * (14 + @cate_facturi))/60) as nr
	INTO #rapFormChitanta
	FROM @numarator nr, pozplin p
	LEFT JOIN terti t on p.Tert = t.Tert
	left join Localitati l on l.cod_oras = t.Localitate
	left join Judete j on j.cod_judet = t.Judet
	LEFT JOIN #dateFirma df ON df.locm = p.Loc_de_munca
	where p.Subunitate = @subunitate 
		and p.Cont = @contF 
		and p.data = @dataF 
		and p.numar = @numarF
		and (@tert = '' or p.tert = @tert)
	GROUP BY p.cont, p.data, p.numar, nr.nr


	if exists (select 1 from sysobjects o where o.name='rapFormChitantaSP1')
		exec rapFormChitantaSP1 @sesiune=@sesiune, @parXML=@parXML, @cont=@cont, @data=@data, @numar_pozitie=@numar_pozitie, @numar=@numar, @nrExemplare=@nrExemplare


	set @comandaSQL = 'select * from #rapFormChitanta'
	exec sp_executesql @statement = @comandaSQL

end try
begin catch
	declare @mesajEroare varchar(500)
	set @mesajEroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@mesajEroare, 16, 1)
end catch
