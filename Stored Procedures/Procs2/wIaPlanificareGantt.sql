
CREATE PROCEDURE [dbo].[wIaPlanificareGantt] @sesiune VARCHAR(50), @parXML XML
AS
DECLARE @dataJos DATETIME, @dataSus DATETIME, @cautare VARCHAR(100), @docXML XML, @interventii XML

SET @dataJos = @parXML.value('(/*/@datajos)[1]', 'datetime')
SET @dataSus = @parXML.value('(/*/@datasus)[1]', 'datetime')
SET @cautare = '%' + rtrim(ltrim(isnull(@parXML.value('(/*/@_cautare)[1]', 'varchar(100)'), '%'))) + '%'

IF CHARINDEX('#', @cautare) > 0
	SELECT @cautare = REPLACE(@cautare, '%', '')

SELECT rtrim(s.descriere) + ' (' + rtrim(s.cod) + ')' AS '@utilaj', rtrim(s.cod) AS '@cod_masina', rtrim(s.descriere) AS 
	'@tooltiputilaj', (
		SELECT rtrim(p.comanda) AS '@comanda', CONVERT(VARCHAR(10), p.dataStart, 101) AS '@dataStart', convert(INT, SUBSTRING(
					oraStart, 1, 2)) AS '@oraStart', CONVERT(VARCHAR(10), p.dataStop, 101) AS '@dataStop', convert(INT, SUBSTRING(
					oraStop, 1, 2)) AS '@oraStop', rtrim(isnull(cp.Denumire, '')) AS '@denoperatie', convert(INT, SUBSTRING(
					oraStart, 3, 2)) AS '@minutStart', convert(INT, SUBSTRING(oraStop, 3, 2)) AS '@minutStop', CONVERT(DECIMAL(15, 2
				), p.cantitate) AS '@cantitate', p.id AS '@id', rtrim(cp.Cod) AS '@operatie', rtrim(com.Tip_comanda) AS '@tip', RTRIM
			(com.Starea_comenzii) AS '@stare', (
				CASE WHEN com.Starea_comenzii = 'S' THEN 'Simulare' + CHAR(13) WHEN com.Tip_comanda = 'X' THEN 'Interventie' + CHAR(13) 
					ELSE '' END
				) AS '@tooltip', (CASE com.Starea_comenzii WHEN 'L' THEN 'Lansata' WHEN 'S' THEN 'Simulata' END) AS 
			'@starecomanda', (CASE com.tip_comanda WHEN 'X' THEN 'Interventie' WHEN 'P' THEN 'Productie' END) AS 
			'@tipcomanda', 'Alte informatii' AS '@info'
		FROM planificare p
		INNER JOIN pozLansari pz ON pz.tip = 'O'
			AND pz.id = p.idOp
		INNER JOIN catop cp ON cp.Cod = pz.cod
		INNER JOIN comenzi com ON com.Comanda = p.comanda
			AND com.Tip_comanda IN ('P', 'X') and com.Starea_comenzii in ('L','S')
		INNER JOIN pozLansari ln ON ln.cod = com.Comanda
			AND ln.tip = 'L'
		WHERE (
				p.resursa = s.cod
				OR ln.resursa = s.cod
				)
			AND (
				p.dataStart BETWEEN @dataJos
					AND @dataSus
				OR p.dataStop BETWEEN @dataJos
					AND @dataSus
				)
			AND (
				com.comanda LIKE @cautare
				OR (
					@cautare = '#S'
					AND com.Starea_comenzii = 'S'
					)
				OR (
					@cautare = '#I'
					AND com.Tip_comanda = 'X'
					)
				OR (
					@cautare = '#L'
					AND com.Starea_comenzii = 'L'
					)
				)
		FOR XML path('Operatie'), root('Planificari'), type
		)
FROM Resurse s
FOR XML path('Resursa'), root('Date')
