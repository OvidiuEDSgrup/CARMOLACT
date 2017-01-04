
CREATE PROCEDURE wIaFolSalariati @sesiune varchar(30), @parXML xml
AS
BEGIN
	DECLARE @marca varchar(9)
	SELECT @marca = isnull(@parXML.value('(/row/@marca)[1]', 'varchar(9)'), '')  

	SELECT TOP 100 a.Tip_gestiune AS tip_gestiune, RTRIM(a.Cod_gestiune) AS cod_gestiune, RTRIM(a.cod) AS cod, RTRIM(a.cont) AS cont,
		CONVERT(varchar(10), a.Data, 101) AS data, CONVERT(varchar(10), a.Data_ultimei_iesiri, 101) AS data_ultimei_iesiri, CONVERT(decimal(12,4), a.Pret) AS pret,
		RTRIM(Cod_intrare) AS cod_intrare, CONVERT(decimal(12,4), Intrari) AS intrari, CONVERT(decimal(12,4), Iesiri) AS iesiri, CONVERT(decimal(12,4), a.stoc) AS stoc,
		CONVERT(decimal(12,2), TVA_neexigibil) AS tva_neexigibil, RTRIM(a.Loc_de_munca) AS loc_de_munca, RTRIM(n.denumire) as denumire,
		RTRIM(Comanda) AS comanda, RTRIM([contract]) AS [contract], CONVERT(decimal(12,4), Stoc_initial) AS stoc_initial, RTRIM(ISNULL(a.lot, '')) AS lot
	FROM stocuri a 
	LEFT JOIN nomencl n ON n.Cod = a.cod
	WHERE a.Cod_gestiune = @marca
		AND a.Tip_gestiune = 'F'
		AND a.Stoc <> 0
	ORDER BY a.Cod
	FOR XML RAW
END
