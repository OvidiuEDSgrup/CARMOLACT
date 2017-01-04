
CREATE PROCEDURE [dbo].[wIaPozFundamentareLans] @sesiune VARCHAR(50), @parXML XML
AS
IF EXISTS (
		SELECT *
		FROM sysobjects
		WHERE NAME = 'wIaPozFundamentareLansSP'
			AND type = 'P'
		)
BEGIN
	EXEC wIaPozFundamentareLansSP @sesiune = @sesiune, @parXML = @parXML

	RETURN
END

DECLARE @cod VARCHAR(20), @tip VARCHAR(20), @utilizator VARCHAR(20), @subunitate VARCHAR(20), @dataInchisa DATETIME

SET @cod = @parXML.value('(/row/@cod)[1]', 'varchar(20)')

SELECT @dataInchisa = CONVERT(DATETIME, Val_alfanumerica)
FROM par
WHERE Tip_parametru = 'MP'
	AND Parametru = 'DATAINCH'

EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

SELECT RTRIM(t.codp) AS comanda, RTRIM(t.codp) AS denumire, RTRIM(isnull(tt.denumire, '-')) AS tert, CONVERT(VARCHAR(10), pc.Termen, 
		101) AS termen, CONVERT(DECIMAL(15, 3), t.cantitate - p.cantitate) AS cantitate, (
		CASE WHEN c.contract IS NOT NULL
				AND c.tip = 'BK' THEN 'Generat de comanda livrare' WHEN c.contract IS NOT NULL
				AND c.tip = 'BF' THEN 'Generat de contract' ELSE 'Generat de produs' END
		) AS tipNecesar, RTRIM(tt.Tert) AS codtert, c.tip as tipcontract
FROM tmpprodsisemif t
LEFT JOIN con c
	ON c.Contract = t.codp
		AND c.Tip IN ('BK', 'BF')
		AND c.Data >= @dataInchisa
		AND t.tipCon = c.Tip
LEFT JOIN pozcon pc
	ON pc.Tip = c.Tip
		AND pc.Contract = c.Contract
		AND pc.Tert = c.Tert
		AND pc.Data = c.Data
LEFT JOIN terti tt
	ON tt.tert = c.Tert
CROSS APPLY (
	SELECT ISNULL(SUM(pl.cantitate), 0) AS cantitate
	FROM pozLansari pl
	INNER JOIN dependenteLans dp
		ON dp.contract = t.codp
			AND pl.tip = 'L'
			AND pl.cod = dp.comandaleg
			AND pl.idp = t.id
			AND dp.tip = c.tip
	) p
WHERE t.utilizator = @utilizator
	AND t.codNomencl = @cod
	AND (
		(
			c.Contract IS NOT NULL
			AND pc.Cod = @cod
			)
		OR c.Contract IS NULL
		)
FOR XML raw, root('Date')
