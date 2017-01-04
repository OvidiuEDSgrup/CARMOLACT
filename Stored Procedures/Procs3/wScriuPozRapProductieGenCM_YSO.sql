
CREATE PROCEDURE [dbo].[wScriuPozRapProductieGenCM_YSO] @sesiune VARCHAR(50), @parXML XML
AS

DECLARE @eroare VARCHAR(2000)

SET @eroare = ''

	declare @iDoc int
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
	SET @semif = isnull(@parXML.value('(/parametri/@tehn)[1]', 'varchar(20)'), '')
	SET @idRealizare = @parXML.value('(/parametri/@idRealizare)[1]', 'int')
	SET @cantitate = isnull(@parXML.value('(/parametri/@cantitate)[1]', 'float'), 0)
	SET @idPozRealizare = @parXML.value('(/parametri/@id)[1]', 'int')
	SET @codIntrareL = @parXML.value('(/parametri/@cod)[1]', 'varchar(20)')
	SET @codIntrareL2 = @parXML.value('(/parametri/@codL2)[1]', 'varchar(20)')
	SET @codIntrareL3 = @parXML.value('(/parametri/@codL3)[1]', 'varchar(20)')
	set @cantL= isnull(@parXML.value('(/parametri/@cantL)[1]', 'float'),0)
	set @cantL2= isnull(@parXML.value('(/parametri/@cantL2)[1]', 'float'),0)
	set @cantL3= isnull(@parXML.value('(/parametri/@cantL3)[1]', 'float'),0)
	EXEC luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate OUTPUT
	
	
	DECLARE @par TABLE 
	(
		nrDoc varchar(10),
		resursa varchar(10),
		data Date,
		codRes varchar(10),
		idRealizare int,
		cod varchar(40),
		nrPP int,
		nrpoz int,
		gestPP varchar(10),
		nr varchar(10),
		cantL float,
		codL2 varchar(10),
		cantL2 float,
		codL3 varchar(10),
		cantL3 float,
		grid xml
	)
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @parXML

	insert into @par
	select nrDoc ,resursa , data, codRes,idRealizare, cod, nrPP ,nrpoz ,
	gestPP, nr,isnull(cantL,0),isnull(codL2,''),isnull(cantL2,0),isnull(codL3,''),isnull(cantL3,0),grid
	
	from OPENXML(@iDoc, '/parametri')
	WITH
	(
		nrDoc varchar(10) '@nrDoc',
		resursa varchar(10) '@resursa',
		data Date '@data',
		codRes varchar(10) '@codRes',
		idRealizare int '@idRealizare',
		cod varchar(40) '@cod',
		nrPP int '@nrPP',
		nrpoz int '@nrpoz',
		gestPP varchar(10) '@gestPP',
		nr varchar(10) '@nr',
		cantL float '@cantL',
		codL2 varchar(10) '@codL',
		cantL2 float '@candL2',
		codL3 varchar(10) '@codL3',
		cantL3 float 'cantL3',
		grid xml 'DateGrid'
	)
	exec sp_xml_removedocument @iDoc 
	
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
				
				/*
				set @cantM=(SELECT  convert(DECIMAL(16, 2), @cantitate * cantitate) 
									FROM pozTehnologii
									WHERE tip = 'M'
										AND cantitate > 0 AND parinteTop = @idTehnologie and cod='L')
				set @stocCI=(select SUM(stoc) from stocuri where cod='L' and Cod_intrare=@codIntrareL)
				*/
															  
					
				
				

									
				SET @cons = (
							SELECT 'CM' AS '@tip', @data AS '@data', @nrPP AS '@numar', '1' AS '@subunitate', isnull(@idPozRealizare,0) AS '@idRealizare', 
								(select w.* from  
								(
									SELECT 
										r.value('@gestiune', 'varchar(10)') as '@gestiune',
										r.value('@cod', 'varchar(10)') as '@cod',
										CONVERT(DECIMAL(10,2),r.value('@cantitate', 'float')) as '@cantitate',
										CONVERT(DECIMAL(10,2),r.value('@pstoc', 'float')) as '@pstoc',
										r.value('@comanda', 'varchar(10)') as '@comanda',
										r.value('@lm', 'varchar(10)') as '@lm',
										r.value('@codintrare', 'varchar(10)') as '@codintrare'  
									FROM @par
									CROSS APPLY grid.nodes('/DateGrid/row') AS x(r)
										
										union 
									SELECT (select (case when ISNULL(gestiune,'')='' then @gestiuneMP else Gestiune end) from nomencl where cod=pozTehnologii.cod) AS '@gestiune', rtrim(cod) AS '@cod', 
									(case when cod='L' then convert(DECIMAL(10, 2), @cantL) else convert(DECIMAL(10, 2), @cantitate * cantitate) end) AS '@cantitate',
									 pret AS '@pstoc', /*rtrim(@semif)*/@semif AS '@comanda', @resursa AS 
										'@lm', (case when cod='L' then @codIntrareL else  '' end)  as '@codintrare'
									FROM pozTehnologii
									WHERE tip = 'M'
										AND cod='L'
										AND cantitate > 0
										AND idp = @idTehnologie
										union 	
									
									SELECT (select (case when ISNULL(gestiune,'')='' then @gestiuneMP else Gestiune end) from nomencl where cod=pozTehnologii.cod) AS '@gestiune', rtrim(cod) AS '@cod', 
									(case when cod='L' then convert(DECIMAL(10, 2), @cantL2) else convert(DECIMAL(10, 2), @cantitate * cantitate) end) AS '@cantitate',
									 pret AS '@pstoc', /*rtrim(@semif)*/@semif AS '@comanda', @resursa AS 
										'@lm', (case when cod='L' then @codIntrareL2 else  '' end)  as '@codintrare'
									FROM pozTehnologii
									WHERE tip = 'M'
										AND cantitate > 0
										AND idp = @idTehnologie
										and @cantL2>0
										union 
									SELECT (select (case when ISNULL(gestiune,'')='' then @gestiuneMP else Gestiune end) from nomencl where cod=pozTehnologii.cod) AS '@gestiune', rtrim(cod) AS '@cod', 
									(case when cod='L' then convert(DECIMAL(10, 2), @cantL3) else convert(DECIMAL(10, 2), @cantitate * cantitate) end) AS '@cantitate',
									 pret AS '@pstoc', /*rtrim(@semif)*/@semif AS '@comanda', @resursa AS 
										'@lm', (case when cod='L' then @codIntrareL3 else  '' end)  as '@codintrare'
									FROM pozTehnologii
									WHERE tip = 'M'
										AND cantitate > 0
										AND idp = @idTehnologie
										and @cantL3>0
										and cod='L'	
										/*union 
									SELECT (select(case when ISNULL(gestiune,'')='' then @gestiuneMP else Gestiune end) from nomencl where cod=pozTehnologii.cod) AS '@gestiune', rtrim(cod) AS '@cod', 
									 convert(DECIMAL(10, 2), (@cantitate * cantitate)-@cantL-@cantL2-@cantL3)  AS '@cantitate',
									 pret AS '@pstoc', /*rtrim(@semif)*/@semif AS '@comanda', @resursa AS 
										'@lm', ''  as '@codintrare'
									FROM pozTehnologii
									WHERE tip = 'M'
										AND cantitate > 0
										AND idp = @idTehnologie
										and convert(DECIMAL(10, 2),(@cantitate * cantitate)-@cantL-@cantL2-@cantL3)!=0
										and cod='L'
										*/
										)w
										where @cantitate!=0	
									FOR XML path, type
									)
							FOR XML path, type
							)
				--END
				--select @cons
				--BEGIN TRY
					EXEC wScriuPozdoc @sesiune, @cons
			
			--update pozdoc set cod_intrare=@codIntrareL where tip='CM' and DATA=@data and Numar=@nrPP and cod='L';
			
			if(select COUNT(*) from pozdoc where DATA=@data and tip='CM' and Numar=@nrPP and Comanda=@semif)>0
			begin
				update pozRealizari set CM=@nrPP where id=@idRealizare
				update pozRealizari set CM=@nrPP where id=@idPozRealizare
			end
			--end
			