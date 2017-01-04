--***
/*
exec Declaratia394
	@sesiune='', @data='2016-07-31'
	,@nume_declar='', @prenume_declar='', @functie_declar=''
	,@cui=null, @den=null, @adresa=null
	,@telefon=null,@fax=null, @mail=null
	,@caleFisier=''
	,@dinRia=1		-->	par care determina modul de scriere pe harddisk
	,@tip_D394='L'	-->	L=lunar, T=trimestrial, S=semestrial, A=anual
	,@cifR=null, @denR=null, @adresaR=null, @telefonR=null,
				@faxR=null, @mailR=null
	,@genRaport=1	-- daca procedura este apelata pentru generare raport
	,@siTXT=0	--> 1=se va genera si fisier txt, 
	,@tert='5031652'	--> filtrare pe tert pentru rapDeclaratia394
	,@locm=''	--> filtrare pe loc de munca pentru rapDeclaratia394
	,@optiuniGenerare=0
*/
Create procedure Declaratia394
	(@sesiune varchar(50)='', @data datetime--, @datasus datetime
	,@nume_declar varchar(200), @prenume_declar varchar(200), @functie_declar varchar(100)	-- pastrat cei 3 parametrii pentru compatibilitate in urma.
	,@cui varchar(100)=null, @den varchar(100)=null, @adresa varchar(100)=null
	,@telefon varchar(100)=null,@fax varchar(100)=null, @mail varchar(100)=null
	,@caleFisier varchar(300)	--> calea completa, incluzand fisierul; daca fisierul nu este dat se creeaza unul in functie de data, tip si cod fiscal firma
	,@dinRia int=1		-->	parametru care determina modul de scriere pe harddisk
	-->	decl394:
	,@tip_D394 varchar(1)	-->	L=lunar, T=trimestrial, S=semestrial, A=anual
	--/**	--necunoscute (trebe, nu trebe?). Trebuie incepand cu versiunea valabila cu 01.07.2016 dar le citim din tabela D394. Le pastram ca parametrii pentru declaratiile perioadelor anterioare.
	,@cifR varchar(20)=null, @denR varchar(200)=null, @adresaR varchar(1000)=null, @telefonR varchar(15)=null,
				@faxR varchar(15)=null, @mailR varchar(200)=null,
	@genRaport int=0	-- daca procedura este apelata pentru generare raport; 1=vechi, pt o eventuala compatibilitate, 2=raportul declaratie 394
	,@siTXT bit=1		--> @siTXT=1=se va genera si fisier txt, se pare ca odata cu noul format, nu se mai permite import de fisier TXT in PDF-ul inteligent. Pastram parametru pentru declaratiile perioadelor anterioare.
	,@tert varchar(100)=''	--> filtrare pe tert pentru rapDeclaratia394
	,@locm varchar(100)=''	--> filtrare pe loc de munca pentru rapDeclaratia394
	,@optiuniGenerare int=0 -->Generare declaratie=0 - calcul date din ASiS+generare XML, 1-Generare XML
	,@siXMLPDF bit=0		--> @siXMLPDF=1 -> odata cu noua declaratie valabila de la 01.07.2017 in PDF-ul inteligent se poate face import doar dintr-un alt format de fisier XML
	)
as

declare @eroare varchar(2000)
set @eroare=''
begin try
	declare @datasus datetime, @datajos datetime
	select @data=dbo.bom(@data)
	select @datajos=(case @tip_D394 when 'L' then @data
									when 'T' then dateadd(M,-(month(@data)-1) % 3,@data)
									when 'S' then dateadd(M,-(month(@data)-1) % 6,@data)
									when 'A' then dateadd(M,-month(@data)+1,@data)
									else @datajos end),
			@datasus=(case @tip_D394 when 'L' then dbo.eom(@data)
									when 'T' then dbo.eom(dateadd(M,-(month(@data)-1) % 3 +2,@data))
									when 'S' then dbo.eom(dateadd(M,-(month(@data)-1) % 6 + 5,@data))
									when 'A' then dbo.eom(dateadd(M,-month(@data)+12,@data))
									else @datajos end)

	declare @fisier varchar(100), @pozSeparator int, @caleCompletaFisier varchar(300), @fisierXML varchar(100), @fisierXMLPDFSoftA varchar(100), 
			@utilizator varchar(20), @lista_lm int, @lmFiltru varchar(9), @lmUtilizator varchar(9), @lmUtilizatorFirma varchar(9), @nrLMFiltru int, @multiFirma int, @totalPlata_A decimal(15), 
			@fact10000_2016 int, @D394_102016 int, @centralizareD394 int, @mesajAtentionare varchar(2000)

	set @fact10000_2016=(case when @dataSus>='10/01/2016' and @dataSus<='12/31/2016' then 1 else 0 end)
	set @D394_102016=(case when @dataSus>='10/01/2016' then 1 else 0 end)
	exec wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator output

	set @multiFirma=0
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1
	set @lista_lm=dbo.f_areLMFiltru(@utilizator)
	select @lmFiltru=isnull(min(Cod),''), @nrLMFiltru=count(1) from LMfiltrare where utilizator=@utilizator and cod in (select cod from lm where Nivel=1)
	if @nrLMFiltru=1
		set @lmUtilizator=@lmFiltru
	if @multiFirma=1
		set @lmUtilizatorFirma=@lmFiltru

	if @multiFirma=1 and nullif(@lmUtilizator,'') is null	--	la multi firma trebuie selectat un loc de munca la intrarea in aplicatie.
		raiserror ('Pentru a genera D394, trebuie selectat un loc de munca (o unitate) la intrarea in aplicatie!',16,1)		

-->	pentru perioade anterioare lunii iunie 2016, apelam procedura functionala pana la 31.05.2016
	if @datasus<'07/01/2016' and exists (select * from sysobjects where name ='Declaratia394v2015' and xtype='P') and (@utilizator<>'lucian' or 1=1)
	begin
		exec Declaratia394v2015 
			@sesiune=@sesiune, @data=@data, @nume_declar=@nume_declar, @prenume_declar=@prenume_declar, @functie_declar=@functie_declar
			,@cui=@cui, @den=@den, @adresa=@adresa, @telefon=@telefon, @fax=@fax, @mail=@mail, @caleFisier=@caleFisier
			,@dinRia=@dinRia,@tip_D394=@tip_D394,@cifR=@cifR, @denR=@denR, @adresaR=@adresaR, @telefonR=@telefonR, @faxR=@faxR, @mailR=@mailR
			,@genRaport=@genRaport, @siTXT=@siTXT, @tert=@tert,@locm=@locm
		return 
	end

	select	@pozSeparator=len(@caleFisier)-charindex('\',reverse(rtrim(@caleFisier))),
			@caleCompletaFisier=@caleFisier
	select	@fisier=substring(@caleFisier,@pozSeparator+2,len(@caleFisier)-@pozseparator+1),
			@caleFisier=substring(@caleFisier,1,@pozseparator)

	declare @sistemTVA int, @op_efectuate int, @efectuat int, @functieR varchar(100)
		,@tip_intocmit int	--> 0=Persoana juridica, 1=Persoana fizica. Am considerat ca implicit sa fie persoana fizica.
		,@den_intocmit varchar(75), @cif_intocmit varchar(13), @calitate_intocmit varchar(75), @functie_intocmit varchar(75)
		,@optiune int, @schimb_optiune int, @solicit_ramb int, @nrAMEF int

	/**	Citire tip TVA baza de date, dupa modelul din inchidTLI.*/
	select top 1 @sistemTVA=(case when tip_tva='I' then 1 else 0 end)
		from TvaPeTerti
		where TvaPeTerti.tipf='B' and tert is null and @dataSus>=dela
		order by dela desc

	if @sistemTVA is null
		set @sistemTVA=0

	select 
		@solicit_ramb=max(case when rand_decl='A_solicit_ramb' then denumire end)
	from D394 where data=@dataSus and (@lmUtilizatorFirma is null and lm is null or lm=@lmUtilizatorFirma) and rand_decl in ('A_solicit_ramb')
	select 
		@solicit_ramb=isnull(@solicit_ramb,0)

	if object_id('tempdb.dbo.#tvavanz') is not null drop table #tvavanz
	if object_id('tempdb.dbo.#tvacump') is not null drop table #tvacump
	if object_id('tempdb.dbo.#tCoduriCereale') is not null drop table #tCoduriCereale
	if object_id('tempdb.dbo.#detaliereSFIF') is not null drop table #detaliereSFIF
	if object_id('tempdb.dbo.#D394') is not null drop table #D394
	if object_id('tempdb.dbo.#D394cif') is not null drop table #D394cif
	if object_id('tempdb.dbo.#D394tmp') is not null drop table #D394tmp
	if object_id('tempdb.dbo.#D394xml') is not null drop table #D394xml
	if object_id('tempdb.dbo.#D394facttmp') is not null drop table #D394facttmp
	if object_id('tempdb.dbo.#D394facttmpCod') is not null drop table #D394facttmpCod
	if object_id('tempdb.dbo.#D394fact') is not null drop table #D394fact
	if object_id('tempdb.dbo.#D394factCod') is not null drop table #D394factCod
	if object_id('tempdb.dbo.#D394factPF') is not null drop table #D394factPF
	if object_id('tempdb.dbo.#D394factPFSub10000') is not null drop table #D394factPFSub10000
	if object_id('tempdb.dbo.#D394facturi') is not null drop table #D394facturi
	if object_id('tempdb.dbo.#D394facturiCod') is not null drop table #D394facturiCod
	if object_id('tempdb.dbo.#D394factExcep') is not null drop table #D394factExcep
	if object_id('tempdb.dbo.#D394factSerii') is not null drop table #D394factSerii
	if object_id('tempdb.dbo.#D394BfFs') is not null drop table #D394BfFs
	if object_id('tempdb.dbo.#D394IncasariZ') is not null drop table #D394IncasariZ
	if object_id('tempdb.dbo.#D394PCICtli') is not null drop table #D394PCICtli
	if object_id('tempdb.dbo.#D394LivrariCodCaen') is not null drop table #D394LivrariCodCaen
	if object_id('tempdb.dbo.#D394autofacturi') is not null drop table #D394autofacturi
	if object_id('tempdb.dbo.#nrbonuri') is not null drop table #nrbonuri
	if object_id('tempdb.dbo.#coteTVA') is not null drop table #coteTVA
	if object_id('tempdb.dbo.#nrCui') is not null drop table #nrCui
	if object_id('tempdb.dbo.#docMarjaProfit') is not null drop table #docMarjaProfit
	if object_id('tempdb.dbo.#plajeserii') is not null drop table #plajeserii
	if object_id('tempdb.dbo.#plajeUtilizate') is not null drop table #plajeUtilizate
	if object_id('tempdb.dbo.#gestiuni') is not null drop table #gestiuni
	if object_id('tempdb.dbo.#judete') is not null drop table #judete

	declare @subunitate varchar(9), @nrFacturi int, @adrTertiComp int, @validLocalit int, @validJudet int, @validTara int, 
			@proprietateNomenclatorCoduriCereale varchar(100), @coduriCereale varchar(3000),	-->	coduri de nomenclatura combinata pt cereale si plante tehnice
			@parXML xml, @parXMLPlaje xml, @dataFactCumpInPerioada int, @pecoduri int, @D394SFIFCereale int, 
			@codfiscal varchar(13), @caen varchar(100), @versiune varchar(1),	--> variabila pt. versiune declaratie
			@dirgen varchar(100), @fdirgen varchar(100)

	select	@proprietateNomenclatorCoduriCereale='CODNOMENCLATURA',
			--@coduriCereale='1001,1002,1003,1004,1005,1201,1205,120600,121291,10086000,120400',
			@parXML=(select @datajos datajos, @datasus datasus, 1 as pecoduri for xml raw),
			@parXMLPlaje=(select @datajos datajos, @datasus datasus for xml raw),
			@dataFactCumpInPerioada=0, -- ar putea fi setare "Data facturilor de cumparare sa fie in perioada selectata". Nu mai trebuie setare.
			@pecoduri=1
	set @subunitate = isnull(nullif((select max(Val_alfanumerica) from par where Tip_parametru='GE' and Parametru='SUBPRO'),''),'1')
	set @adrTertiComp = isnull((select max(cast(val_logica as int)) from par where tip_parametru='GE' and parametru='ADRCOMP'),0)
	set @validLocalit = isnull((select max(cast(val_logica as int)) from par where tip_parametru='GE' and parametru='LOCTERTI'),0)
	set @validJudet = isnull((select max(cast(val_logica as int)) from par where tip_parametru='GE' and parametru='JUDTERTI'),0)
	set @validTara = isnull((select max(cast(val_logica as int)) from par where tip_parametru='GE' and parametru='TARATERTI'),0)
	set @D394SFIFCereale = isnull((select max(cast(val_logica as int)) from par where tip_parametru='GE' and parametru='394SFIFCE'),0)
	set @caen=rtrim(isnull((select max(Val_alfanumerica) from par where Tip_parametru='PS' and Parametru='CODCAEN'),''))
	set @codfiscal=isnull((select max(Val_alfanumerica) from par where Tip_parametru='GE' and Parametru='CODFISC'),'')
	set @dirgen=rtrim(isnull((select max(Val_alfanumerica) from par where Tip_parametru='GE' and Parametru='DIRGEN'),''))
	set @fdirgen=rtrim(isnull((select max(Val_alfanumerica) from par where Tip_parametru='GE' and Parametru='FDIRGEN'),''))
	set @codfiscal=replace(replace(replace(@codfiscal, 'RO', ''), 'R', ''), ' ','') 

-->	versiune=3 pentru declaratiile valabile incepand cu 01.07.2016. Pentru perioadele anterioare lui 01.07.2016, versiunile sunt tratate in procedura Declaratia394v2015.
	set @versiune='3'

	create table #tCoduriCereale (cod varchar(20), codNomenclatura varchar(20))
	insert into #tCoduriCereale (cod, codNomenclatura)
	select cod, valoare as codNomenclatura from proprietati 
		where tip='NOMENCL'
			--and charindex(','+rtrim(valoare)+',',','+@coduriCereale+',')>0
			and cod_proprietate=@proprietateNomenclatorCoduriCereale

-->	Daca se apeleaza procedura cu parametru @optiuniGenerare=1, nu se mai recalculeaza datele din tabela D394.
	if @optiuniGenerare=0
	begin
		create table #D394cif
			(codtert varchar(13), codfisc varchar(20), dentert varchar(80), tipop varchar(3), baza float, tva float, 
			codNomenclator varchar(20) default '', bun varchar(20) default '', invers int default 0, cota_tva int, tip_partener int, tli int default 0, factPFpeCUI int, tertPF int, regimspec394 int, tipDocNepl char(1))
		create table #D394tmp
			(codtert varchar(13), codfisc varchar(20), dentert varchar(80), tipop varchar(3), nrfacturi int, baza float, tva float, 
			codNomenclator varchar(20), invers int default 0, cota_tva int, tip_partener int, tli int default 0,	--> invers:	1=taxare inversa; altceva=nu e taxare inversa
			factPFpeCUI int, tertPF int, regimspec394 int, bun varchar(20), tipDocNepl char(1))
		create table #D394fact
			(codfisc varchar(20), tipop varchar(3), invers int default 0, nrfacturi int, cota_tva int, tip_partener int, tli int default 0, factPFpeCUI int, codtert varchar(20), tipDocNepl char(1))
		create table #D394facttmp
			(codfisc varchar(20), tipop varchar(3), invers int default 0, nrfacturi int, cota_tva int, tip_partener int, tli int default 0, factPFpeCUI int, tertPF int, regimspec394 int, codtert varchar(20), tipDocNepl char(1))
		create table #D394factCod
			(codfisc varchar(20), tipop varchar(3), invers int default 0, nrfacturi int, cota_tva int, tip_partener int, tli int default 0, factPFpeCUI int, codNomenclatura varchar(20), codtert varchar(20), tipDocNepl char(1))
		create table #D394facttmpCod
			(codfisc varchar(20), tipop varchar(3), invers int default 0, nrfacturi int, cota_tva int, tip_partener int, tli int default 0, factPFpeCUI int, tertPF int, regimspec394 int, codNomenclatura varchar(20), codtert varchar(20), tipDocNepl char(1))
		create table #D394factExcep
			(tip_factura int, serie varchar(10), numar varchar(20), cota_tva int, baza float, tva float, idplaja int)
		create table #D394factSerii
			(tip int, serieI varchar(10), nrI varchar(20), serieF varchar(10), nrF varchar(20), cuiP varchar(20), denP varchar(100), nrFacturi int, idplaja int)
		create table #D394factPF	-- tabela pentru facturi (livrari) persoane fizice. Pentru a stabili valoarea individuala a fiecarei facturi.
			(codtert varchar(20), codfisc char(20), factura varchar(20), baza float, tva float)
		create table #D394factPFSub10000	-- tabela pentru facturi (livrari) persoane fizice. Pentru a stabili valoarea individuala a fiecarei facturi.
			(codtert varchar(20), codfisc char(20), factura varchar(20), cota_tva int, baza float, tva float, nrFacturi int)
		-- tabela de facturi (livrari si achizitii) pentru a numara corect numarul de facturi pe cote de TVA conform Ordinului 3769 (daca sunt 2/mai multe cote de TVA pe o factura).
		create table #D394facturi
			(codtert varchar(20), codfisc char(20), tipop varchar(3), factura varchar(20), cota_tva int, baza float, tva float)
		-- tabela de facturi (livrari si achizitii) pentru a numara corect numarul de facturi pe cote de TVA si coduri conform Ordinului 3769 (daca sunt 2/mai multe coduri pe o factura).
		create table #D394facturiCod
			(codtert varchar(20), codfisc char(20), tipop varchar(3), factura varchar(20), codNomenclatura varchar(20), cota_tva int, baza float, tva float)
		-- tabela de facturi (livrari si achizitii) pentru a numara corect numarul de facturi pe cote de TVA si coduri conform Ordinului 3769 (daca sunt 2/mai multe coduri pe o factura).
		create table #coteTVA
			(cota_tva int)
		insert into #coteTVA
		select 24 as cota_tva union all
		select 20 as cota_tva union all
		select 19 as cota_tva union all
		select 9 as cota_tva union all
		select 5 as cota_tva

		if object_id('tempdb..#D394det') is null
		begin
			create table #D394det (subunitate varchar(20))
			exec Declaratia39x_tabela
		end

		create table #tvavanz (subunitate char(9))
		exec CreazaDiezTVA @numeTabela='#tvavanz'
		exec TVAVanzari @DataJ=@datajos, @DataS=@datasus, @ContF='', @ContFExcep=0, @Gest='', @LM=@locm, @LMExcep=0, @Jurnal=''
			,@ContCor='', @TVAnx=0, @RecalcBaza=0, @CtVenScDed='', @CtPIScDed='', @nTVAex=8, @FFFBTVA0='1'
			,@SiFactAnul=0, @TipCump=1, @TVAAlteCont=0, @DVITertExt=0, @OrdDataDoc=0, @OrdDenTert=0
			,@Tert=@tert, @Factura='', @D394=1, @FaraCump=1, @parXML='<row />'

		create table #tvacump (subunitate char(9))
		exec CreazaDiezTVA @numeTabela='#tvacump'
		exec TVACumparari @DataJ=@datajos, @DataS=@datasus, @ContF='', @Gest='', @LM=@locm, @LMExcep=0, @Jurnal='', @ContCor='', @TVAnx=0, @RecalcBaza=0
				,@nTVAex=0, @FFFBTVA0='2', /* sunt cazuri in care trebuie aduse si FF cu TVA=0*/@SFTVA0='2', @IAFTVA0=0, @TipCump=9, @TVAAlteCont=2, @DVITertExt=0
				,@OrdDataDoc=0, @Tert=@tert, @Factura='', @UnifFact=0, @FaraVanz=1, @nTVAned=2, @parXML='<row />'

		--	apel procedura specifica Declaratia394SP care permite completarea/modificarea tabelelor #tvacump si #tvavanz
		if exists (select 1 from sysobjects o where o.type='P' and o.name='Declaratia394SP') 
			exec Declaratia394SP @parXML 

		insert into #D394det
				(subunitate, numar, numarD, tipD, data, factura, tert, valoare_factura, baza, tva, explicatii,
				tip, cota_tva, discFaraTVA, discTVA, data_doc, ordonare, drept_ded, cont_TVA, cont_coresp, exonerat, 
				vanzcump, numar_pozitie, tipDoc, cod, factadoc, contf, codfisc, dentert, tipop, codNomenclator, invers, 
				idpozitie, tip_partener, tip_tva, fsimplificata, tip_nom, nrbonuri, tli, regimspec394, codcaen, marjaprofit, tipDocNepl, idplaja, modemitfact, lm)
		select 
			d.subunitate, d.numar, d.numarD, d.tipD, d.data, d.factura, d.tert, d.valoare_factura,
			round(convert(decimal(15,3),d.baza_22),3) baza, round(convert(decimal(15,3),d.tva_22),3) tva, d.explicatii,
			d.tip, d.cota_tva, d.discFaraTVA, d.discTVA, d.data_doc, d.ordonare, d.drept_ded, d.cont_TVA, d.cont_coresp, d.exonerat,
			d.vanzcump, d.numar_pozitie, d.tipDoc, d.cod, d.factadoc, d.contf, --codfisc, dentert, tipop, codNomenclator, coloana
			replace(replace(replace(isnull(t.cod_fiscal,(case when d.tipD='FA' or d.tipD='BP' and d.tip='F'
					then d.cont_TVA else '' end)), 'RO', ''), 'R', ''), ' ','') as codfisc,
			isnull(t.denumire, d.explicatii) as dentert, 'L' as tipop,
			d.cod as codNomencl, 
			(case when dbo.coloanaTVAVanzari(d.cota_tva, d.drept_ded, d.exonerat, d.vanzcump, d.cont_coresp, '', isnull(it.zile_inc, 0), tari.teritoriu,
											isnull(n.tip, ''), d.tert, d.factura, d.tipD, d.numar, d.data, d.numar_pozitie, d.numarD, d.tipDoc, d.cod)
				= 10 then 1 else 0 end) as invers, idpozitie, isnull(it.zile_inc, 0) as tip_partener, d.tip_tva, 0 as fsimplificata, isnull(n.tip,''), 
			(case when d.tipDoc='IC' then d.detalii.value('(/row/@nrbonuri)[1]','decimal(12,2)') else 0 end) as nrbonuri, 0 as tli, 0 as regimspec394, 
			isnull(nullif(n.detalii.value('(/row/@_codcaen)[1]','varchar(10)'),''),isnull(lm.detalii.value('(/row/@_codcaen)[1]','varchar(10)'),'')) as codcaen,
			isnull(n.detalii.value('(/row/@_marjaprofit)[1]','int'),0) as marjaprofit, NULL as tipDocNepl, isnull(nullif(d.detalii.value('(/row/@idplaja)[1]','int'),0),doc.idplaja) as idplaja, 
			nullif(doc.detalii.value('/row[1]/@_modemitfact','char(1)'),''), d.lm
		from #tvavanz d
				--> deocamdata @nTVAex a ramas 8 in loc de 18, deoarece nu functiona corect taxarea inversa.
			left join terti t on t.subunitate=d.subunitate and t.tert=d.tert and d.tipD<>'FA' and not (d.tipD='BP' and d.tip='F')
			left outer join infotert it on it.subunitate=t.subunitate and it.tert=t.tert and it.identificator=''
			left outer join nomencl n on n.cod=d.cod
			left outer join doc on doc.subunitate=d.subunitate and doc.tip=d.tipDoc and doc.numar=d.numar and doc.data=d.data_doc
			left outer join pozdoc i on i.subunitate='INTRASTAT' and i.tip=d.tipdoc and i.numar=d.numar and i.data=d.data_doc and i.numar_pozitie=0
			left outer join tari on cod_tara=isnull(doc.detalii.value('/row[1]/@taraexp', 'varchar(20)'),i.cont_intermediar)
			left outer join lm on lm.cod=d.lm
		where (isnull(it.zile_inc, 0)=0 or 1=1) and d.vanzcump='V' and (@pecoduri=1 or d.exonerat=0)
			and (d.tipD<>'FA' and not (d.tipD='BP' and d.tip='F') 
				or d.tipD='BP' and d.tip='F' and charindex('R', d.cont_TVA)>0)
			and not (d.tipD='FA' and d.factura='FACT.UA' and d.tert='ABON.UA')
			and d.tipDoc<>'IB' -- sa nu ia avansurile in D.394
			and (t.tert is not null or d.tipDoc='IC')	--initial era inner join pe tert. Dar la IC este posibil sa fie tertul necompletat.
			and isnull(d.detalii.value('(/row/@_netaxabiltva)[1]','int'),0)!=1	-- sa nu duca in D394 operatiunile marcate explicit ca netaxabile.
		union all
	
		select d.subunitate, d.numar, d.numarD, d.tipD, d.data, d.factura, d.tert, d.valoare_factura,
			round(convert(decimal(15,3),d.baza_22),3) baza, round(convert(decimal(15,3),d.tva_22),3) tva, d.explicatii,
			d.tip, d.cota_tva, d.discFaraTVA, d.discTVA, d.data_doc, d.ordonare, d.drept_ded, d.cont_TVA, d.cont_coresp, d.exonerat,
			d.vanzcump, d.numar_pozitie, d.tipDoc, d.cod, d.factadoc, d.contf, --codfisc, dentert, tipop, codNomenclator, coloana
			replace(replace(replace(isnull(t.cod_fiscal, ''), 'RO', ''), 'R', ''), ' ','') as codfisc, 
			isnull(t.denumire, d.explicatii) as dentert, 'A' as tipop, d.cod,
			(case when dbo.coloanaTVACumparari (d.cota_tva, exonerat, vanzcump, cont_coresp, '', isnull(it.zile_inc, 0), Teritoriu, isnull(n.tip, ''), d.tert,
						d.factura, (case when d.tipD='RM' then d.tipDoc else d.tipD end), d.numar, d.data_doc, d.numar_pozitie, d.numarD, d.tipDoc, d.cod)
				in (17,11,21) then 1 else 0 end) invers, idpozitie, isnull(it.zile_inc, 0) as tip_partener, d.tip_tva, 
			ISNULL(d.detalii.value('(/*/@_fsimplificata)[1]','int'),ISNULL(doc.detalii.value('(/*/@_fsimplificata)[1]','int'),0)) as fsimplificata, isnull(n.tip,''), 0 as nrbonuri,
			(case when isnull((select top 1 tt.tip_tva from tvapeterti tt where tt.tert=t.Tert and tt.tipf='F' and tt.dela<=d.data and isnull(tt.factura,'')='' order by tt.dela desc),'P')='I' 
				then 1 else 0 end) as tli, isnull(d.detalii.value('(/row/@_regimspec394)[1]','int'),isnull(t.detalii.value('(/row/@_regimspec394)[1]','int'),0)) as regimspec394, null as codcaen, 0 as marjaprofit,
			ISNULL(doc.detalii.value('(/*/@_tipdocnepl)[1]','char(1)'),'') as tipDocNepl, NULL as idplaja, nullif(doc.detalii.value('/row[1]/@_modemitfact','char(1)'),''), d.lm
		from #tvacump d
			inner join terti t on t.subunitate=d.subunitate and t.tert=d.tert
			left outer join infotert it on it.subunitate=t.subunitate and it.tert=t.tert and it.identificator=''
			left outer join nomencl n on n.cod=d.cod
			left outer join doc on doc.subunitate=d.subunitate and doc.tip=d.tipDoc and doc.numar=d.numar and doc.data=d.data_doc
			left outer join pozdoc i on i.subunitate='INTRASTAT' and i.tip=d.tipdoc and i.numar=d.numar and i.data=d.data_doc and i.numar_pozitie=0
			left outer join tari on cod_tara=isnull(doc.detalii.value('/row[1]/@taraexp', 'varchar(20)'),i.cont_intermediar)
		where (isnull(it.zile_inc, 0)=0 or 1=1) and d.vanzcump='C' and (@pecoduri=1 or d.exonerat=0)
			and d.tipD<>'FA' 
			and (@dataFactCumpInPerioada=0 or d.data between @datajos and @datasus or d.tipDoc in ('PC','IC') and d.Numar like 'ITVA%') -- campul "data" reprezinta data facturii
			and d.tipDoc<>'PF' -- sa nu ia avansurile in D.394
			and isnull(d.detalii.value('(/row/@_netaxabiltva)[1]','int'),0)!=1

	-->	Aducem aici si idplaja din pozadoc
		update d set d.idplaja=pd.idplaja
		from #D394det d
			inner join pozadoc pd on pd.idPozadoc=d.idPozitie
		where d.tipD='FB'

	-->	Nu trebuie declarate operatiunile cu terti UE care apar in declaratia 390. Am pus aici stergerea pentru a nu pune conditia la ambele selecturi de mai sus.
		delete from #D394det where tip_partener=1 and exonerat in (1,2)

	-->	Stabilire care terti sunt persoane fizice.
		update d set 
			d.tertPF=(case when len(rtrim(codfisc))=13 and isnull(it.zile_inc,0)=0 or t.detalii.value('(/row/@_persfizica)[1]','int')=1 then 1 else 0 end)
		from #D394det d 
		left join terti t on t.subunitate=d.subunitate and t.tert=d.tert
		left outer join infotert it on it.subunitate=t.subunitate and it.tert=t.tert and it.identificator=''

		delete from #D394det where cota_tva=0 and tip_partener in (1,2) and tva=0 and tipop='A'
	-->	Recodificare tip_partener functie de valorile specifice declaratiei 394
		update d set d.tip_partener=(case 
			when d.tip_partener in (0,1,2) and isnull((select top 1 tt.tip_tva from tvapeterti tt where tt.tert=d.Tert and tt.tipf='F' and tt.dela<=d.data and isnull(tt.factura,'')='' order by tt.dela desc),'P')='N' 
				or d.tip_partener in (1,2) and d.codfisc=''
				or d.tertPF=1 then 2
			when d.tip_partener=2 then 4 when d.tip_partener=1 then 3  
			else 1 end)
		from #D394det d

	-->	Pentru perioada 01.07.2016 - 30.09.2016 se declara doar persoanele impozabile inregistrate in scopuri de TVA in Romania.
		delete from #D394det where tip_partener>1 and @D394_102016=0

	-->	Nu trebuie declarate operatiunile neimpozabile cu terti interni - penalizari de intarziere, majorari/dobanzi. (cota_tva=0). 
	-->	La terti interni cred ca n-ar trebui sa existe cazuri de operatiuni impozabile cu cota_tva=0. Am pus si conditia de tip_nom=R,S.
	-->	Tratat sa nu duca nici livrarile catre terti UE/externi daca nu au TVA.
		delete from #D394det where cota_tva=0 and (tip_nom in ('R','S') and tip_partener=1 and isnull(regimspec394,0)=0 or tip_partener in (2,3,4) and tva=0 and tipop='L')

		update d set 
			d.bunimob=
				(case 
					when isnull(nullif(mf.cod_de_clasificare,''),im.codcl) like '1.1.%' then 'CI'
					when isnull(nullif(mf.cod_de_clasificare,''),im.codcl) like '1.6.4.%' then 'CB'
					when isnull(nullif(mf.cod_de_clasificare,''),im.codcl) like '1.6.1.%' then 'CR'
					when isnull(nullif(mf.cod_de_clasificare,''),im.codcl) like '1.%' then 'A'
					when isnull(nullif(mf.cod_de_clasificare,''),im.codcl) like '8.%' then 'T'
					when isnull(nullif(mf.cod_de_clasificare,''),im.codcl) like '7.%' then 'Necorp'
				end)
		from #D394det d
			inner join pozdoc pd on pd.idPozdoc=d.idpozitie
			left join imobilizari im on im.nrinv=pd.cod_intrare
			left join mfix mf on mf.numar_de_inventar=pd.cod_intrare and mf.subunitate=@subunitate
		where d.tip_nom='F'		

	--> Se cere cota_tva=0 si TVA=0 pentru pt inversat (in bd e 24). De aceea am comentat si update-ul urmator. 
	-->	Se pare ca si la livrarile aferente bunurilor second hand (cu marja de profit) trebuie declarat cota_tva=0 (chiar daca marja de profit are TVA). Am intrebat la ANAF, au zis ca asa trebuie.
		update d set d.cota_tva=0
		from #D394det d where d.exonerat=2 and d.tva=0 and d.cota_tva<>0 or d.cota_tva<>0 and d.tva<>0 and d.marjaprofit=1

		--update r set tva=r.baza*r.cota_tva/100		--> se calculeaza tva-ul pe loc pt inversat (in bd e 0)
		--from #D394det r where r.exonerat=2 and r.tva=0 and r.cota_tva<>0

		/*	Punem operatiunile referitoare plati/incasari cu TVA la incasare in tabela separata pentru a nu afecta restul declaratiei. 
			Avem nevoie aici si de pozitiile aferente facturilor din luni anterioare. */
		select * into #D394PCICtli
		from #D394det 
		where tipDoc in ('PC','IC') and Numar like 'ITVA%'

		delete from	#D394det 
		where tipDoc in ('PC','IC') and Numar like 'ITVA%'

		if object_id('tempdb..#jurnalTLI') is null
		begin
			create table #jurnalTLI(Factura varchar(20))
			exec rapJurnalTvaLaIncasare_faJurnalTLI
		end

		-->	Tratat TVA corespunzator incasarilor aferente facturilor (emise) cu TVA la incasare ce provin din UA. Adaugam aceste sume la cele care vin din CG (prin #tvavanz)
		if @D394_102016=1 and exists (select * from sysobjects o where o.name='rapUAJurnalTvaLaIncasare' and o.type='P')
		begin
			exec rapUAJurnalTvaLaIncasare @datajos=@datajos, @datasus=@datasus, @tert=@tert, @factura=NULL, @loc_de_munca=null, @sesiune=@sesiune, @D394=1

			insert into #D394PCICtli (subunitate, tert, codfisc, dentert, tipop, baza, data, factura, cota_tva, data_doc, tipDoc, tva)
			select @subunitate, tert, cod_fiscal, denTert, 'L', baza, data, factura, isnull(cota_tva,20), data, 'IC', rulaj_credit_tli
			from #jurnalTLI
		end

		/**	Bonuri fiscale, facturi simplificate, etc. Le punem aici pentru ca de exemplu facturile simplificate nu trebuie sa apara la nivel de tert. */	
		select d.data as data, d.tert as tert, d.codfisc, d.dentert dentert, d.tipop, d.tip_partener, d.tli, d.cota_tva, d.factura,
			--	fsimplificata=1 ->	bon fiscal cu rol de factura simplificata, fsimplificata=2	->	factura simplificata ppzisa, 
			(case when d.tipD in ('RM','RS','FF') and d.fsimplificata=1 then 2 when d.tipD='RM' and d.tipDoc='RC' or d.tipD='FF' and d.fsimplificata=2 then 1 else d.fsimplificata end) as fsimplificata,
			d.valoare_factura+d.tva incasare, d.baza baza, d.tva tva, isnull(nrbonuri,0) as nrbonuri, convert(varchar(6),'AMEF') as tipinc, d.lm, d.idpozitie
		into #D394BfFs
		from #D394det d
		where @D394_102016=1 and (d.tipD='PI' and (d.tipDoc='IC' and not(d.codfisc=@codfiscal and left(d.NumarD,1)='6') --clasa 6 = autofacturare
			or d.tipDoc='PC' and d.fsimplificata in (1,2)) 
			or d.tipD='RM' and d.tipDoc='RC' or d.tipD in ('RM','RS') and d.fsimplificata=1 or d.tipD='FF' and d.fsimplificata in (1,2))
		union all
		-->	Stornam din valoarea incasarilor cu Z, facturile emise din bonuri. Nu vor fi incluse in sectiunea G bonurile fiscale pentru care au fost emise facturi conform art. 319 din Codul fiscal.
		select d.data as data, max(d.tert) as tert, d.codfisc, max(d.dentert) dentert, d.tipop, d.tip_partener, d.tli, d.cota_tva, d.factura, 0 as fsimplificata,
			-1*sum(d.valoare_factura+d.tva) incasare, -1*sum(d.baza) baza, -1*sum(d.tva) tva, 0 as nrbonuri, convert(varchar(6),'AMEF') as tipinc, d.lm, d.idpozitie
		from #D394det d
		where @D394_102016=1 and d.tipD='BP' and d.tipDoc='BP'	--Facturi emise din bonuri
		group by d.data, d.subunitate, d.codfisc, d.tipop, d.tip_partener, d.tli, d.cota_tva, d.factura, d.lm, d.idpozitie

		select codcaen, (case when tip_nom not in ('R','S') then 1 else 2 end) as tipop, convert(decimal(15),sum(baza)) as baza, convert(decimal(15),sum(tva)) as tva, cota_tva
		into #D394LivrariCodCaen
		from #D394det 
		where tipop in ('L') and cota_tva<>0 and nullif(codcaen,'') is not null and @D394_102016=1 
		group by codcaen, cota_tva, (case when tip_nom not in ('R','S') then 1 else 2 end)

		select factura, baza, tva, cota_tva, idplaja into #D394autofacturi
		from #D394det 
		where tipop='L' and tipDoc='IC' and codfisc=@codfiscal and left(NumarD,1)='6'

		delete from	#D394det 
		where tipD='PI' and (tipDoc='IC' or tipDoc='PC' and (fsimplificata>0 or left(NumarD,1)='6')) --	stergem PC-uri cu cont antet = clasa 6 (reprezinta protocol nedeductibil).
			or tipD='RM' and tipDoc='RC' or tipD in ('RM','RS') and fsimplificata=1 or tipD='FF' and fsimplificata in (1,2)

	-->	Nu recomandam varianta de a opera pt. cereale documente de tip SF/IF. 
	-->	In cazul cerealelor documentele de tip SF/IF se vor opera prin RM/AP pe cod de tip serviciu care va avea atasat un cod de Nomenclatura combinata pt. cereale
		if @D394SFIFCereale=1
		begin
		--> se inlocuiesc SF-urile si IF-urile cu date de pe facturile propriu-zise (doc RM, respectiv AP); feliere pe coduri si calcul ponderat al valorilor
			create table #detaliereSFIF (tip varchar(2), factura varchar(20), tert varchar(20), cod varchar(20), baza decimal(15,3), codNomenclatura varchar(20), pondere decimal(15,5))
	
			insert into #detaliereSFIF(tip, factura, tert, cod, baza, codNomenclatura, pondere)
			select (case p.tip when 'RM' then 'SF' when 'AP' then 'IF' end) tip, p.factura, p.tert, p.cod,
					sum(p.Cantitate*p.Pret_valuta) baza, isnull(pr.valoare,'') as codNomenclatura, 0 pondere
			from pozdoc p left join proprietati pr on pr.Tip='NOMENCL' and pr.Cod_proprietate=@proprietateNomenclatorCoduriCereale and pr.Cod=p.Cod
			where exists (select 1 from #D394det r 
					where ((r.tipDoc='SF' and p.Tip='RM') and r.exonerat=1  or (r.tipDoc='IF' and p.Tip='AP') and r.exonerat=2)
						--and r.exonerat=1 
						and r.factadoc<>''
						and p.factura=r.factadoc and p.Tert=r.tert
					)
			group by p.tip, p.factura, p.tert, p.cod, pr.valoare
	
			update d set pondere=(case when t.total=0 then 0 else d.baza/t.total end)
			from #detaliereSFIF d inner join (select sum(t.baza) total, tip, factura, tert from #detaliereSFIF t group by tip, factura, tert) t 
					on t.tip=d.tip and t.factura=d.factura and t.tert=d.tert

		-->	am scos conditia de @exonerat=1 din insert/delete-ul de mai jos intrucat la insert in #detaliereSFIF se preiau doar acele documente cu @exonerat corespunzator.
			insert into #D394det(subunitate, numar, numarD, tipD, data, factura, tert, valoare_factura, baza, tva, explicatii,
					tip, cota_tva, discFaraTVA, discTVA, data_doc, ordonare, drept_ded, cont_TVA, cont_coresp, exonerat,
					vanzcump, numar_pozitie, tipDoc, cod, factadoc, contf, codfisc, dentert, tipop, codNomenclator, invers, tip_partener, tip_tva, tli, tipDocNepl)
			select max(r.subunitate), max(r.numar), max(r.numarD), max(r.tipD), max(r.data), max(r.factura), max(r.tert), sum(r.valoare_factura)*max(p.pondere),
					sum(r.baza)*max(p.pondere), sum(r.tva)*max(p.pondere), max(r.explicatii), max(r.tip), max(r.cota_tva), max(r.discFaraTVA), max(r.discTVA),
					max(r.data_doc), max(r.ordonare), max(r.drept_ded), max(r.cont_TVA), max(r.cont_coresp), max(r.exonerat), max(r.vanzcump), max(r.numar_pozitie),
					max(r.tipDoc), p.cod, max(r.factadoc), max(r.contf), max(r.codfisc), max(r.dentert), max(r.tipop), p.cod, max(r.invers+10), max(r.tip_partener), max(tip_tva), max(tli), max(r.tipDocNepl)
			from #D394det r inner join #detaliereSFIF p on p.tip=r.tipDoc and p.factura=r.factadoc and p.tert=r.tert /*and r.exonerat=1*/ and r.factadoc<>''
			group by p.tip, p.factura, p.tert, p.cod

			delete r from #D394det r inner join #detaliereSFIF p on p.tip=r.tipDoc and p.factura=r.factadoc and p.tert=r.tert /*and r.exonerat=1*/ and rtrim(r.factadoc)<>'' and r.invers<10
		end
		update #D394det set invers=invers-10 where invers>=10
		--	sfarsit functie frapTVApecoduridet

		--> sa nu aduc facturi de prestari cu taxare inversa - nu intra la D. 394 (?)
		delete from #D394det
		where tipDoc='RP' and invers=1 and tipOp='A'

		-->	Preluare bun din nomenclator.detalii sau grupe.detalii
		update d set d.bun=(case when isnull(c.codNomenclatura,'')<>'' then '21' 
			else isnull(nullif(n.detalii.value('(/row/@codnc394)[1]','varchar(20)'),''),isnull(gn.detalii.value('(/row/@codnc394)[1]','varchar(20)'),'')) end)
		from #D394det d
			inner join nomencl n on n.cod=d.codNomenclator 
			left join grupe gn on gn.grupa=n.grupa
			left join #tCoduriCereale c on d.codNomenclator=c.cod

		-->	Preluare cod nomenclatura de pe proprietati. Am tratat aici pentru ca este nevoie de cod nomenclatura si in raport pentru detalierea pe cod fiscal si cod nomenclatura.
		update d set d.codNomenclatura=rtrim(isnull(nullif(c.codNomenclatura,''),isnull(d.bun,'')))
		from #D394det d
			left join #tCoduriCereale c on d.codNomenclator=c.cod

		-->	apel procedura specifica Declaratia394SP1 care permite completarea/modificarea tabelei #D394det
		if exists (select 1 from sysobjects o where o.type='P' and o.name='Declaratia394SP1') 
			exec Declaratia394SP1 @parXML 

		--	grupare date pentru stabilire valoare facturi catre persoane fizice
		insert #D394factPF (codtert, codfisc, factura, baza, tva)
		select tert, codfisc, factura, sum(baza) as baza, sum(tva) as tva
		from #D394det d
		where (abs(round(convert(decimal(15,3),d.baza),2))>=0.01 or @pecoduri=1 and abs(round(convert(decimal(15,3),d.tva),2))>=0.01 or d.cota_tva<>0)
			and d.tip_partener=2 and d.tertPF=1 and d.tipop='L'
		group by d.tert, d.subunitate, d.codfisc, d.factura

		-->	formare aici tip operatie (tipop) pentru a nu mai dubla conditia si in procedura de raport unde se afiseaza facturile.
		update #D394det set tipop=(case when invers=1 and tipop='L' then 'V' when tipop='L' and marjaprofit=1 then 'LS' 
						when invers=1 and tipop='A' then 'C' when tipop='A' and regimspec394=1 and tli=0 then 'AS' when tipop='A' and tli=1 then 'AI' 
						when tipop='A' and tip_partener=2 then 'N' else tipop end)

		update #D394det set tipDocNepl = (case when tip_partener=2 and tipop='N' then isnull(nullif(tipDocNepl,''),(case when tertPF=1 then 2 else 1 end)) else '' end)

		if exists (select 1 from #D394det where tip_partener=1 and tipop in ('C','V') and isnull(codNomenclatura,'')='') and app_name() not like '%unipaas%'
		begin
			set @mesajAtentionare=''
			select @mesajAtentionare=RTRIM(@mesajAtentionare)+RTRIM(tipDoc)+' '+rtrim(numar)+' cod: '+rtrim(cod)+';'
			from (select distinct tipDoc, numar, cod from #D394det where tip_partener=1 and tipop in ('C','V') and isnull(codNomenclatura,'')='') a
			set @mesajAtentionare= 'Exista facturi la care se aplica taxarea inversa, dar codurile de pe aceste doc. nu au completat in nomenclator codul specific declaratiei 394! (Ex. '
				+ left(@mesajAtentionare,LEN(@mesajAtentionare)-1) + ')!'		-- Sterg ultima virgula din @mesajAtentionare
			if @genRaport=0
				select rtrim(@mesajAtentionare) as textMesaj for xml raw, root('Mesaje')
		end

		if exists (select 1 from #D394det where tip_partener=2 and tipop='N' and tertPF=1 and isnull(codNomenclatura,'')='') and app_name() not like '%unipaas%'
		begin
			set @mesajAtentionare=''
			select @mesajAtentionare=RTRIM(@mesajAtentionare)+RTRIM(tipDoc)+' '+rtrim(numar)+' cod: '+rtrim(cod)+';'
			from (select distinct tipDoc, numar, cod from #D394det where tip_partener=2 and tipop='N' and tertPF=1 and isnull(codNomenclatura,'')='') a
			set @mesajAtentionare= 'Exista receptii de la persoane fizice, dar codurile de pe aceste doc. nu au completat in nomenclator codul specific declaratiei 394! (Ex. '
				+ left(@mesajAtentionare,LEN(@mesajAtentionare)-1) + ')!'		-- Sterg ultima virgula din @mesajAtentionare
			if @genRaport=0
				select rtrim(@mesajAtentionare) as textMesaj for xml raw, root('Mesaje')
		end

		--	grupare date pentru stabilire valoare tva si cota tva majoritara pe factura.
		insert #D394facturi (codtert, codfisc, tipop, factura, cota_tva, baza, tva)
		select tert, codfisc, tipop, factura, cota_tva, baza, tva from
		(select tert, codfisc, tipop, factura, cota_tva, sum(baza) as baza, sum(tva) as tva, RANK() over (partition by codfisc, factura order by sum(tva) Desc, cota_tva desc, sum(baza) desc) as ordine
		from #D394det d
		where (abs(round(convert(decimal(15,3),d.baza),2))>=0.01 or @pecoduri=1 and abs(round(convert(decimal(15,3),d.tva),2))>=0.01 or d.cota_tva<>0 or d.cota_tva=0 and (d.exonerat=2 or d.marjaprofit=1))
		group by d.subunitate, d.tert, d.codfisc, d.tipop, d.factura, d.cota_tva) a
		where ordine=1

		--	grupare date pentru stabilire valoare tva si cota tva majoritara pe factura si codNomenclatura.
		insert #D394facturiCod (codtert, codfisc, tipop, factura, codNomenclatura, cota_tva, baza, tva)
		select tert, codfisc, tipop, factura, codNomenclatura, cota_tva, baza, tva from
		(select tert, codfisc, tipop, factura, codNomenclatura, cota_tva, sum(baza) as baza, sum(tva) as tva, RANK() over (partition by codfisc, factura order by sum(tva) Desc, cota_tva desc, sum(baza) Desc) as ordine
		from #D394det d
		where (abs(round(convert(decimal(15,3),d.baza),2))>=0.01 or @pecoduri=1 and abs(round(convert(decimal(15,3),d.tva),2))>=0.01 or d.cota_tva<>0 or d.cota_tva=0 and (d.exonerat=2 or d.marjaprofit=1))
		group by d.subunitate, d.tert, d.codfisc, d.tipop, d.factura, d.codNomenclatura, d.cota_tva) a
		where ordine=1

		-->	grupare date pentru stabilire numar de facturi pe tert, tipop
		insert #D394facttmp(codfisc, tipop, invers, nrfacturi, cota_tva, tip_partener, tli, factPFpeCUI, tertPF, regimspec394, codtert, tipDocNepl)
		select d.codfisc, d.tipop, d.invers, count(distinct d.factura) as nrfacturi, d.cota_tva, d.tip_partener, d.tli, 
			(case when @fact10000_2016=1 or @datasus<'10/01/2016' then 0 else 1 end), d.tertPF as tertPF, d.regimspec394, 
			(case when d.tip_partener=2 and d.tertPF=1 and d.tipop in ('N','L','LS') then d.tert else '' end), d.tipDocNepl
		from #D394det d
			left outer join #D394factPF dpf on dpf.codfisc=d.codfisc and dpf.factura=d.factura
			inner join #D394facturi df on df.codfisc=d.codfisc and df.tipop=d.tipop and df.factura=d.factura and df.cota_tva=d.cota_tva
		-- am scos conditia referitoare la valoare baza/tva pentru a nu "falsifica" numarul de facturi (facturi cu plus/minus). Ramine in discutie problema facturilor de penalitati care nu "poarta" TVA.
		where (abs(round(convert(decimal(15,3),d.baza),2))>=0.01 or @pecoduri=1 and abs(round(convert(decimal(15,3),d.tva),2))>=0.01 or d.cota_tva<>0 or d.cota_tva=0 and (d.exonerat=2 or d.marjaprofit=1))
			and (not(d.tip_partener=2 and d.tertPF=1 and d.tipop in ('L','LS')) or abs(dpf.baza+dpf.tva)<=10000 or @fact10000_2016=0)
		group by d.subunitate, d.codfisc, d.tipop, d.invers, d.cota_tva, d.tip_partener, d.tli, d.tertPF, d.regimspec394, 
			(case when d.tip_partener=2 and d.tertPF=1 and d.tipop in ('N','L','LS') then d.tert else '' end), d.tipDocNepl
		having abs(sum(round(convert(decimal(15,3),d.baza),2)))>=0.01 or @pecoduri=1 and abs(sum(round(convert(decimal(15,3),d.tva),2)))>=0.01 or 1=1
		union all
		-->	TRATAM SEPARAT FACTURILE DE PESTE 10000 RON CATRE PERSOANE FIZICE. DOAR ACESTEA TREBUIE DECLARATE PE CNP IN PERIOADA 01.10.2016 - 31.12.2016
		select d.codfisc, d.tipop, d.invers, count(distinct d.factura) as nrfacturi, d.cota_tva, d.tip_partener, d.tli, 1, d.tertPF, d.regimspec394, 
			(case when d.tertPF=1 and d.codfisc='' then d.tert else '' end), ''
		from #D394det d
			left outer join #D394factPF dpf on dpf.codfisc=d.codfisc and dpf.factura=d.factura 
			inner join #D394facturi df on df.codfisc=d.codfisc and df.tipop=d.tipop and df.factura=d.factura and df.cota_tva=d.cota_tva
		-- am scos conditia referitoare la valoare baza/tva pentru a nu "falsifica" numarul de facturi (facturi cu plus/minus). Ramine in discutie problema facturilor de penalitati care nu "poarta" TVA.
		where (abs(round(convert(decimal(15,3),d.baza),2))>=0.01 or @pecoduri=1 and abs(round(convert(decimal(15,3),d.tva),2))>=0.01 or d.cota_tva<>0)
			and @fact10000_2016=1 and d.tip_partener=2 and d.tertPF=1 and d.tipop in ('L','LS') and abs(dpf.baza+dpf.tva)>10000
		group by d.subunitate, d.codfisc, d.tipop, d.invers, d.cota_tva, d.tip_partener, d.tli, d.tertPF, d.regimspec394, (case when d.tertPF=1 and d.codfisc='' then d.tert else '' end)
		having abs(sum(round(convert(decimal(15,3),d.baza),2)))>=0.01 or @pecoduri=1 and abs(sum(round(convert(decimal(15,3),d.tva),2)))>=0.01 or 1=1

		-->	grupare date pentru stabilire numar de facturi pe tert, tipop si COD NOMENCLATURA D394
		insert #D394facttmpCod(codfisc, tipop, invers, nrfacturi, cota_tva, tip_partener, tli, factPFpeCUI, tertPF, regimspec394, codNomenclatura, codtert, tipDocNepl)
		select d.codfisc, d.tipop, d.invers, count(distinct d.factura) as nrfacturi, d.cota_tva, d.tip_partener, d.tli, 
			(case when @fact10000_2016=1 or @datasus<'10/01/2016' then 0 else 1 end), d.tertPF as tertPF, d.regimspec394, d.codNomenclatura, 
			(case when d.tip_partener=2 and d.tertPF=1 and d.tipop in ('N','L','LS') then d.tert else '' end), d.tipDocNepl
		from #D394det d
			left outer join #D394factPF dpf on dpf.codfisc=d.codfisc and dpf.factura=d.factura 
			inner join #D394facturiCod dfc on dfc.codfisc=d.codfisc and dfc.tipop=d.tipop and dfc.factura=d.factura and dfc.cota_tva=d.cota_tva and dfc.codNomenclatura=d.codNomenclatura
		-- am scos conditia referitoare la valoare baza/tva pentru a nu "falsifica" numarul de facturi (facturi cu plus/minus). Ramine in discutie problema facturilor de penalitati care nu "poarta" TVA.
		where (abs(round(convert(decimal(15,3),d.baza),2))>=0.01 or @pecoduri=1 and abs(round(convert(decimal(15,3),d.tva),2))>=0.01 or d.cota_tva<>0 or d.cota_tva=0 and (d.exonerat=2 or d.marjaprofit=1))
			and (not(d.tip_partener=2 and d.tertPF=1 and d.tipop in ('L','LS')) or abs(dpf.baza+dpf.tva)<=10000 or @fact10000_2016=0)
		group by d.subunitate, d.codfisc, d.tipop, d.invers, d.cota_tva, d.tip_partener, d.tli, d.tertPF, d.regimspec394, d.codNomenclatura, 
			(case when d.tip_partener=2 and d.tertPF=1 and d.tipop in ('N','L','LS') then d.tert else '' end), d.tipDocNepl
		having abs(sum(round(convert(decimal(15,3),d.baza),2)))>=0.01 or @pecoduri=1 and abs(sum(round(convert(decimal(15,3),d.tva),2)))>=0.01 or 1=1
		union all
		-->	TRATAM SEPARAT FACTURILE DE PESTE 10000 RON CATRE PERSOANE FIZICE. DOAR ACESTEA TREBUIE DECLARATE PE CNP IN PERIOADA 01.10.2016 - 31.12.2016
		select d.codfisc, d.tipop, d.invers, count(distinct d.factura) as nrfacturi, d.cota_tva, d.tip_partener, d.tli, 1, d.tertPF, d.regimspec394, d.codNomenclatura, 
			(case when d.tertPF=1 and d.codfisc='' then d.tert else '' end), ''
		from #D394det d
			left outer join #D394factPF dpf on dpf.codfisc=d.codfisc and dpf.factura=d.factura
			inner join #D394facturiCod dfc on dfc.codfisc=d.codfisc and dfc.tipop=d.tipop and dfc.factura=d.factura and dfc.cota_tva=d.cota_tva and dfc.codNomenclatura=d.codNomenclatura
		--> am scos conditia referitoare la valoare baza/tva pentru a nu "falsifica" numarul de facturi (facturi cu plus/minus). Ramine in discutie problema facturilor de penalitati care nu "poarta" TVA.
		where (abs(round(convert(decimal(15,3),d.baza),2))>=0.01 or @pecoduri=1 and abs(round(convert(decimal(15,3),d.tva),2))>=0.01 or d.cota_tva<>0)
			and @fact10000_2016=1 and d.tip_partener=2 and d.tertPF=1 and d.tipop in ('L','LS') and abs(dpf.baza+dpf.tva)>10000
		group by d.subunitate, d.codfisc, d.tipop, d.invers, d.cota_tva, d.tip_partener, d.tli, d.tertPF, d.regimspec394, d.codNomenclatura, 
			(case when d.tertPF=1 and d.codfisc='' then d.tert else '' end)
		having abs(sum(round(convert(decimal(15,3),d.baza),2)))>=0.01 or @pecoduri=1 and abs(sum(round(convert(decimal(15,3),d.tva),2)))>=0.01 or 1=1

		if @genRaport=2
		begin
			-->	Daca se apeleaza procedura Declaratia394 dinspre rapDeclaratia394, atunci aici pastram in D394, doar operatiunile care mai jos se centralizeaza pentru numarare.
			delete d 
			from #D394det d
				left outer join #D394factPF dpf on dpf.codfisc=d.codfisc and dpf.factura=d.factura
			where not((d.cota_tva<>0 or d.cota_tva=0 and (d.exonerat=2 or d.marjaprofit=1) or d.regimspec394=1 or d.tip_partener=2) 
					and (not(d.tip_partener=2 and d.tertPF=1 and d.tipop in ('L','LS')) or abs(dpf.baza+dpf.tva)<=10000 or @fact10000_2016=0)
				or d.cota_tva<>0 and @fact10000_2016=1 and d.tip_partener=2 and d.tertPF=1 and d.tipop in ('L','LS') and abs(dpf.baza+dpf.tva)>10000)
			
			return
		end

		-->	grupare date (din #D394det in #D394tmp).
		insert #D394tmp(codtert, codfisc, dentert, tipop, nrfacturi, baza, tva, codNomenclator, invers, cota_tva, tip_partener, tli, factPFpeCUI, tertPF, regimspec394, bun, tipDocNepl)
		select max(d.tert) as tert, max(d.codfisc) codfisc, max(d.dentert) dentert, d.tipop, 0, sum(d.baza) baza, sum(d.tva) tva, d.cod, d.invers, d.cota_tva, d.tip_partener, d.tli, 
			(case when @fact10000_2016=1 or @datasus<'10/01/2016' then 0 else 1 end), d.tertPF, d.regimspec394, d.bun, d.tipDocNepl
		from #D394det d
			left outer join #D394factPF dpf on dpf.codfisc=d.codfisc and dpf.factura=d.factura
		where (d.cota_tva<>0 or d.cota_tva=0 and (d.exonerat=2 or d.marjaprofit=1) or d.regimspec394=1 or d.tip_partener=2)
			and (not(d.tip_partener=2 and d.tertPF=1 and d.tipop in ('L','LS')) or abs(dpf.baza+dpf.tva)<=10000 or @fact10000_2016=0)
		group by d.subunitate, d.codfisc, d.cod, d.tipop, d.invers, d.cota_tva, d.tip_partener, d.tli, d.tertPF, d.regimspec394, d.bun, d.tipDocNepl, 
			(case when d.tertPF=1 and d.codfisc='' then d.tert else '' end)
		-- nu mai duc in declaratie documentele cu baza de tva 0 - sper sa fie bine asa
		-- Lucian: Am adaugat conditia @pecoduri=1 si sum(TVA)>0.01 astfel incat sa ia in calcul si pozitiile cu TVA nedeductibil (unde baza=0 si TVA<>0)
		-- probabil ca nu trebuie sa aduca pozitiile unde baza=0 si tva=0 (facturi+storno ale acelor facturi)
		-- am scos conditia referitoare la valoare baza/tva pentru a nu "falsifica" numarul de facturi (facturi cu plus/minus). Ramine in discutie problema facturilor de penalitati care nu "poarta" TVA.
		having abs(sum(round(convert(decimal(15,3),d.baza),2)))>=0.01 or @pecoduri=1 and abs(sum(round(convert(decimal(15,3),d.tva),2)))>=0.01 or 1=1
		union all 
		--	TRATAM SEPARAT FACTURILE DE PESTE 10000 RON CATRE PERSOANE FIZICE. DOAR ACESTEA TREBUIE DECLARATE PE CNP IN PERIOADA 01.10.2016 - 31.12.2016
		select max(d.tert) as tert, max(d.codfisc) codfisc, max(d.dentert) dentert, d.tipop, 0, sum(d.baza) baza, sum(d.tva) tva, d.cod, d.invers, d.cota_tva, d.tip_partener, d.tli, 
			1, d.tertPF, d.regimspec394, d.bun, ''
		from #D394det d
			left outer join #D394factPF dpf on dpf.codfisc=d.codfisc and dpf.factura=d.factura
		where d.cota_tva<>0 and @fact10000_2016=1 and d.tip_partener=2 and d.tertPF=1 and d.tipop in ('L','LS') and abs(dpf.baza+dpf.tva)>10000
		group by d.subunitate, d.codfisc, d.cod, d.tipop, d.invers, d.cota_tva, d.tip_partener, d.tli, d.tertPF, d.regimspec394, d.bun, 
			(case when d.tertPF=1 and d.codfisc='' then d.tert else '' end)
		-- nu mai duc in declaratie documentele cu baza de tva 0 - sper sa fie bine asa
		-- Lucian: Am adaugat conditia @pecoduri=1 si sum(TVA)>0.01 astfel incat sa ia in calcul si pozitiile cu TVA nedeductibil (unde baza=0 si TVA<>0)
		-- probabil ca nu trebuie sa aduca pozitiile unde baza=0 si tva=0 (facturi+storno ale acelor facturi)
		-- am scos conditia referitoare la valoare baza/tva pentru a nu "falsifica" numarul de facturi (facturi cu plus/minus). Ramine in discutie problema facturilor de penalitati care nu "poarta" TVA.
		having abs(sum(round(convert(decimal(15,3),d.baza),2)))>=0.01 or @pecoduri=1 and abs(sum(round(convert(decimal(15,3),d.tva),2)))>=0.01 or 1=1

		--> facturi din UAPlus:
		if exists (select 1 from sysobjects o where o.type='TF' and o.name='docTVAVanzUA') and exists (select 1 from sysobjects o where o.type='U' and o.name='incfactAbon')
		begin
			insert #D394tmp (codtert, codfisc, dentert, tipop, nrfacturi, baza, tva, codNomenclator, invers, cota_tva, tip_partener,tli,factPFpeCUI,tertPF,regimspec394,bun)
			--	de transmis lui Norbert sa aduca si cota_tva / tip_partener / tli / factPFpeCUI completat
			OUTPUT inserted.codfisc, inserted.tipop, inserted.invers, inserted.nrfacturi,inserted.cota_tva,inserted.tip_partener,inserted.tli,inserted.factPFpeCUI,inserted.tertPF,inserted.regimspec394	
			into #D394facttmp(codfisc, tipop, invers, nrfacturi, cota_tva, tip_partener,tli,factPFpeCUI,tertPF,regimspec394) 
			select codtert,codfisc,dentert,tipop,nrfacturi,baza,tva,codNomenclator, invers, cota_tva, tip_partener,tli,factPFpeCUI,tertPF,regimspec394,bun from dbo.rapTVAUAPlus(@datajos,@datasus) 
		end

		--> facturi din UARia:
		if exists (select 1 from sysobjects o where o.type='P' and o.name='TVAVanzariUA') and exists (select 1 from sysobjects o where o.type='U' and o.name='AntetfactAbon')
		begin
			exec Declaratia394UA @DataJos=@datajos,@DataSus=@datasus,@sesiune=@sesiune
		end

		insert #D394cif(codtert, codfisc, dentert, tipop, baza, tva, codNomenclator, invers, cota_tva, tip_partener, tli, factPFpeCUI, tertPF, regimspec394, bun, tipDocNepl)
		select max(codtert),codfisc,max(dentert) as dentert,tipop, sum(baza), sum(tva), codNomenclator, invers, cota_tva, tip_partener, tli, factPFpeCUI, tertPF, regimspec394, bun, tipDocNepl
		from #D394tmp
		group by codfisc,tipop, codNomenclator, invers, cota_tva, tip_partener, tli, factPFpeCUI, tertPF, regimspec394, bun, tipDocNepl, 
			(case when tertPF=1 and codfisc='' then codtert else '' end)
		-- am scos conditia referitoare la valoare baza/tva pentru a nu "falsifica" numarul de facturi (facturi cu plus/minus). Ramine in discutie problema facturilor de penalitati care nu "poarta" TVA.
		having abs(sum(round(convert(decimal(15,3),baza),2)))>=0.01 or @pecoduri=1 and abs(sum(round(convert(decimal(15,3),tva),2)))>=0.01 or 1=1
		order by tipop desc, dentert

		-->	Preluare bun din nomenclator.detalii sau grupe.detalii
		update d set d.bun=isnull(nullif(n.detalii.value('(/row/@codnc394)[1]','varchar(20)'),''),isnull(nullif(gn.detalii.value('(/row/@codnc394)[1]','varchar(20)'),''),d.bun))
		from #D394cif d
			inner join nomencl n on n.cod=d.codNomenclator 
			left join grupe gn on gn.grupa=n.grupa

		-->	Reincadrare bun pentru Constructii/Terenuri si Tip_partener=1
		update #D394cif set bun=(case when bun in ('32','33') and tip_partener=1 then '27' else bun end)

		insert #D394fact(codfisc, tipop, invers, nrfacturi, cota_tva, tip_partener, tli, factPFpeCUI, codtert, tipDocNepl)
		select codfisc,tipop, invers, sum(nrfacturi), cota_tva, tip_partener, tli, factPFpeCUI, (case when tertPF=1 and codfisc='' then codtert else '' end), tipDocNepl
		from #D394facttmp
		group by codfisc, tipop, invers, cota_tva, tip_partener, tli, factPFpeCUI, (case when tertPF=1 and codfisc='' then codtert else '' end), tipDocNepl

		insert #D394factCod(codfisc, tipop, invers, nrfacturi, cota_tva, tip_partener, tli, factPFpeCUI, codNomenclatura, codtert, tipDocNepl)
		select codfisc,tipop, invers, sum(nrfacturi), cota_tva, tip_partener, tli, factPFpeCUI, codNomenclatura, (case when tertPF=1 and codfisc='' then codtert else '' end), tipDocNepl
		from #D394facttmpCod
		group by codfisc, tipop, invers, cota_tva, tip_partener, tli, factPFpeCUI, codNomenclatura, (case when tertPF=1 and codfisc='' then codtert else '' end), tipDocNepl

		select max(rtrim(d.codtert)) codtert, rtrim(d.codfisc) cuiP, max(rtrim(d.dentert)) dentert
			,d.tipop, d.cota_tva, d.tip_partener, max(d.tli) as tli
			-->	Tip document se completeaza doar pentru tip partener=2 si tipop=A (Achizitii).
			-->	De vazut cum putem sa diferentiem Borderourile de achizitie de Carnetele de comercializare. Pentru inceput tot ce este persoana fizica am pus pe Borderouri.
			,nullif(d.tipDocNepl,'') as tip_document
			,(case when row_number() over (partition by d.codfisc, d.tip_partener, d.tipop, d.cota_tva, d.factPFpeCUI, 
				(case when d.tertPF=1 and d.codfisc='' then d.codtert else '' end), d.tipDocNepl
				order by d.cota_tva desc, rtrim(isnull(nullif(c.codNomenclatura,''),isnull(d.bun,''))))=1 
					then max(isnull(f.nrfacturi,0)) else 0 end) as nrfacturi
			,(case when row_number() over (partition by d.codfisc, d.tip_partener, d.tipop, d.cota_tva, d.factPFpeCUI, rtrim(isnull(nullif(c.codNomenclatura,''),isnull(d.bun,''))),
				(case when d.tertPF=1 and d.codfisc='' then d.codtert else '' end), d.tipDocNepl
				order by d.cota_tva desc, rtrim(isnull(nullif(c.codNomenclatura,''),isnull(d.bun,''))))=1 
					then max(isnull(fc.nrfacturi,0)) else 0 end) as nrfacturicod
			,convert(decimal(15),convert(decimal(15,3),sum(d.baza))) baza, convert(decimal(15),convert(decimal(15,3),sum(d.tva))) tva
			,rtrim(isnull(nullif(c.codNomenclatura,''),isnull(d.bun,''))) as cod		--> pentru acest cod de nomenclator s-a separat rapTVAInform in rapTVApecoduri si rapTVAInform
			,max(rtrim(n.Denumire)) as denumirecod
			,(case when isnull(c.codNomenclatura,'')<>'' then '21' else isnull(d.bun,'') end) as bun, d.factPFpeCUI, d.tertPF
		into #D394
		from #D394cif d
			left join #tCoduriCereale c on d.codNomenclator=c.cod
			left join nomencl n on n.Cod=d.codNomenclator
			left outer join grupe gn on gn.grupa=n.grupa
			left join #D394fact f on f.tip_partener=d.tip_partener and d.codfisc=f.codfisc and d.tipop=f.tipop and d.invers=f.invers and d.cota_tva=f.cota_tva and d.factPFpeCUI=f.factPFpeCUI	
				and d.tipDocNepl=f.tipDocNepl and (not(d.tertPF=1 and d.codfisc='') or f.codtert=d.codtert)
			left join #D394factCod fc on fc.tip_partener=d.tip_partener and d.codfisc=fc.codfisc and d.tipop=fc.tipop and d.invers=fc.invers and d.cota_tva=fc.cota_tva 
				and rtrim(isnull(nullif(c.codNomenclatura,''),isnull(d.bun,'')))=fc.codNomenclatura and d.factPFpeCUI=fc.factPFpeCUI
				and d.tipDocNepl=fc.tipDocNepl and (not(d.tertPF=1 and d.codfisc='') or fc.codtert=d.codtert)
		group by d.codfisc, d.tipop, d.tipDocNepl, d.cota_tva, d.tip_partener, d.factPFpeCUI, d.tertPF, 
				rtrim(isnull(nullif(c.codNomenclatura,''),isnull(d.bun,''))), (case when isnull(c.codNomenclatura,'')<>'' then '21' else isnull(d.bun,'') end),
				(case when d.tertPF=1 and d.codfisc='' then d.codtert else '' end)
		order by 4,3,8

		insert into #D394factPFSub10000 (nrfacturi, baza, tva, cota_tva)
		select sum(nrfacturi) as nrfacturi, convert(decimal(15),sum(baza)) as baza, convert(decimal(15),sum(tva)), cota_tva
		from #D394
		where tip_partener=2 and tertPF=1 and factPFpeCUI=0 and tipop in ('L','LS') and @fact10000_2016=1	-->doar pentru aceasta perioada se declara numar facturi, baza, tva aferent facturilor catre persoane fizice cu valoare pana in 10000 RON .
		group by cota_tva

		delete from #D394 
		where tip_partener=4 and tipop='A'	--la terti externi se declara doar achizitiile cu taxare inversa.
				or tip_partener=2 and tertPF=1 and factPFpeCUI=0 and tipop in ('L','LS')	--stergem si tertii PF care nu se declara nominal
		--delete #D394 where abs(baza)<0.01 and abs(tva)<0.01	--Am scos aceasta stergere pentru a nu "falsifica" numarul de facturi.

		-->	Stergere pozitii completate printr-o generare anterioara.
		delete from D394 where data=@dataSus and (@lmUtilizator is null or lm=@lmUtilizator) and isnull(Introdus_manual,0)=0

		-->	Inceput de populare tabela D394. Preluare date unitate (tip_intocmit, intocmit, calitate intocmit, etc) care se vor putea edita
		insert into D394 (data, lm, rand_decl, denumire, Introdus_manual)
		select @datasus, @lmUtilizatorFirma, rand_decl, denumire, Introdus_manual
		from D394 d
		where data=DateADD(day,-1,@dataJos) and (@lmUtilizatorFirma is null and d.lm is null or d.lm=@lmUtilizatorFirma)
			and rand_decl in ('A_cifR','A_denR','A_functieR','A_adresaR'
				,'A_tip_intocmit', 'A_den_intocmit', 'A_cif_intocmit', 'A_calitate_intocmit', 'A_functie_intocmit', 'A_optiune', 'A_schimb_optiune','A_solicit_ramb','A_nrcasemarcat')
			and not exists (select 1 from D394 d1 where d1.data=@dataSus and (@lmUtilizatorFirma is null and d1.lm is null or isnull(d1.lm,'')=isnull(d.lm,'')) and d1.rand_decl=d.rand_decl)

		if not exists (select 1 from D394 where data=@dataSus and (@lmUtilizatorFirma is null and lm is null or lm=@lmUtilizatorFirma) and rand_decl='A_tip_intocmit')
		begin
			-->	Pentru prima luna citim denumire si functie intocmit din parametri.
			exec luare_date_par 'GE', 'NDECLTVA', 0, 0, @den_intocmit output
			exec luare_date_par 'GE', 'FDECLTVA', 0, 0, @functie_intocmit output

			-->	Valori implicite pentru datele 
			insert into D394 (data, lm, rand_decl, denumire, Introdus_manual)
			select @datasus, @lmUtilizatorFirma, 'A_tip_intocmit', '1', 1 union all
			select @datasus, @lmUtilizatorFirma, 'A_den_intocmit', @den_intocmit, 1 union all
			select @datasus, @lmUtilizatorFirma, 'A_cif_intocmit', '', 1 union all
			select @datasus, @lmUtilizatorFirma, 'A_calitate_intocmit', '', 1 union all
			select @datasus, @lmUtilizatorFirma, 'A_functie_intocmit', @functie_intocmit, 1 union all
			select @datasus, @lmUtilizatorFirma, 'A_optiune', '0', 1 union all
			select @datasus, @lmUtilizatorFirma, 'A_schimb_optiune', '', 1 union all
			select @datasus, @lmUtilizatorFirma, 'A_solicit_ramb', '0', 1 union all
			select @datasus, @lmUtilizatorFirma, 'A_cifR', '', 1 union all
			select @datasus, @lmUtilizatorFirma, 'A_denR', @dirgen, 1 union all
			select @datasus, @lmUtilizatorFirma, 'A_functieR', @fdirgen, 1 union all
			select @datasus, @lmUtilizatorFirma, 'A_adresaR', '', 1
		end

		-->	Numarul de case de marcat il tratam separat intrucat acesta se declara doar incepand cu declaratia lunii octombrie 2016.
		if not exists (select 1 from D394 where data=@dataSus and (@lmUtilizatorFirma is null and lm is null or lm=@lmUtilizatorFirma) and rand_decl='A_nrcasemarcat')
			insert into D394 (data, lm, rand_decl, nrCui, Introdus_manual)
			select @datasus, @lmUtilizatorFirma, 'A_nrcasemarcat', @nrAMEF, 1

		-->	Numarul de case de marcat il luam din declaratia perioadei  anterioare
		select @nrAMEF=max(nrCui)
		from D394 d
		where data=DateADD(day,-1,@dataJos) and (@lmUtilizatorFirma is null and lm is null or lm=@lmUtilizatorFirma) and rand_decl='A_nrcasemarcat'

		/*
			tip_partener = 1	-> Persoane impozabile inregistrate in scopuri de TVA in Romania.
			tip_partener = 2	-> Persoane neinregistrate in scopuri de TVA.
			tip_partener = 3	-> Persoane nestabilite in Romania, din UE
			tip_partener = 4
		*/

		-->	Preluare sume facturi pe tipuri de parteneri. (sectiunile REZUMAT C., D., E., F.)
		insert into D394 (data, lm, rand_decl, tip_partener, nrCui, tipop, tli, nrfacturi, baza, tva, cota_tva, tip_document, Introdus_manual)
		select @datasus, @lmUtilizator, (case when tip_partener=1 then 'C.' when tip_partener=2 then 'D.' when tip_partener=3 then 'E.' when tip_partener=4 then 'F.' end)
				+(case when tip_partener in (3,4) and tipop='V' then 'L' else tipop end),
			tip_partener, count(cuiP), tipop, max(tli), sum(nrfacturi), sum(baza), sum(tva), cota_tva, tip_document, 0
		from #D394 
		where tip_partener=1 or tip_partener=2 and (tipop='N' or tipop='L' and (tertPF=0 or factPFPeCUI=1)) 
			or tip_partener=3 and (tipop in ('L','V') or tipop in ('A','C')) or tip_partener=4 and (tipop in ('L','V') or tipop in ('A','C'))
		group by (case when tip_partener=1 then 'C.' when tip_partener=2 then 'D.' when tip_partener=3 then 'E.' when tip_partener=4 then 'F.' end)
					+(case when tip_partener in (3,4) and tipop='V' then 'L' else tipop end), tip_partener, tipop, cota_tva, tip_document

		-->	Preluare sume facturi detaliate si pe bunuri.
		insert into D394 (data, lm, rand_decl, tip_partener, tipop, bun, nrfacturi, baza, tva, cota_tva, tip_document, Introdus_manual)
		select @datasus, @lmUtilizator, (case when tip_partener=1 then 'C.' when tip_partener=2 then 'D.' end)+tipop,
			tip_partener, tipop, bun, sum(nrfacturicod), sum(baza), sum(tva), cota_tva, tip_document, 0	--LUCIAN: aici am modificat din SUM in MAX pentru cazul celor cu cereale (Agrirom)
		from #D394 
		where (tip_partener=1 and tipop in ('V','C') /*or tip_partener=1 and tipop in ('A','AI','L') and nullif(bun,'') in ('29','30','31')*/ 
			or tip_partener=2 and tipop='N' and isnull(tertPF,0)=1) and nullif(bun,'') is not null
		group by tip_partener, tipop, bun, cota_tva, tip_document

		create table #nrbonuri (cota_tva int, datalunii datetime, gestiune varchar(20), lm varchar(20), nrbonuri decimal(12,2))
		create table #gestiuni (cod_gestiune varchar(20), lm varchar(20))
		insert into #gestiuni
		select cod_gestiune, isnull(detalii.value('(/row/@lm)[1]','varchar(20)'),'') as lm
		from gestiuni where subunitate=@subunitate
		if @D394_102016=1 
			--	Citim numarul de bonuri prioritar din pozplin la nivel de loc de munca si apoi din tabelele de PVria. Acolo unde nu se va dori acest lucru vom trata fie prin parametru, fie prin SP.
			--	Asa rezolvam si cazul in care o firma are gestiuni cu PVria si altele fara PV (la gestiunile unde nu au PV se va culege manual numarul de bonuri in pozplin). 
			--	and not exists (select 1 from #D394BfFs where tipop='L' and tipinc='AMEF' and isnull(nrbonuri,0)<>0)
		begin
			insert into #nrbonuri (cota_tva, datalunii, gestiune, lm, nrbonuri)
			select '99' as cota_tva, dbo.EOM(bp.data), max(b.gestiune), isnull(nullif(b.Loc_de_munca,''),g.lm) as lm, 
				count(distinct rtrim(convert(varchar(8),bp.casa_de_marcat))+'|'+isnull(nullif(b.Loc_de_munca,''),g.lm)+'|'+rtrim(convert(varchar(8),bp.numar_bon))+'|'+convert(varchar(10),bp.data,101)) as nrbonuri
			from bp
				JOIN antetBonuri b on b.numar_bon = bp.numar_bon and b.casa_de_marcat=bp.casa_de_marcat and b.vinzator=bp.Vinzator and b.data_bon=bp.data and b.Chitanta=1
				LEFT JOIN antetBonuri f on f.Factura=b.Factura and f.Data_facturii=b.Data_facturii and f.tert=b.tert and f.idAntetBon<>b.idAntetBon and f.Chitanta=0
				LEFT OUTER JOIN #gestiuni g on g.Cod_gestiune=b.gestiune
			where bp.data between @datajos and @datasus and bp.cod_produs<>'' 
				and bp.factura_chitanta=1 and bp.tip='21'	--	Nu numaram bonurile pentru care s-au emis facturi direct in pozdoc.
				and f.Factura is NULL --	Nu numaram bonurile pentru care s-au emis facturi din BON.
			group by dbo.EOM(bp.data), isnull(nullif(b.Loc_de_munca,''),g.lm)
		end

		if exists (select 1 from #nrbonuri where lm='')
		begin
			declare @gestiuniFaraLM varchar(1000)
			set @gestiuniFaraLM=''
			select @gestiuniFaraLM=RTRIM(@gestiuniFaraLM)+RTRIM(gestiune)+';'
			from (select distinct gestiune from #nrbonuri where lm='') a
			set @gestiuniFaraLM=left(@gestiuniFaraLM,LEN(@gestiuniFaraLM)-1)
			set @mesajAtentionare='Exista pozitii in antetBonuri care nu au completat locul de munca si gestiunea ('+rtrim(@gestiuniFaraLM)+') de pe acele bonuri nu are atasat loc de munca! Completati locul de munca in macheta Gestiuni!'
			raiserror (@mesajAtentionare,16,1)
		end

		-->	Numaram bonurile la nivel de loc de munca. Daca s-a cules la nivel de loc de munca nr. bonuri in pozplin il citim prioritar de aici, altfel citim numarul de bonuri din bp.
		select d.tipop, d.tipinc, d.lm as lmZ, month(d.data) as luna, 
			d.tli, isnull(sum(d.nrbonuri),0) as nrbonuriZ, (case when d.cota_tva=max(ctva.cota_tva) then isnull(max(nr.nrbonuri),0) else 0 end) as nrbonuriPV, 
				convert(decimal(15,2),sum(d.baza)) as baza, convert(decimal(15,2),sum(d.tva)) as tva, 
				d.cota_tva, convert(decimal(15,2),sum(d.incasare)) as incasare
		into #D394IncasariZ
		from #D394BfFs d
			left join #nrbonuri nr on nr.cota_tva=99 and nr.lm=d.lm --nr.cota_tva=d.cota_tva
			outer apply (select top 1 cota_tva from #D394BfFs order by cota_tva desc) ctva
		where tipop='L' and tipinc='AMEF' and @D394_102016=1
		group by d.tipop, d.tipinc, month(d.data), d.tli, d.cota_tva, d.lm

		-->	Preluare sume referitoare la facturi simplificate/bonuri fiscale prin intermediul AMEF. (sectiunea REZUMAT G.)
		insert into D394 (data, lm, rand_decl, denumire, tipop, tli, nrfacturi, baza, tva, cota_tva, incasari, Introdus_manual)
		select @datasus, @lmUtilizator, 'G.1', convert(varchar(2),luna), 'I1' as tipop, d.tli, 
			sum(isnull(nullif(d.nrbonuriZ,0),d.nrbonuriPV)), convert(decimal(15,0),sum(d.baza)), convert(decimal(15,0),sum(d.tva)), 
			d.cota_tva, convert(decimal(15,0),sum(d.incasare)), 0
		from #D394IncasariZ d
		group by d.tipop, convert(varchar(2),luna), d.tli, d.cota_tva

		-->	Inserez si pozitii cu acele cote de TVA pe care nu sunt incasari in baza de date. Trebuie sa apara in XML. Le inserez doar daca exista incasari.
		if exists (select 1 from #D394IncasariZ)
			insert into D394 (data, lm, rand_decl, denumire, tipop, tli, nrfacturi, baza, tva, cota_tva, incasari, Introdus_manual)
			select @datasus, @lmUtilizator, 'G.1', convert(varchar(2),month(@dataSus)), 
				'I1' as tipop, 0, 0, 0, 0, ct.cota_tva, 0, 0
			from (select c.cota_tva from #coteTVA c where c.cota_tva<>24 and not exists (select 1 from #D394IncasariZ bf where bf.tipop='L' and bf.tipinc='AMEF' and bf.cota_tva=c.cota_tva)) ct
			where @D394_102016=1 --	Inseram intrucat se cer sa apara in sectiunea G1 cate un rand pentru fiecare cota de TVA.

		-->	Preluare sume referitoare la facturi simplificate/bonuri fiscale exceptate de la obligatia utilizarii AMEF.
		insert into D394 (data, lm, rand_decl, denumire, tip_partener, tipop, tli, nrfacturi, baza, tva, cota_tva, incasari, Introdus_manual)
		select @datasus, @lmUtilizator, 'G.2', convert(varchar(2),month(data)), NULL, 'I2', tli, sum(nrbonuri), sum(baza), sum(tva), cota_tva, sum(incasare), 0
		from #D394BfFs 
		where tipop='L' and tipinc='EAMEF' and @D394_102016=1
		group by /*tip_partener,*/ tipop, convert(varchar(2),month(data)), tli, cota_tva

		if exists (select 1 from #D394BfFs where tipop='L' and tipinc='EAMEF')
			insert into D394 (data, lm, rand_decl, denumire, tipop, tli, nrfacturi, baza, tva, cota_tva, incasari, Introdus_manual)
			select @datasus, @lmUtilizator, 'G.2', convert(varchar(2),month(@dataSus)), 'I2' as tipop, 0, 0, 0, 0, ct.cota_tva, 0, 0
			from (select c.cota_tva from #coteTVA c where c.cota_tva<>24 and not exists (select 1 from #D394BfFs bf where bf.tipop='L' and bf.tipinc='EAMEF' and bf.cota_tva=c.cota_tva)) ct
			where @D394_102016=1 --	Inseram intrucat se cer sa apara in sectiunea G2 cate un rand pentru fiecare cota de TVA.

		-->	Preluare sume facturi pe tipuri de operatiuni (centralizare) pe cote de TVA.
		insert into D394 (data, lm, rand_decl, tipop, nrfacturi, baza, tva, cota_tva, incasari, Introdus_manual)
		select @datasus, @lmUtilizator, 
			'H.'+(case when tipop in ('L') then 'L' when tipop in ('A','C') then 'AC' when tipop in ('AI') then 'AI' end),
			(case when tipop in ('L') then 'L' when tipop in ('A','C') then 'AC' when tipop in ('AI') then 'AI' end), 
			sum(nrfacturi), sum(baza), sum(tva), cota_tva, 0, 0
		from #D394 
		where tip_partener=1 and (tipop in ('L') or tipop in ('A','C','AI')) and cota_tva in (24,20,19,9,5)
		group by cota_tva, (case when tipop in ('L') then 'L' when tipop in ('A','C') then 'AC' when tipop in ('AI') then 'AI' end)

		-->	Preluare sume referitoare la facturi simplificate/bonuri fiscale prin intermediul AMEF. (sectiunea REZUMAT I.)
		insert into D394 (data, lm, rand_decl, nrfacturi, baza, tva, cota_tva, Introdus_manual)
		select @datasus, @lmUtilizator, 'I.1'+'.'+
			(case --when tipop='L' and nullif(codfisc,'') is not null then '1' -- when tipop='L' and nullif(codfisc,'') is null then '2' 
				when tipop='A' and fsimplificata=2 and tli=0 and nullif(codfisc,'') is not null then '3' 
				when tipop='A' and fsimplificata=2 and tli=1 and nullif(codfisc,'') is not null then '4' 
				when tipop='A' and fsimplificata=1 and nullif(codfisc,'') is not null then '5' end), 
			sum(nrbonuri), convert(decimal(15),sum(baza)), convert(decimal(15),sum(tva)), cota_tva, 0
		from #D394BfFs 
		-->	Momentan nu stim ce inseamna Livrari cu Facturi simplificate in ASiS. De lamurit daca Factura simplificata la Livrari = Bon fiscal cu cod fiscal. Pare ca cele 2 nu sunt egale.
		where tipop='A' and fsimplificata in (1,2) --or tipop='L' and fsimplificata=1	
		group by cota_tva, (case --when tipop='L' and nullif(codfisc,'') is not null then '1' --when tipop='L' and nullif(codfisc,'') is null then '2' 
				when tipop='A' and fsimplificata=2 and tli=0 and nullif(codfisc,'') is not null then '3' 
				when tipop='A' and fsimplificata=2 and tli=1 and nullif(codfisc,'') is not null then '4' 
				when tipop='A' and fsimplificata=1 and nullif(codfisc,'') is not null then '5' end)

		-->	Plajele de facturi se declara doar incepand cu declaratia lunii octombrie 2016.
		if @D394_102016=1
		begin
			-->	Preluam plaja de facturi alocate din declaratia perioadei anterioare.
			if not exists (select 1 from #D394factSerii)
				insert into #D394factSerii (tip, serieI, nrI, serieF, nrF, idplaja)
				select tip, serieI, nrI, serieI, nrF, idplaja
				from D394 d
					inner join docfiscale df on df.serie=d.serieI and df.NumarInf=d.nrI and df.Factura=1 and df.dela<=@datasus and df.panala>=@datajos
				where data=DateADD(day,-1,@dataJos) and (@lmUtilizator is null or lm=@lmUtilizator)
					and rand_decl='I.2.1' and tip='1'

			-->	Citire plaje de facturi alocate si emise cu procedura wIaFacturiFiscale.
			if object_id('tempdb..#plajeserii') is null
			begin
				create table #plajeserii (idplaja int)
				create table #plajeUtilizate (idplaja int)
				exec wIaFacturiFiscale_faTabela
			end
			exec wIaFacturiFiscale @sesiune=@sesiune, @parXML=@parXMLPlaje

			insert into #D394factSerii (tip, serieI, nrI, serieF, nrF, idplaja)
			select '1', Serie, NumarInf, Serie, NumarSup, p.idplaja
			from #plajeSerii p
			where idplaja>0 and not exists (select 1 from #D394factSerii s where s.tip='1' and s.SerieI=p.Serie and s.nrI=p.NumarInf)

			if exists (select 1 from #plajeUtilizate where idplaja=-1) and app_name() not like '%unipaas%' and @genRaport=0
				select 'Exista facturi nealocate pe plajele de facturi definite! Consultati facturile nealocate in macheta Plaje de facturi!' as textMesaj for xml raw, root('Mesaje')

			-->	Aici trebuie sa tratam plajele de facturi emise (utilizate). 
			insert into #D394factSerii (tip, serieI, nrI, serieF, nrF, nrFacturi, idplaja)
			select '2', Serie, NumarInf, Serie, NumarSup, nr, p.idplaja
			from #plajeUtilizate p
			where idplaja>0 and not exists (select 1 from #D394factSerii s where s.tip='2' and s.SerieI=p.Serie and s.nrI=p.NumarInf)

			-->	Facturi emise de beneficiari sau terti in numele furnizorului. Furnizor=firma proprietara a bazei de date.
			insert into #D394factSerii (tip, serieI, nrI, serieF, nrF, cuiP, denP, idplaja)
			select (case when d.modemitfact='B' then '3' else '4' end) as tip, NULL as serie, d.factura, NULL as serie, d.factura, d.codfisc, max(d.dentert), d.idplaja
			from #D394Det d
			where d.subunitate=@subunitate and d.tipop='L' and d.modemitfact in ('B','T')
			group by d.codfisc, d.factura, (case when d.modemitfact='B' then '3' else '4' end), d.idplaja

			-->	Completare sectiuni I.2.1 (plaje de facturi utilizate), I.2.2 (plaje de facturi emise), I.2.3 (facturi emise de beneficiari in numele firmei) si I.2.4 (facturi emise de terti in numele firmei)
			insert into D394 (data, lm, rand_decl, tip, serieI, nrI, serieF, nrF, cuiP, denP, nrfacturi, Introdus_manual, idplaja)
			select @datasus, @lmUtilizator, 'I.2.'+rtrim(tip), tip, serieI, nrI, serieF, nrF, cuiP, denP, nrFacturi, 0, idplaja
			from #D394factSerii

			insert into #D394factExcep (tip_factura, serie, numar, baza, tva, cota_tva, idplaja)
			select '1', max(nullif(p.serie,'')) as serie, 
				substring(d.factura, (case when len(df.serie)>0 and (isnull(df.SerieInNumar,0) = 1 or charindex(rtrim(df.serie),d.Factura)=1) then len(df.serie)+1 else 0 end), 20), 
				null, null, null, max(d.idplaja)	-- Factura stono dpdv D394 = factura emisa cu valoare totala negativa
			from #D394det d
				inner join #plajeserii p on p.idplaja=d.idplaja
				inner join docfiscale df on df.id=d.idplaja
			where d.tipop='L' and d.tipD not in ('PI')
			group by d.codfisc, substring(d.factura, (case when len(df.serie)>0 and (isnull(df.SerieInNumar,0) = 1 or charindex(rtrim(df.serie),d.Factura)=1) then len(df.serie)+1 else 0 end), 20)
			having sum(round(convert(decimal(15,3),d.baza+d.tva),2))<0
			union all	--	ar fi si varianta sa citim documentele din doc care nu au pozitii in pozdoc (fara legatura cu campul stare=1). 
			select 2, max(nullif(p.serie,'')) as serie, 
				substring(doc.factura, (case when len(df.serie)>0 and (isnull(df.SerieInNumar,0) = 1 or charindex(rtrim(df.serie),doc.Factura)=1) then len(df.serie)+1 else 0 end), 20), 
				null, null, null, max(doc.idplaja) as idplaja
			from doc
				inner join #plajeserii p on p.idplaja=doc.idplaja
				inner join docfiscale df on df.id=doc.idplaja
			where doc.subunitate=@subunitate and doc.tip in ('AP','AS') and doc.data_facturii between @datajos and @datasus and doc.stare='1'
			group by substring(doc.factura, (case when len(df.serie)>0 and (isnull(df.SerieInNumar,0) = 1 or charindex(rtrim(df.serie),doc.Factura)=1) then len(df.serie)+1 else 0 end), 20)
			union all
			-->	Autofacturare = facturi catre tert care are codul fiscal = cod fiscal baza de date. Facturi emise pentru a declara un TVA colectat aferent unui TVA dedus in plus in perioade anterioare (protocol).
			select 3, max(nullif(s.serie,'')) as serie, d.factura, convert(decimal(15),sum(d.tva)*100.00/cota_tva), sum(d.tva), cota_tva, max(isnull(d.idplaja,s.idplaja)) as idplaja
			from #D394autofacturi d
				outer apply (select top 1 serie, idplaja from #plajeserii p where d.factura between p.numarinf and p.numarsup) s
			group by d.factura, d.cota_tva
			union all
			-->	Facturi emise de firma (proprietara a bazei de date), in calitate de beneficiar in numele furnizorilor.
			select 4, max(nullif(s.serie,'')) as serie, d.factura, null, null, null, max(isnull(d.idplaja,s.idplaja)) as idplaja
			from #D394Det d
				outer apply (select top 1 serie, idplaja from #plajeserii p where d.factura between p.numarinf and p.numarsup) s
			where d.subunitate=@subunitate and d.tipop='A' and d.modemitfact='F'
			group by d.factura

			-->	apel procedura specifica UA Declaratia394UAFacturiExceptie care permite completarea/modificarea tabelei #D394factExcep cu facturile anulate.
			if exists (select 1 from sysobjects where type='P' and name='Declaratia394UAFacturiExceptie') 
				exec Declaratia394UAFacturiExceptie @parXML 

			-->	apel procedura specifica Declaratia394SPFacturiExceptie care permite completarea/modificarea tabelei #D394factExcep
			if exists (select 1 from sysobjects where type='P' and name='Declaratia394SPFacturiExceptie') 
				exec Declaratia394SPFacturiExceptie @parXML 

			-->	Completare sectiune I.2.2.F, facturi anulate, stornate, autofacturari
			insert into D394 (data, lm, rand_decl, tip, serieI, nrI, cota_tva, baza, tva, Introdus_manual, idplaja)
			select @datasus, @lmUtilizator, 'I.2.2.F', tip_factura, serie, numar, cota_tva, baza, tva, 0, idplaja
			from #D394factExcep
		end

		-->	Preluare informatii in D394, sectiune I.3 pentru cazul solicitarii rambursarii TVA-ului.
		if @solicit_ramb=1 and @D394_102016=1
		begin
			insert into D394 (data, lm, rand_decl, are_doc, Introdus_manual)
			select @datasus, @lmutilizator, 'I.3.A.PE', 0, 0 union all
			select @datasus, @lmutilizator, 'I.3.A.CR', (case when exists (select 1 from #D394det where tipop in ('A','C') and bunimob='CR') then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.CB', (case when exists (select 1 from #D394det where tipop in ('A','C') and bunimob='CB') then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.CI', (case when exists (select 1 from #D394det where tipop in ('A','C') and bunimob='CI') then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.Necorp', (case when exists (select 1 from #D394det where tipop in ('A','C') and bunimob='Necorp') then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.Necorp', (case when exists (select 1 from #D394det where tipop in ('L','V') and bunimob='Necorp') then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.A', (case when exists (select 1 from #D394det where tipop in ('A','C') and bunimob in ('A','T')) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.B24',
				(case when exists (select 1 from #D394det where tipop in ('A','C') and nullif(bunimob,'') is null and tip_nom not in ('R','S') and cota_tva=24) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.B20',
				(case when exists (select 1 from #D394det where tipop in ('A','C') and nullif(bunimob,'') is null and tip_nom not in ('R','S') and cota_tva=20) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.B19',
				(case when exists (select 1 from #D394det where tipop in ('A','C') and nullif(bunimob,'') is null and tip_nom not in ('R','S') and cota_tva=19) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.B9',
				(case when exists (select 1 from #D394det where tipop in ('A','C') and nullif(bunimob,'') is null and tip_nom not in ('R','S') and cota_tva=9) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.B5',
				(case when exists (select 1 from #D394det where tipop in ('A','C') and nullif(bunimob,'') is null and tip_nom not in ('R','S') and cota_tva=5) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.S24',
				(case when exists (select 1 from #D394det where tipop in ('A','C') and nullif(bunimob,'') is null and tip_nom in ('R','S') and cota_tva=24) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.S20',
				(case when exists (select 1 from #D394det where tipop in ('A','C') and nullif(bunimob,'') is null and tip_nom in ('R','S') and cota_tva=20) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.S19',
				(case when exists (select 1 from #D394det where tipop in ('A','C') and nullif(bunimob,'') is null and tip_nom in ('R','S') and cota_tva=19) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.S9',
				(case when exists (select 1 from #D394det where tipop in ('A','C') and nullif(bunimob,'') is null and tip_nom in ('R','S') and cota_tva=9) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.S5',
				(case when exists (select 1 from #D394det where tipop in ('A','C') and nullif(bunimob,'') is null and tip_nom in ('R','S') and cota_tva=5) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.A.IB',
				(case when exists (select 1 from #D394det where tipop in ('A','C') and tip_partener=4 and tip_nom not in ('R','S')) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.BI',
				(case when exists (select 1 from #D394det where tipop in ('L') and nullif(bunimob,'') is not null) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.BUN24',
				(case when exists (select 1 from #D394det where tipop in ('L') and nullif(bunimob,'') is null and tip_nom not in ('R','S') and cota_tva=24) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.BUN20',
				(case when exists (select 1 from #D394det where tipop in ('L') and nullif(bunimob,'') is null and tip_nom not in ('R','S') and cota_tva=20) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.BUN19',
				(case when exists (select 1 from #D394det where tipop in ('L') and nullif(bunimob,'') is null and tip_nom not in ('R','S') and cota_tva=19) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.BUN9',
				(case when exists (select 1 from #D394det where tipop in ('L') and nullif(bunimob,'') is null and tip_nom not in ('R','S') and cota_tva=9) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.BUN5',
				(case when exists (select 1 from #D394det where tipop in ('L') and nullif(bunimob,'') is null and tip_nom not in ('R','S') and cota_tva=5) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.BS',
				(case when exists (select 1 from #D394det where tipop in ('L') and nullif(bunimob,'') is null and tip_nom not in ('R','S') and cota_tva=0) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.BUNTI',
				(case when exists (select 1 from #D394det where tipop in ('L') and invers=1) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.P24',
				(case when exists (select 1 from #D394det where tipop in ('L') and tip_nom in ('R','S') and cota_tva=24) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.P20',
				(case when exists (select 1 from #D394det where tipop in ('L') and tip_nom in ('R','S') and cota_tva=20) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.P19',
				(case when exists (select 1 from #D394det where tipop in ('L') and tip_nom in ('R','S') and cota_tva=19) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.P9',
				(case when exists (select 1 from #D394det where tipop in ('L') and tip_nom in ('R','S') and cota_tva=9) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.P5',
				(case when exists (select 1 from #D394det where tipop in ('L') and tip_nom in ('R','S') and cota_tva=5) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.PS',
				(case when exists (select 1 from #D394det where tipop in ('L') and tip_nom in ('R','S') and cota_tva=0) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.Intra',
				(case when exists (select 1 from #D394det where tipop in ('L') and tip_nom not in ('R','S') and tip_partener=3) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.PIntra',
				(case when exists (select 1 from #D394det where tipop in ('L') and tip_nom in ('R','S') and tip_partener=3) then 1 else 0 end), 0 union all
			select @datasus, @lmutilizator, 'I.3.L.Export',
				(case when exists (select 1 from #D394det where tipop in ('L') and tip_nom not in ('R','S') and tip_partener=4) then 1 else 0 end), 0
		end

		-->	Preluare sume referitoare la TVA aferent facturilor platite/incasate cu TVA la incasare
		insert into D394 (data, lm, rand_decl, tva, cota_tva, Introdus_manual)
		select @datasus, @lmUtilizator, 'I.'+(case when @sistemTVA=0 and tipDoc='PC' then '4.1' 
			when @sistemTVA=1 and tipDoc='IC' then '5.1' when @sistemTVA=1 and tipDoc='PC' and tli=0 then '5.2' when @sistemTVA=1 and tipDoc='PC' and tli=1 then '5.3' end), 
			convert(decimal(15),sum(tva)) as tva, cota_tva, 0 
		from #D394PCICtli
		where @D394_102016=1 --or 1=1	--pentru testare raport
		group by cota_tva, (case when @sistemTVA=0 and tipDoc='PC' then '4.1' 
			when @sistemTVA=1 and tipDoc='IC' then '5.1' when @sistemTVA=1 and tipDoc='PC' and tli=0 then '5.2' when @sistemTVA=1 and tipDoc='PC' and tli=1 then '5.3' end)

		select distinct d.tipD as tip, d.numar, d.data 
		into #docMarjaProfit
		from #D394det d
		where d.tipop in ('LS') and d.marjaprofit=1 and @D394_102016=1 

		/*	Preluare livrari pentru marja de profit aferenta operatiunilor pentru bunuri second-hand.
			Pus datele pentru marja de profit. La nevoie se vor putea altera printr-un SP. */
		select @datasus as data, @lmUtilizator as lm, 'I.6.2' as rand_decl, convert(decimal(15),sum(d.baza)) as baza, convert(decimal(15),sum(d.tva)) as tva, 
			convert(decimal(15),sum(d.baza+(case when d.cota_tva=0 and tva=0 then valoare_factura else 0 end))) as incasari, 
			convert(decimal(15),sum((case when d.cota_tva=0 and tva=0 then valoare_factura else 0 end))) as cheltuieli, 0 as introdus_manual
		into #marjaProfit
		from #D394det d
			inner join #docMarjaProfit dm on dm.tip=d.tipD and dm.numar=d.numar and dm.data=d.data
			left join nomencl n on n.cod=d.cod 
		where tipop in ('L','LS') and @D394_102016=1
			and (d.marjaprofit=1 or n.tip<>'S')	--	Am tratat sa nu ia in calcul alte servicii fara TVA, operate pe aceste facturi (asigurari, etc)
		delete from #marjaProfit where baza is null and tva is null and incasari is null and cheltuieli is null

		insert into D394 (data, lm, rand_decl, baza, tva, incasari, cheltuieli, Introdus_manual)
		select data, lm, rand_decl, baza, tva, incasari, cheltuieli, introdus_manual
		from #marjaProfit

		-->	Preluare livrari defalcate pe coduri CAEN.
		insert into D394 (data, lm, rand_decl, denumire, tipop, baza, tva, cota_tva, Introdus_manual)
		select @datasus, @lmUtilizator, 'I.7.CAEN', codcaen, tipop, convert(decimal(15),baza) as baza, convert(decimal(15),tva) as tva, cota_tva, 0
		from #D394LivrariCodCaen

		-->	Completam in D394, datele detaliate pe tipuri de parteneri, coduri fiscale, cote de TVA, tipuri de operatiuni
		insert into D394 (data, lm, rand_decl, codtert, cuiP, denP, tipop, cota_tva, tip_partener, tli, nrfacturi, baza, tva, cod, bun, tip_document, Introdus_manual)
		select @datasus, @lmUtilizator, 
			(case when tip_partener=1 then 'C' when tip_partener=2 then 'D' when tip_partener=3 then 'E' when tip_partener=4 then 'F' end)
				+'.'+(case when tip_partener in (3,4) and tipop='V' then 'L' else tipop end)+'.cuiP', 
			codtert, cuiP, max(dentert), tipop, cota_tva, tip_partener, tli, sum(nrfacturi) as nrfacturi, convert(decimal(15),sum(baza)) as baza, convert(decimal(15),sum(tva)) as tva, null, null, tip_document, 0
		from #D394
		where not (tip_partener=2 and tertPF=1 and tipop in ('L','LS') and factPFpeCUI=0)	-->facturile catre neplatitori cu valoare<=10000 nu se declara pe cod fiscal
		group by (case when tip_partener=1 then 'C' when tip_partener=2 then 'D' when tip_partener=3 then 'E' when tip_partener=4 then 'F' end)
				+'.'+(case when tip_partener in (3,4) and tipop='V' then 'L' else tipop end), 
			codtert, cuiP, tipop, cota_tva, tip_partener, tli, tip_document

		-->	Completam in D394, datele detaliate pe coduri fiscale, CODURI si BUNURI.
		insert into D394 (data, lm, rand_decl, codtert, cuiP, denP, tipop, cota_tva, tip_partener, tli, nrfacturi, baza, tva, cod, bun, tip_document, Introdus_manual)
		select @datasus, @lmUtilizator, 
			(case when tip_partener=1 then 'C' when tip_partener=2 then 'D' when tip_partener=3 then 'E' when tip_partener=4 then 'F' end)
				+'.'+(case when tip_partener in (3,4) and tipop='V' then 'L' else tipop end)+'.cuiP', 
			codtert, cuiP, max(dentert), tipop, cota_tva, tip_partener, tli, sum(nrfacturicod) as nrfacturi, convert(decimal(15),sum(baza)) as baza, convert(decimal(15),sum(tva)) as tva, cod, bun, tip_document, 0
		from #D394 
		where not (tip_partener=2 and tertPF=1 and tipop in ('L','LS') and factPFpeCUI=0) 
			and (tip_partener=1 and tipop in ('V','C') or tip_partener=2 and tipop='N' and isnull(tertPF,0)=1 /* or tip_partener=1 and tipop in ('A','AI','L') and nullif(bun,'') in ('29','30','31')*/)
			and (nullif(bun,'') is not null or nullif(cod,'') is not null)
		group by (case when tip_partener=1 then 'C' when tip_partener=2 then 'D' when tip_partener=3 then 'E' when tip_partener=4 then 'F' end)
				+'.'+(case when tip_partener in (3,4) and tipop='V' then 'L' else tipop end)+'.cuiP', 
			codtert, cuiP, tipop, cota_tva, tip_partener, tli, cod, bun, tip_document

		-->	Preluare sume referitoare la livrari spre persoane fizice cu valoare individuala/persoana <=10000.
		insert into D394 (data, lm, rand_decl, tipop, nrfacturi, baza, tva, cota_tva, Introdus_manual)
		select @datasus, @lmUtilizator, 'D_EXCEPTII', 'L' as tipop, sum(nrfacturi), convert(decimal(15),sum(baza)) as baza, convert(decimal(15),sum(tva)), cota_tva, 0
		from #D394factPFSub10000
		where @fact10000_2016=1	-->doar pentru aceasta perioada se declara numar facturi, baza, tva aferent facturilor catre persoane fizice cu valoare pana in 10000 RON .
		group by cota_tva
	end

	--	apel procedura specifica Declaratia394SPAntXML care permite completarea/modificarea tabelei D394 (eventual cu date din alte baze de date).
	if exists (select 1 from sysobjects o where o.type='P' and o.name='Declaratia394SPAntXML') 
		exec Declaratia394SPAntXML @parXML 

	-->	Implicit ne aflam pe o baza de date unde nu facem centralizare. La CNADNR, daca in D394 nu exista pozitii cu LM=null, inseamna ca ne aflam pe o BD unde s-au importat XML-uri si facem o centralizare din D394
	set @centralizareD394=0	
	if @lmUtilizator is null and not exists (select 1 from D394 where data=@dataSus and cuiP is not null and lm is null)
		set @centralizareD394=1

	select * into #D394xml
	from D394 where data=@dataSus and (@lmUtilizator is null and (@centralizareD394=1 or lm is null) 
		or @lmUtilizator is not null and (lm=@lmUtilizator and rand_decl not like 'A_%'
			or rand_decl like 'A_%' and (@multiFirma=1 and lm=@lmUtilizator or @multiFirma=0 and nullif(lm,'') is null)))

	select	@op_efectuate=(case when exists (select 1 from #D394xml where nullif(baza,0) is not null or nullif(tva,0) is not null) then 1 else 0 end),
			@efectuat=(case when @solicit_ramb=1 then (case when exists (select 1 from #D394xml where tipop in ('L','V')) then 1 else 0 end) end)

-->	generare declaratie
	if @genRaport=0
	begin
		if (@cui is null)
		select 
			@cui=ltrim(rtrim(replace(replace(
				max(case when parametru='CODFISC' then val_alfanumerica else '' end),'RO',''),'R','')))
			,@den=max(case when parametru='NUME' then rtrim(val_alfanumerica) else '' end)
			,@telefon=max(case when parametru='TELFAX' then rtrim(val_alfanumerica) else '' end)
			,@fax=max(case when parametru='FAX' then rtrim(val_alfanumerica) else '' end)
			,@mail=max(case when parametru='EMAIL' then rtrim(val_alfanumerica) else '' end)
		from par where tip_parametru='GE' and parametru in ('CODFISC','NUME','TELFAX','FAX','EMAIL')

		if @fax=''  -- compatibilitate in urma
			set @fax=@telefon

		if len(rtrim(@fisier))=0	--<<	Aici se compune numele fisierului, daca a fost omis
			select @fisier='394_'+@tip_D394+
					'_D'+rtrim(convert(varchar(2),month(@data)))+right(convert(varchar(4),year(@data)),2)+
					'_J'+rtrim(@cui)
	
			--> se elimina o eventuala extensie adaugata din greseala din macheta:
		if left(right(@fisier,4),1)='.' set @fisier=substring(@fisier, 1, len(@fisier)-charindex('.',reverse(@fisier)))
		
		if left(right(@fisier,4),1)<>'.' 
			select @fisierXML=@fisier+'.xml', @fisierXMLPDFSoftA=rtrim(@fisier)+'_PDFSoftA'+'.xml' 

		if (@adresa is null)
			select 
			@adresa=max(case when rtrim(val_alfanumerica)<>'' and parametru='LOCALIT' then 'Localitatea '+rtrim(val_alfanumerica)+' ' else '' end)
				+max(case when rtrim(val_alfanumerica)<>'' and parametru='STRADA' then 'str '+rtrim(val_alfanumerica)+' ' else '' end)
				+max(case when rtrim(val_alfanumerica)<>'' and parametru='NUMAR' then 'nr '+rtrim(val_alfanumerica)+' ' else '' end)
				+max(case when rtrim(val_alfanumerica)<>'' and parametru='BLOC' then 'bl '+rtrim(val_alfanumerica)+' ' else '' end)
				+max(case when rtrim(val_alfanumerica)<>'' and parametru='SCARA' then 'sc '+rtrim(val_alfanumerica)+' ' else '' end)
				+max(case when rtrim(val_alfanumerica)<>'' and parametru='ETAJ' then 'etaj '+rtrim(val_alfanumerica)+' ' else '' end)
				+max(case when rtrim(val_alfanumerica)<>'' and parametru='APARTAM' then 'ap '+rtrim(val_alfanumerica)+' ' else '' end)
				+max(case when rtrim(val_alfanumerica)<>'' and parametru='JUDET' then 'jud '+rtrim(val_alfanumerica)+' ' else '' end)
				+max(case when rtrim(val_alfanumerica)<>'' and parametru='CODPOSTAL' then 'cod postal '+rtrim(val_alfanumerica)+' ' else '' end)
				+max(case when rtrim(val_alfanumerica)<>'' and parametru='SECTOR' then 'sector '+rtrim(val_alfanumerica)+' ' else '' end)
				from par where tip_parametru='PS' and parametru in 
					('LOCALIT','STRADA','NUMAR','BLOC','SCARA','ETAJ','APARTAM','JUDET','CODPOSTAL','SECTOR')
		
		select	@cui=(case when rtrim(@cui)='' then null else @cui end),
				@den=(case when rtrim(@den)='' then null else @den end),
				@telefon=(case when rtrim(@telefon)='' then null else @telefon end),
				@fax=(case when rtrim(@fax)='' then null else @fax end),
				@mail=(case when rtrim(@mail)='' then null else @mail end),
				@adresa=(case when rtrim(@adresa)='' then null else @adresa end)

		if exists (select 1 from #D394xml where rand_decl='I.2.2')
			set @nrFacturi=isnull((select sum(nrFacturi) from #D394xml where tip_partener in (1,2,3,4) and cuiP is null and tipop in ('L','V','LS') or rand_decl='D_EXCEPTII'),0)
				+isnull((select count(nrI) from #D394xml where rand_decl='FACTURI'),0)
		set @nrFacturi=isnull(@nrFacturi,0)

		select 
			@cifR=rtrim(nullif(max(case when rand_decl='A_cifR' then denumire end),'')),
			@denR=rtrim(max(case when rand_decl='A_denR' then denumire end)),
			@functieR=rtrim(max(case when rand_decl='A_functieR' then denumire end)),
			@adresaR=rtrim(max(case when rand_decl='A_adresaR' then denumire end)),
			@tip_intocmit=max(case when rand_decl='A_tip_intocmit' then denumire end), 
			@den_intocmit=rtrim(max(case when rand_decl='A_den_intocmit' then denumire end)),
			@cif_intocmit=rtrim(max(case when rand_decl='A_cif_intocmit' then denumire end)),
			@calitate_intocmit=rtrim(nullif(max(case when rand_decl='A_calitate_intocmit' then denumire end),'')),
			@functie_intocmit=rtrim(nullif(max(case when rand_decl='A_functie_intocmit' then denumire end),'')),
			@optiune=max(case when rand_decl='A_optiune' then denumire end),
			@schimb_optiune=nullif(max(case when rand_decl='A_schimb_optiune' then denumire end),''),
			@solicit_ramb=max(case when rand_decl='A_solicit_ramb' then denumire end),
			@nrAMEF=max(case when rand_decl='A_nrcasemarcat' then nrCui end)
		from #D394xml 
		where rand_decl in ('A_cifR','A_denR','A_functieR','A_adresaR','A_tip_intocmit', 'A_den_intocmit', 'A_cif_intocmit', 'A_calitate_intocmit', 'A_functie_intocmit', 
				'A_optiune', 'A_schimb_optiune','A_solicit_ramb','A_nrcasemarcat') and ((@multiFirma=0 and lm is null) or (@multiFirma=1 and lm=@lmUtilizator))

		-->	De tratat solutia pentru reprezentant legal.
		if isnull(@denR,'')=''
			select @cifR=null, @denR='denumireR', @functieR='functieR', @adresaR='adresaR', @telefonR=null, @faxR=null, @mailR=null

		select count(distinct (case when tip_partener=1 then cuiP end)) as nrCui1
			,count((case when tip_partener=2 /*and cuiP=''*/ then 1 end))/*+count(distinct (case when tip_partener=2 and cuiP!='' then rand_decl+cuiP end))*/ as nrCui2
			,count(distinct (case when tip_partener=3 then cuiP end)) as nrCui3, count(distinct (case when tip_partener=4 then cuiP end)) as nrCui4 
		into #nrCui
		from #D394xml where left(rand_decl,1) in ('C','D','E','F') 
			and (tip_partener in (1,2,3,4) and nullif(cuiP,'') is not null or tip_partener=2 and rand_decl in ('D.N.cuiP','D.L.cuiP') and cuiP='')
			and nullif(bun,'') is null

		set @totalPlata_A=(select isnull(nrCui1,0)+isnull(nrCui2,0)+isnull(nrCui3,0)+isnull(nrCui4,0) from #nrCui)
			+isnull((select sum(baza) from #D394xml where (left(rand_decl,2) in ('C.','D.','E.','F.') and tipop in ('A','C','L','AI') and nullif(cuiP,'') is null and denP is null and nullif(bun,'') is null)),0)

		select *, replace(str(row_number() over (order by denumire),2),' ','0') as codjudet394 into #judete 
		from judete where cod_judet not in ('B','CL','GR')
		insert into #judete
		select *, (case when cod_judet='B' then '40' when cod_judet='CL' then '51' when cod_judet='GR' then '52' end) as codjudet394 from judete where cod_judet in ('B','CL','GR')
		update #judete set codjudet394=(case when cod_judet='BV' then '08' when cod_judet='BR' then '09' when cod_judet='SM' then '30' when cod_judet='SJ' then '31' 
			when cod_judet='VS' then '37' when cod_judet='VL' then '38' end) 
		where cod_judet in ('BV','BR','SM','SJ','VL','VS')

		declare @continutXml xml, @continutXmlChar varchar(max)
		select @continutXml=(
			select 'mfp:anaf:dgti:d394:declaratie:v'+@versiune as [@nu_am_alte_idei_decat_replace_pe_string],
				month(@datasus) as [@luna], year(@data) as [@an]
				,@tip_D394 [@tip_D394], @sistemTVA [@sistemTVA], @op_efectuate [@op_efectuate]
				,rtrim(@cui) [@cui], rtrim(@caen) as [@caen], rtrim(@den) [@den], rtrim(@adresa) [@adresa]
				,rtrim(@telefon) [@telefon], rtrim(@fax) [@fax], rtrim(@mail) [@mail]
				,convert(decimal(15),@totalPlata_A) as [@totalPlata_A]
				,@cifR [@cifR], @denR [@denR], @functieR as [@functie_reprez], @adresaR [@adresaR], @telefonR [@telefonR]
				,@faxR [@faxR], @mailR [@mailR]
				,@tip_intocmit [@tip_intocmit], rtrim(@den_intocmit) [@den_intocmit], @cif_intocmit [@cif_intocmit]
				,@calitate_intocmit [@calitate_intocmit], rtrim(@functie_intocmit) [@functie_intocmit]
				,@optiune [@optiune], @schimb_optiune [@schimb_optiune]
				,(select
					isnull(max(nrc.nrCui1),0) as [@nrCui1], isnull(max(nrc.nrCui2),0) as [@nrCui2]
					,isnull(max(nrc.nrCui3),0) as [@nrCui3], isnull(max(nrc.nrCui4),0)  as [@nrCui4]
					,isnull(sum(case when rand_decl='G.1' then nrfacturi else 0 end),0) as [@nr_BF_i1]
					,convert(decimal(15),isnull(sum(case when rand_decl='G.1' then convert(decimal(15),incasari) else 0 end),0)) as [@incasari_i1]
					,convert(decimal(15),isnull(sum(case when rand_decl='G.2' then convert(decimal(15),incasari) else 0 end),0)) as [@incasari_i2]
					,ISNULL((select count(1) from #D394xml where rand_decl='I.2.4'),0) as [@nrFacturi_terti]
					,ISNULL((select count(1) from #D394xml where rand_decl='I.2.3'),0) as [@nrFacturi_benef]
					,@nrFacturi as [@nrFacturi]
					,isnull(sum(case when rand_decl='D_EXCEPTII' and tipop='L' then nrfacturi else 0 end),0) as [@nrFacturiL_PF]
					,isnull(sum(case when rand_decl='D_EXCEPTII' and tipop='LS' then nrfacturi else 0 end),0) as [@nrFacturiLS_PF]
					,isnull(convert(decimal(15),sum(case when rand_decl='D_EXCEPTII' and tipop='LS' then baza else 0 end)),0) as [@val_LS_PF]
					,(case when @sistemTVA=1 then convert(decimal(15),isnull(sum(case when rand_decl like 'I.5.2%' and cota_tva=24 then tva else 0 end),0)) end) as [@tvaDed24]
					,(case when @sistemTVA=1 then convert(decimal(15),isnull(sum(case when rand_decl like 'I.5.2%' and cota_tva=19 then tva else 0 end),0)) end) as [@tvaDed19]
					,(case when @sistemTVA=1 then convert(decimal(15),isnull(sum(case when rand_decl like 'I.5.2%' and cota_tva=20 then tva else 0 end),0)) end) as [@tvaDed20]
					,(case when @sistemTVA=1 then convert(decimal(15),isnull(sum(case when rand_decl like 'I.5.2%' and cota_tva=9 then tva else 0 end),0)) end) as [@tvaDed9]
					,(case when @sistemTVA=1 then convert(decimal(15),isnull(sum(case when rand_decl like 'I.5.2%' and cota_tva=5 then tva else 0 end),0)) end) as [@tvaDed5]
					,convert(decimal(15),isnull(sum(case when (rand_decl like 'I.4.1%' or rand_decl like 'I.5.3%') and cota_tva=24 then tva else 0 end),0)) as [@tvaDedAI24]
					,convert(decimal(15),isnull(sum(case when (rand_decl like 'I.4.1%' or rand_decl like 'I.5.3%') and cota_tva=19 then tva else 0 end),0)) as [@tvaDedAI19]
					,convert(decimal(15),isnull(sum(case when (rand_decl like 'I.4.1%' or rand_decl like 'I.5.3%') and cota_tva=20 then tva else 0 end),0)) as [@tvaDedAI20]
					,convert(decimal(15),isnull(sum(case when (rand_decl like 'I.4.1%' or rand_decl like 'I.5.3%') and cota_tva=9 then tva else 0 end),0)) as [@tvaDedAI9]
					,convert(decimal(15),isnull(sum(case when (rand_decl like 'I.4.1%' or rand_decl like 'I.5.3%') and cota_tva=5 then tva else 0 end),0)) as [@tvaDedAI5]
					,(case when @sistemTVA=1 then convert(decimal(15),isnull(sum(case when rand_decl like 'I.5.1%' and cota_tva=24 then tva else 0 end),0)) end) as [@tvaCol24]
					,(case when @sistemTVA=1 then convert(decimal(15),isnull(sum(case when rand_decl like 'I.5.1%' and cota_tva=19 then tva else 0 end),0)) end) as [@tvaCol19]
					,(case when @sistemTVA=1 then convert(decimal(15),isnull(sum(case when rand_decl like 'I.5.1%' and cota_tva=20 then tva else 0 end),0)) end) as [@tvaCol20]
					,(case when @sistemTVA=1 then convert(decimal(15),isnull(sum(case when rand_decl like 'I.5.1%' and cota_tva=9 then tva else 0 end),0)) end) as [@tvaCol9]
					,(case when @sistemTVA=1 then convert(decimal(15),isnull(sum(case when rand_decl like 'I.5.1%' and cota_tva=5 then tva else 0 end),0)) end) as [@tvaCol5]
					,convert(decimal(15),max(case when rand_decl like 'I.6.1%' then incasari else 0 end)) as [@incasari_ag]
					,convert(decimal(15),max(case when rand_decl like 'I.6.1%' then cheltuieli else 0 end)) as [@costuri_ag]
					,convert(decimal(15),max(case when rand_decl like 'I.6.1%' then baza else 0 end)) as [@marja_ag]
					,convert(decimal(15),max(case when rand_decl like 'I.6.1%' then tva else 0 end)) as [@tva_ag]
					,convert(decimal(15),max(case when rand_decl like 'I.6.2%' then incasari else 0 end)) as [@pret_vanzare]
					,convert(decimal(15),max(case when rand_decl like 'I.6.2%' then cheltuieli else 0 end)) as [@pret_cumparare]
					,convert(decimal(15),max(case when rand_decl like 'I.6.2%' then baza else 0 end)) as [@marja_antic]
					,convert(decimal(15),max(case when rand_decl like 'I.6.2%' then tva else 0 end)) as [@tva_antic]
					,@solicit_ramb as [@solicit]
					,max(case when rand_decl='I.3.A.PE' then are_doc end) as [@achizitiiPE]
					,max(case when rand_decl='I.3.A.CR' then are_doc end) as [@achizitiiCR]
					,max(case when rand_decl='I.3.A.CB' then are_doc end) as [@achizitiiCB]
					,max(case when rand_decl='I.3.A.CI' then are_doc end) as [@achizitiiCI]
					,max(case when rand_decl='I.3.A.A' then are_doc end) as [@achizitiiA]
					,max(case when rand_decl='I.3.A.B24' then are_doc end) as [@achizitiiB24]
					,max(case when rand_decl='I.3.A.B20' then are_doc end) as [@achizitiiB20]
					,max(case when rand_decl='I.3.A.B19' then are_doc end) as [@achizitiiB19]
					,max(case when rand_decl='I.3.A.B9' then are_doc end) as [@achizitiiB9]
					,max(case when rand_decl='I.3.A.B5' then are_doc end) as [@achizitiiB5]
					,max(case when rand_decl='I.3.A.S24' then are_doc end) as [@achizitiiS24]
					,max(case when rand_decl='I.3.A.S20' then are_doc end) as [@achizitiiS20]
					,max(case when rand_decl='I.3.A.S19' then are_doc end) as [@achizitiiS19]
					,max(case when rand_decl='I.3.A.S9' then are_doc end) as [@achizitiiS9]
					,max(case when rand_decl='I.3.A.S5' then are_doc end) as [@achizitiiS5]
					,max(case when rand_decl='I.3.A.IB' then are_doc end) as [@importB]
					,max(case when rand_decl='I.3.A.Necorp' then are_doc end) as [@acINecorp]
					,max(case when rand_decl='I.3.L.BI' then are_doc end) as [@livrariBI]
					,max(case when rand_decl='I.3.L.BUN24' then are_doc end) as [@BUN24]
					,max(case when rand_decl='I.3.L.BUN20' then are_doc end) as [@BUN20]
					,max(case when rand_decl='I.3.L.BUN19' then are_doc end) as [@BUN19]
					,max(case when rand_decl='I.3.L.BUN9' then are_doc end) as [@BUN9]
					,max(case when rand_decl='I.3.L.BUN5' then are_doc end) as [@BUN5]
					,max(case when rand_decl='I.3.L.BS' then are_doc end) as [@valoareScutit]
					,max(case when rand_decl='I.3.L.BUNTI' then are_doc end) as [@BunTI]
					,max(case when rand_decl='I.3.L.P24' then are_doc end) as [@Prest24]
					,max(case when rand_decl='I.3.L.P20' then are_doc end) as [@Prest20]
					,max(case when rand_decl='I.3.L.P19' then are_doc end) as [@Prest19]
					,max(case when rand_decl='I.3.L.P9' then are_doc end) as [@Prest9]
					,max(case when rand_decl='I.3.L.P5' then are_doc end) as [@Prest5]
					,max(case when rand_decl='I.3.L.PS' then are_doc end) as [@PrestScutit]
					,max(case when rand_decl='I.3.L.Intra' then are_doc end) as [@LIntra]
					,max(case when rand_decl='I.3.L.PIntra' then are_doc end) as [@PrestIntra]
					,max(case when rand_decl='I.3.L.Export' then are_doc end) as [@Export]
					,max(case when rand_decl='I.3.L.Necorp' then are_doc end) as [@livINecorp]
					,convert(decimal(15),@efectuat) as [@efectuat]
					from #D394xml d1 
					left outer join #nrCui nrc on 1=1
					where (left(d1.rand_decl,1) in ('C','D','E','F') and d1.tip_partener in (1,2,3,4) and nullif(d1.cuiP,'') is not null
						or rand_decl like 'I.4%' or rand_decl like 'I.5%' or rand_decl like 'I.3%' and @solicit_ramb=1 or rand_decl like 'I.6%' or rand_decl in ('G.1','G.2')
						or rand_decl='D_EXCEPTII')
					for xml path('informatii'),type
				)
				,(select 
					a.tip_partener as [@tip_partener], a.cota_tva as [@cota],
					(case when a.cota_tva<>0 then sum(case when tipop='L' then a.nrfacturi else 0 end) end) as [@facturiL],
					(case when a.cota_tva<>0 then convert(decimal(15),sum(case when a.tipop='L' then convert(decimal(15),a.baza) else 0 end)) end) as [@bazaL],
					(case when a.cota_tva<>0 then convert(decimal(15),sum(case when a.tipop='L' then convert(decimal(15),a.tva) else 0 end)) end) as [@tvaL],
					(case when cota_tva=0 and (tip_partener<>2 or tip_partener=2 and isnull(a.tip_document,'')=1) then sum(case when tipop='LS' then a.nrfacturi else 0 end) end) as [@facturiLS],
					(case when cota_tva=0 and (tip_partener<>2 or tip_partener=2 and isnull(a.tip_document,'')=1) 
						then convert(decimal(15),sum(case when a.tipop='LS' then convert(decimal(15),a.baza) else 0 end)) end) as [@bazaLS],
					(case when a.tip_partener=1 and a.cota_tva<>0 then sum(case when a.tipop='A' then a.nrfacturi else 0 end) end) as [@facturiA],
					(case when a.tip_partener=1 and a.cota_tva<>0 then convert(decimal(15),sum(case when a.tipop='A' then convert(decimal(15),a.baza) else 0 end)) end) as [@bazaA],
					(case when a.tip_partener=1 and a.cota_tva<>0 then convert(decimal(15),sum(case when a.tipop='A' then convert(decimal(15),a.tva) else 0 end)) end) as [@tvaA],
					(case when a.tip_partener=1 and a.cota_tva<>0 then sum(case when a.tipop='AI' /*and a.tli=1*/ then a.nrfacturi else 0 end) end) as [@facturiAI],
					(case when a.tip_partener=1 and a.cota_tva<>0 then convert(decimal(15),sum(case when a.tipop='AI' then convert(decimal(15),a.baza) else 0 end)) end) as [@bazaAI],
					(case when a.tip_partener=1 and a.cota_tva<>0 then convert(decimal(15),sum(case when a.tipop='AI' then convert(decimal(15),a.tva) else 0 end)) end) as [@tvaAI],
					(case when a.tip_partener=1 and a.cota_tva=0 then sum(case when tipop='AS' then a.nrfacturi else 0 end) end) as [@facturiAS],
					(case when a.tip_partener=1 and a.cota_tva=0 then convert(decimal(15),sum(case when a.tipop='AS' then convert(decimal(15),a.baza) else 0 end)) end) as [@bazaAS],
					(case when a.tip_partener=1 and a.cota_tva=0 then sum(case when a.tipop='V' then a.nrfacturi else 0 end) end) as [@facturiV],
					(case when a.tip_partener=1 and a.cota_tva=0 then convert(decimal(15),sum(case when a.tipop='V' then convert(decimal(15),a.baza) else 0 end)) end) as [@bazaV],
					(case when a.tip_partener in (1,3,4) and a.cota_tva<>0 then sum(case when tipop='C' then a.nrfacturi else 0 end) end) as [@facturiC],
					(case when a.tip_partener in (1,3,4) and a.cota_tva<>0 then convert(decimal(15),sum(case when a.tipop='C' then convert(decimal(15),a.baza) else 0 end)) end) as [@bazaC],
					(case when a.tip_partener in (1,3,4) and a.cota_tva<>0 then convert(decimal(15),sum(case when a.tipop='C' then convert(decimal(15),a.tva) else 0 end)) end) as [@tvaC],
					(case when a.tip_partener=2 and a.cota_tva=0 then sum(case when tipop='N' then a.nrfacturi else 0 end) end) as [@facturiN],
					(case when a.tip_partener=2 and a.cota_tva=0 then isnull(a.tip_document,'') end) as [@document_N],
					(case when a.tip_partener=2 and a.cota_tva=0 then convert(decimal(15),sum(case when tipop='N' then a.baza else 0 end)) end) as [@bazaN]
					,(select 
						d.bun as [@bun], 
						(case when d.tip_partener=1 then sum(case when d.tipop='V' and d.cota_tva=0 then d.nrfacturi end) end) as [@nrLivV],
						(case when d.tip_partener=1 then convert(decimal(15),sum(case when d.tipop='V' and d.cota_tva=0 then convert(decimal(15),d.baza) end)) end) as [@bazaLivV],
						(case when d.tip_partener=1 then sum(case when d.tipop='C' and d.cota_tva<>0 then d.nrfacturi end) end) as [@nrAchizC],
						(case when d.tip_partener=1 then convert(decimal(15),sum(case when d.tipop='C' and d.cota_tva<>0 then convert(decimal(15),d.baza) end)) end) as [@bazaAchizC],
						(case when d.tip_partener=1 then convert(decimal(15),sum(case when d.tipop='C' and d.cota_tva<>0 then convert(decimal(15),d.tva) end)) end) as [@tvaAchizC],
						(case when d.tip_partener=2 then sum(case when d.tipop='N' then d.nrfacturi else 0 end) end) as [@nrN],
						(case when d.tip_partener=2 then convert(decimal(15),sum(case when d.tipop='N' then convert(decimal(15),d.baza) else 0 end)) end) as [@valN]
					from #D394xml d	where d.tip_partener=a.tip_partener and d.cota_tva=a.cota_tva and isnull(d.tip_document,'')=isnull(a.tip_document,'')
						and (d.tip_partener=1 and d.tipop in ('V','C') or d.tip_partener=2 and d.tipop='N' ) and d.cuiP is null and nullif(d.bun,'') is not null
					group by tip_partener, d.tip_document, bun for xml path('detaliu'), type
					)
				from #D394xml a where a.tip_partener in (1,2,3,4) and a.cuiP is null and nullif(a.bun,'') is null
				group by a.tip_partener, a.cota_tva, isnull(a.tip_document,'') for xml path('rezumat1'), type
				) --as rezumat1
			,
				(select 
					cota_tva as [@cota],
					convert(decimal(15),sum(case when rand_decl='I.1.1' then convert(decimal(15),baza) else 0 end)) as [@bazaFSLcod],
					convert(decimal(15),sum(case when rand_decl='I.1.1' then convert(decimal(15),tva) else 0 end)) as [@TVAFSLcod],
					convert(decimal(15),sum(case when rand_decl='I.1.2' then convert(decimal(15),baza) else 0 end)) as [@bazaFSL],
					convert(decimal(15),sum(case when rand_decl='I.1.2' then convert(decimal(15),tva) else 0 end)) as [@TVAFSL],
					convert(decimal(15),sum(case when rand_decl='I.1.3' then convert(decimal(15),baza) else 0 end)) as [@bazaFSA],
					convert(decimal(15),sum(case when rand_decl='I.1.3' then convert(decimal(15),tva) else 0 end)) as [@TVAFSA],
					convert(decimal(15),sum(case when rand_decl='I.1.4' then convert(decimal(15),baza) else 0 end)) as [@bazaFSAI],
					convert(decimal(15),sum(case when rand_decl='I.1.4' then convert(decimal(15),tva) else 0 end)) as [@TVAFSAI],
					convert(decimal(15),sum(case when rand_decl='I.1.5' then convert(decimal(15),baza) else 0 end)) as [@bazaBFAI],
					convert(decimal(15),sum(case when rand_decl='I.1.5' then convert(decimal(15),tva) else 0 end)) as [@TVABFAI],

					sum(case when left(rand_decl,2) in ('C.','D.','E.','F.') and tipop in ('L') then nrfacturi else 0 end) as [@nrFacturiL],
					convert(decimal(15),sum(case when left(rand_decl,2) in ('C.','D.','E.','F.') and tipop in ('L') then convert(decimal(15),baza) else 0 end)) as [@bazaL],
					convert(decimal(15),sum(case when left(rand_decl,2) in ('C.','D.','E.','F.') and tipop in ('L') then convert(decimal(15),tva) else 0 end)) as [@tvaL],
					sum(case when left(rand_decl,2) in ('C.','D.','E.','F.') and tipop in ('A','C') then nrfacturi else 0 end) as [@nrFacturiA],
					convert(decimal(15),sum(case when left(rand_decl,2) in ('C.','D.','E.','F.') and tipop in ('A','C') then convert(decimal(15),baza) else 0 end)) as [@bazaA],
					convert(decimal(15),sum(case when left(rand_decl,2) in ('C.','D.','E.','F.') and tipop in ('A','C') then convert(decimal(15),tva) else 0 end)) as [@tvaA],
					sum(case when left(rand_decl,2) in ('C.','D.','E.','F.') and tipop='AI' then nrfacturi else 0 end) as [@nrFacturiAI],
					convert(decimal(15),sum(case when left(rand_decl,2) in ('C.','D.','E.','F.') and tipop='AI' then convert(decimal(15),baza) else 0 end)) as [@bazaAI],
					convert(decimal(15),sum(case when left(rand_decl,2) in ('C.','D.','E.','F.') and tipop='AI' then convert(decimal(15),tva) else 0 end)) as [@tvaAI],

					convert(decimal(15),sum(case when rand_decl='G.1' then convert(decimal(15),baza) else 0 end)) as [@baza_incasari_i1],
					convert(decimal(15),sum(case when rand_decl='G.1' then convert(decimal(15),tva) else 0 end)) as [@tva_incasari_i1],
					convert(decimal(15),sum(case when rand_decl='G.2' then convert(decimal(15),baza) else 0 end)) as [@baza_incasari_i2],
					convert(decimal(15),sum(case when rand_decl='G.2' then convert(decimal(15),tva) else 0 end)) as [@tva_incasari_i2],
					convert(decimal(15),sum(case when rand_decl='D_EXCEPTII' and tipop='L' then convert(decimal(15),baza) else 0 end)) as [@bazaL_PF],
					convert(decimal(15),sum(case when rand_decl='D_EXCEPTII' and tipop='L' then convert(decimal(15),tva) else 0 end)) as [@tvaL_PF]
				from #D394xml where (left(rand_decl,1) in ('C','D','E','F') and tipop in ('A','C','L','AI'/*,'V'*/) and nullif(cuiP,'') is null and denP is null and nullif(bun,'') is null
						or rand_decl like 'I.1%' or rand_decl like 'G%') and cota_tva in (5,9,19,20,24)
				group by cota_tva
				for xml path('rezumat2'), type
				) --as rezumat
			,
				(select
					tip [@tip], rtrim(nullif(serieI,'')) [@serieI], rtrim(nrI) [@nrI], rtrim(nrF) [@nrF]	--tip = 1 Emise, 2 = Utilizate, 3 = Emise de beneficiari, 4 = Emise de terti
					,rtrim(denP) as [@den], rtrim(cuiP) as [@cui]
					from #D394xml where rand_decl in ('I.2.1','I.2.2','I.2.3','I.2.4')
					for xml path('serieFacturi'),type
				)
			,	-->	Detaliere livrari pe anumite activitati=Cod CAEN. Aici trebuie sa ramina aceasta sectiune. In alta parte da eroare.
				(select
					denumire [@caen], cota_tva as [@cota], rtrim(tipop) as [@operat]
					,convert(decimal(15),baza) as [@valoare], convert(decimal(15),tva) as [@tva]
					from #D394xml where rand_decl='I.7.CAEN'
					for xml path('lista'),type
				)
			,
				(select
					-->	tip_factura = 1 Factura stornata, 2 = Factura anulata, 3 = Autofacturare, 4 = in calitate de beneficiar in numele furnizorilor. De tratat pe cota de TVA.
					tip [@tip_factura], rtrim(serieI) [@serie], rtrim(nrI) [@nr] 
					,(case when tip=3 then convert(decimal(15),sum(case when cota_tva=24 then baza else 0 end)) end) as [@baza24]
					,(case when tip=3 then convert(decimal(15),sum(case when cota_tva=19 then baza else 0 end)) end) as [@baza19]
					,(case when tip=3 then convert(decimal(15),sum(case when cota_tva=20 then baza else 0 end)) end) as [@baza20]
					,(case when tip=3 then convert(decimal(15),sum(case when cota_tva=9 then baza else 0 end)) end) as [@baza9]
					,(case when tip=3 then convert(decimal(15),sum(case when cota_tva=5 then baza else 0 end)) end) as [@baza5]
					,(case when tip=3 then convert(decimal(15),sum(case when cota_tva=5 then tva else 0 end)) end) as [@tva5]
					,(case when tip=3 then convert(decimal(15),sum(case when cota_tva=9 then tva else 0 end)) end) as [@tva9]
					,(case when tip=3 then convert(decimal(15),sum(case when cota_tva=19 then tva else 0 end)) end) as [@tva19]
					,(case when tip=3 then convert(decimal(15),sum(case when cota_tva=20 then tva else 0 end)) end) as [@tva20]
					,(case when tip=3 then convert(decimal(15),sum(case when cota_tva=24 then tva else 0 end)) end) as [@tva24]
					from #D394xml where rand_decl='I.2.2.F'
					group by tip, serieI, nrI
					for xml path('facturi'),type
				)
			,
				(select
					rtrim(d1.tipop) [@tip], d1.tip_partener [@tip_partener], d1.cota_tva [@cota], NULLIF(d1.cuiP,'') as [@cuiP]
						,max(d1.denP) [@denP]
						,rtrim(max(case when tip_partener=2 and nullif(d1.cuiP,'') is null /*and isnull(it.zile_inc,0)>0*/ 
							then (case when isnull(it.zile_inc,0)=0 then 'RO' else isnull(tari.cod_tara,isnull(t.judet,'')) end) end)) as [@taraP]
						,rtrim(max(case when tip_partener=2 and nullif(d1.cuiP,'') is null and isnull(it.zile_inc,0)=0 then nullif(isnull(l.oras,t.localitate),'') end)) as [@locP]
						,rtrim(max(case when tip_partener=2 and nullif(d1.cuiP,'') is null and isnull(it.zile_inc,0)=0 then nullif(isnull(j.codjudet394,isnull(jc.codjudet394,'')),'') end)) as [@judP]
						,rtrim(max(case when tip_partener=2 and nullif(d1.cuiP,'') is null and @adrTertiComp=1 and isnull(it.zile_inc,0)=0 then nullif(left(t.adresa,30),'') end)) as [@strP]
						,rtrim(max(case when tip_partener=2 and nullif(d1.cuiP,'') is null and @adrTertiComp=1 and isnull(it.zile_inc,0)=0 then nullif(substring(t.adresa,31,8),'') end)) as [@nrP]
						,rtrim(max(case when tip_partener=2 and nullif(d1.cuiP,'') is null and @adrTertiComp=1 and isnull(it.zile_inc,0)=0 then nullif(substring(t.adresa,39,6),'') end)) as [@blP]
						,rtrim(max(case when tip_partener=2 and nullif(d1.cuiP,'') is null and @adrTertiComp=1 and isnull(it.zile_inc,0)=0 then nullif(substring(t.adresa,50,3),'') end)) as [@apP]
						,sum(d1.nrfacturi) as [@nrFact], convert(decimal(15),sum(d1.baza)) as [@baza], 
							(case when tipop in ('A','C','AI','L') then convert(decimal(15),sum(d1.tva)) end) as [@tva], d1.tip_document [@tip_document], 
					(select sum(d.nrfacturi) [@nrFactPR], isnull(nullif(d.cod,''),nullif(d.bun,'')) [@codPR]
						,convert(decimal(15),sum(baza)) [@bazaPR], convert(decimal(15),sum(case when d.tipop in ('A','C','AI','L') then tva end)) [@tvaPR] 
						from #D394xml d
						where (d.tip_partener=1 and d.tipop in ('V','C') or d.tip_partener=2 and d.tipop='N')
							and d.tip_partener=d1.tip_partener and d.tipop=d1.tipop and (d.cuip=d1.cuip and not(d1.tip_partener=2 and d1.cuiP='') or d1.tip_partener=2 and d1.cuiP='' and d.codtert=max(d1.codtert))
							and isnull(nullif(d.cod,''),nullif(d.bun,'')) is not null 
							and isnull(d.tip_document,'')=isnull(d1.tip_document,'')
							and d.cota_tva=d1.cota_tva
						group by isnull(nullif(d.cod,''),nullif(d.bun,''))
						order by isnull(nullif(d.cod,''),nullif(d.bun,'')) for xml path('op11'),type)
				from #D394xml d1 
					left outer join terti t on t.subunitate=@subunitate and (t.tert=d1.codtert and t.cod_fiscal=d1.cuiP or t.tert=d1.codtert and d1.cuiP='') and tip_partener=2 
						and (nullif(d1.cuip,'') is not null or d1.tip_partener=2 and d1.cuiP='')
					left outer join infotert it on it.subunitate=t.subunitate and it.tert=t.tert and it.identificator=''
					left outer join localitati l on @validLocalit=1 and l.cod_oras=t.localitate
					left outer join #judete j on @validJudet=0 and it.zile_inc=0 and j.denumire=t.judet
					left outer join #judete jc on @validJudet=1 and it.zile_inc=0 and jc.cod_judet=t.judet
					left outer join Tari on @validTara=0 and it.zile_inc>0 and tari.denumire=t.judet
				where (nullif(d1.cuiP,'') is not null or d1.tip_partener='2' and d1.cuiP='') and nullif(d1.bun,'') is null and d1.tip_partener in (1,2,3,4)
				group by d1.tipop, d1.tip_partener, d1.cota_tva, d1.cuiP, d1.tip_document, (case when d1.tip_partener=2 and d1.cuiP='' then d1.codtert else '' end)
				order by max(d1.denP)
				for xml path('op1'),type
				)
			,
				(select
					rtrim(tipop) [@tip_op2], rtrim(denumire) [@luna], (case when rand_decl like 'G.1%' then @nrAMEF end) as [@nrAMEF], 
					(case when tipop='I1' then sum(nrfacturi) end) as [@nrBF]
					,convert(decimal(15),isnull(sum(incasari),0)) as [@total]
					,convert(decimal(15),isnull(sum(case when cota_tva=20 then baza end),0)) as [@baza20]
					,convert(decimal(15),isnull(sum(case when cota_tva=9 then baza end),0)) as [@baza9]
					,convert(decimal(15),isnull(sum(case when cota_tva=5 then baza end),0)) as [@baza5]
					,convert(decimal(15),isnull(sum(case when cota_tva=19 then baza end),0)) as [@baza19]
					,convert(decimal(15),isnull(sum(case when cota_tva=20 then tva end),0)) as [@TVA20]
					,convert(decimal(15),isnull(sum(case when cota_tva=9 then tva end),0)) as [@TVA9]
					,convert(decimal(15),isnull(sum(case when cota_tva=5 then tva end),0)) as [@TVA5]
					,convert(decimal(15),isnull(sum(case when cota_tva=19 then tva end),0)) as [@TVA19]
					from #D394xml
					where (rand_decl like 'G.1%' or rand_decl like 'G.2%') and (nrfacturi<>0 or incasari<>0 or baza<>0 or tva<>0 or @nrAMEF<>0)
					group by rand_decl, tipop, rtrim(denumire)
					for xml path('op2'),type
				)
			for xml path('declaratie394'), type)

		--/*--> urmeaza scrierea fizica a fisierului:
		select @continutXmlChar='<?xml version="1.0"?>'+char(10)+replace(convert(varchar(max),@continutXml),'nu_am_alte_idei_decat_replace_pe_string','xmlns')

--> compunere continut XML pentru PDF-ul inteligent (Soft A):
		declare @continutXmlPDFSoftA xml, @continutXmlPDFSoftAChar varchar(max)
		if @siXMLPDF=1
		begin
			select @continutXmlPDFSoftA=
				(select 
					(select '' as HEADER, 
						(select year(@data) as an_r, @tip_D394 as TIP_D394, month(@data) as luna_r, @sistemTVA as sistem, @op_efectuate as operatiuni for xml path('sub_per'), type),
						(select @cui as cif, @den as den, @adresa as adresa, rtrim(@telefon) as telefon, rtrim(@fax) as fax, rtrim(@mail) as mail, 0 as d_rec, @caen as caen 
						for xml path('sub_dateDeIdentificare'), type)
					for xml path('body1'), type),
					(select 
						(select @denR as denR, @adresaR as adresaR for xml path('sub_dateDeIdentificare'), type)
					for xml path('body11'), type),
					(select NULL as nimic for xml path('bodyC'), type),
					(select isnull(nrCui1,0)+isnull(nrCui2,0)+isnull(nrCui3,0)+isnull(nrCui4,0) as nrCUI from #nrCui for xml path('bodyD'), type),
					(select NULL as nimic for xml path('bodyE'), type),
					(select NULL as nimic for xml path('bodyF'), type),
					(select '' as reprezentant, 'administrator' as tip_reprez, @tip_intocmit as tip_intocmit,
						rtrim(@den_intocmit) as den_intocmit, rtrim(@functie_intocmit) as functie, @cif_intocmit as cui_intocmit,
						@schimb_optiune as schim_opt, @optiune as optiune
					for xml path('intocmit'), type),
					(select NULL as nimic for xml path('body12'), type),
					(select tp.tip_partener as tip_partener,
						(select 
						(select row_number() over (order by s2.tipop, s2.cuiP) as seq2, rtrim(s2.tipop) as Tip, s2.cota_tva as cota, rtrim(s2.cuiP) as cuiP, rtrim(s2.denP) as denP, 
							convert(decimal(15),s2.baza) as baza, convert(decimal(15),s2.tva) as tva, convert(int,s2.nrfacturi) as nrfact
							from #D394xml s2 
							where s2.tip_partener=s1.tip_partener and s1.cuiP is not null and s2.cuiP=s1.cuiP and s2.tipop=s1.tipop and s2.cota_tva=s1.cota_tva and nullif(s2.cod,'') is null
							for xml path ('sub2'), type),
						(select row_number() over (order by s3.cod) as seq3, rtrim(s3.cod) as codPR, convert(int,s3.nrfacturi) as nrFacturi,
							convert(decimal(15),s3.baza) as baza, convert(decimal(15),s3.tva) as tva
							from #D394xml s3 
							where s3.tip_partener=s1.tip_partener and s3.cuiP is not null and s3.cuiP=s1.cuiP and s3.tipop=s1.tipop and s3.cota_tva=s1.cota_tva and nullif(s3.cod,'') is not null
							for xml path ('sub3'), type)
						from #D394xml s1 where s1.tip_partener=tp.tip_partener and s1.cuiP is not null and nullif(s1.cod,'') is null
						for xml path('sub1'), type)
					from #D394xml tp
					where left(tp.rand_decl,1) in ('C','D','E','F') and tp.tip_partener in (1,2,3,4) and (nullif(tp.cuiP,'') is not null or tp.tip_partener=2 and left(tp.rand_decl,2)='D.' and tp.cuiP='')
					group by tp.tip_partener
					for xml path('tip1'), type)
					--,(select NULL as nimic, (select NULL as nimic, (select NULL as nimic, 
					--		(select NULL as nimic, (select baza, tva from #D394xml where rand_decl='I.1.1' and cota_tva=24 for xml raw) for xml path ('L24'), type), 
					--		(select NULL as nimic, (select baza, tva from #D394xml where rand_decl='I.1.1' and cota_tva=20 for xml raw) for xml path ('L20'), type),
					--		(select NULL as nimic, (select baza, tva from #D394xml where rand_decl='I.1.1' and cota_tva=19 for xml raw) for xml path ('L19'), type),
					--		(select NULL as nimic, (select baza, tva from #D394xml where rand_decl='I.1.1' and cota_tva=9 for xml raw) for xml path ('L9'), type),
					--		(select NULL as nimic, (select baza, tva from #D394xml where rand_decl='I.1.1' and cota_tva=5 for xml raw) for xml path ('L5'), type) 
					--	for xml path ('info1'), type)  for xml path ('I1'), type) for xml path('rezI'), type)
				for xml path('form1'),type)
	--select @continutXmlPDFSoftA
			--/*--> urmeaza scrierea fizica a fisierului:
			select @continutXmlPDFSoftAChar='<?xml version="1.0"?>'+char(10)+replace(convert(varchar(max),@continutXmlPDFSoftA),'nimic=""','')
		end

-->	salvez declaratia ca si continut in tabela declaratii
		if exists (select * from sysobjects where name ='scriuDeclaratii' and xtype='P')
			exec scriuDeclaratii @cod='394', @tip='0', @data=@datasus, @continut=@continutXmlChar

		if (@siXMLPDF=1) --> se va genera alt format de fisier XML, care se poate importa in PDF-ul inteligent.
		begin
			if OBJECT_ID('tempdb..##D394outputXMLPDF') is not null
				drop table ##D394outputXMLPDF
			create table ##D394outputXMLPDF (valoare varchar(max), id int identity)
		end

-->	salvare fisier xml
		if (@dinRia=1)
		begin
			if (@siXMLPDF=1)	--> Salvam apeland salvareFisier, varianta care genereaza fisierul cu bcp intrucat acel format se poate importa in PDF-ul inteligent (ANSI in loc de UNICODE).
			begin
				insert into ##D394outputXMLPDF
				select @continutXmlPDFSoftAChar as valoare
				exec salvareFisier @codXML='', @caleFisier=@caleFisier, @numeFisier=@fisierXMLPDFSoftA, @numeTabelDate='##D394outputXMLPDF'
			end
			exec salvareFisier @codXML=@continutXmlChar, @caleFisier=@caleFisier, @numeFisier=@fisierXML
		end
		else
		begin
			if OBJECT_ID('tempdb..##D394outputXML') is not null
				drop table ##D394outputXML
			create table ##D394outputXML (valoare varchar(max), id int identity)
			insert into ##D394outputXML
			select @continutXmlChar as valoare
			exec salvareFisier @codXML='', @caleFisier=@caleFisier, @numeFisier=@fisierXML, @numeTabelDate='##D394outputXML'

			--> Pentru inceput doar pe ASiSria, vedem daca trebuie si in ASiSplus. Salvam apeland salvareFisier, varianta care genereaza fisierul cu bcp intrucat acel format se poate importa in PDF-ul inteligent.
			if (@siXMLPDF=1) and 1=0
			begin
				insert into ##D394outputXMLPDF
				select @continutXmlPDFSoftAChar as valoare
				exec salvareFisier @codXML='', @caleFisier=@caleFisier, @numeFisier=@fisierXMLPDFSoftA, @numeTabelDate='##D394outputXMLPDF'
			end
		end
	end
	else 
	if @genRaport<2 and object_id('tempdb..#D394') is not null
	begin
		if object_id('tempdb..#D394plus') is not null
			insert into #D394plus (codtert, cuiP, dentert, tipop, nrfacturi, baza, tva, cod, denumirecod)
			select codtert, cuiP, dentert, tipop, nrfacturi, baza, tva, cod, denumirecod
			from #D394
		else
			select codtert, cuiP, dentert, tipop, nrfacturi, baza, tva, cod, denumirecod
			from #D394
	end
end try

begin catch
	set @eroare=ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
end catch

if object_id('tempdb.dbo.#tvavanz') is not null drop table #tvavanz
if object_id('tempdb.dbo.#tvacump') is not null drop table #tvacump
if object_id('tempdb.dbo.#tCoduriCereale') is not null drop table #tCoduriCereale
if object_id('tempdb.dbo.#detaliereSFIF') is not null drop table #detaliereSFIF
if object_id('tempdb.dbo.#D394') is not null drop table #D394
if object_id('tempdb.dbo.#D394cif') is not null drop table #D394cif
if object_id('tempdb.dbo.#D394tmp') is not null drop table #D394tmp
if object_id('tempdb.dbo.#D394xml') is not null drop table #D394xml
if object_id('tempdb.dbo.#D394facttmp') is not null drop table #D394facttmp
if object_id('tempdb.dbo.#D394facttmpCod') is not null drop table #D394facttmpCod
if object_id('tempdb.dbo.#D394fact') is not null drop table #D394fact
if object_id('tempdb.dbo.#D394factCod') is not null drop table #D394factCod
if object_id('tempdb.dbo.#D394factPF') is not null drop table #D394factPF
if object_id('tempdb.dbo.#D394factPFSub10000') is not null drop table #D394factPFSub10000
if object_id('tempdb.dbo.#D394facturi') is not null drop table #D394facturi
if object_id('tempdb.dbo.#D394facturiCod') is not null drop table #D394facturiCod
if object_id('tempdb.dbo.#D394factExcep') is not null drop table #D394factExcep
if object_id('tempdb.dbo.#D394factSerii') is not null drop table #D394factSerii
if object_id('tempdb.dbo.#D394BfFs') is not null drop table #D394BfFs
if object_id('tempdb.dbo.#D394IncasariZ') is not null drop table #D394IncasariZ
if object_id('tempdb.dbo.#D394PCICtli') is not null drop table #D394PCICtli
if object_id('tempdb.dbo.#D394LivrariCodCaen') is not null drop table #D394LivrariCodCaen
if object_id('tempdb.dbo.#D394autofacturi') is not null drop table #D394autofacturi
if object_id('tempdb.dbo.#nrbonuri') is not null drop table #nrbonuri
if object_id('tempdb.dbo.#coteTVA') is not null drop table #coteTVA
if object_id('tempdb.dbo.#nrCui') is not null drop table #nrCui
if object_id('tempdb.dbo.#docMarjaProfit') is not null drop table #docMarjaProfit
if object_id('tempdb.dbo.#plajeserii') is not null drop table #plajeserii
if object_id('tempdb.dbo.#plajeUtilizate') is not null drop table #plajeUtilizate
if object_id('tempdb.dbo.#gestiuni') is not null drop table #gestiuni
if object_id('tempdb.dbo.#judete') is not null drop table #judete

if len(@eroare)>0 raiserror(@eroare,16,1)
