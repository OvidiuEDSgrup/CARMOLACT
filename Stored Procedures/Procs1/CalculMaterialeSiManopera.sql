
CREATE PROCEDURE CalculMaterialeSiManopera @sesiune VARCHAR(50), @parXML XML
OUTPUT AS

IF EXISTS (
		SELECT *
		FROM sysobjects
		WHERE NAME = 'CalculMaterialeSiManoperaSP'
			AND type = 'P'
		)
BEGIN
	EXEC CalculMaterialeSiManoperaSP @sesiune , @parXML OUTPUT

	RETURN
END

DECLARE @calculat INT, @nivel INT, @idAntec INT

SET @calculat = @parXML.value('(/*/@calculat)[1]', 'int')
SET @nivel = @parXML.value('(/*/@nivel)[1]', 'int')
SET @idAntec = @parXML.value('(/*/@id)[1]', 'int')

IF @idAntec IS NULL --facem calculul din tabela de tehnologii
	UPDATE anteclcpeCoduri
	SET Mat = preturi.pretmat, Man = preturi.pretman
	FROM anteclcpeCoduri, (
			SELECT pttop.cod, SUM(CASE WHEN pt.tip = 'M' THEN ISNULL(pt.cantitate * n.Pret_stoc, 0) ELSE 0 END) AS pretmat, SUM(CASE WHEN 
							pt.tip = 'O' THEN ISNULL(pt.cantitate * c.tarif, 0) ELSE 0 END) AS pretman
			FROM dbo.pozTehnologii ptTop
			INNER JOIN dbo.pozTehnologii pt ON pt.parinteTop = ptTop.id
			LEFT OUTER JOIN nomencl n ON pt.tip = 'M'
				AND pt.cod = n.cod
			LEFT OUTER JOIN catop c ON pt.tip = 'O'
				AND pt.cod = c.Cod
			INNER JOIN anteclcpeCoduri reducere ON reducere.nivel = @nivel
				AND reducere.cod = ptTop.cod
			WHERE ptTop.tip = 'T'
			GROUP BY ptTop.cod
			) preturi
	WHERE anteclcpeCoduri.cod = preturi.cod
		AND anteclcpeCoduri.nivel = @nivel
ELSE --facem calculul din tabela de antecalculatii
BEGIN
	UPDATE anteclcpeCoduri
	SET Mat = preturi.pretmat, Man = preturi.pretman
	FROM anteclcpeCoduri, (
			SELECT a.cod, SUM(CASE WHEN pt.tip = 'M' THEN ISNULL(pt.cantitate * pt.pret, 0) ELSE 0 END) AS pretmat, SUM(CASE WHEN pt.tip = 
							'O' THEN ISNULL(pt.cantitate * pt.pret, 0) ELSE 0 END) AS pretman
			FROM dbo.Antecalculatii a
			INNER JOIN dbo.pozAntecalculatii pt ON pt.parinteTop = a.idPoz
			LEFT OUTER JOIN nomencl n ON pt.tip = 'M'
				AND pt.cod = n.cod
			LEFT OUTER JOIN catop c ON pt.tip = 'O'
				AND pt.cod = c.Cod
			WHERE a.idAntec = @idAntec
			GROUP BY a.cod
			) preturi
	WHERE anteclcpeCoduri.cod = preturi.cod
END

SET @calculat = @@ROWCOUNT
SET @parXML = (
		SELECT @calculat calculat
		FOR XML raw
		)
