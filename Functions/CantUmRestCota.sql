CREATE FUNCTION [CantUmRestCota] (@nCantUMcota FLOAT, @nCantUGcota FLOAT, @nGradProd FLOAT, 
										@nCotaProd FLOAT, @nGrasMedieAchiz FLOAT=NULL, @nCoefConvUM FLOAT=NULL)
RETURNS FLOAT
BEGIN

    DECLARE @nCotaUtilizata FLOAT
	DECLARE @nCotaRest FLOAT
	DECLARE @nCantUMRestCota FLOAT

	IF @nCoefConvUM IS NULL
	BEGIN
		SET @nCoefConvUM= ISNULL( (SELECT MAX( val_numerica) FROM par WHERE tip_parametru= 'AL' and parametru= 'COEFCONVL'),1.03)
	END

	/*IF @nGrasMedieAchiz  IS NULL
	BEGIN
		SET @nGrasMedieAchiz= ISNULL( (SELECT MAX( val_numerica) FROM par WHERE tip_parametru= 'AL' and parametru= 'PROCGRASS'),3.5)
	END*/
	SET @nGrasMedieAchiz=ROUND(ISNULL(@nCantUGcota/NULLIF(@nCantUMcota,0),0),2)

	SET @nCotaUtilizata= @nCantUMcota+ @nCantUMcota* ISNULL( 0.18/100
						*(NULLIF((ISNULL(@nCantUGcota/ NULLIF( @nCantUMcota, 0)*10,0)- @nGradProd),0) *10), 0)
	SET @nCotaUtilizata= ROUND( ISNULL( @nCotaUtilizata,0), 2)
	SET @nCotaRest= CASE WHEN @nCotaProd- @nCotaUtilizata>0 THEN @nCotaProd- @nCotaUtilizata ELSE 0 END
	SET @nCantUMRestCota = ROUND((@nCotaRest/(1+0.18*@nGrasMedieAchiz-0.018*@nGradProd))/@nCoefConvUM, 2)

    RETURN @nCantUMRestCota
END