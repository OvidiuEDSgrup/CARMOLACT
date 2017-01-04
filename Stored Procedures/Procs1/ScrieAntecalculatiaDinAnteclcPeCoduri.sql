
CREATE PROCEDURE [dbo].[ScrieAntecalculatiaDinAnteclcPeCoduri] @sesiune VARCHAR(50), @parXML XML
AS
IF EXISTS (
		SELECT *
		FROM sysobjects
		WHERE NAME = 'ScrieAntecalculatiaDinAnteclcPeCoduriSP'
			AND type = 'P'
		)
BEGIN
	EXEC ScrieAntecalculatiaDinAnteclcPeCoduriSP @sesiune = @sesiune, @parXML = @parXML OUTPUT

	RETURN
END

DECLARE @numar VARCHAR(20), @data DATETIME, @elem VARCHAR(20), @id INT, @userASiS VARCHAR(50), @procent FLOAT, @mesaj VARCHAR(500), 
	@valuta VARCHAR(10), @curs FLOAT

BEGIN TRY
	SET @numar = ISNULL(@parXML.value('(/row/@numarDoc)[1]', 'varchar(20)'), '')
	SET @data = ISNULL(@parXML.value('(/row/@data)[1]', 'datetime'), '')
	SET @id = @parXML.value('(/row/@id)[1]', 'int')
	SET @valuta = @parXML.value('(/row/@valuta)[1]', 'varchar(10)')
	SET @curs = @parXML.value('(/row/@curs)[1]', 'float')

	EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @userASiS OUTPUT

	IF @numar = ''
	BEGIN
		DECLARE @NrDocFisc VARCHAR(20), @fXML XML

		SET @fXML = '<row/>'
		SET @fXML.modify('insert attribute tipmacheta {"AT"} into (/row)[1]')
		SET @fXML.modify('insert attribute tip {"LP"} into (/row)[1]')
		SET @fXML.modify('insert attribute utilizator {sql:variable("@userASiS")} into (/row)[1]')

		EXEC wIauNrDocFiscale @fXML, @NrDocFisc OUTPUT

		IF ISNULL(@NrDocFisc, 0) <> 0
			SET @numar = LTrim(RTrim(CONVERT(CHAR(8), @NrDocFisc)))
	END

	IF @id IS NULL --Trebuie inserate elemente
	BEGIN
		INSERT INTO dbo.pozAntecalculatii (tip, cod, cantitate, pret, idp)
		SELECT 'A', @numar, 1, isnull(TP, 0), pt.id
		FROM anteclcpecoduri a
		INNER JOIN dbo.pozTehnologii pt ON pt.tip = 'T'
			AND pt.cod = a.cod

		INSERT INTO dbo.antecalculatii (Cod, Data, Pret, valuta, curs, idPoz, numar)
		SELECT a.cod, @data, isnull(a.TP, 0), @valuta, @curs, pa.id, @numar
		FROM anteclcpecoduri a
		INNER JOIN dbo.pozTehnologii pt ON pt.tip = 'T'
			AND pt.cod = a.cod
		INNER JOIN dbo.pozAntecalculatii pa ON pa.tip = 'A'
			AND pa.cod = @numar
			AND pa.idp = pt.id

		/*Adaugarea materialelor si a manoperei din Tehnologie*/
		INSERT INTO dbo.pozAntecalculatii (tip, cod, cantitate, pret, idp, parinteTop)
		SELECT ptTehn.tip, ptTehn.cod, ptTehn.cantitate, (CASE WHEN ptTehn.tip = 'M' THEN n.Pret_stoc ELSE c.Tarif END
				), pa.id AS idp, pa.id AS parinteTop
		FROM anteclcpecoduri a
		INNER JOIN dbo.pozTehnologii pt ON pt.tip = 'T'
			AND pt.cod = a.cod
		INNER JOIN dbo.pozAntecalculatii pa ON pa.tip = 'A'
			AND pa.cod = @numar
			AND pa.idp = pt.id
		INNER JOIN dbo.pozTehnologii ptTehn ON ptTehn.parinteTop = pt.id
			AND ptTehn.tip IN ('M', 'O')
		LEFT OUTER JOIN dbo.nomencl n ON ptTehn.tip = 'M'
			AND n.cod = ptTehn.cod
		LEFT OUTER JOIN catop c ON ptTehn.tip = 'O'
			AND ptTehn.cod = c.Cod
	END --else facem update in tabela antecalculatii cu pretul nou

	BEGIN
		UPDATE dbo.Antecalculatii
		SET Antecalculatii.Pret = dbo.anteclcpeCoduri.TP
		FROM dbo.anteclcpeCoduri
		WHERE dbo.Antecalculatii.idAntec = @id
			AND dbo.anteclcpeCoduri.cod = dbo.Antecalculatii.cod

		UPDATE dbo.pozAntecalculatii
		SET dbo.pozAntecalculatii.Pret = dbo.anteclcpeCoduri.TP
		FROM dbo.anteclcpeCoduri, pozantecalculatii, dbo.Antecalculatii
		WHERE Antecalculatii.idAntec = @id
			AND dbo.anteclcpeCoduri.cod = dbo.Antecalculatii.cod
			AND pozantecalculatii.id = dbo.Antecalculatii.idPoz
	END

	/*Pentru elementele TIPUL E - facem o parcurgere in bucla cu insertul aferent*/
	DECLARE @nF INT, @cSQL VARCHAR(8000)

	DECLARE cursorelem CURSOR
	FOR
	SELECT element, valoare_implicita
	FROM ##tmpElemAntec
	ORDER BY pas

	OPEN cursorelem

	FETCH NEXT
	FROM cursorelem
	INTO @elem, @procent

	SET @nF = @@FETCH_STATUS

	WHILE @nF = 0
	BEGIN
		SET @cSQL = 'insert into pozAntecalculatii(tip ,cod ,cantitate ,pret ,idp ,parinteTop)
		select ''E'',''' + rtrim(
				@elem) + ''',' + CONVERT(VARCHAR(max), @procent) + ',a.' + rtrim(@elem) + 
			',pa.id,pa.id
			FROM anteclcpecoduri a
		INNER JOIN dbo.pozTehnologii pt ON pt.tip=''T'' AND pt.cod=a.cod
		INNER JOIN dbo.pozAntecalculatii pa ON pa.tip=''A'' AND pa.cod=''' 
			+ @numar + ''' AND pa.idp=pt.id'

		EXEC (@cSQL)

		FETCH NEXT
		FROM cursorelem
		INTO @elem, @procent

		SET @nF = @@FETCH_STATUS
	END

	CLOSE cursorelem

	DEALLOCATE cursorelem

	EXEC wStergAntecalculatiiVechi @sesiune = @sesiune, @parXML = @parXML
END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (ScrieAntecalculatiaDinAnteclcPeCoduri)'

	RAISERROR (@mesaj, 11, 1)
END CATCH
