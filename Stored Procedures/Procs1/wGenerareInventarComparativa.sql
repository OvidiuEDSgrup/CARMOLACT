--***
CREATE PROCEDURE wGenerareInventarComparativa (@parXML xml)
AS
if OBJECT_ID('wGenerareInventarComparativaSP') is not null
begin
	exec wGenerareInventarComparativaSP @parXML
	return
end
BEGIN TRY
/*
	Exemplu de apel
	exec wGenerareInventarComparativa '<row data="2013-08-02" gestiune="21" cod="0000275" faradocumentcorectie="1" variantaNoua="1"/>'
*/
	DECLARE 
			@data DATETIME, @gestiune VARCHAR(20), @variantaNoua bit,
			@tipg VARCHAR(1), @categatasata VARCHAR(10), @subunitate VARCHAR(13), @idInventar INT, @mesaj VARCHAR(500), @grupa varchar(13),@cod varchar(20),
			@cuCategorie bit,@faradocumentcorectie int, @locatie varchar(20), @grPret bit, @tip_stoc varchar(1), @cont varchar(20),
			@grupari varchar(200),	--> grupari suplimentare: contine 'S' => grupare suplimentara pe cont de stoc - pentru inventar comparativa
			@cufaptic bit
			,@cu_ptabela bit	--> cu procedura tabela; daca nu inseamna ca e apelata cu insert into .. exec si trebuie executat select la final

	select	@data=@parXML.value('(row/@data)[1]','datetime'),
			@gestiune=@parXML.value('(row/@gestiune)[1]','varchar(20)'),
			@grupa=@parXML.value('(row/@grupa)[1]','varchar(13)'),
			@cod=@parXML.value('(row/@cod)[1]','varchar(20)'),
			@variantaNoua=isnull(@parXML.value('(row/@variantaNoua)[1]','bit'),1),
			@categatasata=@parXML.value('(row/@categatasata)[1]','varchar(20)'),
			@cuCategorie=isnull(@parXML.value('(row/@cuCategorie)[1]','bit'),0),
			@faradocumentcorectie=isnull(@parXML.value('(row/@faradocumentcorectie)[1]','bit'),0),
			@locatie=@parXML.value('(row/@locatie)[1]','varchar(20)'),
			@grPret=isnull(@parXML.value('(row/@grupare_cod_pret)[1]','bit'),0),
			@tip_stoc=isnull(@parXML.value('(row/@tip_gestiune)[1]','varchar(1)'),'D'),
			@cont=@parXML.value('(row/@cont)[1]','varchar(20)'),
			@grupari=isnull(@parXML.value('(row/@grupari)[1]','varchar(200)'),''),
				--> grupari = parametru prin care se specifica nivelul de grupare: cont de [S]toc, [P]ret, [L]ocatie, l[O]t
			@cufaptic=isnull(@parXML.value('(row/@cufaptic)[1]','bit'),1)
			
	select @cu_ptabela=(case when object_id('tempdb..#inventar_comparativa') is null then 0 else 1 end)

	declare @grLocatie bit, @grLot bit, @grCont bit
	select	@grLocatie=(case when charindex('L',@grupari)>0 then 1 else 0 end),
			@grLot=(case when charindex('O',@grupari)>0 then 1 else 0 end),
			@grCont=(case when charindex('S',@grupari)>0 then 1 else 0 end)
	exec luare_date_par 'GE','SUBPRO',0,0,@subunitate OUTPUT
	--SET @faradocumentcorectie = 0

	SELECT TOP 1 @tipg = tip_gestiune
	FROM gestiuni
	WHERE Subunitate = @subunitate
		AND Cod_gestiune = @gestiune
	
	create table #inventar (cod varchar(20), stoc_faptic decimal(15,3), locatie varchar(100), lot varchar(100))

-->	in acest punct se determina care structuri se folosesc (in mod normal cele noi;
	-->	in cazul in care se merge pe varianta veche datele sunt luate din tabela inventar):
	if @cufaptic=1
	begin
		if (@variantaNoua=1)
		begin
			SELECT TOP 1 
				@idInventar = idInventar,
				@tip_stoc= (case when tip='G' then 'D' else 'F' end)
			FROM AntetInventar
			WHERE data = @data
				AND gestiune = @gestiune
				and (grupa=@grupa or isnull(@grupa,'')='')--daca sunt inventare deschise la nivel de grupa

			insert into #inventar(cod, stoc_faptic, locatie, lot)
			select cod, sum(stoc_faptic), max(locatie), max(lot)
			from
				(SELECT cod AS cod, stoc_faptic AS stoc_faptic, 
					(case when @grLocatie>0 then detalii.value('(row/@locatie)[1]','varchar(100)') else '' end) locatie,
					(case when @grLot>0 then detalii.value('(row/@lot)[1]','varchar(100)') else '' end) lot
			FROM PozInventar
			WHERE idInventar = @idInventar and 
				(@cod is null or cod=@cod)
				and (@locatie is null or @locatie=isnull(detalii.value('(row/@locatie)[1]','varchar(30)'),''))
				) i
			GROUP BY cod, locatie, lot
			
			--IF @idInventar IS NULL
			--	RAISERROR ('Nu s-a putut identifica inventarul', 11, 1)
		end
		else
			insert into #inventar(cod, stoc_faptic, locatie, lot)
			SELECT Cod_produs AS cod, sum(stoc_faptic) AS stoc_faptic,'',''
				FROM inventar i
				WHERE i.Gestiunea=@gestiune and i.Data_inventarului=@data and (@cod is null or cod_produs=@cod)
				GROUP BY cod_produs
	end

	declare @p xml
	select @p=(select @data dDataSus, @cod cCod, @gestiune cGestiune, @grupa cGrupa, @tip_stoc TipStoc, @cont cCont, 0 Corelatii, @locatie Locatie
	for xml raw)
	
		if object_id('tempdb..#docstoc') is not null drop table #docstoc
			create table #docstoc(subunitate varchar(9))
			exec pStocuri_tabela
		 
		exec pstoc @sesiune='', @parxml=@p
	--if charindex('U',@grupari) is null 

	--> aici modific campurile pe care se va grupa in functie de regulile de grupare:
	update d set lot=''
	from #docstoc d where @grlot=0
	
	update d set locatie=''
	from #docstoc d where @grlocatie=0

	update d set cont=''
	from #docstoc d where @grcont=0
	
	SELECT subunitate, tip_document, numar_document, data, numar_pozitie, 
		cod, (case when tip_miscare='E' then -1 else 1 end)*cantitate stoc, pret_cu_amanuntul, pret, cont, 
		(case when @grPret=1 then pret else 0 end) gr_pret, locatie, lot
	INTO #fstocuridet
	FROM #docstoc 

	if @faradocumentcorectie=1
	begin
		delete sd
		from #fstocuridet sd, pozdoc pd 
		where sd.subunitate=pd.subunitate and sd.tip_document=pd.tip and sd.numar_document=pd.numar and sd.data=pd.data
			and sd.numar_pozitie=pd.numar_pozitie and pd.detalii.value('(/row/@idInventar)[1]', 'int')=@idInventar
	end

	SELECT cod, sum(stoc) AS stoc_scriptic, sum(stoc * (CASE WHEN @tipg = 'A' THEN pret_cu_amanuntul ELSE pret END)) AS 
		valstoc,sum(stoc * pret_cu_amanuntul) as valspretam, sum(stoc * pret) as valspretstoc, gr_pret, max(cont) as cont,
		locatie, lot
	INTO #fstocuri
	FROM #fstocuridet
	GROUP BY cod, gr_pret, cont, locatie, lot
		--> cont, locatie si lot doar daca sunt specificate in grupare, altfel pana aici sunt deja necompletate
/*
	if exists (select 1 from sys.objects where name ='test_luci')
		drop table test_luci
	select @cont cont into test_luci-- from #fstocuri
--*/
	delete from #fstocuri where abs(stoc_scriptic)<=0.001
	delete from #inventar where abs(stoc_faptic)<=0.001

	if object_id('tempdb..#inventar_comparativa') is null
	begin
		create table #inventar_comparativa(cod varchar(20))
		exec wGenerareInventarComparativa_tabela	--> adaug structura
	end
	
	insert into #inventar_comparativa (cod, stoc_scriptic, stoc_faptic, pret
		,cont, locatie, lot)
	/*
	CREATE TABLE #comparativa (
		cod VARCHAR(20), stoc_scriptic FLOAT, stoc_faptic FLOAT, pret FLOAT, plusinv FLOAT, minusinv FLOAT, valplusinv FLOAT, 
		valminusinv FLOAT,pretstoc float,pretam float, cont varchar(40), locatie varchar(100), lot varchar(100)
		)

	INSERT INTO #comparativa (cod, stoc_scriptic, stoc_faptic, pret, cont, locatie, lot)*/
	SELECT DISTINCT isnull(fs.cod, inv.cod), isnull(fs.stoc_scriptic, 0), isnull(inv.stoc_faptic, 0), gr_pret, cont
		,isnull(fs.locatie, isnull(inv.locatie,'')), isnull(fs.lot, isnull(inv.lot,''))
	FROM #fstocuri fs
	FULL JOIN #inventar inv
		ON inv.cod = fs.cod and isnull(inv.locatie,'')=isnull(fs.locatie,'') and isnull(inv.lot,'')=isnull(fs.lot,'')
	--where (@locatie is null or fs.cod is not null)
	--Se incearca prima data cu pretul din tabela de stocuri
	UPDATE i
	SET pret = fs.valstoc / fs.stoc_scriptic, pretam=fs.valspretam / fs.stoc_scriptic, pretstoc=fs.valspretstoc/fs.stoc_scriptic
	FROM #inventar_comparativa i, #fstocuri fs
	WHERE i.cod = fs.cod and i.locatie=fs.locatie and i.lot=fs.lot
		AND abs(fs.stoc_scriptic) > 0.01 and fs.gr_pret=i.pret

	if (@categatasata is null)
	--In cazul in care pretul ramane null se va incerca din tabela de preturi (daca exista o proprietate)
	SELECT @categatasata = NULLIF(valoare,'')
	FROM proprietati
	WHERE tip = 'GESTIUNE'
		AND Cod_proprietate = 'CATEGPRET'
		AND cod = @gestiune

	--if isnull(@categatasata,'')=''
	--	set @categatasata='1'

	create table #preturi(cod varchar(20),nestlevel int)
	IF @categatasata IS NOT NULL
	BEGIN
		insert into #preturi
		select cod,@@NESTLEVEL
		from #inventar_comparativa
		group by cod
		
		exec CreazaDiezPreturi
		declare @px xml
		select @px=(select @categatasata as categoriePret, @data as data, @gestiune as gestiune for xml raw)
		exec wIaPreturi @sesiune=null,@parXML=@px

		UPDATE i
		SET pret = p.Pret_amanunt, pretam=p.Pret_amanunt
		FROM #inventar_comparativa i, #preturi p
		WHERE i.cod = p.cod
		
	END

	-- la cazuri limita, se calculeaza pretul de stoc gresit, si ar rezulta un pret de stoc negativ
	update #inventar_comparativa set	pret = case when pret<0 then null else pret end,
										pretstoc = case when pretstoc<0 then null else pretstoc end,
										pretam = case when pretam<0 then null else pretam end

	--Inca o sansa, luam preturile din nomenclator
	UPDATE i
	SET pret = (case when i.pret IS NULL then (CASE WHEN @tipg = 'A' THEN nomencl.pret_cu_amanuntul ELSE nomencl.Pret_stoc END) else i.pret end),
	pretstoc = (case when i.pretstoc is null then nomencl.pret_stoc else i.pretstoc end),
	pretam = (case when i.pretam is null then nomencl.pret_cu_amanuntul else i.pretam end)
	FROM #inventar_comparativa i, nomencl
	WHERE i.cod = nomencl.cod and (i.pret is null or i.pretstoc is null or i.pretam is null)
	

	--Ultima sansa cautam in receptiile ultimelor 12 luni
	if exists (select * from #inventar_comparativa where pretstoc=0)
	begin
		select cod 
		into #nepretuite
		from #inventar_comparativa where pretstoc=0
		group by cod

		select n.cod,p.pret_de_stoc,rank() over (partition by n.cod order by p.data desc) as ranc
		into #nepretuite1
		from #nepretuite n
		inner join pozdoc p on p.subunitate='1' and p.tip in ('RM','AI') and p.cod=n.cod and p.data>dateadd(m,-12,@data)
	

		delete from #nepretuite1 where ranc>1
		
		update i set pretstoc=#nepretuite1.Pret_de_stoc
			from #inventar_comparativa i, #nepretuite1 where i.pretstoc=0 and i.cod=#nepretuite1.cod
	end
	--Completam celelate coloane

	UPDATE #inventar_comparativa
	SET plusinv = (CASE WHEN stoc_faptic > stoc_scriptic THEN stoc_faptic - stoc_scriptic ELSE 0 END), minusinv = (CASE WHEN stoc_scriptic > stoc_faptic THEN stoc_scriptic - stoc_faptic ELSE 0 END
			)

	UPDATE #inventar_comparativa
	SET valplusinv = plusinv * pret, valminusinv = minusinv * pret

	UPDATE #inventar_comparativa
	SET pretstoc = pret -- daca am pret si n-am pretstoc
	where pretstoc=0 and @tipg != 'A'
	
	UPDATE #inventar_comparativa
	SET pretam = pret -- daca am pret si n-am pretam
	where pretam=0 and @tipg = 'A'
	
	if @cu_ptabela=0
	SELECT cod,stoc_scriptic,stoc_faptic,pret,plusinv,minusinv,valplusinv,valminusinv,pretstoc,pretam,cont
	FROM #inventar_comparativa
END TRY

BEGIN CATCH
	SET @mesaj = ERROR_MESSAGE() + ' (wGenerareInventarComparativa)'

	RAISERROR (@mesaj, 11, 1)
END CATCH
