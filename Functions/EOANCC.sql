CREATE FUNCTION [EOANCC] ( @nAnCurent NUMERIC=NULL, @nLunaAnCurent NUMERIC=NULL)
RETURNS DATETIME
BEGIN

    DECLARE @dataSfAnCota DATETIME
	DECLARE @nParAnCotaCurent NUMERIC
	DECLARE @nParLunaIncaAnCota NUMERIC
--	DECLARE @nAnImpl NUMERIC
--	DECLARE @nLunaImpl NUMERIC	

	SET @nParLunaIncaAnCota= ISNULL((SELECT MAX(val_numerica) FROM par WHERE tip_parametru= 'AL' and parametru= 'LUNINCANC'),1)
	IF @nLunaAnCurent IS NULL
	BEGIN
	SET @nLunaAnCurent=@nParLunaIncaAnCota
	END

	SET @nParAnCotaCurent= ISNULL((SELECT MAX(val_numerica) FROM par WHERE tip_parametru= 'AL' and parametru= 'ANCOTACUR'),2000)
	IF @nAnCurent IS NULL
	BEGIN
	SET @nAnCurent= @nParAnCotaCurent
	END
	
	SET @dataSfAnCota=	DATEADD(yy,1,dbo.BOANCC( @nAnCurent, @nLunaAnCurent))- 1

    RETURN @dataSfAnCota

END
