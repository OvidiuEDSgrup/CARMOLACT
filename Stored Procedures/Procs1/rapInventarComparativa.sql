--***
create procedure rapInventarComparativa(@sesiune varchar(50)=null,
		@dData datetime,
		@tipgest varchar(1),	--> tip gestiune: Depozit, Folosinta, (cusTodie)
		@ordonare varchar(1),	--> 'c'=cod, 'd'=denumire
		@grupare_cod_pret bit=0,
		@grupare varchar(1),	--> locm(=1), gestiune; nu functioneaza! (procedura nu aduce locuri de munca)
		@cCod varchar(50)=null, @cGestiune varchar(50)=null, @locm varchar(50)=null,
		@cont varchar(50)=null, 
		@contnom varchar(50)=null, @antetInventar int=null,
		@tippret varchar(1)='s',	--> s,t,v s=pret de stoc, t=f(tip gestiune), v=pret vanzare
		@categpret smallint=null,
		@faraDocumentCorectie int=0, -->Implicit cu documente de corectie
		@locatie varchar(200)=null,
		@standard int=0	--> apel procedura pentru: 0=inventar comparativa, 1=inventar standard, 2=inventar folosinta
		,@stocscriptic int=1	--> parametru pentru generarea unui raport fara nici un fel de valori
		,@faptic int=1		--> stocul faptic: 1 = sa fie adus, 0 = sa fie ignorat
		,@grupari varchar(20)='UG'	-->	reguli de grupare: implicit pe unitate si gestiune; optiunile sunt: 
									--	[U]nitate
									--	[G]estiune
									--	Cont de [S]toc
									--	[L]ocatie
		,@detaliere int=0			--	0=cod, 1=cod + pret, 2=cod + lot
		)
as
	declare @eroare varchar(2000)
	set @eroare=''
	begin try
	
	set transaction isolation level read uncommitted
		if @detaliere=0 and @grupare_cod_pret=1		--> unificare parametri de grupare pe pret - vechi cu nou
			set @detaliere=1
	declare @cGrupa varchar(13), @gestiuneXML varchar(50), @cui varchar(50),
		@ordreg varchar(50), @adresa varchar(200)

		declare @grupare1 varchar(1), @grupare2 varchar(1)
		select @grupare1=left(@grupari,1), @grupare2=substring(@grupari,2,1)
	-->	tratare erori, prelucrari parametri:
		--> exista doua variante ale raportului:  daca exista date in antetInventar se foloseste parametrul 
		-->				@antetInventar,	altfel se lucreaza cu parametri @gestiune, @data, @locm
		declare @variantaNoua bit	--> parametru care semnalizeaza folosirea noilor structuri
		select @variantaNoua=(case when not (exists (select 1 from sys.objects where name='antetinventar') and (select count(1) from antetinventar)>0) then 0 else 1 end)
		select @variantaNoua=(case when @standard=0 then @variantaNoua else 0 end)
		if isnull(@antetInventar,0)=0 and @variantaNoua=1 and @cGestiune is null and @locm is null	-- and @ccod is null
			raiserror('Este necesara specificarea unui antet de inventar, gestiune sau loc de munca!',16,1)
		if (@variantaNoua=1 or @standard<>0) and isnull(@antetInventar, 0) <> 0
			select @cGestiune=a.gestiune, @dData=a.data, @cGrupa=grupa from antetInventar a where a.idInventar=@antetInventar
		else if @cGestiune is null and @locm is null --and @ccod is null
			raiserror('Completati gestiunea!',16,1)

		if (@cGestiune is null and isnull(@antetInventar,0)>0 and @variantaNoua = 0)
			raiserror('Nu s-a gasit inventarul in antet inventar!',16,1)

		--if @standard<2 and (@cGestiune is null) raiserror('Este necesara completarea gestiunii!',16,1)
		--if @standard=2 and (@cGestiune is null) raiserror('Este necesara completarea marcii!',16,1)
		
		if (@tippret<>'s' and @categPret is null and @cGestiune is null)
		raiserror('Pentru tip pret diferit de pret de stoc alegeti o categorie de pret!',16,1)

		/** In cazul in care se selecteaza un antet inventar din depozit, iar tip gestiune = 'Folosinta', atunci inversam tipul. Similar Depozit. */
		if isnull(@antetInventar, 0) <> 0 and not exists (select 1 from AntetInventar where idInventar = @antetInventar and tip = (case when @tipgest = 'D' then 'G' else 'M' end))
			set @tipgest = (case when @tipgest = 'D' then 'F' else 'D' end)

		declare @subunitate varchar(20), @flt_cCod bit, @flt_contnom bit
		select @subunitate=isnull((select rtrim(val_alfanumerica) from par
							where tip_parametru='GE' and parametru='subpro'),'1'),
				@flt_cCod=(case when @cCod is null then 0 else 1 end),
				@flt_contnom=(case when @contnom is null then 0 else 1 end),
	-->	Prelucrari parametri
				@contnom=isnull(@contnom,'%')
		--select (case when @tippret<>'s' then @categpret else null end)
		if object_id('tempdb.dbo.#inventar_comparativa') is not null drop table #inventar_comparativa

		-->	Preluarea datelor din inventar
		IF OBJECT_ID('tempdb.dbo.#grupate') is not null drop table #grupate

		CREATE TABLE #grupate (
			gestiune varchar(50), dengest varchar(150), cod varchar(20), stoc_scriptic float, stoc_faptic float, grupare varchar(50),
			valoare float, val_unit float, diferentaCantitate float, diferentaValorica float, valoareInventar float, cont varchar(40)
			,locatie varchar(200)
			,grupare1 varchar(1000) default null, grupare2 varchar(1000) default null
			,dengrupare1 varchar(1000) default null, dengrupare2 varchar(1000) default null
		)

		declare @denGest varchar(1000), @parXML xml, @codGestiune varchar(20)
		declare @lista table(cod varchar(50))
		
		/** Inseram gestiunile/marcile in @lista, doar daca s-a selectat filtrul pe loc de munca sau daca nu se ia stocul faptic: */
		select @locm=ISNULL(@locm, '')
		IF @locm <> '' 
		BEGIN
			IF @tipgest = 'D'
			BEGIN
				INSERT INTO @lista(cod)
				SELECT RTRIM(g.Cod_gestiune)
				FROM gestiuni g
				LEFT JOIN AntetInventar ai ON ai.gestiune = g.Cod_gestiune AND ai.tip = 'G'
				WHERE g.detalii.value('(/row/@lm)[1]', 'varchar(50)') LIKE RTRIM(@locm) + '%'
					AND (@faptic=0 or ai.data = @dData) and 
					(@cGestiune is null or g.Cod_gestiune=@cGestiune)
				group by RTRIM(g.Cod_gestiune)
			END
			ELSE
			BEGIN
				INSERT INTO @lista(cod)
				SELECT RTRIM(p.Marca)
				FROM personal p
				LEFT JOIN AntetInventar ai ON ai.gestiune = p.Marca AND ai.tip <> 'G'
				WHERE p.Loc_de_munca LIKE RTRIM(@locm) + '%' 
					AND (@faptic=0 or ai.data = @dData)
					and (@cGestiune is null or p.Marca=@cGestiune)
				group by RTRIM(p.Marca)
			END
		END
		
		IF @cGestiune is not null and not exists (select 1 from @lista where cod=@cGestiune)
			insert into @lista values(@cGestiune)

		SET @codGestiune = NULL
		SELECT TOP 1 @codGestiune = cod FROM @lista

		while @codGestiune is not null 
		begin

			select @parXML=(select @dData data, @cGrupa grupa, @codGestiune gestiune, @variantaNoua variantaNoua, (case when @tippret='s' then 0 else 1 end) cuCategorie,
							(case when @tippret<>'s' then @categpret else null end) as categatasata,@faraDocumentCorectie as faradocumentcorectie, @locatie locatie,
							(case when @detaliere=1 then 1 else 0 end) grupare_cod_pret, @tipgest as tip_gestiune, @cont cont,
							@grupari+(case when @detaliere=2 then 'O' else '' end) grupari, @ccod cod
						for xml raw)
		
			if @tipgest = 'D'
				select @denGest=rtrim(g.Denumire_gestiune) from gestiuni g where g.Cod_gestiune=@codGestiune
			else
				select @denGest=rtrim(nume) from personal p where p.marca=@codGestiune

			if object_id('tempdb..#inventar_comparativa') is null
			begin
				create table #inventar_comparativa(cod varchar(20))
				exec wGenerareInventarComparativa_tabela	--> adaug structura
			end
	
			exec wGenerareInventarComparativa @parXML=@parXML
			insert into #grupate (gestiune, dengest, cod, stoc_scriptic, stoc_faptic, grupare,
				valoare, val_unit, diferentaCantitate, diferentaValorica, valoareInventar, cont, locatie
				,grupare1, grupare2
				,dengrupare1, dengrupare2)
			select
				@codGestiune as gestiune, @denGest as dengest, cod, sum(stoc_scriptic) stoc_scriptic, sum(stoc_faptic) stoc_faptic,
				rtrim(convert(varchar(100),cod))+isnull(' | '+nullif(rtrim(convert(varchar(20), max(case @detaliere when 1 then convert(varchar(20),convert(decimal(15,3),isnull(pret,0))) when 2 then lot else '' end))),''),'') grupare,
				--sum((c.stoc_scriptic-c.stoc_faptic)*c.pret) valoare, 
				sum(c.stoc_scriptic*c.pret) valoare, 
				max(c.pret) val_unit, 
				sum(c.stoc_scriptic-c.stoc_faptic) diferentaCantitate,
				sum((c.stoc_scriptic-c.stoc_faptic)*c.pret) diferentaValorica,
				sum(c.stoc_scriptic*c.pret) valoareInventar, 
				max(c.cont), max(c.locatie)
				-->	gruparile dinamice:
				,rtrim(case @grupare1 when 'U' then '' when 'G' then @codGestiune when 'S' then cont when 'L' then locatie end) as grupare1
				,rtrim(case @grupare2 when 'U' then '' when 'G' then @codGestiune when 'S' then cont when 'L' then locatie end) as grupare2
				,'',''
			from #inventar_comparativa c
			group by cod, (case when @detaliere=1 then isnull(pret,0) else 0 end)
					, (case when @detaliere=2 then lot else '' end)
					--> Luci: s-ar putea sa aiba impact mare asupra performantei, va trebui vazut:
				,rtrim(case @grupare1 when 'U' then '' when 'G' then @codGestiune when 'S' then cont when 'L' then locatie end)
				,rtrim(case @grupare2 when 'U' then '' when 'G' then @codGestiune when 'S' then cont  when 'L' then locatie end)

			truncate table #inventar_comparativa

			delete from @lista where cod = @codGestiune
			set @codGestiune = null
			select top 1 @codGestiune = cod from @lista

		end

		--> denumiri pentru gruparile dinamice:
			--> default se va pune cod in locul denumirii
		update g set dengrupare1=grupare1
					,dengrupare2=grupare2
		from #grupate g
		
		--> in continuare se ia pe rand si se completeaza : [G]estiune, cont de [S]toc, [L]ocatie
		if charindex('G',@grupari)>0
		update g set dengrupare1=rtrim(case @grupare1 when 'G' then g.dengest else g.dengrupare1 end)
					,dengrupare2=rtrim(case @grupare2 when 'G' then g.dengest else g.dengrupare2 end)
		from #grupate g
		
		if charindex('S',@grupari)>0
		update g set dengrupare1=rtrim(case @grupare1 when 'S' then c.denumire_cont else g.dengrupare1 end)
					,dengrupare2=rtrim(case @grupare2 when 'S' then c.denumire_cont else g.dengrupare2 end)
		from #grupate g
			inner join conturi c on g.cont=c.cont
			
		if charindex('L',@grupari)>0
		update g set dengrupare1=rtrim(case @grupare1 when 'L' then l.descriere else g.dengrupare1 end)
					,dengrupare2=rtrim(case @grupare2 when 'L' then l.descriere else g.dengrupare2 end)
		from #grupate g
			inner join locatii l on g.locatie=l.cod_locatie
			
		select @cui = rtrim(Val_alfanumerica) from par where Tip_parametru = 'GE' and Parametru = 'CODFISC'
		select @ordreg = rtrim(Val_alfanumerica) from par where Tip_parametru = 'GE' and Parametru = 'ORDREG'
		select @adresa = rtrim(Val_alfanumerica) from par where Tip_parametru = 'GE' and Parametru = 'ADRESA'

		if @stocscriptic=0
		update #grupate set stoc_scriptic=0, valoare=0,
			diferentaCantitate=0, diferentaValorica=0
		if @faptic=0 update #grupate set stoc_faptic=0,
			diferentaCantitate=0, diferentaValorica=0
		
		--if @detaliere=2 update #grupate set cod=grupare	--> lotul e luat in cod produs
		
		select	@cui as cui, @ordreg as ordreg, @adresa as adresa,
				rtrim(c.gestiune) gestiune, rtrim(c.dengest) as den_gest, 
				rtrim(case when @detaliere=2 then grupare else c.cod end) cod, c.stoc_scriptic, --c.pret,
				(case when @tipgest='F' and 1=0 then 0 else convert(decimal(15,2), c.valoare) end) valoare, convert(decimal(17,5), c.val_unit) as val_unit,
				'1901-1-1' data, 'c' loc_de_munca,
				rtrim(n.Denumire) denumire,
				rtrim(n.um) um,
				c.stoc_faptic,
				'n' nume_lm,
				convert(decimal(15,2), c.diferentaCantitate) as diferentaCantitate,
				c.grupare,
				(case when diferentaValorica>0 or @tipgest='F' then 0 else convert(decimal(15,2), -diferentaValorica) end) as plus,
				(case when diferentaValorica<0 or @tipgest='F' then 0 else convert(decimal(15,2), diferentaValorica) end) as minus,
				(case when @tipgest='F' and 1=0 then 0 else convert(decimal(15,2), valoareInventar) end) valoareInventar, 
				c.cont
				,grupare1, grupare2, dengrupare1, dengrupare2
		from #grupate c
			left join nomencl n on c.cod=n.Cod
		where (@flt_cCod=0 or c.cod=@cCod)
			and (@flt_contnom=0 or n.Cont like @contnom)
		order by grupare1, grupare2, (case @ordonare when 'c' then rtrim(c.cod) else rtrim(isnull(n.denumire,'')) end), n.denumire, c.cod
	end try
	begin catch
		set @eroare=ERROR_MESSAGE()+' (rapInventarComparativa '+convert(varchar(20),error_line())+')'
	end catch
	if object_id('tempdb.dbo.#inventar_comparativa') is not null drop table #inventar_comparativa
	if object_id('tempdb.dbo.#grupate') is not null drop table #grupate
	if object_id('tempdb.dbo.#preturi') is not null drop table #preturi

	if len(@eroare)>0 --raiserror(@eroare,16,1)
		select @eroare as den_gest, '<EROARE>' as gestiune
