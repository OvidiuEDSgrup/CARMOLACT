
CREATE PROCEDURE wIaPlajeDocumente @sesiune VARCHAR(50), @parXML XML
AS
	set transaction isolation level read uncommitted
	DECLARE 
		@f_tipdocument VARCHAR(20), @f_serie VARCHAR(20), @f_serieinnumar VARCHAR(20), @f_descriere varchar(20), @f_denumire varchar(20)

	select 
		@f_tipdocument = '%' + @parXML.value('(/*/@f_tipdocument)[1]', 'varchar(20)') + '%',
		@f_serie = '%' + @parXML.value('(/*/@f_serie)[1]', 'varchar(20)') + '%',
		@f_serieinnumar = '%' + @parXML.value('(/*/@f_serieinnumar)[1]', 'varchar(2)') + '%',
		@f_descriere = '%' + @parXML.value('(/*/@f_descriere)[1]', 'varchar(20)') + '%',
		@f_denumire = '%' + @parXML.value('(/*/@f_denumire)[1]', 'varchar(20)') + '%'

	if OBJECT_ID('tempdb..#plaje') is not null
		drop table #plaje

	SELECT 
		rtrim(df.tipDoc) AS tipdocument, rtrim(df.serie) AS serie, numarInf AS numarinferior, numarSup AS numarsuperior, ultimulnr AS ultimulnumar, 
		rtrim(cl.denumire) AS denumire, (CASE isnull(df.serieinnumar, 0) WHEN 0 THEN 'Nu' ELSE 'Da' END) AS denserieinnumar, isnull(df.serieinnumar, 0) AS serieinnumar, df.id as idPlaja,
		df.meniu meniupl, df.subtip subtippl, df.descriere descriere, convert(varchar(10), ISNULL(df.dela, '1901-01-01'), 101) dela, convert(varchar(10), ISNULL(df.panala,'2901-01-01'), 101) panala,
		isnull(df.factura,0) factura, df.detalii 
	into #plaje
	FROM docfiscale df
	OUTER APPLY (select top 1 (CASE adf.tipAsociere WHEN 'J' THEN 'Jurnal' WHEN 'U' THEN 'Utilizator' WHEN 'L' THEN 'Loc de munca' WHEN '' THEN 'Unitate' WHEN 'G' 
				THEN 'Grup de utilizatori' when 'C' then 'Configurabil' END	) +  ': ' + adf.cod denumire
		from AsociereDocFiscale adf where adf.id=df.id ) cl
	LEFT JOIN dbo.wfIaTipuriDocumente(null) td ON df.TipDoc = td.tip and ISNULL(df.meniu,'')=ISNULL(td.meniu,'') and ISNULL(df.subtip,'')=ISNULL(td.subtip,'')
	WHERE (
			@f_serieinnumar IS NULL
			OR (CASE isnull(df.serieinnumar, 0) WHEN 0 THEN 'nu' ELSE 'da' END) LIKE @f_serieinnumar
			)
		AND (
			@f_serie IS NULL
			OR df.serie LIKE @f_serie
			)
		AND (
			@f_tipdocument IS NULL
			OR df.tipDoc LIKE @f_tipdocument
			)
		AND (
			@f_descriere IS NULL
			OR df.descriere LIKE @f_descriere
			)
		AND (
			@f_denumire IS NULL
			OR cl.denumire LIKE @f_denumire
			)

	if exists (select * from sysobjects where name='wIaPlajeDocumenteSP' and type='P')
		exec wIaPlajeDocumenteSP @sesiune, @parXML 
	
	select '1' as areDetaliiXml for xml raw, root('Mesaje')
	select * from #plaje FOR XML raw, root('Date')
