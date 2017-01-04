
CREATE PROCEDURE [dbo].[wScriuPozRapProductieGenCM] @sesiune VARCHAR(50), @parXML XML
AS

DECLARE @eroare VARCHAR(2000)

SET @eroare = ''

	DECLARE --antet  
		@resursa VARCHAR(20), @data DATETIME, @nrdoc VARCHAR(20), @update BIT, @idRealizare INT, @idTehnologie INT, @idPozRealizare 
		INT, --pozitie  
		@cod VARCHAR(20), @cantitate FLOAT, @cm BIT, @pp BIT, @observatii VARCHAR(200), @gestiuneMP VARCHAR(20), @gestiunePF VARCHAR(
			20), @fXML XML, @cons XML, @pred XML, @nrPP VARCHAR(20), @utilizator VARCHAR(20), @semif VARCHAR(20), @comanda VARCHAR(20)
		, @subunitate VARCHAR(20), @detalii XML,@codIntrareL varchar(13),@cantM float, @stocCI float,@cantL float,
		@codIntrareL2 varchar(13),@codIntrareL3 varchar(13),@cantL2 float,@cantL3 float
		
	SET @nrdoc = @parXML.value('(/parametri/@nrDoc)[1]', 'varchar(20)')
	SET @resursa = isnull(@parXML.value('(/parametri/@codRes)[1]', 'varchar(20)'), @parXML.value('(/row/@resursa)[1]', 'varchar(20)'))
	SET @data = isnull(@parXML.value('(/parametri/@data)[1]', 'datetime'), GETDATE())
	SET @nrPP = @parXML.value('(/parametri/@nrPP)[1]', 'varchar(20)')
	SET @semif = isnull(@parXML.value('(/parametri/row/@cod)[1]', 'varchar(20)'), '')
	SET @idRealizare = @parXML.value('(/parametri/@idRealizare)[1]', 'int')
	SET @cantitate = isnull(@parXML.value('(/parametri/row/@cantitate)[1]', 'float'), 0)
	SET @idRealizare = @parXML.value('(/parametri/row/@id)[1]', 'int')
	SET @codIntrareL = @parXML.value('(/parametri/@cod)[1]', 'varchar(20)')
	SET @codIntrareL2 = @parXML.value('(/parametri/@codL2)[1]', 'varchar(20)')
	SET @codIntrareL3 = @parXML.value('(/parametri/@codL3)[1]', 'varchar(20)')
	set @cantL= isnull(@parXML.value('(/parametri/@cantL)[1]', 'float'),0)
	set @cantL2= isnull(@parXML.value('(/parametri/@cantL2)[1]', 'float'),0)
	set @cantL3= isnull(@parXML.value('(/parametri/@cantL3)[1]', 'float'),0)
	EXEC luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate OUTPUT
	--SET @semif = (select MAX(cod) from pozdoc where tip='PP' and Numar=@nrPP and DATA=@data)


	SELECT TOP 1 @idTehnologie = id
	FROM pozTehnologii
	WHERE tip = 'T'
		AND cod = @semif
		AND idp IS NULL

	IF (@idTehnologie IS NULL)RAISERROR ('(wScriuPozRapProductie)Nu s-a identificat tehnologia pentru codul ales!', 16, 1)

	EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

	

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
				/*
				if(@stocCI<@cantM)
				BEGIN
					SET @eroare = 'Cantitatea:'+ltrim(rtrim(cast(convert(DECIMAL(16, 2),@cantM) as varchar(20)))) +' depaseste stocul de:'+ltrim(rtrim(cast(convert(DECIMAL(16, 2),@stocCI) as varchar(20)))) ;

					RAISERROR (@eroare, 16, 1)
				END
				*/
				--if(@stocCI>=@cantM) 
				--begin
				
					SET @cons = (
							SELECT 'CM' AS '@tip', @data AS '@data', @nrPP AS '@numar', '1' AS '@subunitate', @idPozRealizare AS 
								'@idRealizare', (select w.* from  (
									SELECT (select (case when ISNULL(gestiune,'')='' then @gestiuneMP else Gestiune end) from nomencl where cod=pozTehnologii.cod) AS '@gestiune', rtrim(cod) AS '@cod', 
									(case when cod='L' then convert(DECIMAL(16, 5), @cantL) else convert(DECIMAL(16, 5), @cantitate * cantitate) end) AS '@cantitate',
									 pret AS '@pstoc', /*rtrim(@semif)*/@semif AS '@comanda', @resursa AS 
										'@lm', (case when cod='L' then @codIntrareL else  '' end)  as '@codintrare'
									FROM pozTehnologii
									WHERE tip = 'M'
										AND cantitate > 0
										AND idp = @idTehnologie
										union 
									SELECT (select (case when ISNULL(gestiune,'')='' then @gestiuneMP else Gestiune end) from nomencl where cod=pozTehnologii.cod) AS '@gestiune', rtrim(cod) AS '@cod', 
									(case when cod='L' then convert(DECIMAL(16, 5), @cantL2) else convert(DECIMAL(16, 5), @cantitate * cantitate) end) AS '@cantitate',
									 pret AS '@pstoc', /*rtrim(@semif)*/@semif AS '@comanda', @resursa AS 
										'@lm', (case when cod='L' then @codIntrareL2 else  '' end)  as '@codintrare'
									FROM pozTehnologii
									WHERE tip = 'M'
										AND cantitate > 0
										AND idp = @idTehnologie
										and @cantL2>0
								union 
									SELECT (select (case when ISNULL(gestiune,'')='' then @gestiuneMP else Gestiune end) from nomencl where cod=pozTehnologii.cod) AS '@gestiune', rtrim(cod) AS '@cod', 
									(case when cod='L' then convert(DECIMAL(16, 5), @cantL3) else convert(DECIMAL(16, 5), @cantitate * cantitate) end) AS '@cantitate',
									 pret AS '@pstoc', /*rtrim(@semif)*/@semif AS '@comanda', @resursa AS 
										'@lm', (case when cod='L' then @codIntrareL3 else  '' end)  as '@codintrare'
									FROM pozTehnologii
									WHERE tip = 'M'
										AND cantitate > 0
										AND idp = @idTehnologie
										and @cantL3>0
										and cod='L'	
										union 
									SELECT (select(case when ISNULL(gestiune,'')='' then @gestiuneMP else Gestiune end) from nomencl where cod=pozTehnologii.cod) AS '@gestiune', rtrim(cod) AS '@cod', 
									 convert(DECIMAL(16, 5), (@cantitate * cantitate)-@cantL-@cantL2-@cantL3)  AS '@cantitate',
									 pret AS '@pstoc', /*rtrim(@semif)*/@semif AS '@comanda', @resursa AS 
										'@lm', ''  as '@codintrare'
									FROM pozTehnologii
									WHERE tip = 'M'
										AND cantitate > 0
										AND idp = @idTehnologie
										and convert(DECIMAL(16, 5),(@cantitate * cantitate)-@cantL-@cantL2-@cantL3)!=0
										and cod='L')w
										where @cantitate!=0	
									FOR XML path, type
									)
							FOR XML path, type
							)
				--END
				select @cons
				--BEGIN TRY
				--	EXEC wScriuPozdoc @sesiune, @cons
			
			--update pozdoc set cod_intrare=@codIntrareL where tip='CM' and DATA=@data and Numar=@nrPP and cod='L';
			
			if(select COUNT(*) from pozdoc where DATA=@data and tip='CM' and Numar=@nrPP and Comanda=@semif)>0
			begin
			update pozRealizari set CM=@nrPP where id=@idRealizare
			end
			--end
			