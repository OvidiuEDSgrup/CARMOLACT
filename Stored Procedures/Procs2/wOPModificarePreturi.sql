--***
create procedure [dbo].[wOPModificarePreturi] @sesiune varchar(50), @parXML xml                
as  begin try
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	declare 
		@subunitate varchar(9),@gestiune varchar(20),@utilizator varchar(100), @data datetime, 
		@datajos datetime, @datasus datetime, @cod varchar(20), @pXML xml, @pStoc xml	

	select 
		@gestiune= NULLIF(@parXML.value('(/*/@gestiune)[1]', 'varchar(20)'), ''),
		@datajos = @parXML.value('(/*/@datajos)[1]', 'datetime'),
		@datasus = @parXML.value('(/*/@datasus)[1]', 'datetime'),
		@cod=NULLIF(@parXML.value('(/*/@cod)[1]', 'varchar(20)'), '')

	if @gestiune=''
	begin
		raiserror('Modificarile de pret trebuie sa fie pe o singura gestiune!',16,1)
		return
	end

	if month(@datajos)!=month(@datasus) and year(@datajos)!=year(@datasus)
	begin
		raiserror('Modificarile de pret trebuie sa fie intr-o singura luna!',16,1)
		return
	end

	exec wIaUtilizator @sesiune = @sesiune , @utilizator = @utilizator OUTPUT
	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate output              
		
	IF OBJECT_ID('tempdb.dbo.#tmpgest') IS NOT NULL
		DROP TABLE #tmpgest

	IF OBJECT_ID('tempdb.dbo.#tmppreta') IS NOT NULL
		DROP TABLE #tmppreta

	IF OBJECT_ID('tempdb.dbo.#TEdescris') IS NOT NULL
		DROP TABLE #TEdescris

	select
		rtrim(g.Cod_gestiune) gestiune, isnull(rtrim(pr.valoare),1) categorie_pret
	into #tmpgest
	FROM Gestiuni g
	LEFT JOIN proprietati pr on pr.tip='GESTIUNE' and pr.cod_proprietate='CATEGPRET' and pr.cod=g.cod_gestiune and pr.valoare<>''
	where
		(g.tip_gestiune='A' or g.pret_am=1)
		and (g.Cod_gestiune=@gestiune or @gestiune is null)
	
	select
		g.gestiune, g.categorie_pret, rtrim(p.Cod_produs) cod, p.Pret_cu_amanuntul pret, 
		p.Data_inferioara data,0.00 as tva_neexigibil
	into #tmppreta
	from preturi p 
	JOIN Nomencl n on n.cod=p.cod_produs
	inner join #tmpgest g on g.categorie_pret=p.UM
	where 
		(p.Cod_produs=@cod or @cod is null) 
		and p.Tip_pret='1' and p.Data_inferioara between @datajos and @datasus
	
	/*Trebuie sa adaugam si modificarile de preturi facute pe categoria 1 ale codurilor inexistente in categoria gestiunii */
	insert into #tmppreta 
	select
		g.gestiune, '1', rtrim(p.Cod_produs) cod, p.Pret_cu_amanuntul pret, 
		p.Data_inferioara data,0.00 as tva_neexigibil
	from preturi p
	left join #tmpgest g on 1=1
	JOIN Nomencl n on n.cod=p.cod_produs
	where 
		(p.Cod_produs=@cod or @cod is null) 
		and p.um='1' and p.Tip_pret='1' and p.Data_inferioara between @datajos and @datasus

	IF NOT EXISTS (Select 1 from #tmppreta)
		RETURN

	create table #TEdescris (gestiune varchar(20), cod varchar(20), data datetime, pret_amanunt float, pret_stoc float, stoc float, pret_amanunt_stoc float, cod_intrare varchar(20),tva_neexigibil decimal(12,2))
		
	if object_id('tempdb..#docstoc') is not null drop table #docstoc
		create table #docstoc(subunitate varchar(9))
	exec pStocuri_tabela

	create table #preturi(cod varchar(20),umprodus varchar(3),nestlevel int)
	exec CreazaDiezPreturi

	declare
		@dData datetime, @cCod varchar(20), @GestFiltru varchar(20)

	select top 1 @cCod = cod, @dData = data, @GestFiltru = gestiune from #tmppreta		

	/*Periem tabela #tmppreta astfel incat sa existe o singura modificare intr-o zi*/
	WHILE EXISTS (select 1 from #tmppreta)
	BEGIN
		
		truncate table #preturi
		insert into #preturi (cod)
		select @cCod
		
		declare @xPreturi xml
		set @xPreturi=(select @Gestiune as gestiune,dateadd(day,-1,@dData) as data for xml raw)
		exec wIaPreturi @sesiune=@sesiune,@parXML=@xPreturi
		declare @pretIeri float,@pretAzi float
		select top 1 @pretIeri=pret_amanunt from #preturi
		if @pretIeri is null
			set @pretIeri=0			
		
		truncate table #preturi
		insert into #preturi (cod)
		select @cCod
		set @xPreturi=(select @Gestiune as gestiune,@dData as data for xml raw)
		exec wIaPreturi @sesiune=@sesiune,@parXML=@xPreturi
			select top 1 @pretAzi=pret_amanunt from #preturi
		

		if @pretIeri<>@pretAzi--Facem modificarea de preturi doar atunci
		begin
			delete #docstoc	
		
			select @pStoc=(select dateadd(day,-1,@dData) ddatasus, dateadd(day,-1,@dData) ddatajos,  @cCod ccod, @GestFiltru cgestiune, 1 grcod, 1 grgest, 1 grcodi, 'D' tipstoc for xml raw)

			exec pstoc @sesiune=@sesiune, @parxml=@pStoc		
				
			insert into #TEdescris (gestiune, cod, data, pret_amanunt, pret_stoc, stoc, pret_amanunt_stoc,cod_intrare,tva_neexigibil)
			select
				@GestFiltru, @cCod, @dData, @pretAzi,ds.pret,ds.stoc,@pretIeri, ds.cod_intrare,ds.tva_neexigibil
			from #docstoc ds 
			where ds.cod=@cCod and ds.gestiune=@GestFiltru and abs(stoc)>0.001
		end
				
		delete #tmppreta where cod=@cCod and data=@dData and gestiune=@GestFiltru
		select top 1 @cCod = cod, @dData = data, @GestFiltru = gestiune from #tmppreta		
	END
	
	delete p 
	from pozdoc p 
	where p.tip='TE' 
	and p.numar='MP'+p.gestiune 
	and p.gestiune=@gestiune
	and p.gestiune=p.gestiune_primitoare 
	and p.data between @datajos and @datasus

	IF NOT EXISTS (select 1 from #TEdescris )
		RETURN

	set @pXML =
	(
		select 
			'TE' tip, ta.data data, 'MP'+ta.gestiune numar, ta.gestiune gestiune, ta.gestiune gestprim,
			(
				select
					tp.cod, convert(decimal(12,5),tp.pret_stoc) pstoc, convert(decimal(12,5), tp.stoc) cantitate,tp.tva_neexigibil as tvaneexigibil,
					tp.cod_intrare codintrare, tp.cod_intrare codiprimitor,ta.gestiune, ta.gestiune gestprim,  convert(decimal(12,5), tp.pret_amanunt) pamanunt,
					convert(decimal(12,5),tp.pret_amanunt_stoc) pret_amanunt_predator
				from #TEdescris tp
				where tp.gestiune=ta.gestiune and tp.data = ta.data 
				for xml raw, type
			)
		from #TEdescris ta
		group by ta.gestiune, ta.data
		for xml raw, root('Date')
	)
	--select @pXML
	/* FINAL	*/	
	exec wScriuDoc @sesiune = @sesiune, @parXML = @pXML

END TRY
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH
