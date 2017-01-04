
CREATE PROCEDURE rapUrmarireMateriale @comanda VARCHAR(20), @datajos DATETIME, @datasus DATETIME, @siInchise INT, @codMaterial 
	VARCHAR(20)
AS
/** Pt teste
declare 
	@comanda VARCHAR(20), @datajos DATETIME, @datasus DATETIME, @siInchise INT, @codMaterial VARCHAR
	(20)

SELECT @comanda = NULL, @datajos = '01/01/2012', @datasus = '01/01/2013', @siInchise = 1, @codMaterial = NULL
*/
SELECT rtrim(pl.cod) AS comanda, RTRIM(mat.cod) AS codMaterial, RTRIM(nommat.Denumire) AS denMaterial, RTRIM(nommat.UM) AS um, RTRIM(
		pzdoc.numar) AS nrCM, convert(DECIMAL(15, 3), mat.cantitate) AS cantitateLansata, isnull(convert(DECIMAL(15, 3), pzdoc.
			cant), 0) AS cantitateConsumata, (CASE WHEN reper.id <> pl.id THEN rtrim(reper.cod) ELSE rtrim(prod.cod) END) AS 
	reper
FROM pozLansari pl
LEFT JOIN comenzi com ON pl.tip = 'L'
	AND com.subunitate = '1'
	AND com.comanda = pl.cod
INNER JOIN pozTehnologii prod ON prod.tip = 'T'
	AND prod.idp IS NULL
	AND prod.id = pl.idp
INNER JOIN nomencl nom ON nom.cod = prod.cod
LEFT JOIN pozLansari mat ON mat.tip = 'M'
	AND mat.parinteTop = pl.id
LEFT JOIN pozLansari reper ON reper.id = mat.idp
LEFT JOIN nomencl nommat ON nommat.cod = mat.cod
OUTER APPLY (
	SELECT pz.numar, isnull(SUM(pz.cantitate), 0) cant
	FROM pozdoc pz
	WHERE pz.Subunitate = '1'
		AND pz.tip = 'CM'
		AND pz.Comanda = pl.cod
		AND pz.Cod = mat.cod
	GROUP BY pz.cod, pz.numar
	) pzdoc
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
		@codMaterial IS NULL
		OR mat.cod = @codMaterial
		)
	AND (
		(
			com.data_lansarii BETWEEN @datajos
				AND @datasus
			)
		OR (com.Data_lansarii IS NULL)
		)
