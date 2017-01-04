
create procedure wOPExportBalantaStocuri @idRulare int = 0
as
begin try
	set transaction isolation level read uncommitted

	/** parametri/filtre pentru rapBalantaStocuri */
	declare
		@sesiune varchar(50), @dDataJos datetime, @dDataSus datetime, @cCod varchar(20), @cGestiune varchar(20) ,
		@grupGestiuni varchar(20) , @cCodi varchar(20) , @cCont varchar(40) ,
		@TipStocuri varchar(20) ,@den varchar(20) , @gr_cod varchar(20) , 
		@tip_pret varchar(1) , @tiprap varchar(20) , @ordonare varchar(20) , @grupare4 bit,
		@comanda varchar(200), @centralizare int, @grupare int, @categpret smallint,
		@locatie varchar(30), @furnizor_nomenclator varchar(20), @furnizor varchar(50),
		@locm varchar(50), @locmg varchar(200), @parXML xml
	--> sql server 2005 nu stie declarare cu atribuire valoare:
	select @cGestiune = null,
		@grupGestiuni = null, @cCodi = null, @cCont = null,
		@TipStocuri = '', @den = null, @gr_cod = null, 
		@tip_pret = '0', @tiprap = 'D', @ordonare = '0', @grupare4 =0,
		@comanda =null, @centralizare =3, @grupare =0, @categpret =null,
		@locatie =null, @furnizor_nomenclator =null, @furnizor ='',
		@locm ='', @locmg =null

	select @parXML = parXML, @sesiune = @sesiune from asisria..ProceduriDeRulat where idRulare = @idRulare
	
	if @parXML IS NULL 
		raiserror('Eroare la citirea filtrelor. Detalii tehnice: parametrul XML nu exista!', 16, 1)

	select 
		@dDataJos = @parXML.value('(/*/@datajos)[1]', 'datetime'),
		@dDataSus = @parXML.value('(/*/@datasus)[1]', 'datetime'),
		@cCod = nullif(@parXML.value('(/*/@cod)[1]', 'varchar(20)'), ''),
		@cCont = nullif(@parXML.value('(/*/@cont)[1]', 'varchar(20)'), ''),
		@cGestiune = nullif(@parXML.value('(/*/@gestiune)[1]', 'varchar(20)'), ''),
		@locm = isnull(@parXML.value('(/*/@lm)[1]', 'varchar(50)'), ''),
		@den = nullif(@parXML.value('(/*/@denumire)[1]', 'varchar(200)'), ''),
		@grupGestiuni = nullif(@parXML.value('(/*/@grupGestiuni)[1]', 'varchar(20)'), '')

	if object_id('tempdb.dbo.#dateBalanta') is not null drop table #dateBalanta
	create table #dateBalanta (ordineNivDoc int, cont varchar(20), cod varchar(50), cod_intrare varchar(20), gestiune varchar(20),
		pret float, tip_document varchar(2), numar_document varchar(20), data datetime, stoci float, intrari float,
		iesiri float, DenGest varchar(200), DenProd varchar(200), um varchar(10), grupa varchar(20), nume_grupa varchar(200),
		nume_cont varchar(100), loc_de_munca varchar(50), den_marca varchar(200), den_lm varchar(200), predator varchar(200),
		stocCumulat float, valStocCumulat float, comanda varchar(100), valStoci float, valIntrari float, valIesiri float,
		grupare1 varchar(100), grupare2 varchar(100), grupare3 varchar(100), grupare4 varchar(100), grupare5 varchar(100),
		denumire1 varchar(200), denumire2 varchar(200), denumire3 varchar(200), denumire4 varchar(200),
		locatie varchar(100), lot varchar(100), ordonareGrupare varchar(100)
	)

	insert into #dateBalanta (ordineNivDoc, cont, cod, cod_intrare, gestiune, pret, tip_document, numar_document, data, stoci, intrari,
		iesiri, DenGest, DenProd, um, grupa, nume_grupa, nume_cont, loc_de_munca, den_marca, den_lm, predator,
		stocCumulat, valStocCumulat, comanda, valStoci, valIntrari, valIesiri, grupare1, grupare2, grupare3, grupare4, grupare5,
		denumire1, denumire2, denumire3, denumire4, locatie, lot, ordonareGrupare)
	exec rapBalantaStocuri @sesiune = @sesiune, @dDataJos = @dDataJos, @dDataSus = @dDataSus, @cCod = @cCod, @cGestiune = @cGestiune,
		@grupGestiuni = @grupGestiuni, @cCodi = @cCodi, @cCont = @cCont, @TipStocuri = @TipStocuri, @den = @den, @gr_cod = @gr_cod,
		@tip_pret = @tip_pret, @tiprap = @tiprap, @ordonare = @ordonare, @grupare4 = @grupare4, @comanda = @comanda, @centralizare = @centralizare,
		@grupare = @grupare, @categpret = @categpret, @locatie = @locatie, @furnizor_nomenclator = @furnizor_nomenclator, @furnizor = @furnizor,
		@locm = @locm, @locmg = @locmg


	select 
		rtrim(gestiune) as CodGestiune, rtrim(DenGest) as Gestiune, rtrim(grupa) as CodGrupa, rtrim(nume_grupa) as Grupa,
		rtrim(cont) as Cont, rtrim(nume_cont) as DenumireCont, rtrim(cod) as CodProdus, rtrim(DenProd) as Produs, rtrim(um) as UM,
		rtrim(cod_intrare) as CodIntrare, tip_document as TipDocument, isnull(numar_document, '-') as NumarDocument,
		convert(varchar(10), data, 103) as Data, rtrim(predator) as PredatorPrimitor, convert(decimal(17,4), pret) as Pret,
		convert(decimal(15,3), stoci) as StocInitial, convert(decimal(15,2), valStoci) as ValoareStocInitial,
		convert(decimal(15,3), intrari) as Intrari, convert(decimal(15,2), valIntrari) as ValoareIntrari,
		convert(decimal(15,3), iesiri) as Iesiri, convert(decimal(15,2), valIesiri) as ValoareIesiri,
		convert(decimal(15,3), stoci + intrari - iesiri) as Stoc,
		convert(decimal(15,2), valStoci + valIntrari - valIesiri) as ValoareStoc
	from #dateBalanta
	order by gestiune, cod_intrare, data
end try

begin catch
	declare @mesajEroare varchar(500)
	set @mesajEroare = error_message() + ' (' + object_name(@@procid) + ')'
	raiserror(@mesajEroare, 16, 1)
end catch
