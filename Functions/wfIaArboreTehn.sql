
CREATE FUNCTION [dbo].[wfIaArboreTehn] (@id INT, @cantitate FLOAT = 0)
RETURNS XML
AS
BEGIN

	IF EXISTS (
			SELECT *
			FROM sysobjects
			WHERE NAME = 'wfIaArboreTehnSP'
				AND type = 'FN'
			)
	BEGIN
		RETURN (
				SELECT dbo.wfIaArboreTehnSP(@id, @cantitate)
				)
	END
	DECLARE @tip VARCHAR(1), @idt INT, @codT VARCHAR(20)

	--Daca este tipul R nu vom gasi copii ca si avand IDP ID-ul lui, ci vor fi cu tipul T in pozTehnologii la codul respectiv
	SELECT @tip = tip, @codT = cod
	FROM pozTehnologii
	WHERE id = @id

	--IF @tip = 'R'
	--BEGIN
	--	SET @idt = (
	--			SELECT id
	--			FROM pozTehnologii
	--			WHERE cod = @codT
	--				AND idp IS NULL
	--				AND tip = 'T'
	--			)
	--	SET @id = @idt
	--END
	IF @tip = 'M'
	BEGIN
		IF (
				SELECT tip
				FROM nomencl
				WHERE cod = @codT
				) = 'P'
		BEGIN
			IF (
					SELECT count(1)
					FROM tehnologii
					WHERE codNomencl = @codT
					) > 0
			BEGIN
				SELECT TOP 1 @codT = cod
				FROM tehnologii
				WHERE codNomencl = @codT

				SELECT TOP 1 @id = id
				FROM pozTehnologii
				WHERE tip = 'T'
					AND cod = @codT
			END
		END
	END

	RETURN (
			SELECT (
					CASE WHEN p.tip = 'O' THEN 'Operatie' WHEN p.tip = 'R' THEN 'Reper' WHEN (
								p.tip = 'M'
								AND n.tip = 'P'
								) THEN 'Semifabricat' WHEN p.tip = 'Z' THEN 'Rezultat' ELSE 'Material' END
					) AS _grupare, (
					CASE WHEN p.tip IN ('M', 'Z') THEN rtrim(n.denumire) WHEN p.tip = 'O' THEN rtrim(
									c.Denumire) WHEN p.tip = 'R' THEN RTRIM(isnull(p.detalii.value(
											'(/row/@denumire)[1]', 'varchar(20)'),'')) END
					) AS denumire, (
					CASE WHEN p.tip IN ('M', 'Z') THEN rtrim(n.um) WHEN p.tip = 'O' THEN rtrim(c.um) 
						END
					) AS um, (CASE WHEN p.tip = 'R' THEN 'RS' WHEN p.tip = 'M' THEN 'MT' WHEN p.tip = 'O' THEN 'OP' WHEN p.tip = 'Z' THEN 'RZ' ELSE 'TT' END
					) AS subtip, (
					(
						CASE WHEN p.tip IN ('M', 'Z') THEN rtrim(n.denumire) WHEN p.tip = 'O' 
								THEN rtrim(c.Denumire) ELSE '' END
						) + ' (' + rtrim(p.cod) + ')'
					) AS denumireCod, (
					CASE WHEN p.tip NOT IN ('R', 'M') THEN p.id WHEN (
								p.tip IN ('R', 'M')
								AND p2.id IS NOT NULL
								) THEN p2.id ELSE p.id END
					) AS id, p.id AS idReal, p.idp AS idp, p.parinteTop AS parinteTop, isnull(convert(DECIMAL(10, 2), p.ordine_o), 0) AS 
				ordine, rtrim(p.cod) AS cod, p.idp AS idParinte, ISNULL(convert(DECIMAL(16, 6), p.cantitate_i), 0) AS cant_i, rtrim(p
					.resursa) AS resursa, CONVERT(DECIMAL(12, 3), p.pret) AS pret, p.tip AS tip, (
					CASE WHEN @cantitate > 0 THEN CONVERT(DECIMAL(16, 6), p.cantitate * @cantitate) ELSE convert(DECIMAL(16, 6), p.
								cantitate) END
					) AS cantitate, rtrim(r.descriere) AS denresursa, (
					CASE WHEN (@cantitate > 0) THEN convert(XML, dbo.wfIaArboreTehn(p.id, p.
										cantitate * @cantitate)) ELSE convert(XML, dbo.wfIaArboreTehn(p.id, DEFAULT)) END
					), (case when p.detalii IS not null then p.detalii end) detalii
			FROM pozTehnologii p
			LEFT JOIN poztehnologii p2 ON p2.tip = 'T'
				AND p2.idp IS NULL
				AND p.cod = p2.cod
			LEFT JOIN nomencl n ON n.Cod = p.cod
			LEFT JOIN catop c ON c.Cod = p.cod
			LEFT JOIN resurse r ON r.cod = p.resursa
				AND p.tip = 'O'
				AND r.tip = 'U'
			WHERE p.idp = @id
				AND p.tip NOT IN ('A', 'L', 'E')
			ORDER BY 1 DESC
			FOR XML raw, type
			)
END
