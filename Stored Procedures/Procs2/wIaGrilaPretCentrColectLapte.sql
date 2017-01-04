CREATE PROCEDURE [dbo].[wIaGrilaPretCentrColectLapte]
	@sesiune varchar(50),
	@parXML xml
AS
DECLARE @userASIS varchar(50), @mesajEroare varchar(500)

BEGIN TRY
	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS output

	SELECT TOP (100) RTRIM(G.Centru_colectare) AS centruColectare, RTRIM(G.Tip_lapte) as tipLapte, CONVERT(varchar(10),G.Data_lunii,101) AS dataLunii,
		CONVERT(decimal(12,5),G.Pret) AS pret, CONVERT(decimal(7,2), G.Procent) AS procent
	FROM GrilaPretCentrColectLapte G
	WHERE 1=1
	FOR XML RAW, ROOT('Date')

END TRY
BEGIN CATCH
	SET @mesajEroare = ERROR_MESSAGE() + '('+OBJECT_NAME(@@PROCID)+')'
END CATCH

