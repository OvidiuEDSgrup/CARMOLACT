-- procedura folosita pentru generarea de facturi din contracte/comenzi
CREATE PROCEDURE [dbo].[wOPFacturareContracteSP] @sesiune VARCHAR(50), @parXML XML, @idRulare int = 0
AS
BEGIN TRY
	if @idRulare=0 
	begin	
		declare @numeProcedura varchar(500)
		set @numeProcedura = object_name(@@procid)
		if @parXML.value('(/*/@secundeRefresh)[1]','int') is null
			set @parXML.modify('insert attribute secundeRefresh {"2"} as first into (/*)[1]')
		exec wOperatieLunga @sesiune=@sesiune, @parXML=@parXML, @procedura=@numeProcedura
		return	
	end

	select @sesiune=p.sesiune, @parXML=p.parXML
	from asisria..ProceduriDeRulat p
	where idRulare=@idrulare  

	declare @procid int=@@procid, @objname sysname
	set @objname=object_name(@procid)
	EXEC wJurnalizareOperatie @sesiune=@sesiune, @parXML=@parXML, @obiectSql=@objname

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	DECLARE 
		@docJurnal XML, @idContract INT, @tertdelegat VARCHAR(20), @lm VARCHAR(20), @gestiune VARCHAR(20), @grupa VARCHAR(20), @mesaj VARCHAR(400), 
		@explicatiiJurnal VARCHAR(60), @detaliiJurnal XML, @dataJos DATETIME, @dataSus DATETIME, @detaliiContract XML, @gestiune_primitoare VARCHAR(20), 
		@valuta VARCHAR(20), @curs FLOAT, @punct_livrare VARCHAR(20), @stare INT, @mijlocInterval datetime, @xml xml,
		@nrContracte int, @utilizator varchar(50), @cNrFact varchar(20), @numarFact int, @serieFact varchar(50), @idContractFiltrat int, @data_facturilor datetime,
		@formular varchar(50), @dataAzi datetime, @iDoc int, @fara_mesaje bit, @ddoc int, @xml_proc xml, @cuRezervari bit, @gestiuneRezervari varchar(20), @detalii xml,
		@tip varchar(2), @aviznefacturat bit, @numar_pozdoc varchar(20), @nrFacturi int, @fara_mesaj bit
		/** Variabile pt scrierea in AnexFac **/
		
		,@delegat varchar(20) ,@dendelegat varchar(100), @dentertdelegat varchar(100), @nou bit, @data_expedierii datetime, @ora_expedierii varchar(6),
		@observatii varchar(300), -- observatii expeditie
		@nume varchar(150), @prenume varchar(150), -- cand parsam delegatInexistent (fullname delegat), punem in aceste doua variabile
		@delegatInexistent varchar(300), -- nu exista in infotert
		@cDataExpedierii varchar(30), @nrauto varchar(20), @dennrauto varchar(50)
		, @seriaBuletin VARCHAR(10), @numarBuletin VARCHAR(10), @eliberat VARCHAR(30)

	EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT
	EXEC luare_date_par 'GE','REZSTOCBK', @cuRezervari OUTPUT, 0, @gestiuneRezervari OUTPUT

	SELECT
		@formular = isnull(@parXML.value('(/*/@nrform)[1]', 'varchar(50)'),''), -- codul formularului folosit pt. generare facturi
		@dataJos = isnull(@parXML.value('(/*/@datajos)[1]', 'datetime'),'1901-01-01'), -- data inferioara pt. filtrare
		@dataSus = isnull(@parXML.value('(/*/@datasus)[1]', 'datetime'),'2999-01-01'), -- data superioara pt. filtrare
		@data_facturilor = isnull(@parXML.value('(/*/@data_facturii)[1]', 'datetime'), convert(datetime, convert(char(10), getdate(), 101), 101)),
		@numar_pozdoc = NULLIF(@parXML.value('(/*/@numar_pozdoc)[1]', 'varchar(20)'),''),
		@valuta = ISNULL(@parXML.value('(/*/@valuta)[1]', 'varchar(20)'),''), -- filtru valuta
		@curs = @parXML.value('(/*/@curs)[1]', 'float'), -- cursul de facturare
		@fara_mesaje = ISNULL(@parXML.value('(//@fara_mesaje)[1]', 'bit'),0),
		@tip = ISNULL(@parXML.value('(//@tipdoc)[1]', 'varchar(2)'),'AP'),
		@aviznefacturat = isnull(@parXML.value('(/*/@aviznefacturat)[1]', 'bit'),0)
		
	if @parXML.exist('(/*/detalii)[1]')=1
	begin
		SET @detalii = @parXML.query('(/*/detalii/row)[1]')
		/** Variabile pt scrierea in AnexFac **/
		set @tertdelegat = @parXML.value('(/*/detalii/row/@tertdelegat)[1]', 'varchar(20)')
		set @delegat = @parXML.value('(/*/detalii/row/@delegat)[1]', 'varchar(20)')
		set @dentertdelegat = @parXML.value('(/*/detalii/row/@dentertdelegat)[1]', 'varchar(100)')
		set @dendelegat = @parXML.value('(/*/detalii/row/@dendelegat)[1]', 'varchar(100)')
		set @data_expedierii = @parXML.value('(/*/detalii/row/@data_expedierii)[1]', 'datetime')
		set @ora_expedierii = @parXML.value('(/*/detalii/row/@ora_expedierii)[1]', 'varchar(6)')
		set @observatii = @parXML.value('(/*/detalii/row/@observatii)[1]', 'varchar(300)')
		set @nrauto = @parXML.value('(/*/detalii/row/@nrauto)[1]', 'varchar(20)')
		set @dennrauto = @parXML.value('(/*/detalii/row/@dennrauto)[1]', 'varchar(50)')
	end

	update asisria..ProceduriDeRulat 
		set procent_finalizat=0, statusText='Iau comenzile alese ...'
	where idRulare=@idrulare 

	--citire date din gridul de operatii
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @parXML
	IF OBJECT_ID('tempdb..#xmlPozitii') IS NOT NULL
		DROP TABLE #xmlPozitii
	
	SELECT 
		isnull(idContract,idContractAntet) as idContract, 
		--idPozContract, 
		numar_contract,
		data_contract=try_convert(datetime,data_contract,101),
		--cod,
		--convert(decimal(17,5),pret) as pret, 
		--CONVERT(decimal(12,2),discount) as discount,
		--isnull(defacturat, cantitate) as cantitate, 
		valuta as valuta,
		convert(decimal(12,5),curs) as curs, 
		--cod_specific as cod_specific, 
		--NULLIF(cod_intrare,'') cod_intrare, 
		tert,
		gestiune,
		--comanda,
		detalii
		,ales
	INTO #xmlPozitii
	FROM OPENXML(@iDoc, '/*/DateGrid/row')
	WITH
	(
		detalii xml 'detalii/row',
		idContractAntet int '../../@idContract',
		idContract int '@idContract',
		--idPozContract	int '@idPozContract',
		numar_contract varchar(20) '@numar_contract',
		data_contract varchar(10) '@data_contract',
		--cod varchar(20) '@cod',
		--cod_intrare varchar(20) '@codintrare',
		--cantitate FLOAT '@cantitate',
		--defacturat FLOAT '@defacturat',
		--pret FLOAT '@pret',
		--discount FLOAT '@discount',
		valuta varchar(3) '@valuta',
		curs float '@curs',
		tert varchar(20) '@tert',
		--cod_specific varchar(20) '@cod_specific',
		--comanda varchar(20) '@comanda',
		gestiune varchar(20) '@gestiune'
		,ales int '@ales'
	)
	
	EXEC sp_xml_removedocument @iDoc 			
	-- tabela cu contractele facturate
	declare @contracte table(
		idContract int primary key, 
		nrFactura varchar(20), -- numar factura aferent contractului
		dataFactura datetime,
		subunitate varchar(10),
		tip varchar(2),
		numar varchar(20),
		data datetime,
		idJurnal int ,-- id-ul din tabela de jurnale aferent operatiei curente
		valuta varchar(3),
		curs float,
		numar_contract varchar(20),
		tert varchar(13),
		gestiune varchar(20)
	)

	--punem intr-o tabela contractele de pe care se va factura
	insert into @contracte(idContract, valuta, curs, numar_contract, tert, gestiune
		, nrFactura, dataFactura)
	select idContract, max(valuta), max(curs), max(numar_contract),max(tert), max(gestiune)
		,try_convert(int,@numar_pozdoc)+row_number() over(order by max(data_contract),max(numar_contract))-1, @data_facturilor
	from #xmlPozitii where ales=1
	group by idContract

	alter table #xmlPozitii add idLinie int identity
	set @xml = 
	(
		SELECT 
			'1' AS subunitate, @tip AS tip,CONVERT(VARCHAR(10), @data_facturilor, 101) data, c.loc_de_munca lm,rtrim(c.tert) tert,'1' AS fara_luare_date,'1' as returneaza_inserate, 
				nullif(cf.nrFactura,'') as numar, rtrim(c.punct_livrare) as punctlivrare, rtrim(c.gestiune) as gestiune, @aviznefacturat as aviznefacturat, @detalii detalii, isnull(@curs, cf.curs) as curs,
				[contract]=rtrim(numar_contract),doarCuStoc='1',comanda='GEN',categpret=convert(decimal(5,0),c.detalii.value('(/row/@Dobanda)[1]','float')),
			(
				SELECT 
					rtrim(p.cod) cod, p.cod_specific AS barcod, rtrim(c.gestiune) as gestiune,-- p.cod_intrare codintrare,
					convert(DECIMAL(15, 3),p.cantitate) cantitate,convert(DECIMAL(15, 5),p.pret) as pvaluta,convert(DECIMAL(12, 2),p.discount) as discount,
					p.idPozContract as idpozcontract, --prez.idPozDoc idpozdocrezervare,		
					p.idPozContract idlinie, cf.idJurnal as idjurnalcontract, p.detalii--, p.comanda comanda
				from PozContracte p--#xmlPozitii p
				INNER JOIN Nomencl n on n.cod=p.cod
				--LEFT JOIN LegaturiContracte lc on lc.idPozContract=p.idPozContract and @cuRezervari=1
				--LEFT JOIN PozDoc prez on  prez.tip='TE' and prez.gestiune_primitoare=@gestiuneRezervari and prez.idPozDoc=lc.idPozDoc
				where p.idContract=cf.idContract 
					--and (@cuRezervari = 0 OR prez.idPozDoc is not null or n.tip ='S')
				order by p.Numar_pozitie FOR XML raw,type
			)
		from @contracte cf
		inner join contracte c on c.idContract=cf.idContract
		ORDER BY cf.data,cf.numar_contract
		FOR XML raw,root('Date')
	)

	update asisria..ProceduriDeRulat 
		set procent_finalizat=10, statusText='Scriu facturile ...'
	where idRulare=@idrulare
	 
--select '@xml'=@xml	
	BEGIN TRAN wOPFacturareContracteSP
if @sesiune=''
	select 'wScriuDoc', @xml

	if exists (select * from sysobjects where name ='wScriuDoc')
		exec wScriuDoc @sesiune=@sesiune, @parXML=@xml OUTPUT
	else 
	if exists (select * from sysobjects where name ='wScriuDocBeta')
		exec wScriuDocBeta @sesiune=@sesiune, @parXML=@xml OUTPUT
	else 
		raiserror('Eroare configurare: aceasta procedura necesita folosirea procedurii wScriuDoc(beta).', 16, 1)

	EXEC sp_xml_preparedocument @ddoc OUTPUT, @xml
	IF OBJECT_ID('tempdb..#xmlPozitiiReturnate') IS NOT NULL
		DROP TABLE #xmlPozitiiReturnate
	
	SELECT
		idlinie, idPozDoc
	INTO #xmlPozitiiReturnate
	FROM OPENXML(@ddoc, '/row/docInserate/row')
	WITH
	(
		idLinie int '@idlinie',
		idPozDoc	int '@idPozDoc'

	)
	EXEC sp_xml_removedocument @ddoc 

	--generare inregistrari contabile
	if object_id('tempdb.dbo.#DocDeContat') is not null drop table #DocDeContat
	CREATE TABLE #DocDeContat (subunitate varchar(20),tip varchar(2),numar varchar(20),data datetime
		, yso_factura varchar(20) null, yso_data_facturii datetime null, yso_tert varchar(20) null, yso_discount float null) 
	insert into #DocDeContat (subunitate,tip,numar,data,yso_factura,yso_data_facturii,yso_tert,yso_discount)
	select subunitate,tip,numar,data,MAX(factura),MAX(Data_facturii),MAX(tert),MAX(discount)
	from pozdoc pd 
		inner join #xmlPozitiiReturnate x on x.idPozDoc=pd.idPozdoc
	where subunitate='1' and tip='AP' and data=@data_facturilor
	group by subunitate,tip,numar,data

	set @nrFacturi=(select count(distinct yso_factura) from #DocDeContat)

	if @nrFacturi=0
	begin
		COMMIT TRAN wOPFacturareContracteSP
		goto finalizare
	end

	update ct set subunitate=pd.subunitate, tip=pd.tip, numar=pd.numar, data=pd.data
	from @contracte ct 
		join #docDeContat pd on pd.yso_factura=ct.nrFactura and pd.yso_data_facturii=ct.dataFactura
--select * from @contracte
	delete ct 
	from @contracte ct 
		left join #docDeContat pd on pd.yso_factura=ct.nrFactura and pd.yso_data_facturii=ct.dataFactura
	where pd.numar is null

	update doc set Discount_p=pd.yso_discount
	from doc join #DocDeContat pd on pd.subunitate=doc.Subunitate and pd.tip=doc.Tip and pd.data=doc.Data and pd.numar=doc.Numar
	where Abs(Discount_p-pd.yso_discount)>=0.01

	exec faInregistrariContabile @dinTabela=2

	create table #Legaturi (a bit)
	exec CreazaDiezLegaturi

	insert into #Legaturi (idPozContract, idPozDoc)
	select
		pr.idlinie, pr.idPozDoc
	from #xmlPozitiiReturnate pr 
	--JOIN #xmlPozitii it on pr.idlinie=it.idLinie
	
	set @xml_proc= (select 'Generare factura' explicatii for xml raw)
	exec wOPTrateazaLegaturiSiStariContracte @sesiune=@sesiune, @parXML=@xml_proc	

	if isnull(@delegat,'')<>'' and 1=0
	begin
		IF ISNULL(@tertdelegat, '') = ''
			if ISNULL((SELECT val_logica FROM par WHERE Tip_parametru = 'AR' AND Parametru = 'EXPEDITIE'), 0)=0
				EXEC luare_date_par 'UC', 'TERTGEN', 0, 0, @tertdelegat OUTPUT
		if exists (select top (1) 1 from infotert del where del.identificator=@delegat and del.tert=@tertdelegat and del.subunitate='C1')
		begin
			select  
				@seriaBuletin=rtrim(dbo.fStrToken(del.buletin, 1, ',')), @numarBuletin=rtrim(dbo.fStrToken(del.buletin, 2, ',')), @eliberat=rtrim(del.eliberat)
			from infotert del 
			where del.identificator=@delegat and del.tert=@tertdelegat and del.subunitate='C1'

			/** Scriere in AnexaFac- o singura data **/
			delete a 
			from anexafac as a join @contracte as c on a.subunitate=c.subunitate and a.Numar_factura=c.nrFactura
			
			INSERT anexafac (Subunitate, Numar_factura, Numele_delegatului, Seria_buletin, Numar_buletin, Eliberat, Mijloc_de_transport, 
				Numarul_mijlocului, Data_expedierii, Ora_expedierii, Observatii)
			select c.subunitate, c.nrFactura, @dendelegat, @seriaBuletin, @numarBuletin, @eliberat, isnull(@dennrauto,@nrauto), 
				@nrauto, c.dataFactura, '', @observatii
			from @contracte c 
		end
	end

	delete a 
	from anexafac as a join @contracte as c on a.subunitate=c.subunitate and a.Numar_factura=c.nrFactura
			
	INSERT anexafac (Subunitate, Numar_factura, Numele_delegatului, Seria_buletin, Numar_buletin, Eliberat, Mijloc_de_transport, 
		Numarul_mijlocului, Data_expedierii, Ora_expedierii, Observatii)
	select c.subunitate, c.nrFactura, i.Nume_delegat, LEFT(i.Buletin,2), RIGHT(RTRIM(i.Buletin),6), i.Eliberat, LEFT(i.Mijloc_tp,13), 
		LEFT(i.Mijloc_tp,13), c.dataFactura, '', @observatii
	from @contracte c join contracte n on n.idContract=c.idContract
		join infotert i on i.Subunitate=C.subunitate and i.Tert=N.tert and i.Identificator=n.punct_livrare
		
	COMMIT TRAN wOPFacturareContracteSP
	
	DECLARE @dateInitializare XML

	set @parXML.modify('delete /*/*')
	set @parXML=dbo.fInlocuireDenumireElementXML(@parXML,'row')
	set @dateInitializare=
	--(select @parXML,
		(select c.nrFactura as factura, CONVERT(CHAR(10), c.dataFactura, 101) data_facturii, c.tert
			,c.subunitate,c.tip,c.numar,c.data
			,c.idContract, c.numar_contract
		from @contracte c for xml raw,root('facturi'))  
	--for xml raw)
	set @parXML.modify('insert sql:variable("@dateInitializare") as last into (/row)[1]')

	finalizare: 
	declare @mesajXML xml

	IF @fara_mesaje=0 and @nrFacturi=0
		SET @mesajXML = (select 
			'Au fost generate '+convert(varchar, isnull(@nrFacturi,0))+' facturi.' textMesaj,'Finalizare generare facturi' titluMesaj
		for xml raw, root('Mesaje'))
	ELSE 
		SET @mesajXML = (SELECT 'Operatie pentru listare facturi contracte'  nume, 'CL' codmeniu, 'D' tipmacheta,'CL' tip,'LS' subtip,'O' fel,
			@parXML dateInitializare FOR XML RAW('deschideMacheta'), ROOT('Mesaje'))

	if @idRulare<>-1	
		UPDATE p
			SET procent_finalizat=100, statusText = 'Finalizare operatie', mesaje = @mesajXml
		FROM asisria.dbo.ProceduriDeRulat p
		WHERE p.idRulare = @idRulare
	else 
		select @mesajXML

END TRY

begin catch
	IF @@TRANCOUNT>0
		IF EXISTS (SELECT 1 FROM sys.dm_tran_active_transactions WHERE name = 'wOPFacturareContracteSP')            
			ROLLBACK TRANSACTION wOPFacturareContracteSP
		ELSE ROLLBACK TRAN

	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
end catch
