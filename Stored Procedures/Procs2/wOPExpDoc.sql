
create procedure wOPExpDoc @idRulare int = 0
as
set transaction isolation level read uncommitted

declare
	@utilizator varchar(100), @sesiune varchar(50), @eroare varchar(1000), @xml xml, @datajos datetime, @datasus datetime,
	@tip varchar(2), @grupa varchar(100), @dencod varchar(100), @gestiune varchar(20), @lm varchar(20), @denlm varchar(100),
	@comanda varchar(20), @tert varchar(20),  @parXML xml, @codarticol varchar(20), @transportator varchar(300),
	@grupGestiuni varchar(50), @subunitate varchar(10), @lista_lm bit

begin try
	select @sesiune = sesiune, @parXML = parXML from asisria..ProceduriDeRulat where idRulare = @idRulare
	
	if @parXML is null 
		raiserror('Eroare la citirea filtrelor. Detalii tehnice: parametrul XML nu exista!', 11, 1)
	
	exec luare_date_par @tip='GE', @par='SUBPRO', @val_l=null, @val_n=null, @val_a=@subunitate output
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output
	
	if exists (select * from LMFiltrare l where l.utilizator=@utilizator)
		set @lista_lm = 1
	else
		set @lista_lm = 0

	select	@datajos = isnull(@parXML.value('(/*/@datajos)[1]', 'datetime'), '01/01/1901'),
			@datasus = isnull(@parXML.value('(/*/@datasus)[1]', 'datetime'), '01/01/2901'),
			@tip = isnull(@parXML.value('(/*/@tip)[1]', 'varchar(2)'), 'T'),
			@grupa = isnull(@parXML.value('(/*/@grupa)[1]', 'varchar(100)'), ''),
			@dencod = isnull(@parXML.value('(/*/@dencod)[1]', 'varchar(100)'), ''),
			@gestiune = isnull(@parXML.value('(/*/@gestiune)[1]', 'varchar(20)'), ''),
			@lm = isnull(@parXML.value('(/*/@lm)[1]', 'varchar(20)'), ''),
			@denlm = isnull(@parXML.value('(/*/@denlm)[1]', 'varchar(100)'), ''),
			@comanda = isnull(@parXML.value('(/*/@comanda)[1]', 'varchar(20)'), ''),
			@tert = isnull(@parXML.value('(/*/@tert)[1]', 'varchar(20)'), ''),
			@codarticol = isnull(@parXML.value('(/*/@codarticol)[1]', 'varchar(20)'), ''),
			@grupGestiuni = isnull(@parXML.value('(/*/@grupGestiuni)[1]', 'varchar(50)'), '')
	
	IF OBJECT_ID('tempdb.dbo.#dateexportdoc') IS NOT NULL
		DROP TABLE #dateexportdoc

	select 
		p.tip TipDocument,
		rtrim(p.numar) NumarDocument,
		convert(char(10), p.data, 103) DataDocument,
		p.gestiune CodGestiune,
		g.denumire_gestiune DenumireGestiune,
		(case when p.tip='TE' then p.gestiune_primitoare else '-' end) CodGestiunePrimitoare,
		(case when p.tip='TE' then gp.denumire_gestiune else '-' end) DenumireGestiunePrimitoare,
		--Marci
		(case
			when p.tip in ('CI','PF','AF') then p.gestiune
			else '-' 
		end) MarcaPredator,
		(case
			when p.tip in ('CI','PF','AF') then isnull(pred.nume,'-')
			else '-' 
		end) AngajatPredator,
		--
		(case
			when p.tip in ('DF','PF') then p.gestiune_primitoare
			else '-' 
		end) MarcaPrimitor,
		(case
			when p.tip in ('DF','PF') then isnull(prim.nume,'-')
			else '-' 
		end)AngajatPrimitor,
		--		
		isnull(p.loc_de_munca,'-') CodLM,
		isnull(rtrim(lm.Denumire),'-') DenumireLM,
		isnull(p.comanda,'-') CodComanda,
		isnull(RTRIM(c.descriere),'-') DenumireComanda,
		isnull(p.tert,'-') CodTert,		
		rtrim(t.Denumire) DenumireTert,
		coalesce(p.lot, pozi.lot, '-') as Lot,
		(case when isnull(rtrim(gr.denumire),'')='' then '-' else n.grupa end) CodGrupa,
		isnull(rtrim(gr.denumire),'-') DenumireGrupa,
		rtrim(p.cod) CodArticol,
		rtrim(n.denumire) DenumireArticol,
		convert(decimal(15,2), p.cantitate) as Cantitate, 
		convert(decimal(15,2), p.Pret_de_stoc) as PretDeStoc, 
		convert(decimal(15,2), p.Pret_vanzare) as PretVanzare,
		convert(decimal(15,2), (case 
			when p.Tip in ('AP','AC','AS') then p.Cantitate * p.Pret_vanzare 
			when p.Tip in ('RM','RS') then p.Cantitate * p.Pret_de_stoc 
			else p.Cantitate * p.Pret_de_stoc end)) as Valoare,
		convert(decimal(15,2), p.TVA_deductibil) as TVA,
		isnull(p.valuta,'-') Valuta,
		(case when p.Valuta<>'' then convert(decimal(15,2), p.Pret_valuta) else 0 end) as PretValuta,
		(case when p.Valuta<>'' then convert(decimal(15,5), p.curs) else 0 end) as Curs,
		(case when p.tip in ('AP','AC','AS','RM','RS','RC','RP') then isnull(rtrim(p.factura),'-') else '-' end) Factura,
		(case when p.tip in ('AP','AC','AS','RM','RS','RC','RP') then convert(char(10), isnull(p.Data_facturii,'1901-01-01'), 103) else '-' end) DataFacturii,
		(case when ISNULL(p.tip,'') in ('AP','AS') then isnull(RTRIM(p.cont_venituri),'-') else '-' end) as ContVenit,
		isnull(RTRIM(p.cont_de_stoc),'-') as ContDeStoc,
		(case when ISNULL(p.tip_miscare,'')='E' then isnull(RTRIM(p.cont_corespondent),'-') else '-' end) as ContDeCheltuiala,
		isnull(RTRIM(p.Utilizator),'-') Utilizator,
		convert(char(10), isnull(p.Data_operarii,'1901-01-01'), 103) DataOperarii
	INTO #dateexportdoc
	from pozdoc p
	inner join doc d on d.subunitate=p.subunitate and d.tip=p.tip and d.numar=p.numar and d.data=p.data
	inner join nomencl n on p.cod=n.cod
	left join gestiuni g on g.cod_gestiune=p.gestiune
	left outer join gestiuni gp on gp.cod_gestiune=p.gestiune_primitoare
	left outer join lm on lm.Cod = p.Loc_de_munca
	left outer join terti t on t.tert = p.Tert and t.Subunitate=p.Subunitate
	left outer join comenzi c on c.comanda = p.Comanda
	left outer join grupe gr on gr.grupa=n.grupa
	left outer join personal prim on prim.marca=p.gestiune_primitoare
	left outer join personal pred on pred.marca=p.gestiune
	left outer join pozdoc pozi on pozi.idPozdoc = p.idIntrareFirma
	where p.subunitate=@subunitate
		and p.data between @datajos and @datasus
		and (@lista_lm = 0 or exists (select * from LMFiltrare lu where lu.utilizator=@utilizator and (lu.cod=d.Loc_munca OR lu.cod=d.detalii.value('(/*/@lmdest)[1]','varchar(20)'))))
		and (@dencod='' or n.cod+n.Denumire like '%'+@dencod+'%')
		and (@tert='' or t.tert=@tert)
		and (@denlm='' or lm.cod+lm.Denumire like '%'+@denlm+'%')
		and (@grupa='' or gr.grupa like @grupa + '%')
		and (@grupGestiuni = '' or g.cod_gestiune like @grupGestiuni + '%')
		and (@lm='' or lm.Cod like @lm + '%')
		and (@comanda='' or p.comanda=@comanda)
		and (@gestiune='' or p.gestiune=@gestiune)
		and (@tip='T' or p.tip=@tip)
		and (@codarticol = '' or n.cod = @codarticol)
	order by p.Data, p.tip, p.numar


	if exists(select * from sysobjects where name = 'wOPExpDocSP1')
		exec wOPExpDocSP1 @sesiune=@sesiune, @ParXML=@parXML

	select * from #dateexportdoc 
end try
begin catch
	set @eroare=ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@eroare,16,1)
end catch
