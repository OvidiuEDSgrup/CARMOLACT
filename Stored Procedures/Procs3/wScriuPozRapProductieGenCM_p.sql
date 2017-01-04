
CREATE PROCEDURE [dbo].[wScriuPozRapProductieGenCM_p] @sesiune VARCHAR(50), @parXML XML
AS

DECLARE @eroare VARCHAR(2000)

SET @eroare = ''

	DECLARE --antet  
		@resursa VARCHAR(20), @data DATE,@dataD varchar(10), @nrdoc VARCHAR(20), @update BIT, @idRealizare INT, @idTehnologie INT, @idPozRealizare 
		INT, --pozitie  
		@cod VARCHAR(20), @cantitate FLOAT, @cm BIT, @pp BIT, @observatii VARCHAR(200), @gestiuneMP VARCHAR(20), @gestiunePF VARCHAR(
			20), @fXML XML, @cons XML, @pred XML, @nrPP VARCHAR(20), @utilizator VARCHAR(20), @semif VARCHAR(20), @comanda VARCHAR(20)
		, @subunitate VARCHAR(20), @detalii XML,@codIntrareL varchar(13),@cantM float, @stocCI float,@cantL float,
		@codIntrareL2 varchar(13),@codIntrareL3 varchar(13),@cantL2 float,@cantL3 float
		
		
	declare @nr varchar(50),@cant float
	select	@nr=@parXML.value('(row/row/@nrPP)[1]','varchar(50)')
	select	@idPozRealizare=@parXML.value('(row/row/@id)[1]','varchar(50)')
	select @cod=@parXML.value('(row/row/@cod)[1]','varchar(50)')
	set @cant=@parXML.value('(row/row/@cantitate)[1]','float')
	select @cantL=
		@cant*(select cantitate from poztehnologii where tip='M' and idp=( select id from pozTehnologii where tip='T' and cod=@cod) and cod='L')
	
	
	select  @nr as nr,cast(@cantL as varchar(10)) as cantL,
	@cod as tehn,CONVERT(DECIMAL(10,2),@cant) as cantitate,
	@idPozRealizare as id
	
	FOR XML RAW, ROOT('Date')
	
	
	SET @nrdoc = @parXML.value('(/row/@nrDoc)[1]', 'varchar(20)')
	SET @resursa = isnull(@parXML.value('(/row/@codRes)[1]', 'varchar(20)'), @parXML.value('(/row/@resursa)[1]', 'varchar(20)'))
	SET @data = isnull(@parXML.value('(/row/@data)[1]', 'datetime'), GETDATE())
	
	
	set @dataD = CAST(@dataD as varchar(10))
	SET @nrPP = @parXML.value('(/row/@nrPP)[1]', 'varchar(20)')
	SET @semif = @cod
	SET @idRealizare = @parXML.value('(/row/@idRealizare)[1]', 'int')
	
	SET @cantitate = isnull(@parXML.value('(/row/row/@cantitate)[1]', 'float'), 0)
	SET @idRealizare = @parXML.value('(/row/row/@id)[1]', 'int')
	SET @codIntrareL = @parXML.value('(/row/@cod)[1]', 'varchar(20)')
	SET @codIntrareL2 = @parXML.value('(/row/@codL2)[1]', 'varchar(20)')
	SET @codIntrareL3 = @parXML.value('(/row/@codL3)[1]', 'varchar(20)')
	set @cantL= isnull(@parXML.value('(/row/@cantL)[1]', 'float'),0)
	set @cantL2= isnull(@parXML.value('(/row/@cantL2)[1]', 'float'),0)
	set @cantL3= isnull(@parXML.value('(/row/@cantL3)[1]', 'float'),0)
	EXEC luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate OUTPUT
	


	SELECT TOP 1 @idTehnologie = id
	FROM pozTehnologii
	WHERE tip = 'T'
		AND cod = @semif
		AND idp IS NULL

	IF (@idTehnologie IS NULL)RAISERROR ('(wScriuPozRapProductie)Nu s-a identificat tehnologia pentru codul ales!', 16, 1)

	set @utilizator=dbo.fIaUtilizator(@sesiune)

	

	IF isnull(@gestiuneMP, '') = ''
		SET @gestiuneMP = (
				SELECT TOP 1 valoare
				FROM proprietati
				WHERE tip = 'utilizator'
					AND cod = @utilizator
					AND Cod_proprietate = 'GESTMP'
				)

	IF rtrim(isnull(@gestiuneMP, '')) = ''
	BEGIN
		SET @eroare = '(wScriuPozRapProductie)Nu s-a gasit gestiune pentru consum!' + CHAR(10) + 
			'Se opereaza in antet sau trebuie sa fie configurata in proprietatile utilizatorului curent, cod proprietate="GESTMP"!'

		RAISERROR (@eroare, 16, 1)
	END
	
	set @cantM=(SELECT  convert(DECIMAL(16, 2), @cantitate * cantitate) 
						FROM pozTehnologii
						WHERE tip = 'M'
							AND cantitate > 0 AND parinteTop = @idTehnologie and cod='L')
	set @stocCI=(select SUM(stoc) from stocuri where cod='L' and Cod_intrare=@codIntrareL)






	
	SELECT  
		(select w.* from  (
			SELECT @data AS '@data', @nrPP AS '@numar',  @idPozRealizare AS '@idRealizare', 
				(select (case when ISNULL(gestiune,'')='' then @gestiuneMP else Gestiune end) from nomencl where cod=poz.cod) AS '@gestiune', 
				rtrim(poz.cod) AS '@cod', RTRIM(nomencl.Denumire) as '@denumire',
				(case when poz.cod='L' then convert(DECIMAL(10, 2), @cantL) else convert(DECIMAL(10, 2), @cantitate * cantitate) end) AS '@cantitate',
				 CONVERT(DECIMAL(10,2),pret) AS '@pstoc', @semif AS '@comanda', @resursa AS '@lm', 
				 (case when poz.cod='L' then @codIntrareL else  '' end)  as '@codintrare'
						FROM pozTehnologii poz
						join nomencl on poz.cod=nomencl.Cod
						WHERE poz.tip = 'M' 
							AND poz.cod<>'L'
							AND cantitate > 0
							AND idp = @idTehnologie) w
							where @cantitate!=0	
						FOR XML path, type
						)
				FOR XML PATH('DateGrid'), ROOT('Mesaje')
				

/*select @cons 
FOR XML RAW

SELECT (   
		select 'test' as numar, '2013-01-01' as data FOR XML RAW, TYPE  
		)  
FOR XML PATH('DateGrid'), ROOT('Mesaje')*/