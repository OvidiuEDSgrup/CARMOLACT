
CREATE PROCEDURE wIaProprietatiGestiune @sesiune varchar(50), @parXML xml
AS
BEGIN

	DECLARE @gestiune varchar(20)
	SELECT @gestiune = @parXML.value('(/*/@gestiune)[1]','varchar(20)')
	
	IF OBJECT_ID('tempdb.dbo.#propr') IS NOT NULL
		DROP TABLE #propr

	SELECT RTRIM(p.cod_proprietate) AS codproprietate, RTRIM(cp.descriere) AS denproprietate, RTRIM(p.valoare) AS valoare,
		CONVERT(varchar(200), '') AS denumire, cp.validare AS validare, cp.catalog AS catalog
	INTO #propr
	FROM proprietati p
	LEFT JOIN catproprietati cp ON p.cod_proprietate = cp.cod_proprietate 
	WHERE p.cod = @gestiune AND p.Tip = 'GESTIUNE'


	UPDATE p
		SET p.denumire = RTRIM(vp.descriere)
	FROM #propr p
	INNER JOIN valproprietati vp ON p.codproprietate = vp.cod_proprietate AND p.validare = 1 AND vp.valoare = p.valoare


	UPDATE p
		SET p.denumire = RTRIM(t.denumire)
	FROM #propr p
	INNER JOIN terti t ON p.validare = 2 AND p.catalog = 'T' AND p.valoare = t.tert


	UPDATE p
		SET p.denumire = RTRIM(t.denumire_gestiune)
	FROM #propr p
	INNER JOIN gestiuni t ON p.validare = 2 AND p.catalog = 'G' AND p.valoare = t.cod_gestiune


	UPDATE p
		SET p.denumire = RTRIM(t.denumire)
	FROM #propr p
	INNER JOIN lm t ON p.validare = 2 AND p.catalog = 'L' AND p.valoare = t.cod


	UPDATE #propr SET denumire = valoare WHERE ISNULL(denumire, '') = ''


	SELECT * FROM #propr
	FOR XML RAW, ROOT('Date')

END
