
CREATE PROCEDURE wOPScadentaMultipla @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	declare
		@furnizor varchar(20), @facturafurn varchar(20), @beneficiar varchar(20), @facturaben varchar(20),
		@sumap varchar(10), @datanoua datetime, @regula varchar(2), @suma_calculata float, @totalcutva float

	select
		@furnizor = @parXML.value('(/*/@furnizor)[1]','varchar(20)'),
		@facturafurn = @parXML.value('(/*/@facturafurn)[1]','varchar(20)'),
		@beneficiar = @parXML.value('(/*/@tert)[1]','varchar(20)'),
		@facturaben = @parXML.value('(/*/@factura)[1]','varchar(20)'),
		@sumap = @parXML.value('(/*/@sumap)[1]','varchar(10)'),
		@totalcutva = @parXML.value('(/*/@totalvaloare)[1]','float'),
		@datanoua = @parXML.value('(/*/@datanoua)[1]','datetime'),
		@regula = @parXML.value('(/*/@regula)[1]','varchar(2)')

/*
	@regula : 
		IB	=	LA INCASARE BENEF
		PD	=	PROCENT SUMA LA DATA

*/
	IF NULLIF(@regula,'') IS NULL
		RAISERROR ('Selectati regula de generare a scadentei!',16,1)

	IF charindex('%',@sumap)<>0
		select	@suma_calculata = @totalcutva * convert(decimal(15,2),replace(@sumap,'%',''))/100.0
	else
		select @suma_calculata = convert(decimal(15,2),@sumap)

	IF @regula = 'IB'
		select @datanoua = '2999-01-01'


	IF @regula = 'PD'
	BEGIN
		select 
			@facturaben = NULL,
			@beneficiar = NULL			
	END

	insert into ScadenteFacturi (tip, tert, factura, data_scadentei, suma, tertf, facturaf, sumaf)
	select 'F', @furnizor, @facturafurn, @datanoua, @suma_calculata, @beneficiar, @facturaben, NULL
		
END TRY
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH
