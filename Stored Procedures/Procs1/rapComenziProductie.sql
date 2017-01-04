
CREATE PROCEDURE rapComenziProductie @dataJos DATETIME, @dataSus DATETIME, @cod VARCHAR(20)
AS
SELECT RTRIM(pl.cod) AS comanda, RTRIM(n.cod) AS codprodus, RTRIM(n.denumire) AS denprodus, CONVERT(VARCHAR(10), c.Data_lansarii, 
		101) AS datalans, CONVERT(DECIMAL(15, 3), pl.cantitate) AS cantlansat, CONVERT(DECIMAL(15, 3), raportat.cant) AS 
	cantraportat, (
		CASE 
			WHEN c.starea_comenzii = 'I'
				THEN 'Inchisa'
			WHEN c.starea_comenzii = 'L'
				THEN 'Lansata'
			ELSE 'Alta'
			END
		) AS starecom, rtrim(rs.descriere) as resursa
FROM pozLansari pl
LEFT JOIN comenzi c ON c.comanda = pl.cod
	AND pl.tip = 'L'
INNER JOIN pozTehnologii pt ON pt.idp IS NULL
	AND pt.tip = 'T'
	AND pt.id = pl.idp
LEFT OUTER JOIN resurse rs on rs.cod=pl.resursa
INNER JOIN nomencl n ON n.cod = pt.cod
OUTER APPLY (
	SELECT isnull(SUM(cantitate), 0) cant
	FROM pozRealizari
	WHERE idLegatura = pl.id and tip='C'
	) raportat
WHERE c.Data_lansarii BETWEEN @dataJos
		AND @dataSus
	AND (
		@cod IS NULL
		OR n.cod = @cod
		)
ORDER BY c.data_lansarii
