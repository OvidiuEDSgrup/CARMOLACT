CREATE 
-- ALTER
FUNCTION [dbo].[BOIMPL] ()
RETURNS DATETIME
BEGIN

    DECLARE @dataIncImpl DATETIME
	DECLARE @nAnImpl NUMERIC
	DECLARE @nLunaImpl NUMERIC	
	SET @nAnImpl =ISNULL((SELECT MAX(val_numerica) FROM par WHERE tip_parametru= 'AL' and parametru= 'ANIMPL'),YEAR( GETDATE()))
	SET @nLunaImpl =ISNULL((SELECT MAX(val_numerica) FROM par WHERE tip_parametru= 'AL' and parametru= 'LUNAIMPL'),1)	

	SET @dataIncImpl= CAST( CAST( @nAnImpl AS CHAR(4))+ '-'+ 
							CAST( @nLunaImpl AS CHAR(2))+ '-'+ '1' AS DATETIME) 
--    SET @dataIncLunii = CAST(YEAR(@dataLunii) AS VARCHAR(4)) + '/' + 
--                       CAST(MONTH(@dataLunii) AS VARCHAR(2)) + '/01'

    RETURN @dataIncImpl

END