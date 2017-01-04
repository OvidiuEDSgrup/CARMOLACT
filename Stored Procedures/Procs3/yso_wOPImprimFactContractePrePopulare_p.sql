-- procedura folosita initalizarea operatiei folosita pentru generare facturi.
-- practic resetam atributele care ar fi completate cand se deschide operatia cand e completat un contract.
CREATE PROCEDURE yso_wOPImprimFactContractePrePopulare_p @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	DECLARE @dataJos DATETIME, @dataSus DATETIME, @tipContract VARCHAR(2), @mesaj varchar(50), @idContract int

	SET @tipContract = @parXML.value('(/*/@tip)[1]', 'varchar(2)')
	SET @idContract = @parXML.value('(/*/@idContract)[1]', 'int')
	
	SET @dataJos = dbo.BOM(getdate())
	SET @dataSus = dbo.EOM(getdate())
	
	select @tipContract as tip, convert(char(10), @dataJos, 101) as datajos, convert(char(10), @dataSus, 101) as datasus, 
		'' as factura,'' tert, '' as punct_livrare, '' as lm, '' as gestiune
		,dencontract=(SELECT RTRIM(ct.numar) + '/' + replace(CONVERT(VARCHAR(10), ct.data, 103),'/','-')+'('+rtrim(isnull(t.denumire,''))+')' AS dencontract 
			FROM Contracte ct
				left JOIN gestiuni g ON g.Cod_gestiune = ct.gestiune and g.Subunitate='1'
				left JOIN terti t ON t.tert = ct.tert and t.Subunitate='1'
			WHERE ct.idContract=@idContract)
	for xml raw,root('Date')
	
END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (yso_wOPImprimFactContractePrePopulare_p)'

	RAISERROR (@mesaj, 11, 1)
END CATCH
