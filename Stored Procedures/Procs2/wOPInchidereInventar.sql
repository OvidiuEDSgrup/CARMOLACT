--***
CREATE PROCEDURE wOPInchidereInventar @sesiune VARCHAR(50), @parXML XML
AS
if OBJECT_ID('wOPInchidereInventarSP') is not null
begin
	exec wOPInchidereInventarSP @sesiune=@sesiune, @parXML=@parXML
	return
end
BEGIN TRY
	IF EXISTS (SELECT *	FROM sysobjects	WHERE NAME = 'wOPInchidereInventarSP1')
		exec wOPInchidereInventarSP1 @sesiune=@sesiune, @parXML=@parXML OUTPUT

	DECLARE @data DATETIME, @gestiune VARCHAR(20), @tipdoc VARCHAR(4), @contcor VARCHAR(20), @tipCor VARCHAR(1), @gestprim VARCHAR(20), 
			@mesaj VARCHAR(400), @semn INT, @nrdoc VARCHAR(20), @tip2 VARCHAR(2), @pX XML, @pX2 XML,@grupa varchar(20),
			@idInventar int, @locatie varchar(20),@subunitate varchar(20), @cod varchar(20)

	exec luare_date_par 'GE','SUBPRO',0,0,@subunitate OUTPUT
	SET @data = @parXML.value('(/*/@data)[1]', 'datetime')
	SET @gestiune = @parXML.value('(/*/@gestiune)[1]', 'varchar(20)')
	SET @grupa= @parXML.value('(/*/@grupa)[1]', 'varchar(20)')  
	SET @tipdoc = @parXML.value('(/*/@tipuriDoc)[1]', 'varchar(4)')
	SET @tipCor = @parXML.value('(/*/@tipuriCor)[1]', 'varchar(1)')
	SET @contcor = @parXML.value('(/*/@contcorespondent)[1]', 'varchar(20)')
	SET @gestprim = @parXML.value('(/*/@gestiuneprimitoare)[1]', 'varchar(20)')
	set @locatie=@parXML.value('(/*/@locatie)[1]', 'varchar(20)')
	set @cod=@parXML.value('(/*/@cod)[1]', 'varchar(20)')

	IF @tipdoc IN ('AI', 'AE', 'CM', 'AIAE')
		AND isnull(@contcor, '') = ''
		RAISERROR ('La acest tip de document este necesara completarea contului corespondent!', 11, 1)

	IF @tipdoc IN ('TE','PF')
		AND isnull(@gestprim, '') = ''
		RAISERROR ('La acest tip de document este necesara completarea gestiunii primitoare!', 11, 1)

	IF @tipdoc = 'AIAE'
		AND @tipcor <> 'T'
		RAISERROR ('Pentru documente de tipul Alte Intrari/Iesiri selectati "Toate" corectiile!', 11, 1)

	--identificare inventar 
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AntetInventar]') AND type in (N'U'))
	begin
		SELECT TOP 1 @idInventar = idInventar
			FROM AntetInventar
			WHERE data = @data
				AND gestiune = @gestiune
				and (grupa=@grupa or isnull(@grupa,'')='')--daca sunt inventare deschise la nivel de grupa
	end
	
	IF @tipdoc = 'AIAE'
	BEGIN
		SET @tipdoc = 'AI'
		SET @tipCor = 'P'
		SET @tip2 = 'AE'
	END
	-- gruparile specifice de inventariere se vor stabili in wOPInchidereInventarSP1 si se vor pune in @parXML
	-- va fi un sir de caractere ce contine: L=locatii, O=loturi, S=conturi; ex. 'LO'=locatii si loturi
	declare @grupari varchar(200)
	set @grupari=isnull(@parXML.value('(row/@grupari)[1]','varchar(200)'),'')
	declare @parXML2 xml
	select @parXML2=(select @data data, @gestiune gestiune, @grupa grupa, 
				@grupari grupari, 
				@cod cod, 
				1 as faradocumentcorectie for xml raw)

	if object_id('tempdb..#inventar_comparativa') is not null drop table #inventar_comparativa

	if object_id('tempdb..#inventar_comparativa') is null
	begin
		create table #inventar_comparativa(cod varchar(20))
		exec wGenerareInventarComparativa_tabela	--> adaug structura
	end
			
	EXEC wGenerareInventarComparativa @parXML=@parXML2
	
	--In cazul in care generam intrari inversam semnul.
	IF @tipdoc IN ('AI','AF')
		SET @semn = -1
	ELSE
		SET @semn = 1
	
	declare @detalii xml
	set @detalii='<row idInventar="'+convert(varchar,@idInventar)+'"/>'

	if object_id('tempdb..#stocuri_comparativa') is not null 
		drop table #stocuri_comparativa
	select top 0 minusinv-plusinv cantitate, cod, locatie, lot, space(100) cod_intrare, pretstoc, minusinv 
		into #stocuri_comparativa 
		from #inventar_comparativa

	if not (@tipdoc='AE' or @tip2='AE') -- doar intrari, nu trebuie sa fac spargere pe coduri de intrare 
		or not exists (select 1 from #inventar_comparativa where isnull(lot,'')<>'' or isnull(locatie,'')<>'') -- spargerea este necesara doar daca se cer iesiri de pe lot sau locatie
	begin
	insert into #stocuri_comparativa(cantitate, cod, locatie, lot, cod_intrare, pretstoc, minusinv)
	select minusinv-plusinv cantitate, cod, locatie, lot, null cod_intrare, pretstoc, minusinv
		from #inventar_comparativa i 
		WHERE --minusinv > 0.001
			(@tipCor = 'T'
					AND abs(plusinv - minusinv) >= 0.001
					)
				OR (
					@tipCor = 'P'
					AND plusinv >= 0.001
					)
				OR (
					@tipCor = 'M'
					AND minusinv >= 0.001
					)
	end
	else -- spargere pe coduri de intrare - cazul inventarului pe loturi si/sau locatii
	begin
		declare @c_cantitate decimal(15,3), @c_cod varchar(100), @c_locatie varchar(100), @c_lot varchar(100), @c_cod_intrare varchar(100)
				, @c_pretstoc decimal(15,3), @c_minusinv decimal(15,3), @c_stoc decimal(15,3)
		declare @f1 int, @f2 int
		declare c cursor for 
			select minusinv-plusinv cantitate, cod, locatie, lot, pretstoc, minusinv
			from #inventar_comparativa 
			WHERE --minusinv > 0.001
				(@tipCor = 'T'
						AND abs(plusinv - minusinv) >= 0.001
						)
					OR (
						@tipCor = 'P'
						AND plusinv >= 0.001
						)
					OR (
						@tipCor = 'M'
						AND minusinv >= 0.001
						)
		open c
		fetch next from c into @c_cantitate, @c_cod, @c_locatie, @c_lot, @c_pretstoc, @c_minusinv
		set @f1=@@fetch_status
		while @f1=0
		begin
			declare c2 cursor for
				select s.stoc, s.cod_intrare from stocuri s where s.cod=@c_cod and s.locatie=@c_locatie and s.lot=@c_lot and s.stoc<>0 and Cod_gestiune=@gestiune
			open c2
			
			fetch next from c2 into @c_stoc, @c_cod_intrare
			set @f2=@@fetch_status
			
			while @f2=0 and @c_stoc<@c_cantitate
			begin
				select @c_cantitate=@c_cantitate-@c_stoc
				insert into #stocuri_comparativa(cantitate, cod, locatie, lot, cod_intrare, pretstoc, minusinv)
					select @c_stoc, @c_cod, @c_locatie, @c_lot, @c_cod_intrare, @c_pretstoc, @c_minusinv
				fetch next from c2 into @c_stoc, @c_cod_intrare
				set @f2=@@fetch_status
			end
			insert into #stocuri_comparativa(cantitate, cod, locatie, lot, cod_intrare, pretstoc, minusinv)
				select @c_cantitate, @c_cod, @c_locatie, @c_lot, @c_cod_intrare, @c_pretstoc, @c_minusinv
				
			close c2
			deallocate c2
			
			fetch next from c into @c_cantitate, @c_cod, @c_locatie, @c_lot, @c_pretstoc, @c_minusinv
			set @f1=@@fetch_status
		end
		close c
		deallocate c
	end

	SET @nrdoc = 'INV' + convert(varchar,ISNULL(@idInventar,@gestiune))
	SET @pX = (
			SELECT @tipdoc AS '@tip', @nrdoc AS '@numar', @data AS '@data', @gestiune AS '@gestiune', (CASE WHEN @tipdoc IN ('AI', 'AE', 'CM') THEN @contcor END
					) AS '@contcorespondent', '9' AS '@stare',
					(CASE @tipdoc WHEN 'TE' THEN @gestprim WHEN 'PF' THEN @gestprim END) AS '@gestprim'
					, @detalii as detalii,
					(SELECT rtrim(cod) AS '@cod', convert(DECIMAL(12, 3), @semn * (cantitate
								)) AS '@cantitate', convert(DECIMAL(15, 2), pretstoc) AS '@pamanunt',
								convert(decimal(15,2),pretstoc) as '@pstoc'
								, p.cod_intrare '@cod_intrare', p.cod_intrare '@codintrare'	--> ca sa fiu sigur...
								, locatie '@locatie', lot '@lot'
								, @detalii as detalii
								
					FROM #stocuri_comparativa p
					FOR XML path, Type
					)
			FOR XML path, type
			)

	delete from pozdoc where subunitate=@subunitate and tip=@tipdoc and numar=@nrdoc and data=@data

	if exists (select 1 from sys.objects where name='wScriuDoc')
		exec wScriuDoc @sesiune=@sesiune, @parxml=@pX
	else exec wScriuDocBeta @sesiune=@sesiune, @parxml=@pX
	
	IF @tip2 IS NOT NULL
	BEGIN
		SET @semn = - 1
		
		SET @pX2 = (
				SELECT @tip2 AS '@tip', @nrdoc AS '@numar', @data AS '@data', @gestiune AS '@gestiune', @contcor AS '@contcorespondent'
					, '9' AS '@stare'
					, @detalii as detalii,
					(SELECT rtrim(cod) AS '@cod', convert(DECIMAL(12, 3), @semn * p.cantitate
									) AS '@cantitate', convert(DECIMAL(15, 2), pretstoc) AS '@pamanunt'
									, locatie '@locatie', lot '@lot'
									, p.cod_intrare '@cod_intrare', p.cod_intrare '@codintrare'	--> ca sa fiu sigur...
									, @detalii as detalii
						FROM #stocuri_comparativa p
						WHERE minusinv > 0.001
						FOR XML path, Type
						)
				FOR XML path, type
				)
		delete from pozdoc where subunitate=@subunitate and tip=@tip2 and numar=@nrdoc and data=@data

	if exists (select 1 from sys.objects where name='wScriuDoc')
		exec wScriuDoc @sesiune=@sesiune, @parxml=@pX
	else exec wScriuDocBeta @sesiune=@sesiune, @parxml=@pX
	END

	SELECT 'Terminat operatie!' as textMesaj, 
		'Finalizare operatie' as titluMesaj for xml raw, root('Mesaje')
END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (wOPInchidereInventar)'
END CATCH

if object_id('tempdb..#inventar_comparativa') is not null drop table #inventar_comparativa
if object_id('tempdb..#stocuri_comparativa') is not null drop table #stocuri_comparativa
if len(@mesaj)>0 RAISERROR (@mesaj, 11, 1)
