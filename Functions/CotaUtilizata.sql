CREATE 
-- ALTER
FUNCTION [dbo].[CotaUtilizata] (@nCantUMcota FLOAT, @nCantUGcota FLOAT, @nGradProd FLOAT, @nCoefConvUM FLOAT=NULL)
RETURNS FLOAT
BEGIN

    DECLARE @nCotaUtilizata FLOAT, @nCoefCota FLOAT
	
	IF @nCoefConvUM IS NULL
	BEGIN
		SET @nCoefConvUM = ISNULL( (SELECT MAX( val_numerica) FROM par WHERE tip_parametru= 'AL' and parametru= 'COEFCONVL'),1.03)
	END
	
	SET @nCoefCota = CASE WHEN (ISNULL(@nCantUGcota/ NULLIF(@nCantUMcota,0),0)*10- @nGradProd)>=0 THEN 0.09
					ELSE 0.18 END

	/*SET @nCotaUtilizata= @nCantUMcota+ @nCantUMcota* ISNULL( 0.18/100
						*(NULLIF((ISNULL(@nCantUGcota/ NULLIF( @nCantUMcota, 0)*10,0)- @nGradProd),0) *10), 0)*/

	SET @nCotaUtilizata= @nCantUMcota* (1+ @nCoefCota*0.1
						*(ROUND(ISNULL(@nCantUGcota/ NULLIF(@nCantUMcota,0),0)*10,3)- @nGradProd))

	SET @nCotaUtilizata= ROUND( ISNULL( @nCotaUtilizata,0), 2)

    RETURN @nCotaUtilizata
END