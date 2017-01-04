
CREATE PROCEDURE wIaFundamentareLans @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @fltDenumire VARCHAR(80), @fltCod VARCHAR(20), @necesarJos FLOAT, @necesarSus FLOAT, @dataJos DATETIME, @dataSus DATETIME, 
	@comenzi XML, @aux XML, @flttip VARCHAR(20), @utilizator VARCHAR(20), @gestiuni VARCHAR(20), @subunitate VARCHAR(50), @nivel 
	VARCHAR(2), @refresh VARCHAR(5), @dataInchisa DATETIME, @cod VARCHAR(20), @dataChar VARCHAR(20)

SELECT @fltDenumire = '%' + REPLACE(isnull((@parXML.value('(/row/@f_denumire)[1]', 'varchar(80)')), ''), ' ', '%'
	) + '%', @fltCod = '%' + REPLACE(isnull((@parXML.value('(/row/@f_cod)[1]', 'varchar(80)')), '%'), ' ', '') + '%', 
	@fltTip = '%' + isnull((@parXML.value('(/row/@f_tip)[1]', 'varchar(20)')), '') + '%', @refresh = isnull(@parXML.
		value('(/row/@_refresh)[1]', 'varchar(5)'), 1), @cod = '%' + REPLACE(isnull((@parXML.value('(/row/@cod)[1]', 'varchar(80)')
				), '%'), ' ', '') + '%'

-- validare utilizator      
EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

-- citire date din par      
EXEC luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate OUTPUT

EXEC luare_date_par 'MP', 'DATAINCH', 0, 0, @dataChar OUTPUT

SELECT @dataInchisa = CONVERT(DATETIME, @dataChar)

IF OBJECT_ID('tmpFundamentareLansare') IS NULL
BEGIN
	CREATE TABLE tmpFundamentareLansare (
		utilizator VARCHAR(20), denumire VARCHAR(80), cod VARCHAR(20), necesar DECIMAL(15, 6), Tip VARCHAR(20), inProd DECIMAL(15, 6)
		, lans DECIMAL(15, 6), cont VARCHAR(20)
		)

	CREATE NONCLUSTERED INDEX idx_tmpFundamentareLansare ON tmpFundamentareLansare (utilizator, cod)
END

IF @refresh = '0'
BEGIN
	IF NOT EXISTS (
			SELECT *
			FROM sysobjects
			WHERE NAME = 'tmpprodsisemif'
			)
	BEGIN
		CREATE TABLE tmpprodsisemif (
			id INT, utilizator VARCHAR(100), tip VARCHAR(1), codNomencl VARCHAR(20), idp INT, codp VARCHAR(20), nivel INT, cantitate 
			DECIMAL(15, 6), tipCon VARCHAR(2)
			)

		CREATE INDEX ptProdSemif ON tmpprodsisemif (utilizator, codNomencl, codp)
	END

	DELETE
	FROM tmpprodsisemif
	WHERE utilizator = @utilizator

	/** Necesarul de produse din Comenzi de livrare [BK] aflate in starea I **/
	INSERT INTO tmpprodsisemif (id, utilizator, tip, codNomencl, idp, codp, nivel, cantitate, tipCon)
	SELECT pt.id AS id, @utilizator AS utilizator, (CASE WHEN LEFT(n.Cont, 3) = '345' THEN 'P' ELSE 'S' END) AS tip, pc.cod AS 
		codNomencl, 0 AS idp, pc.contract AS codp, 0 AS nivel, (CASE c.tip WHEN 'BK' THEN pc.cantitate WHEN 'BF' THEN pc.Cant_aprobata END
			) cantitate, c.tip
	FROM pozcon pc
	INNER JOIN con c ON pc.Subunitate = c.Subunitate
		AND c.Subunitate = @subunitate
		AND c.Tip IN ('BK', 'BF')
		AND c.Data > @dataInchisa
		AND c.Stare = 1
		AND pc.Tip = c.Tip
		AND pc.Contract = c.Contract
		AND pc.Tert = c.Tert
		AND pc.Data = c.Data
		AND (
			(
				c.Tip = 'BK'
				AND ISNULL(c.Contract_coresp, '') = ''
				)
			OR (c.Tip = 'BF')
			)
	INNER JOIN dbo.pozTehnologii pt ON pt.idp IS NULL
		AND pt.tip = 'T'
		AND pt.cod = pc.cod
	INNER JOIN nomencl n ON n.cod = pc.cod

	/** Stergem din tabelul temporar produsele care au deja comenzi de productie lansate si cantitatile sunt suficiente**/
	DELETE t
	FROM tmpprodsisemif t
	INNER JOIN pozTehnologii pCoduri ON pCoduri.idp IS NULL
		AND pCoduri.tip = 'T'
		AND t.codNomencl = pCoduri.cod
		AND t.utilizator = @utilizator
	INNER JOIN nomencl n ON n.Cod = pCoduri.cod
	CROSS APPLY (
		SELECT ISNULL(SUM(pl.cantitate), 0) AS cantitate
		FROM pozLansari pl
		INNER JOIN dependenteLans dp ON dp.contract = t.codp
			AND dp.tip = t.tipCon
			AND pl.tip = 'L'
			AND pl.cod = dp.comandaleg
			AND pl.idp = pCoduri.id
		) p
	WHERE t.cantitate <= p.cantitate

	/** Pentru produsele care trebuie lansate cautam si semifabricatele lor **/
	EXEC FaSemifabricateDinProduse @sesiune = @sesiune, @parXML = @parXML
END

DELETE
FROM parSesiuniRIA
WHERE username = @utilizator

INSERT INTO parSesiuniRIA (username, param, valoare)
VALUES (@utilizator, 'FLTFLANS', @parXML)

DELETE
FROM tmpFundamentareLansare
WHERE utilizator = @utilizator

/** Insert-ul in tabelul de manevra **/
INSERT INTO tmpFundamentareLansare (utilizator, cod, denumire, necesar, inProd, lans, tip, cont)
SELECT @utilizator, t.codNomencl cod, max(RTRIM(n.denumire)), sum(t.cantitate), sum(p.cantitate), sum(t.cantitate) - sum(p.
		cantitate), (CASE WHEN MIN(LEFT(n.Cont, 3)) = '345' THEN 'Produs' ELSE 'Semifabricat' END) AS Tip, max(n.Cont) AS cont
FROM tmpprodsisemif t
INNER JOIN pozTehnologii pCoduri ON pCoduri.idp IS NULL
	AND pCoduri.tip = 'T'
	AND t.codNomencl = pCoduri.cod
	AND t.utilizator = @utilizator
INNER JOIN nomencl n ON n.Cod = pCoduri.cod
CROSS APPLY (
	SELECT ISNULL(SUM(pl.cantitate), 0) AS cantitate
	FROM pozLansari pl
	INNER JOIN dependenteLans dp ON dp.contract = t.codp
		AND pl.tip = 'L'
		AND pl.cod = dp.comandaleg
		AND pl.idp = pCoduri.id
	) p
GROUP BY t.codNomencl

SELECT TOP 100 *
FROM tmpFundamentareLansare
WHERE Cod LIKE @fltCod
	AND Denumire LIKE @fltDenumire
	AND lans > 0
	AND cod LIKE @cod
	AND (CASE WHEN LEFT(cont, 3) = '345' THEN 'Produs' ELSE 'Semifabricat' END) LIKE @flttip
	AND utilizator = @utilizator
ORDER BY cod
FOR XML raw, root('Date')
