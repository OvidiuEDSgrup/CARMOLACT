CREATE 
-- ALTER
FUNCTION [dbo].[EOANCL] ( @dataLunii    DATETIME , @nLunaIncAnC NUMERIC=NULL)
RETURNS DATETIME
BEGIN

    DECLARE @dataSfAnC DATETIME
--	DECLARE @nLunaIncAnC NUMERIC
--	DECLARE @nAnImpl NUMERIC
--	DECLARE @nLunaImpl NUMERIC	
	IF @nLunaIncAnC IS NULL 
	BEGIN
		SET @nLunaIncAnC=ISNULL((SELECT MAX(val_numerica) FROM par WHERE tip_parametru= 'AL' 
						and parametru= 'LUNINCANC'),1)
	END

	SET @dataSfAnC= DATEADD(yy,1,CAST( CAST( CASE WHEN MONTH(@dataLunii) < @nLunaIncAnC
						THEN YEAR( @dataLunii)- 1
						ELSE YEAR( @dataLunii) END AS CHAR(4))+ '-'+ 
							CAST( @nLunaIncAnC AS CHAR(2))+ '-'+ '1' AS DATETIME))- 1

--    SET @dataIncLunii = CAST(YEAR(@dataLunii) AS VARCHAR(4)) + '/' + 
--                       CAST(MONTH(@dataLunii) AS VARCHAR(2)) + '/01'

    RETURN @dataSfAnC

END