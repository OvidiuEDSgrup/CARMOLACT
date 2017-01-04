
CREATE PROCEDURE wStergGarantiiMateriale @sesiune varchar(50), @parXML xml
AS

DECLARE  @mesaj varchar(100), @marca varchar(6), @o_marca varchar(6)

BEGIN TRY

	SELECT 
		@marca = ISNULL(@parXML.value('(/row/@marca)[1]','varchar(6)'), '')
	update personal
		set detalii.modify('delete (/row/@nrsalgm)[1]')
	where marca=@marca
	update personal
		set detalii.modify('delete (/row/@procentgm)[1]')
	where marca=@marca
END TRY
BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (wStergGarantiiMateriale)'
	RAISERROR(@mesaj, 11, 1)
END CATCH