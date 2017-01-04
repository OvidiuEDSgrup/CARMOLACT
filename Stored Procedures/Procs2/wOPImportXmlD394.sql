--***
Create procedure wOPImportXmlD394 @sesiune varchar(50)=null, @parXML xml
as
begin try
	declare @dataLunii datetime, @fisier varchar(1000), @caleFisier varchar(1000), @locm varchar(9), @SQL_Query varchar(8000), @userASiS char(10), @mesajEroare varchar(1000),
			@pXML xml, @iDoc int, @dataXML datetime, @stergere int, @solicit_ramb int,  
			@utilizator varchar(20), @lista_lm int, @multiFirma int, @lmFiltru varchar(9), @lmUtilizator varchar(9), @nrLMFiltru int, @denlmUtilizator varchar(9)
    select  
		@dataLunii=isnull(@parXML.value('(/parametri/@datalunii)[1]','datetime'),'01/01/1901'),  
		@fisier=isnull(@parXML.value('(/parametri/@fisier)[1]','varchar(1000)'),''), 
		@locm=@parXML.value('(/parametri/@lm)[1]','varchar(9)'), 
		@stergere=@parXML.value('(/parametri/@stergere)[1]','int')

	/*  verificam daca este multifirma - pt. CNADR, ANAR  */
	set @utilizator = dbo.fIaUtilizator(null)
	set @lista_lm=dbo.f_areLMFiltru(@utilizator)
	set @multiFirma=0
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1
	select @lmFiltru=isnull(min(Cod),''), @nrLMFiltru=count(1) from LMfiltrare where utilizator=@utilizator and cod in (select cod from lm where Nivel=1)
	if @multiFirma=1 or @nrLMFiltru=1
		set @lmUtilizator=@lmFiltru

	if @multiFirma=1 
	begin
		select @denlmUtilizator=isnull(min(Denumire),'') from lm where cod=@lmUtilizator
	end

	/*  validare lm  */
	if rtrim(isnull(@locm,''))=''
	begin
		set @mesajEroare='Nu ati introdus locul de munca. Import neefectuat!'
		raiserror(@mesajEroare, 11, 1)
	end
	/*  validare suprascriere  */
	if isnull(@stergere,0)=0 and exists(select 1 from d394 where data=@dataLunii and lm=@locm)
	begin
		set @mesajEroare='Exista date in D394 pe locul de munca '+@locm+' la data '+convert(varchar(10),@dataLunii,104)+'! Daca doriti suprascriere, bifati optiunea!'
		raiserror(@mesajEroare, 11, 1)
	end

	select top 1 @caleFisier=rtrim(val_alfanumerica)+'uploads\' from par where parametru='CALEFORM'  
	set @caleFisier=isnull(@calefisier, 'C:\ASiSRia\Frame\Formulare\uploads\')
	set @fisier=rtrim(@calefisier)+rtrim(@fisier) 

	if object_id('tempdb..##D394xml') is not null drop table ##D394xml
	if object_id('tempdb..#D394imp') is not null drop table ##D394imp
	if object_id('tempdb..#D394') is not null drop table #D394
	if object_id('tempdb..#op1') is not null drop table #op1
	if object_id('tempdb..#op11') is not null drop table #op11
	if object_id('tempdb..#op2') is not null drop table #op2
	if object_id('tempdb..#rezumat1') is not null drop table #rezumat1
	if object_id('tempdb..#rezumat2') is not null drop table #rezumat2
	if object_id('tempdb..#informatii') is not null drop table #informatii
	if object_id('tempdb..#serieFacturi') is not null drop table #serieFacturi
	if object_id('tempdb..#facturi') is not null drop table #facturi
	if object_id('tempdb..#lista') is not null drop table #lista
	if object_id('tempdb..#detaliu') is not null drop table #detaliu


	create table #d394 (data datetime, lm varchar(9), rand_decl varchar(20), denumire varchar(100), 
		tip_partener int, tipop char(3), tli int, nrCui int, codtert varchar(20), cuiP varchar(20), denP varchar(200), cod varchar(20), bun varchar(8), 
		nrfacturi int, baza float, tva float, cota_tva int, incasari float, cheltuieli float, 
		tip int, serieI varchar(10), nrI varchar(20), serieF varchar(10), nrF varchar(20), are_doc int, tip_document int, Introdus_manual int, detaliu int, nusterge int) -- detaliu se foloseste pentru a reordona randurile

	create table ##D394xml(declaratie xml)
	set @SQL_Query='insert into ##D394xml (declaratie)
					select * from openrowset(bulk '''+@fisier+''', SINGLE_BLOB) AS x'
	exec (@SQL_Query)

	set  @pXML=(select declaratie from ##D394xml)

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXML, '<root xmlns:ns="mfp:anaf:dgti:d394:declaratie:v3"/>'
	

	set @dataXML=dbo.eom(convert(varchar(2),@pxml.value('(*/@luna)[1]','int'))+'/01/'+convert(varchar(4),@pxml.value('(*/@an)[1]','int')))

	/*  validare data XML  */
	if @dataLunii!=@dataXML
	begin
		set @mesajEroare='Data lunii este diferita de data din XML!'
		raiserror(@mesajEroare, 11, 1)
	end

	/*  inserare sectiune A cu lm null pentru cazul cand nu este multifirma  */
	if @multiFirma=0 
		begin
			if object_id('tempdb..#sectA') is not null drop table #sectA
			create table #sectA (rand_decl varchar(50), denumire varchar(10))
			insert into #sectA (rand_decl, denumire)
			select 'A_tip_intocmit', '1'union all
			select 'A_den_intocmit', '' union all
			select 'A_cif_intocmit', '' union all
			select 'A_calitate_intocmit', '' union all
			select 'A_functie_intocmit', '' union all
			select 'A_optiune', '0' union all
			select 'A_schimb_optiune', '' union all
			select 'A_solicit_ramb', '0' union all
			select 'A_cifR', '' union all
			select 'A_denR', '' union all
			select 'A_functieR', '' union all
			select 'A_adresaR', '' union all
			select 'A_nrcasemarcat', '0'

			insert into #d394 (data, lm, rand_decl, denumire, Introdus_manual)
			select @dataXML, null, s.rand_decl, s.denumire, 1
			from #sectA s
				left outer join d394 d on d.data=@dataXML and s.rand_decl=d.rand_decl and d.lm is null
			where d.rand_decl is null
		end
	
	/*  sectiune declaratie OP2 */
	select * 
	into #op2
	from OPENXML(@iDoc, '/ns:declaratie394/ns:op2')
	with
	(
		 tip_op2 varchar(10) '@tip_op2'
		,luna int '@luna'
		,nrAMEF int '@nrAMEF'
		,nrBF int '@nrBF'
		,total decimal(15) '@total'
		,baza20 decimal(15) '@baza20'
		,baza9 decimal(15) '@baza9'
		,baza5 decimal(15) '@baza5'
		,baza19 decimal(15) '@baza19'
		,TVA20 decimal(15) '@TVA20'
		,TVA9 decimal(15) '@TVA9'
		,TVA5 decimal(15) '@TVA5'
		,TVA19 decimal(15) '@TVA19'
	)
	
	/*  sectiunea A */
	insert into #d394 (data, lm, rand_decl, denumire, nrCui, Introdus_manual)
	select @dataXML, @locm, 'A_adresaR', isnull(rtrim(@pxml.value('(*/@adresaR)[1]','varchar(50)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_calitate_intocmit', isnull(rtrim(@pxml.value('(*/@calitate_intocmit)[1]','varchar(50)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_cif_intocmit', isnull(rtrim(@pxml.value('(*/@cif_intocmit)[1]','varchar(30)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_cifR', isnull(rtrim(@pxml.value('(*/@cifR)[1]','varchar(30)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_den_intocmit', isnull(rtrim(@pxml.value('(*/@den_intocmit)[1]','varchar(100)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_denR', isnull(rtrim(@pxml.value('(*/@denR)[1]','varchar(100)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_functie_intocmit', isnull(rtrim(@pxml.value('(*/@functie_intocmit)[1]','varchar(50)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_functieR', isnull(rtrim(@pxml.value('(*/@functie_reprez)[1]','varchar(50)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_optiune', isnull(rtrim(@pxml.value('(*/@optiune)[1]','varchar(10)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_schimb_optiune', isnull(rtrim(@pxml.value('(*/@schimb_optiune)[1]','varchar(10)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_solicit_ramb', isnull(rtrim(@pxml.value('(*/@solicit_ramb)[1]','varchar(10)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_tip_intocmit', isnull(rtrim(@pxml.value('(*/@tip_intocmit)[1]','varchar(10)')),''), null, 1
	union all
	select @dataXML, @locm, 'A_nrcasemarcat', '', isnull(nrAMEF,0), 1 from #op2 where tip_op2='I1'


	/*  sectiune declaratie INFORMATII  */
	select 	nrCui1, nrCui2 , nrCui3, nrCui4, nr_BF_i1, incasari_i1, incasari_i2, nrFacturi_terti, nrFacturi_benefint, nrFacturi, nrFacturiL_PF, nrFacturiLS_PF, 
			val_LS_PF, tvaDed24, tvaDed19, tvaDed20, tvaDed9, tvaDed5, tvaDedAI24, tvaDedAI19, tvaDedAI20, tvaDedAI9, tvaDedAI5, tvaCol24, tvaCol19, tvaCol20,
			tvaCol9, tvaCol5, incasari_ag, costuri_ag, marja_ag, tva_ag, pret_vanzare, pret_cumparare, marja_antic, tva_antic, solicit, 
			isnull([I.3.A.PE],0) [I.3.A.PE], isnull([I.3.A.CR],0) [I.3.A.CR], isnull([I.3.A.CB],0) [I.3.A.CB], isnull([I.3.A.CI],0) [I.3.A.CI], isnull([I.3.A.A],0) [I.3.A.A], isnull([I.3.A.B24],0) [I.3.A.B24], 
			isnull([I.3.A.B20],0) [I.3.A.B20], isnull([I.3.A.B19],0) [I.3.A.B19], isnull([I.3.A.B9],0) [I.3.A.B9], isnull([I.3.A.B5],0) [I.3.A.B5], isnull([I.3.A.S24],0) [I.3.A.S24], isnull([I.3.A.S20],0) [I.3.A.S20],
			isnull([I.3.A.S19],0) [I.3.A.S19], isnull([I.3.A.S9],0) [I.3.A.S9], isnull([I.3.A.S5],0) [I.3.A.S5], isnull([I.3.A.IB],0) [I.3.A.IB], isnull([I.3.A.Necorp],0) [I.3.A.Necorp], 
			isnull([I.3.L.BI],0) [I.3.L.BI], isnull([I.3.L.BUN24],0) [I.3.L.BUN24], isnull([I.3.L.BUN20],0) [I.3.L.BUN20], isnull([I.3.L.BUN19],0) [I.3.L.BUN19], isnull([I.3.L.BUN9],0) [I.3.L.BUN9], 
			isnull([I.3.L.BUN5],0) [I.3.L.BUN5], isnull([I.3.L.BS],0) [I.3.L.BS], isnull([I.3.L.BUNTI],0) [I.3.L.BUNTI], isnull([I.3.L.P24],0) [I.3.L.P24], isnull([I.3.L.P20],0) [I.3.L.P20], 
			isnull([I.3.L.P19],0) [I.3.L.P19], isnull([I.3.L.P9],0) [I.3.L.P9], isnull([I.3.L.P5],0) [I.3.L.P5], isnull([I.3.L.PS],0) [I.3.L.PS], isnull([I.3.L.Intra],0) [I.3.L.Intra], 
			isnull([I.3.L.PIntra],0) [I.3.L.PIntra], isnull([I.3.L.Export],0) [I.3.L.Export], isnull([I.3.L.Necorp],0) [I.3.L.Necorp], efectuat
	into #informatii
	from OPENXML(@iDoc, '/ns:declaratie394/ns:informatii')
	with
	(
		 nrCui1 int '@nrCui1'
		,nrCui2 int '@nrCui2'
		,nrCui3 int '@nrCui3'
		,nrCui4 int '@nrCui4'
		,nr_BF_i1 int '@nr_BF_i1'
		,incasari_i1 decimal(15) '@incasari_i1'
		,incasari_i2 decimal(15) '@incasari_i2'
		,nrFacturi_terti int '@nrFacturi_terti'
		,nrFacturi_benefint int '@nrFacturi_benef'	--Lucian: nu stim ce inseamna cele 2 atribute.
		,nrFacturi int '@nrFacturi'
		,nrFacturiL_PF int '@nrFacturiL_PF'
		,nrFacturiLS_PF int '@nrFacturiLS_PF'
		,val_LS_PF decimal(15) '@val_LS_PF'
		,tvaDed24 decimal(15) '@tvaDed24'
		,tvaDed19 decimal(15) '@tvaDed19'
		,tvaDed20 decimal(15) '@tvaDed20'
		,tvaDed9 decimal(15) '@tvaDed9'
		,tvaDed5 decimal(15) '@tvaDed5'
		,tvaDedAI24 decimal(15) '@tvaDedAI24'
		,tvaDedAI19 decimal(15) '@tvaDedAI19'
		,tvaDedAI20 decimal(15) '@tvaDedAI20'
		,tvaDedAI9 decimal(15) '@tvaDedAI9'
		,tvaDedAI5 decimal(15) '@tvaDedAI5'
		,tvaCol24 decimal(15) '@tvaCol24'
		,tvaCol19 decimal(15) '@tvaCol19'
		,tvaCol20 decimal(15) '@tvaCol20'
		,tvaCol9 decimal(15) '@tvaCol9'
		,tvaCol5 decimal(15) '@tvaCol5'
		,incasari_ag decimal(15) '@incasari_ag'
		,costuri_ag decimal(15) '@costuri_ag'
		,marja_ag decimal(15) '@marja_ag'
		,tva_ag decimal(15) '@tva_ag'
		,pret_vanzare decimal(15) '@pret_vanzare'
		,pret_cumparare decimal(15) '@pret_cumparare'
		,marja_antic decimal(15) '@marja_antic'
		,tva_antic decimal(15) '@tva_antic'
		,solicit int '@solicit'
		,[I.3.A.PE] int '@achizitiiPE'
		,[I.3.A.CR] int '@achizitiiCR'
		,[I.3.A.CB] int '@achizitiiCB'
		,[I.3.A.CI] int '@achizitiiCI'
		,[I.3.A.A] int '@achizitiiA'
		,[I.3.A.B24] int '@achizitiiB24'
		,[I.3.A.B20] int '@achizitiiB20'
		,[I.3.A.B19] int '@achizitiiB19'
		,[I.3.A.B9] int '@achizitiiB9'
		,[I.3.A.B5] int '@achizitiiB5'
		,[I.3.A.S24] int '@achizitiiS24'
		,[I.3.A.S20] int '@achizitiiS20'
		,[I.3.A.S19] int '@achizitiiS19'
		,[I.3.A.S9] int '@achizitiiS9'
		,[I.3.A.S5] int '@achizitiiS5'
		,[I.3.A.IB] int '@importB'
		,[I.3.A.Necorp] int '@acINecorp'
		,[I.3.L.BI] int '@livrariBI'
		,[I.3.L.BUN24] int '@BUN24'
		,[I.3.L.BUN20] int '@BUN20'
		,[I.3.L.BUN19] int '@BUN19'
		,[I.3.L.BUN9] int '@BUN9'
		,[I.3.L.BUN5] int '@BUN5'
		,[I.3.L.BS] int '@valoareScutit'
		,[I.3.L.BUNTI] int '@BunTI'
		,[I.3.L.P24] int '@Prest24'
		,[I.3.L.P20] int '@Prest20'
		,[I.3.L.P19] int '@Prest19'
		,[I.3.L.P9] int '@Prest9'
		,[I.3.L.P5] int '@Prest5'
		,[I.3.L.PS] int '@PrestScutit'
		,[I.3.L.Intra] int '@LIntra'
		,[I.3.L.PIntra] int '@PrestIntra'
		,[I.3.L.Export] int '@Export'
		,[I.3.L.Necorp] int '@livNecorp'
		,efectuat int '@efectuat'
	)

	/*  sectiune declaratie OP1 */
	select * 
	into #op1
	from OPENXML(@iDoc, '/ns:declaratie394/ns:op1')
	with
	(
		 tip varchar(2) '@tip'
		,tip_partener int '@tip_partener'
		,cota int '@cota'
		,cuiP varchar(20) '@cuiP'
		,denP varchar(200) '@denP'
		,taraP varchar(50) '@taraP'
		,locP varchar(50) '@locP'
		,judP varchar(50) '@judP'
		,strP varchar(50) '@strP'
		,nrP varchar(20) '@nrP'
		,blP varchar(20) '@blP'
		,apP varchar(20) '@apP'
		,nrFact int '@nrFact'
		,baza decimal(15,0) '@baza'
		,tva decimal(15,0) '@tva'
		,tip_document varchar(10) '@tip_document'
	)

	/*  sectiune declaratie OP11 */
	select * 
	into #op11
	from OPENXML(@iDoc, '/ns:declaratie394/ns:op1/ns:op11')
	with
	(
		 nrFactPR int '@nrFactPR'
		,codPR varchar(20) '@codPR'
		,bazaPR decimal(15) '@bazaPR'
		,tvaPR decimal(15) '@tvaPR'
		,tip varchar(2) '../@tip'
		,tip_partener int '../@tip_partener'
		,cota int '../@cota'
		,cuiP varchar(20) '../@cuiP'
	)
	delete from #op11 where nrFactPR is null


	/*  sectiune declaratie FACTURI */
	select * 
	into #facturi
	from OPENXML(@iDoc, '/ns:declaratie394/ns:facturi')
	with
	(
		 tip_factura varchar(10) '@tip_factura'
		,serie varchar(20) '@serie'
		,nr varchar(20) '@nr' 
		,baza24 decimal(15) '@baza24'
		,baza19 decimal(15) '@baza19'
		,baza20 decimal(15) '@baza20'
		,baza9 decimal(15) '@baza9'
		,baza5 decimal(15) '@baza5'
		,tva5 decimal(15) '@tva5'
		,tva9 decimal(15) '@tva9'
		,tva19 decimal(15) '@tva19'
		,tva20 decimal(15) '@tva20'
		,tva24 decimal(15) '@tva24'
	)

	/*  sectiune declaratie serieFACTURI */
	select * 
	into #serieFacturi
	from OPENXML(@iDoc, '/ns:declaratie394/ns:serieFacturi')
	with
	(
		 tip varchar(10) '@tip'
		,serieI varchar(20) '@serieI'
		,nrI varchar(20) '@nrI' 
		,nrF varchar(20) '@nrF'
	)

	/*  sectiune declaratie LISTA */
	select * 
	into #lista
	from OPENXML(@iDoc, '/ns:declaratie394/ns:lista')
	with
	(
		 caen varchar(20) '@caen'
		,cota int '@cota'
		,operat varchar(10) '@operat'
		,valoare decimal(15) '@valoare'
		,tva decimal(15) '@tva'	
	)

	/*  sectiune declaratie REZUMAT1 */
	select * 
	into #rezumat1
	from OPENXML(@iDoc, '/ns:declaratie394/ns:rezumat1')
	with
	(
		 tip_partener varchar(10) '@tip_partener'
		,cota int '@cota'
		,facturiL int '@facturiL'
		,bazaL decimal(15) '@bazaL'
		,tvaL decimal(15) '@tvaL'
		,facturiLS int 'facturiLS'
		,bazaLS decimal(15) '@bazaLS'
		,facturiA int '@facturiA'
		,bazaA decimal(15) '@bazaA'
		,tvaA decimal(15) '@tvaA'
		,facturiAI int '@facturiAI'
		,bazaAI decimal(15) '@bazaAI'
		,tvaAI decimal(15) '@tvaAI'
		,facturiAS int '@facturiAS'
		,bazaAS decimal(15) '@bazaAS'
		,facturiV int '@facturiV'
		,bazaV decimal(15) '@bazaV'
		,facturiC int '@facturiC'
		,bazaC decimal(15) '@bazaC'
		,tvaC decimal(15) '@tvaC'
		,facturiN int '@facturiN'
		,document_N varchar(20) '@document_N'
		,bazaN decimal(15) '@bazaN'
	)

	/*  sectiune declaratie REZUMAT1/DETALIU */
	select * 
	into #detaliu
	from OPENXML(@iDoc, '/ns:declaratie394/ns:rezumat1/ns:detaliu')
	with
	(
		 tip_partener varchar(10) '../@tip_partener'
		,document_N int '../@document_N'
		,cota int '../@cota'
		,bun varchar(10) '@bun'
		,nrLivV int '@nrLivV'
		,bazaLivV decimal(15) '@bazaLivV'
		,nrAchizC int '@nrAchizC'
		,bazaAchizC decimal(15) '@bazaAchizC'
		,tvaAchizC decimal(15) '@tvaAchizC'
		,nrN int '@nrN'
		,valN decimal(15) '@valN'
	)
	delete from #detaliu where bun is null

	/*  sectiune declaratie REZUMAT2 */
	select * 
	into #rezumat2
	from OPENXML(@iDoc, '/ns:declaratie394/ns:rezumat1')
	with
	(
		 cota int '@cota'
		,bazaFSLcod decimal(15) '@bazaFSLcod'	-- de vazut cum incadram aceste operatiuni in tabela D394
		,TVAFSLcod decimal(15) '@TVAFSLcod'
		,bazaFSL decimal(15) '@bazaFSL'
		,TVAFSL decimal(15) '@TVAFSL'
		,bazaFSA decimal(15) '@bazaFSA'
		,TVAFSA decimal(15) '@TVAFSA'
		,bazaFSAI decimal(15) '@bazaFSAI'
		,TVAFSAI decimal(15) '@TVAFSAI'
		,bazaBFAI decimal(15) '@bazaBFAI'
		,TVABFAI decimal(15) '@TVABFAI'
		,nrFacturiL int '@nrFacturiL'
		,bazaL decimal(15) '@bazaL'
		,tvaL decimal(15) '@tvaL'
		,nrFacturiA int  '@nrFacturiA'
		,bazaA decimal(15) '@bazaA'
		,tvaA decimal(15) '@tvaA'
		,nrFacturiAI int  '@nrFacturiAI'
		,bazaAI decimal(15) '@bazaAI'
		,tvaAI decimal(15) '@tvaAI'
		,baza_incasari_i1 decimal(15) '@baza_incasari_i1'
		,tva_incasari_i1 decimal(15) '@tva_incasari_i1'
		,baza_incasari_i2 decimal(15) '@baza_incasari_i2'
		,tva_incasari_i2 decimal(15) '@tva_incasari_i2'
		,bazaL_PF decimal(15) '@bazaL_PF'
		,tvaL_PF decimal(15) '@tvaL_PF'
	)
	EXEC sp_xml_removedocument @iDoc 

	/*  sfarsit import din XML  in diezuri  */

	/*  sectiunea C-F  */
	/*  centralizari  */
	insert into #d394(data, lm, rand_decl, tip_partener, tipop, nrFacturi, baza, tva, cota_tva, tip_document, Introdus_manual)
	select  @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.A', tip_partener, 'A', facturiA, bazaA, tvaA, cota, null, 1
	from #rezumat1 
	where bazaA is not null
	union all
	select  @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.L', tip_partener, 'L', facturiL, bazaL, tvaL, cota, null, 1 
	from #rezumat1 
	where bazaL is not null
	union all
	/*  anulez sectiunea pentru ca dubleaza anumite rezumate  */
	--select  @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.LS', tip_partener, 'LS', facturiLS, bazaLS, 0, cota, null, 1
	--from #rezumat1 
	--where bazaLS is not null
	--union all
	select  @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.AI', tip_partener, 'AI', facturiAI, bazaAI, tvaAI, cota, null, 1
	from #rezumat1 
	where bazaAI is not null
	union all
	select  @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.AS', tip_partener, 'AS', facturiAS, bazaAS, 0, cota, null, 1
	from #rezumat1 
	where bazaAS is not null
	union all
	select  @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.V', tip_partener, 'V', facturiV, bazaV, 0, cota, null, 1
	from #rezumat1 
	where bazaV is not null
	union all
	select  @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.C', tip_partener, 'C', facturiC, bazaC, tvaC, cota, null, 1
	from #rezumat1 
	where bazaC is not null
	union all
	select  @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.N', tip_partener, 'N', facturiN, bazaN, 0, cota, document_N,  1
	from #rezumat1 
	where bazaN is not null
	--group by tip_partener, cota, document_N

	/*  detaliere la nivel de firme  */
	insert into #d394(data, lm, rand_decl, tip_partener, tipop, cuiP, denP, nrfacturi, baza, tva, cota_tva, tip_document, Introdus_manual)
	select @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.'+rtrim(tip)+'.cuiP', tip_partener, tip, cuiP, denP, nrFact, baza, tva, cota, tip_document, 1
	from #op1 
	
	/* detaliere coduri */
	insert into #d394(data, lm, rand_decl, tip_partener, tipop, cuiP, denP, cod, nrFacturi, baza, tva, cota_tva, tip_document, Introdus_manual, detaliu, nusterge)
	select @dataXML, @locm, char(ascii('C')-1+o1.tip_partener)+'.'+rtrim(o1.tip)+'.cuiP', o1.tip_partener, o1.tip, o1.cuiP, o2.denP, o1.codPR, o1.nrFactPR, bazaPR, tvaPR, o1.cota, o2.tip_document, 1, 2, 1
	from #op11 o1
		inner join #op1 o2 on o1.tip=o2.tip and o1.tip_partener=o2.tip_partener and o1.cota=o2.cota and o1.cuiP=o2.cuiP
	
	/* detaliere detaliu */
	insert into #d394(data, lm, rand_decl, tip_partener, tipop, bun, nrfacturi, baza, tva, cota_tva, tip_document,  introdus_manual, detaliu, nusterge)
	select @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.V', tip_partener, 'V', bun, nrLivV, bazaLivV, 0, cota, null, 1, 2, 1
	from #detaliu
	where bazaLivV is not null
	union all
	select @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.C', tip_partener, 'C', bun, nrAchizC, bazaAchizC, tvaAchizC, cota, null, 1, 2, 1
	from #detaliu
	where bazaAchizC is not null
	union all
	select @dataXML, @locm, char(ascii('C')-1+tip_partener)+'.N', tip_partener, 'N', bun, nrN, valN, 0, cota, document_N, 1, 2, 1
	from #detaliu
	where valN is not null
	--group by tip_partener, cota, bun

	/*  sectiunea G  */
	insert into #d394 (data, lm, rand_decl, denumire, tipop, nrfacturi, baza, tva, cota_tva, incasari, introdus_manual)
	select @dataXML, @locm,'G.1', luna, 'I1', 0, baza20, tva20, 20, total, 1
	from #op2
	--where isnull(baza20,0)!=0
	union all
	select @dataXML, @locm,'G.1', luna, 'I1', 0, baza9, tva9, 9, 0, 1
	from #op2
	--where isnull(baza9,0)!=0
	union all
	select @dataXML, @locm,'G.1', luna, 'I1', 0, baza5, tva5, 5, 0, 1
	from #op2
	--where isnull(baza5,0)!=0
	union all
	select @dataXML, @locm,'G.1', luna, 'I1', nrBF, baza19, tva19, 19, 0, 1
	from #op2
	--where isnull(baza19,0)!=0

	/*  sectiunea H  */
	insert into #d394 (data, lm, rand_decl, tipop, nrfacturi, baza, tva, cota_tva, incasari, introdus_manual)
	select @dataXML, @locm,'H.AC', 'AC', isnull(facturiA,0)+isnull(facturiC,0), isnull(bazaA,0)+isnull(bazaC,0),isnull(tvaA,0)+isnull(tvaC,0), cota, 0, 1
	from #rezumat1
	where tip_partener=1 and isnull(bazaA,0)+isnull(bazaC,0)!=0
	union all
	select @dataXML, @locm,'H.AI', 'AI', isnull(facturiAI,0), isnull(bazaAI,0), isnull(tvaAI,0), cota, 0, 1
	from #rezumat1
	where tip_partener=1 and isnull(bazaAI,0)!=0
	union all
	select @dataXML, @locm,'H.LV', 'LV', isnull(facturiL,0)+isnull(facturiV,0), isnull(bazaL,0)+isnull(bazaV,0),isnull(tvaL,0), cota, 0, 1
	from #rezumat1
	where tip_partener=1 and isnull(bazaL,0)+isnull(bazaV,0)!=0

	/*  sectiunea I.1  */
	insert into #d394 (data, lm, rand_decl, baza, tva, cota_tva, introdus_manual)
	select @dataXML, @locm,'I.1.1', bazaFSLcod, TVAFSLcod, cota, 1
	from #rezumat2
	where isnull(bazaFSLcod,0)!=0
	union all
	select @dataXML, @locm,'I.1.2', bazaFSL, TVAFSL, cota, 1
	from #rezumat2
	where isnull(bazaFSL,0)!=0
	union all
	select @dataXML, @locm,'I.1.3', bazaFSA, TVAFSA, cota, 1
	from #rezumat2
	where isnull(bazaFSA,0)!=0
	union all
	select @dataXML, @locm,'I.1.4', bazaFSAI, TVAFSAI, cota, 1
	from #rezumat2
	where isnull(bazaFSAI,0)!=0
	union all
	select @dataXML, @locm,'I.1.5', bazaBFAI, TVABFAI, cota, 1
	from #rezumat2
	where isnull(bazaBFAI,0)!=0

	/*  sectiunea I.2  */
	insert into #d394 (data, lm, rand_decl, serieI, nrI, nrF, tip, introdus_manual)
	select @dataXML, @locm,'I.2.'+rtrim(convert(char(1),tip)), serieI, nrI, nrF, tip, 1 
	from #serieFacturi
	insert into #d394 (data, lm, rand_decl, tip, serieI, nrI, introdus_manual)
	select @dataXML, @locm,'I.2.2.F', tip_factura, serie, nr, 1 
	from #facturi

	/*  sectiunea I.3  */
	select top 1 @solicit_ramb=solicit from #informatii
	insert into #d394 (data, lm, are_doc, rand_decl, introdus_manual)
	select @dataXML, @locm, valoare, camp, 1
	from 
	(select nrcui1, [I.3.A.PE],	[I.3.A.CR],	[I.3.A.CB],	[I.3.A.CI],	[I.3.A.A], [I.3.A.B24], [I.3.A.B20], [I.3.A.B19], [I.3.A.B9], [I.3.A.B5], [I.3.A.S24], [I.3.A.S20],	[I.3.A.S19],
			[I.3.A.S9],	[I.3.A.S5],	[I.3.A.IB], [I.3.A.Necorp], [I.3.L.BI],	[I.3.L.BUN24], [I.3.L.BUN20], [I.3.L.BUN19], [I.3.L.BUN9], [I.3.L.BUN5], [I.3.L.BS], [I.3.L.BUNTI], 
			[I.3.L.P24], [I.3.L.P20], [I.3.L.P19], [I.3.L.P9], [I.3.L.P5], [I.3.L.PS], [I.3.L.Intra], [I.3.L.PIntra], [I.3.L.Export], [I.3.L.Necorp] from #informatii) p
	unpivot (valoare for camp in ([I.3.A.PE],	[I.3.A.CR],	[I.3.A.CB],	[I.3.A.CI],	[I.3.A.A], [I.3.A.B24], [I.3.A.B20], [I.3.A.B19], [I.3.A.B9], [I.3.A.B5], [I.3.A.S24], [I.3.A.S20],	[I.3.A.S19],
			[I.3.A.S9],	[I.3.A.S5],	[I.3.A.IB], [I.3.A.Necorp], [I.3.L.BI],	[I.3.L.BUN24], [I.3.L.BUN20], [I.3.L.BUN19], [I.3.L.BUN9], [I.3.L.BUN5], [I.3.L.BS], [I.3.L.BUNTI],
			[I.3.L.P24], [I.3.L.P20], [I.3.L.P19], [I.3.L.P9], [I.3.L.P5], [I.3.L.PS], [I.3.L.Intra], [I.3.L.PIntra], [I.3.L.Export], [I.3.L.Necorp])) as pvt
	where @solicit_ramb=1

	/*  sectiunea I.4  */
	insert into #d394 (data, lm, tva, rand_decl, cota_tva, introdus_manual)
	select @dataXML, @locm, valoare, 'I.4.1', convert(int,(case when isnumeric(right(rtrim(camp),2))!=0 then right(rtrim(camp),2) else right(rtrim(camp),1) end)) cota, 1
	from 
	(select tvaDed24, tvaDed19, tvaDed20, tvaDed9, tvaDed5, tvaDedAI24, tvaDedAI19, tvaDedAI20, tvaDedAI9, tvaDedAI5, tvaCol24, tvaCol19, tvaCol20,
			tvaCol9, tvaCol5 from #informatii) p 
	unpivot (valoare for camp in (tvaDed24, tvaDed19, tvaDed20, tvaDed9, tvaDed5, tvaDedAI24, tvaDedAI19, tvaDedAI20, tvaDedAI9, tvaDedAI5, tvaCol24, tvaCol19, tvaCol20,
			tvaCol9, tvaCol5)) as pvt
	where valoare!=0 and charindex('DedAI',camp,1)!=0

	/*  sectiunea I.5  */
	insert into #d394 (data, lm, tva, cota_tva, rand_decl, introdus_manual)
	select @dataXML, @locm, valoare, convert(int,(case when isnumeric(right(rtrim(camp),2))!=0 then right(rtrim(camp),2) else right(rtrim(camp),1) end)) cota,
		(case when charindex('Col',camp,1)!=0 then 'I.5.1' 
			  when charindex('DedAI',camp,1)!=0 then 'I.5.3' 
			  when charindex('DedAI',camp,1)=0 and charindex('Ded',camp,1)!=0 then 'I.5.2' 
			  else '' end) rand_decl, 1
	from 
	(select tvaDed24, tvaDed19, tvaDed20, tvaDed9, tvaDed5, tvaDedAI24, tvaDedAI19, tvaDedAI20, tvaDedAI9, tvaDedAI5, tvaCol24, tvaCol19, tvaCol20,
			tvaCol9, tvaCol5 from #informatii) p 
	unpivot (valoare for camp in (tvaDed24, tvaDed19, tvaDed20, tvaDed9, tvaDed5, tvaDedAI24, tvaDedAI19, tvaDedAI20, tvaDedAI9, tvaDedAI5, tvaCol24, tvaCol19, tvaCol20,
			tvaCol9, tvaCol5)) as pvt
	where valoare!=0 

	/*  sectiune I.6  */
	insert into #d394 (data, lm, rand_decl, incasari, cheltuieli, baza, tva, Introdus_manual)
	select @dataXML, @locm, '6.I.1', incasari_ag, costuri_ag, marja_ag, tva_ag, 1
	from #informatii
	where isnull(marja_ag,0)!=0
	union all
	select @dataXML, @locm, '6.I.2', pret_vanzare, pret_cumparare, marja_antic, tva_antic, 1
	from #informatii
	where isnull(marja_antic,0)!=0

	/*  sectiune I.7  */
	insert into #d394 (data, lm, rand_decl, denumire, tipop, baza, tva, cota_tva, Introdus_manual)
	select @dataXML, @locm, 'I.7.CAEN', caen, operat, valoare, tva, cota, 1
	from #lista

	update #d394
		set bun=(case when len(rtrim(cod))<4 then cod else '21' end)
	where cod is not null

	delete from #d394 where nrfacturi=0 and baza=0 and tva=0 and isnull(nusterge, 0)=0
	/*  scriere in tabela D394  */
	delete from d394 where data=@dataXML and @stergere=1 and lm=@locm
	insert into d394 (data, lm, rand_decl, denumire, tip_partener, tipop, tli, nrCui, codtert, cuiP, denP, cod, bun, nrfacturi, baza, tva, cota_tva, incasari, cheltuieli,
				tip, serieI, nrI, serieF, nrF, are_doc, tip_document, Introdus_manual)
	select data, lm, rand_decl, denumire, tip_partener, tipop, tli, nrCui, codtert, cuiP, denP, cod, bun, nrfacturi, baza, tva, cota_tva, incasari, cheltuieli,
				tip, serieI, nrI, serieF, nrF, are_doc, tip_document, Introdus_manual
	from #d394 order by rand_decl, cuiP, cota_tva, detaliu

	update d394 
		set nrCui=(select sum(nrcui) from d394 where data=@dataXML and lm is not null and rand_decl='A_nrcasemarcat')
	where data=@dataXML and lm is null and rand_decl='A_nrcasemarcat'

	select 'Operatia de import pe locul de munca '+rtrim(@locm)+' finalizata cu succes!' as textMesaj, 'Finalizare operatie' as titluMesaj for xml raw, root('Mesaje')

end try

begin catch
	set @mesajEroare=ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@mesajEroare, 11, 1)
end catch

/*  script de test

declare @p2 xml
set @p2=(select '394_T_D416_J3239704.xml' fisier, '06/30/2016' datalunii for xml raw, type)
exec importXmlD394 @sesiune='05508B19BBD84',@parXML=@p2

select * from d394 where data='06/30/2016'


*/
