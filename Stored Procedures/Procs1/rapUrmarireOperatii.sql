
CREATE PROCEDURE rapUrmarireOperatii @comanda VARCHAR(20), @datajos DATETIME, @datasus DATETIME, @siInchise INT, @codResursa VARCHAR
	(20), @codOperatie VARCHAR(20)
AS
/** Pt teste
declare 
	@comanda VARCHAR(20), @datajos DATETIME, @datasus DATETIME, @siInchise INT, @codResursa VARCHAR
	(20), @codOperatie VARCHAR(20)

SELECT @comanda = NULL, @datajos = '01/01/2012', @datasus = '01/01/2013', @siInchise = 1, @codOperatie = NULL, @codOperatie = NULL
*/
SELECT RTRIM(pl.cod) AS comanda, rtrim(isnull(res.cod, '')) AS codResursa, rtrim(oper.cod) AS codOperatie, RTRIM(ct.denumire) AS 
	denOperatie, max((CASE WHEN reper.id <> pl.id THEN rtrim(reper.cod) ELSE rtrim(prod.cod) END)) AS reper, CONVERT(
		DECIMAL(15, 3), isnull(oper.cantitate, 0)) AS cantLansata, isnull(rlz.cantitate, 0) AS cantRealizata, convert(VARCHAR(10), com.
		Data_lansarii, 103) AS data_lansarii, convert(VARCHAR(10),rr.data,103) as dataDocRealizare, rtrim(rr.nrDoc) as numarDoc,
		RTRIM(com.descriere) as descriereCom
FROM pozLansari pl
LEFT JOIN comenzi com ON pl.tip = 'L'
	AND com.subunitate = '1'
	AND com.comanda = pl.cod
INNER JOIN pozTehnologii prod ON prod.tip = 'T'
	AND prod.idp IS NULL
	AND prod.id = pl.idp
INNER JOIN nomencl nom ON nom.cod = prod.cod
LEFT JOIN pozLansari oper ON oper.tip = 'O'
	AND oper.parinteTop = pl.id
LEFT JOIN pozLansari reper ON reper.id = oper.idp
LEFT JOIN planificare pln ON pln.comanda = pl.cod
	AND pln.idOp = oper.id
LEFT JOIN pozRealizari pr ON pr.tip = 'P'
	AND pr.idLegatura = pln.id
LEFT JOIN realizari rr ON rr.id = pr.idRealizare
LEFT JOIN Resurse res ON res.cod = rr.codResursa
LEFT JOIN catop ct ON ct.cod = oper.cod
LEFT JOIN pozRealizari rlz ON rlz.idRealizare = rr.id
	AND rlz.idLegatura = pln.id
WHERE (
		@comanda IS NULL
		OR pl.cod = @comanda
		)
	AND (
		(
			(
				@siInchise = 0
				AND com.starea_comenzii = 'L'
				)
			OR (
				@siInchise = 1
				AND com.starea_comenzii IN ('L', 'I')
				)
			)
		OR com.Starea_comenzii IS NULL
		)
	AND (
		@codResursa IS NULL
		OR rr.codResursa = @codResursa
		)
	AND (
		@codOperatie IS NULL
		OR oper.cod = @codOperatie
		)
	AND (
		(
			com.data_lansarii BETWEEN @datajos
				AND @datasus
			)
		OR (com.Data_lansarii IS NULL)
		)
GROUP BY pl.cod, res.cod, oper.cod, ct.denumire, oper.cantitate, com.Data_lansarii, rlz.cantitate, rr.data, rr.nrDoc, com.Descriere
