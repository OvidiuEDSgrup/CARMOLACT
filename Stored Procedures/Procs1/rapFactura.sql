	/*
	Formular in lei

	pret_unitar =  pret_valuta*curs (daca este)
	tva_unitar= tva_fara discount(vezi mai jos)

	pret_vanzare = pret vanzare cu discount (discountat), totdeauna in LEI

	totalfaratva =cantitate*pret_vanzare
	totaltva = sum(tva_deductibil)

	total fara discount = pret_valuta*curs(daca este)*cantitate
	tva fara discount = pret_valuta*curs(daca este)*cantitate*cota_tva

	discount aplicat se ia prin diferenta (se afiseaza doar daca exista)

	Formular in valuta - daca tert = decontari in valuta (alt formular)
	- alta forma si formule
	- valorile se impart la curs



	EXEMPLU APEL 
		exec rapFactura @sesiune='',@tip='AS', @numar='11000129', @data='2016-01-27', @nrexemplare=1
	*/
create procedure rapFactura (@sesiune varchar(50)=null, @tip varchar(2), @numar varchar(20), @data datetime, @nrExemplare int=1,
	@nrzecimalepret int=null,		--> = numar maxim de zecimale returnate pe campul pret_unitar
			--> daca se doreste trimiterea numarului maxim de zecimale; daca nu e primit procedura va aduce numarul de zecimale la nr maxim din datele returnate
		--> filtre - pentru generarea de formulare pentru un set de documente; are efect doar daca @multedocumente este 1:
	@parXML xml = NULL, @numeTabelTemp varchar(100) = NULL OUTPUT,
	@multedocumente bit=0,
	@datajos datetime=null, @datasus datetime=null, @lm varchar(50)=null,
	@tert varchar(50)=null, @factura varchar(50)=null, @gestiune varchar(50)=null
	)
as
begin try
	set transaction isolation level read uncommitted
	declare 
		@mesajEroare varchar(500),  @subunitate varchar(20),
		@nrmaxim int,	--> @nrmaxim = numarul maxim de documente pentru a evita blocarea serverului sau rularea formularului pe prea multe date,
		@idAntetBon int, @comandaSQL nvarchar(max), @dataFacturii datetime,
		@detalii xml, @data_expedierii datetime, @ora_expedierii varchar(5), @cData_expedierii varchar(30)
	set @mesajEroare=''
	-- LASATI SA RAMANA PRIMUL LUCRU CITIT (pentru cand raportul e apelat prin wTipFormular)
	if len(@numeTabelTemp) > 0 --## nu se poate trimite in URL 
		set @numeTabelTemp = '##' + @numeTabelTemp
	
	if exists (select * from tempdb.sys.objects where name = @numeTabelTemp)
	begin 
		set @comandaSQL = 'select @parXML = convert(xml, parXML) from ' + @numeTabelTemp + '
		drop table ' + @numeTabelTemp
		exec sp_executesql @statement = @comandaSQL, @params = N'@parXML as xml output', @parXML = @parXML output
	end

	select @nrmaxim=500
	select @idAntetBon = ISNULL(@parXML.value('(/row/@idantetbon)[1]', 'int'), 0)

	exec luare_date_par 'GE', 'SUBPRO', 0, 0, @subunitate output

	IF COALESCE (@datajos, @datasus) IS NOT NULL
		select @multedocumente = 1

	if object_id('tempdb.dbo.#filtre') is not null 
		drop table #filtre	
	
	create table #filtre (subunitate varchar(20), tip varchar(2), numar varchar(20), data datetime, utilizator varchar(50), numeutilizator varchar(50) default null, cnputilizator varchar(50) default null)
			
	--> determinare documente si date auxiliare in functie de filtre:
	if @multedocumente=1	
		select 
			@datajos=isnull(@datajos,'1901-01-01'),
			@datasus=isnull(@datasus,'2900-1-1'),
			@lm=rtrim(@lm)+'%'
	
	insert into #filtre (subunitate, tip, numar, data, utilizator, numeutilizator, cnputilizator)
	select top (@nrmaxim+1) @subunitate, p.tip, numar, data, max(p.utilizator), max(rtrim(u.Nume)), isnull(rtrim(dbo.wfProprietateUtilizator('CNP', max(p.utilizator))), '')
	from pozdoc p
		left join utilizatori u on u.ID = p.utilizator
	where 
		p.tip=@tip and
		@multedocumente=0 and p.numar=@numar and p.data=@data
	group by p.tip, numar, data
	union all
	select top (@nrmaxim+1) @subunitate, p.tip, numar, data, max(p.utilizator), max(rtrim(u.Nume)), isnull(rtrim(dbo.wfProprietateUtilizator('CNP', max(p.utilizator))), '')
	from docsters p
		left join utilizatori u on u.ID = p.utilizator
	where 
		p.tip=@tip and
		@multedocumente=0 and p.numar=@numar and p.data=@data
	group by p.tip, numar, data
	union all
	select top (@nrmaxim+1) @subunitate, p.tip, numar, data, max(p.utilizator), max(rtrim(u.Nume)), isnull(rtrim(dbo.wfProprietateUtilizator('CNP', max(p.utilizator))), '')
	from pozdoc p
		left join utilizatori u on u.ID = p.utilizator
	where 
		p.tip=@tip 
		and @multedocumente=1 
		and p.data between @datajos and @datasus
		and subunitate=@subunitate
		and (@lm is null or p.loc_de_munca like @lm)
		and (@tert is null or p.tert like @tert)
		and (@factura is null or p.factura like @factura)
		and (@gestiune is null or p.gestiune like @gestiune)
	group by p.tip, numar, data

	if (select count(1) from #filtre)>@nrmaxim
	begin
		select @mesajEroare ='Numarul de documente depaseste '+convert(varchar(20),@nrmaxim)+'! Reduceti intervalul calendaristic sau completati filtre suplimentare!'
		raiserror(@mesajEroare,16,1)
	end

	/** Daca se da factura din PVria, fara descarcare prioritara, va trebui sa citim datele din bonuri.
		Se trimite in @parXML idantetbon, vom determina bonul respectiv, si vom apela procedura de PV pentru factura.
	*/
	if @idAntetBon <> 0
	begin
		select @tert = RTRIM(a.Tert), @dataFacturii = a.Data_facturii, @factura = RTRIM(a.Factura)
		from antetBonuri a 
		where a.IdAntetBon = @idAntetBon
		
		declare @xmlPv xml, @numeTabelTempPV varchar(100)
		set @xmlPv = (select @tert as tert, convert(char(10), @dataFacturii, 101) as data, @factura as factura,
			1 as facturaNoua for xml raw)

		exec formularFacturaPV @sesiune	= @sesiune, @parXML = @xmlPv, @numeTabelTemp = @numeTabelTemp output
		return
	end

	/** Factura din ASiSria */

	IF OBJECT_ID('tempdb.dbo.#PozDocFiltr') IS NOT NULL
		DROP TABLE #PozDocFiltr
	IF OBJECT_ID('tempdb.dbo.#DocFiltr') IS NOT NULL
		DROP TABLE #DocFiltr
	
	create table #DocFiltr(
		tip varchar(2), numar varchar(20), data datetime,
		tert varchar(20), factura varchar(20), data_facturii datetime, data_scadentei datetime, total float, total_tva float, total_discount float, total_tva_nediscountat float, 
		valuta varchar(20), curs float, detalii xml, gestiune varchar(20), gestiune_primitoare varchar(20))	
	create table #PozDocFiltr (tip varchar(2), numar varchar(20), data datetime, tert varchar(50),
		factura varchar(20), cod varchar(20), denumire varchar(100), um varchar(20), cantitate float, pret float, pret_valuta float, pret_vanzare float, tva_deductibil float,  
		cota_tva float, tva_nediscountat float, valoare float, curs float, valuta varchar(20), discount_unitar float, discount float, subtip varchar(2), 
		numeutilizator varchar(100) default null, cnputilizator varchar(50) default null,
		locm varchar(50) default null, comanda varchar(50), gestiune varchar(20), gestiune_primitoare varchar(20), data_facturii datetime, data_scadentei datetime, nraviz varchar(20), idpozdoc int)
	
	/*	Selectie date din PozDoc (SELECTUL PRINCIPAL) in # fara Intocmire Facturi si altele*/
	insert into #PozDocFiltr (tip, numar, data, tert, factura, cod, denumire, um, cantitate, pret, valoare, pret_valuta, curs, cota_tva, pret_vanzare, tva_deductibil, tva_nediscountat, 
		discount_unitar, discount, subtip, numeutilizator, cnputilizator, locm, comanda, valuta, gestiune, gestiune_primitoare, data_facturii, data_scadentei,idpozdoc)
	select
		max(p.tip),
		p.numar, 
		p.data,
		max(p.tert),
		max(p.factura), 
		p.cod, 
		rtrim(max(n.denumire)),
		max(n.um), 
		sum(cantitate), 
		p.Pret_valuta*(case when max(p.curs)>0 then max(p.curs) else 1 end), 
		sum(round(convert(decimal(18,5),p.cantitate*p.pret_valuta*(case when p.curs>0 then p.curs else 1 end)),2)), 
		p.pret_valuta,
		max(p.curs) curs ,
		max(p.cota_tva) cota_tva,
		p.pret_vanzare,
		SUM(p.tva_deductibil),
		--pret_valuta*(case when max(p.curs)>0 then max(p.curs) else 1 end)*max(p.cota_tva)/100,
		SUM(case when p.pret_vanzare=0 then 0 else p.tva_deductibil*p.pret_valuta*(case when p.curs>0 then p.curs else 1 end)/p.Pret_vanzare end), -- tva_nediscountat
		sum(round(convert(decimal(18,5),p.cantitate*p.pret_valuta*(case when p.curs>0 then p.curs else 1 end)),2)-round(convert(decimal(18,5),p.cantitate*p.pret_vanzare),2)),
		round(convert(decimal(15,2), p.discount), 2),
		max(p.subtip), max(f.numeutilizator), max(f.cnputilizator), max(p.loc_de_munca), rtrim(p.Comanda),
		max(p.valuta), max(p.gestiune), max(p.gestiune_primitoare), max(p.data_facturii), max(p.data_scadentei), max(idpozdoc)		
	from PozDoc p 
	inner join #filtre f on f.subunitate=p.subunitate and f.tip=p.tip and f.data=p.data and f.numar=p.numar
	JOIN nomencl n on p.cod=n.cod
	LEFT JOIN CONTURI C ON p.cont_de_stoc=c.cont
	where p.cont_de_stoc not like '418%'
	group by p.numar, p.data, p.tert, p.factura, p.cod, p.pret_vanzare, p.pret_valuta, p.Discount, p.Comanda
	
	/*	Selectie date din DOCSTERS (facturi anulate)*/
	insert into #PozDocFiltr (tip, numar, data, tert, factura, cod, denumire, um, cantitate, pret, valoare, pret_valuta, curs, cota_tva, pret_vanzare, tva_deductibil, tva_nediscountat, 
		discount_unitar, discount, subtip, numeutilizator, cnputilizator, locm, comanda, valuta, gestiune, gestiune_primitoare, data_facturii, data_scadentei)
	select
		max(p.tip),
		p.numar, 
		p.data,
		max(p.tert),
		max(p.factura), 
		p.cod, 
		rtrim(max(n.denumire)),
		max(n.um), 
		sum(cantitate), 
		isnull(p.Pret_valuta,p.pret_vanzare)*(case when max(isnull(p.curs,0))>0 then max(isnull(p.curs,0)) else 1 end), 
		sum(round(convert(decimal(18,5),p.cantitate*isnull(p.Pret_valuta,p.pret_vanzare)*(case when isnull(p.curs,0)>0 then isnull(p.curs,0) else 1 end)),2)), 
		isnull(p.Pret_valuta,p.pret_vanzare),
		max(p.curs) curs ,
		max(isnull(p.cota_tva,n.cota_tva)) cota_tva,
		p.pret_vanzare,
		SUM(isnull(p.tva_deductibil,round(p.cantitate*p.pret_vanzare*n.cota_tva/100.00,2))),
		--pret_valuta*(case when max(p.curs)>0 then max(p.curs) else 1 end)*max(p.cota_tva)/100,
		SUM(isnull(p.tva_deductibil,round(p.cantitate*p.pret_vanzare*n.cota_tva/100.00,2))*isnull(p.Pret_valuta,p.pret_vanzare)*(case when isnull(p.curs,0)>0 then isnull(p.curs,0) else 1 end)/p.Pret_vanzare),
		sum(round(convert(decimal(18,5),p.cantitate*isnull(p.Pret_valuta,p.pret_vanzare)*(case when isnull(p.curs,0)>0 then isnull(p.curs,0) else 1 end)),2)-round(convert(decimal(18,5),p.cantitate*p.pret_vanzare),2)),
		round(convert(decimal(15,2), isnull(p.discount,0)), 2),
		max(isnull(p.subtip,'')), max(f.numeutilizator), max(f.cnputilizator), max(isnull(p.loc_de_munca,'')), rtrim(isnull(p.Comanda,'')),
		max(isnull(p.valuta,'')), max(p.gestiune), max(p.gestiune_primitoare), max(isnull(p.data_facturii,p.data)), max(isnull(p.data_scadentei,p.data))		
	from docSters p 
	inner join #filtre f on f.subunitate=p.subunitate and f.tip=p.tip and f.data=p.data and f.numar=p.numar
	JOIN nomencl n on p.cod=n.cod
	LEFT JOIN CONTURI C ON p.cont=c.cont
	group by p.numar, p.data, p.tert, p.factura, p.cod, p.pret_vanzare, p.pret_valuta, p.Discount, p.Comanda
	
	/* 
		Selectie date din PozDoc in # doar pentru INTOCMIRE FACTURA 
		Intocmire Facturi = c.sold_credit=2 adica cont de stoc este atribuit Clienti
		Se iau datele din avize
	*/
	insert into #PozDocFiltr (tip, numar, data, tert, factura, cod, denumire, um, cantitate, pret, valoare, pret_valuta, curs, cota_tva, pret_vanzare, tva_deductibil, tva_nediscountat, 
		discount_unitar, discount, subtip, numeutilizator, cnputilizator, locm, comanda, valuta, gestiune, gestiune_primitoare, data_facturii, data_scadentei, nraviz, idpozdoc)
	select
		intoc.tip,
		rtrim(intoc.numar), 
		intoc.data,
		intoc.tert,
		intoc.factura, 
		rtrim(avize.cod), 
		n.denumire, 
		n.um, 
		avize.Cantitate*intoc.pret_vanzare*intoc.cantitate/cr.total as cantitate, -- cantitate
		avize.Pret_valuta*(case when avize.curs>0 then avize.curs else 1 end), 
		round(convert(decimal(18,5),avize.cantitate*avize.pret_valuta*(case when avize.curs>0 then avize.curs else 1 end)),2),
		avize.pret_valuta,
		intoc.curs curs ,
		intoc.cota_tva cota_tva,
		intoc.pret_vanzare,
		avize.Cantitate*avize.pret_vanzare*intoc.TVA_deductibil/cr.total, -- tva_deductibil
		avize.Cantitate*avize.pret_valuta*(case when avize.curs>0 then avize.curs else 1 end)*intoc.TVA_deductibil/cr.total, -- tva_nediscountat - nu se lucreaza cu discount la IF 
		round(convert(decimal(18,5),intoc.cantitate*intoc.pret_valuta*(case when intoc.curs>0 then intoc.curs else 1 end)),2)-round(convert(decimal(18,5),intoc.cantitate*intoc.pret_vanzare),2),
		intoc.discount,
		rtrim(avize.subtip), 
		rtrim(f.numeutilizator), 
		rtrim(f.cnputilizator), 
		rtrim(avize.loc_de_munca), 
		rtrim(avize.Comanda),
		avize.valuta, 
		avize.gestiune, 
		avize.gestiune_primitoare, 
		avize.data_facturii, 
		intoc.data_scadentei,
		avize.numar,	
		avize.idpozdoc	
	from PozDoc intoc
	inner join #filtre f on f.subunitate=intoc.subunitate and f.tip=intoc.tip and f.data=intoc.data and f.numar=intoc.numar
	INNER join pozdoc avize on intoc.subunitate=avize.subunitate and intoc.tip=avize.tip and avize.factura=intoc.cod_intrare and intoc.tert=avize.tert and avize.cota_tva=intoc.cota_tva
	CROSS APPLY (select sum(cantitate*pret_vanzare) total from PozDoc where subunitate=intoc.subunitate and tip=intoc.tip and factura=intoc.cod_intrare and tert=intoc.tert and cota_tva=intoc.cota_tva) cr
	JOIN nomencl n on avize.cod=n.cod
	LEFT JOIN CONTURI C ON intoc.cont_de_stoc=c.cont
	where intoc.cont_de_stoc like '418%'
	--group by intoc.numar, intoc.data, intoc.tert, intoc.factura, avize.cod, avize.Comanda, avize.numar, avize.pret_valuta

	/** Selectie date din DOC in # unde vom avea totaluri, etc **/
	insert into #DocFiltr (tip, numar, data, tert, factura, data_facturii, data_scadentei, total, total_tva, total_discount, total_tva_nediscountat, valuta, curs, detalii, gestiune, gestiune_primitoare)
	select
			p.tip,
			p.numar, 
			p.data, 
			p.tert,
			p.Factura factura,
			max(p.data_facturii),
			max(p.data_scadentei),						
			sum(p.valoare) ,
			sum(p.tva_deductibil),
			sum(p.discount_unitar),
			--sum(round(p.cantitate*p.Pret_valuta*(case when p.curs>0 then p.curs else 1 end)*p.cota_tva/100.0, 2)),			
			sum(tva_nediscountat), 
			max(p.valuta),
			max(p.curs),
			NULL as detalii, --le vom lua cu update din DOC
			max(p.gestiune),
			max(p.Gestiune_primitoare)
	from #PozDocFiltr p
	group by p.tip, p.numar, p.data, p.factura, p.tert	
--	if suser_name()='CLUJ\luci.maier' select * from #pozdocfiltr
	update 	d
		set detalii = dc.detalii,
		Gestiune_primitoare=dc.gestiune_primitoare
	from #DocFiltr d
	JOIN Doc dc on d.numar=dc.numar and d.tip=dc.tip and d.data=dc.data

	if object_id('tempdb.dbo.#date_factura') is not null
		drop table #date_factura
	
	/** Datele despre firma se vor stoca de acum incolo in tabela #dateFirma */
	IF OBJECT_ID('tempdb.dbo.#dateFirma') IS NOT NULL 
		DROP TABLE #dateFirma
	CREATE TABLE #dateFirma(locm varchar(50))

	exec wDateFirma_tabela

	insert into #dateFirma(locm)
	select distinct d.loc_de_munca from #filtre f inner join pozdoc d on f.subunitate=d.subunitate and f.numar=d.numar and f.tip=d.tip and f.data=d.data union 
	select locm from #pozdocfiltr

	EXEC wDateFirma

	declare @nrzecimalepret_maxim int
	select @nrzecimalepret_maxim=(case when @nrzecimalepret is null then 5 else @nrzecimalepret end)
	
	/* Selectul care returneaza datele din cele doua tabele */
	select 
		--> antet, totaluri, samd
		rtrim(p.numar) numar, p.data data_doc,
		nr.N as nr,
		row_number() over (partition by nr.n, p.numar, p.data order by p.cod) as nrint,
		df.firma as unitate,
		df.capitalSocial as capital,
		df.ordreg as ordreg, 
		df.codFiscal as codfiscal,
		df.adresa as adresa,
		df.judet as judet,
		df.cont as cont,
		df.banca as banca,
		df.telfax as telfax,
		RTRIM(g.Denumire_gestiune) AS pctlucru,
		ISNULL(g.detalii.value('(/row/@adresa)[1]', 'varchar(200)'), '') AS adresa_pctlucru,
		RTRIM(d.factura) as factura,
		RTRIM(p.tert) as codtert,
		ISNULL(NULLIF(d.detalii.value('(//@numepf)[1]','varchar(100)'),''), rtrim(t.denumire)) as tert,
		rtrim(it.banca3) as ordreg_ben,
		ISNULL(NULLIF(d.detalii.value('(//@codpf)[1]','varchar(100)'),''),RTRIM(t.cod_fiscal)) as codfiscal_ben,
		ISNULL(NULLIF(d.detalii.value('(//@judetpf)[1]','varchar(100)'),''),RTRIM(isnull(j.denumire, t.judet))) as judet_ben,
		isnull(rtrim(l.oras), rtrim(t.localitate)) AS localitate_ben,
		ISNULL(NULLIF(d.detalii.value('(//@adresapf)[1]','varchar(100)'),''),convert(varchar(500), (isnull(rtrim(l.oras), rtrim(t.localitate)) + ', ' + ltrim(left(t.adresa, 60))))) as adresa_ben,
		rtrim(t.cont_in_banca) as cont_ben,
		(isnull(rtrim(b.Denumire), rtrim(t.banca)) + ', ' + rtrim(b.Filiala)) as banca_ben,
		isnull(rtrim(t.Telefon_fax), '') as telfax_ben,
		isnull(rtrim(inf.Descriere) + ', ' + ltrim(rtrim(inf.e_mail)), '') as pctlivrare,
		d.data_facturii data,
		d.data_scadentei data_scadentei,

		/* Totaluri finale cu discount inclus*/
		round((case t.tert_extern when 0 then d.total - d.total_discount else (d.total - d.total_discount)/ISNULL(NULLIF(d.curs,0),1) end),2) total,
		round((case t.tert_extern when 0 then d.total - d.total_discount +d.total_tva else (d.total - d.total_discount +d.total_tva)/ISNULL(NULLIF(d.curs,0),1) end ),2) totalcutva,
		round((case t.tert_extern when 0 then d.total_tva else d.total_tva/ISNULL(NULLIF(d.curs,0),1) end),2) totaltva , 
		round((case t.tert_extern when 0 then d.total_discount else d.total_discount/ISNULL(NULLIF(d.curs,0),1) end),2) totaldiscount, 
		round((case t.tert_extern when 0 then d.total_tva_nediscountat-d.total_tva else (d.total_tva_nediscountat-d.total_tva)/ISNULL(NULLIF(d.curs,0),1) end ),2 )totaldiscounttva, 
		d.valuta,
		d.curs,
		p.cota_tva,

		--> date pozitii
		rtrim(p.cod) cod,
		RTRIM(p.denumire) denumire,
		RTRIM(p.um) um,
		p.cantitate cantitate,
--> aici
		convert(decimal(15,5),round((case t.tert_extern when 0 then p.pret else p.pret/ISNULL(NULLIF(d.curs,0),1) end),@nrzecimalepret_maxim)) pret_unitar,
		round((case t.tert_extern when 0 then p.valoare else p.valoare/ISNULL(NULLIF(d.curs,0),1) end),2) valoare,
		round((case t.tert_extern when 0 then p.tva_nediscountat else p.tva_nediscountat/ISNULL(NULLIF(d.curs,0),1) end),2) tva_unitar, -- de fapt nu e unitar!
		p.discount as discount, -- discount procentual
		round((case t.tert_extern when 0 then p.discount_unitar else p.discount_unitar/ISNULL(NULLIF(d.curs, 0), 1) end), 2) as discount_unitar,
		round((case t.tert_extern when 0 then p.pret - p.discount_unitar else (p.pret - p.discount_unitar)/ISNULL(NULLIF(d.curs,0),1) end),5) as pret_unitar_discountat,
		isnull(p.subtip, '') as subtip,

		--> footer, delegat, samd
		isnull(convert(varchar(10), d.detalii.value('(/row/@data_expedierii)[1]', 'datetime'), 103), '') as data_expedierii,
		isnull(rtrim(del.descriere), '') as delegat,
		isnull(d.detalii.value('(/row/@ora_expedierii)[1]', 'varchar(6)'), '') as ora_expedierii,
		isnull(dbo.fStrToken(del.Buletin, 1, ','), '') as ci_delegat,
		isnull(dbo.fStrToken(del.Buletin, 2, ','), '') as cis_delegat,
		isnull(rtrim(del.Eliberat), '') as eliberat_delegat,
		isnull(rtrim(del.Mijloc_tp), '')  as auto_delegat,
		isnull(p.numeutilizator, '') as ion,
		isnull(p.cnputilizator, '') as cnp,
		convert(varchar(1000), rtrim(isnull(d.detalii.value('(/row/@observatii)[1]', 'varchar(1000)'),''))) as observatii,
		p.locm,
		rtrim(p.comanda) as comanda,
		rtrim(com.Descriere) as dencomanda,
		p.nraviz aviz, 
		p.idpozdoc
	into #date_factura
	from #PozDocFiltr p
	JOIN #DocFiltr d on p.factura=d.factura and p.tip=d.tip and p.numar=d.numar and p.data=d.data and p.tert=d.tert
	JOIN Terti t on t.Subunitate = @subunitate and t.tert = d.tert
	JOIN dbo.Tally nr on nr.n <= @nrExemplare
	LEFT JOIN infotert it on it.Subunitate = @subunitate and it.Tert = t.tert and it.Identificator = ''
	LEFT JOIN infotert del on del.identificator=isnull(rtrim(d.detalii.value('(/row/@delegat)[1]', 'varchar(20)')), '')
		and del.tert=isnull(rtrim(d.detalii.value('(/row/@tertdelegat)[1]', 'varchar(20)')), '') and del.subunitate='C1'
	LEFT JOIN infotert inf ON inf.Subunitate = @subunitate AND inf.Tert = t.Tert AND inf.Identificator <> '' AND inf.Identificator = d.gestiune_primitoare
	LEFT JOIN localitati l on t.localitate = l.cod_oras
	LEFT JOIN judete j on t.judet = j.cod_judet
	LEFT JOIN bancibnr b on b.Cod = t.Banca
	LEFT JOIN gestiuni g ON g.Cod_gestiune = d.gestiune
	LEFT JOIN #dateFirma df ON df.locm=p.locm
	LEFT JOIN comenzi com ON com.Comanda = p.comanda
	
	
	
	if @nrzecimalepret is null
	select max(	--> aflu lungimea maxima a zecimalelor relevante dupa cum urmeaza:
		case when x.zecimale=0 then 0 else 
		len(		--> daca am ramas cu inversul lexicografic al partii fractionare sub forma de parte intreaga fostele zecimale irelevante dispar de la sine - exceptie facand 0 zecimale
			x.zecimale
			) end) nrzecimalepret
		,d.numar, d.data_doc, d.nr
		into #zecimale	--> zecimalele la nivelul fiecarei facturi
		from #date_factura d
		cross apply (select floor(	--> elimin fosta parte intreaga
				reverse(	--> inversez lexicografic partea fractionara cu partea intreaga
				convert(decimal(15,5),pret_unitar))
			) as zecimale) x	--> cross apply sa nu scriu expresia de doua ori la verificarea a 0 zecimale
		group by d.numar, d.data_doc, d.nr
		
	if @nrzecimalepret is not null
		update #date_factura set pret_unitar=round(pret_unitar,@nrzecimalepret)
	
	/* Se permite modificarea acestor doua tabele pentru a altera datele inainte ca ele sa fie returnate*/	
	IF EXISTS (select 1 from sysobjects where name='rapFacturaSP')
		exec rapFacturaSP @sesiune=@sesiune, @tip= @tip, @numar = @numar, @data = @data

	Select d.*
		,z.nrzecimalepret
		,left(convert(varchar(200),convert(money,floor(d.pret_unitar)),1)
			,charindex('.',
			 convert(varchar(200),convert(money,floor(d.pret_unitar)),1))-1
		)
			+(case when z.nrzecimalepret=0 then '' else substring(convert(varchar(200),d.pret_unitar), charindex('.',convert(varchar(200),d.pret_unitar)),z.nrzecimalepret+1) end)
		 pret_unitar_str
	from #date_factura d
		inner join #zecimale z on d.numar=z.numar and d.data_doc=z.data_doc and d.nr=z.nr
	order by d.factura, d.cod, d.nr 
	
	drop table #date_factura
end try
begin catch
	set @mesajEroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
end catch

if object_id('tempdb.dbo.#filtre') is not null 
	drop table #filtre

if len(@mesajEroare)>0
begin
	select '<EROARE>' AS pctlucru, @mesajEroare AS adresa_pctlucru, 1 nr
	--raiserror(@mesajEroare, 16, 1)	--> nu are sens raiserror ca afiseaza raportul problema; cel mult incurca - uneori agata procedura
end
