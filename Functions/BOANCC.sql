CREATE FUNCTION [BOANCC] ( @nAnCurent NUMERIC=NULL, @nLunaAnCurent NUMERIC=NULL)
RETURNS DATETIME
BEGIN

    DECLARE @dataIncAnCota DATETIME
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
	
	SET @dataIncAnCota=
		CASE WHEN @nLunaAnCurent>= @nParLunaIncaAnCota THEN 
			CAST( CAST( @nAnCurent AS CHAR(4))+ '-'+ CAST( @nParLunaIncaAnCota AS CHAR(2))+ '-'+ '1' AS DATETIME) 
		ELSE CAST( CAST( @nAnCurent-1 AS CHAR(4))+ '-'+ CAST( @nParLunaIncaAnCota AS CHAR(2))+ '-'+ '1' AS DATETIME)
		END
	

    RETURN @dataIncAnCota

END
