
CREATE PROCEDURE wScriuGarantiiMateriale @sesiune varchar(50), @parXML xml
AS

DECLARE
	@marca varchar(6), @o_marca varchar(6), @data datetime, @update int, @detalii xml, @mesaj varchar(1000), 
	@lunaInch int, @anulInch int

BEGIN TRY

	SELECT 
		@marca = ISNULL(@parXML.value('(/row/@marca)[1]','varchar(6)'), ''),
		@o_marca = ISNULL(@parXML.value('(/row/@o_marca)[1]','varchar(6)'), @marca),
		@detalii = @parXML.query('(/row/detalii/row)[1]'),
		@update = ISNULL(@parXML.value('(/row/@update)[1]','int'), 0)

	select	@lunaInch=max(case when Parametru='LUNA-INCH' then Val_numerica else 0 end),
			@anulInch=max(case when Parametru='ANUL-INCH' then Val_numerica else 0 end)
	from par where tip_parametru='PS' and parametru in ('LUNA-INCH','ANUL-INCH')

	set @data=dbo.eom(right('0'+ltrim(rtrim(convert(varchar,@lunaInch))),2)+ '/01/'+rtrim(convert(varchar,@anulInch)))+1
	
	update personal set detalii=@detalii
	where marca=@marca

END TRY
BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (wScriuGarantiiMateriale)'
	RAISERROR(@mesaj, 11, 1)
END CATCH