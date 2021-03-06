﻿--***
Create procedure calculDecontTVA (@parXML xml='<row />')
as
Begin try
	declare @datajos datetime, @datasus datetime, @calcul int, @nr_evid varchar(100), 
		@bifa_cereale char(1), @bifa_mob char(1), @bifa_disp char(1), @bifa_cons char(1), @solicit_ramb varchar(1), 
		@data_scadentei datetime, @data_depunere datetime, @an int, @TVAnedeductibil decimal(12,2),
		@tip_D300 varchar(1), @datajosPAnt datetime, @datasusPAnt datetime, @cotatva decimal(6), @parXMLTLI xml, 
		@utilizator varchar(20), @multiFirma int, @lmFiltru varchar(9), @lmUtilizator varchar(9)
	
	select	@datajos=@parXML.value('(row/@datajos)[1]','datetime'),	--> interval
			@datasus=@parXML.value('(row/@datasus)[1]','datetime'),
			@calcul=@parXML.value('(row/@calcul)[1]','int'),
			@nr_evid=@parXML.value('(row/@nr_evid)[1]','varchar(100)'),
			@bifa_cereale=@parXML.value('(row/@bifa_cereale)[1]','varchar(1)'),
			@bifa_mob=@parXML.value('(row/@bifa_mob)[1]','varchar(1)'),
			@bifa_disp=@parXML.value('(row/@bifa_disp)[1]','varchar(1)'),
			@bifa_cons=@parXML.value('(row/@bifa_cons)[1]','varchar(1)'),
			@solicit_ramb=@parXML.value('(row/@solicit_ramb)[1]','varchar(1)'),
			@data_scadentei=@parXML.value('(row/@data_scadentei)[1]','datetime'),
			@tip_D300=@parXML.value('(row/@tip_D300)[1]','varchar(1)')

	set @cotaTVA=isnull((select Val_numerica from par where Tip_parametru='GE' and Parametru='COTATVA'),20)

	set @an=year(@datasus)
	set @TVAnedeductibil=0
	select @datajosPAnt=(case @tip_D300 when 'L' then DateADD(month,-5,@dataJos)
									when 'T' then dateadd(M,-3,@dataJos)
									else @datajos
									end)
			,@datasusPAnt=DateADD(day,-1,@dataJos)

	set @utilizator=dbo.fIaUtilizator(null)
	set @multiFirma=0
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1
	select @lmFiltru=isnull(min(Cod),'') from LMfiltrare where utilizator=@utilizator and cod in (select cod from lm where Nivel=1)
	if @multiFirma=1
		set @lmUtilizator=@lmFiltru
	
	if object_id('tempdb.dbo.#dectvacump') is not null drop table #dectvacump
	if object_id('tempdb.dbo.#dectvavanz') is not null drop table #dectvavanz
	if object_id('tempdb.dbo.#rapJurnalTvaLaIncasare_Tabela') is not null drop table #rapJurnalTvaLaIncasare_Tabela

--	calculez intr-o variabila valoarea TVA-ului nedeductibil (acel 50 % de la piese auto, combustibil) cu care ulterior diminuez valoarea TVA dedusa (rand 28).
--	TVA nedeductibil se obtine apeland functia fDeclaratia300Cump cu parametru @nTVAned=1 (doar operatiunile cu TVA nedeductibil)
--	am mutat calcul inainte intrucat variabibila este utilizata la partea de totaluri
	create table #dectvacump (total decimal(15))
	exec CreazaDiezTVA '#dectvacump'

	declare @nTVAned int 
	set @nTVAned=1
	set @parXML.modify ('insert (attribute tvaned {sql:variable("@nTVAned")}) into (/row)[1]')
	exec Declaratia300Cump @parXML
	select @TVAnedeductibil=isnull(sum(tva_19+tva_5+tva_9+tva_19_9_reg),0) from #dectvacump
	delete from #dectvacump

	if object_id('tempdb.dbo.#deconttva') is not null 
		drop table #deconttva
	select top 0 * into #deconttva from deconttva where Data=@datasus

	if @calcul=1	
	Begin
		declare @sub varchar(9), @ctTVADePlata varchar(40), @ctTVADeIncasat varchar(40), @soldneg_ant decimal(12), @soldpoz_ant_neachitat decimal(12), @rulajDebitPerioada decimal(12), 
			@sumeInchPerioadaCtTVADePlata decimal(12), @bazaSoldTLILivrari decimal(12,2), @soldTLILivrari decimal(12,2), @bazaSoldTLIAchizitii decimal(12,2), @soldTLIAchizitii decimal(12,2),
			@bazaSoldTLILivrariUltLuni decimal(12,2), @soldTLILivrariUltLuni decimal(12,2), @bazaSoldTLIAchizitiiUltLuni decimal(12,2), @soldTLIAchizitiiUltLuni decimal(12,2)
		
		select @sub=max(case when Parametru='SUBPRO' then Val_alfanumerica else '' end)
			,@ctTVADePlata=max(case when Parametru='CPTVA' then Val_alfanumerica else '' end)
			,@ctTVADeIncasat=max(case when Parametru='CITVA' then Val_alfanumerica else '' end)
		from par where Tip_parametru='GE' and Parametru in ('SUBPRO','CPTVA','CITVA')
		select	@soldneg_ant=0, @soldpoz_ant_neachitat=0, @bazaSoldTLILivrari=0, @soldTLILivrari=0, @bazaSoldTLIAchizitii=0, @soldTLIAchizitii=0, 
				@bazaSoldTLILivrariUltLuni=0, @soldTLILivrariUltLuni=0, @bazaSoldTLIAchizitiiUltLuni=0, @soldTLIAchizitiiUltLuni=0,
				@rulajDebitPerioada=0, @sumeInchPerioadaCtTVADePlata=0
		
		set @data_depunere=(case when GETDATE()>@data_scadentei and 1=0 then @data_scadentei else convert(char(101),GETDATE()) end)

--	calcul sold suma negativa din perioada precedenta pt. care nu s-a solicitat rambursare pe baza sold cont TVA de Incasat
		if not exists (select 1 from deconttva where data=@datajos-1 and Rand_decont='RAMBURSTVA' and Denumire_indicator='D' and (@multiFirma=0 or loc_de_munca=@lmUtilizator))
			set @soldneg_ant=dbo.soldcont(@ctTVADeIncasat,@datajos,'D')	-- pt. a putea obtine soldul la finalul lunii trebuie rulata functia soldcont cu parametru data=prima zi a lunii urmatoare.

--	calcul sold suma de plata din perioada precedenta neachitat pana la data depunerii decontului de TVA
		select @rulajDebitPerioada=suma_debit from fRulajeConturi(0, @ctTVADePlata, null, @data_depunere, null, null, @datajos, null)
		set @sumeInchPerioadaCtTVADePlata=isnull((select sum(suma) from pozncon where subunitate=@sub and tip='IC' and data between @datajos and @datasus and Cont_debitor=@ctTVADePlata),0)
		set @soldpoz_ant_neachitat=dbo.soldcont(@ctTVADePlata,DateADD(day,1,@datasus),'C')-(@rulajDebitPerioada-@sumeInchPerioadaCtTVADePlata)

--	Daca exista sold negativ pentru care nu s-a solicitat rambursare de TVA, atunci nu se poate sa existe sold pozitiv neachitat.	
		if @soldneg_ant>0
			set @soldpoz_ant_neachitat=0
--	scriu in tabela tamporara vanzarile gata insumate
		create table #dectvavanz (total decimal(15))
		exec CreazaDiezTVA '#dectvavanz'
		exec Declaratia300Vanz @parXML

--	pentru a obtine TVA-ul aferent tuturor operatiunilor se apeleaza procedura Declaratia300Cump cu parametru @nTVAned=2 
		set @nTVAned=2
		set @parXML.modify('replace value of (/row/@tvaned)[1] with sql:variable("@nTVAned")') 
--	scriu in tabela temporara #dectvacump (creata mai sus) cumpararile gata insumate
		exec Declaratia300Cump @parXML

--	scriu in tabela tamporara soldul operatiunilor cu TVA la incasare (TVA neexigibil)
		if object_id('tempdb..#rapJurnalTvaLaIncasare_Tabela') is null
		begin
			create table #rapJurnalTvaLaIncasare_Tabela(subunitate varchar(1) default '1')
			exec rapJurnalTvaLaIncasare_faTabela
		end

		if @an>=2013
		Begin
--	sold livrari cu TVA la incasare
			exec rapJurnalTvaLaIncasare @cFurnBenef='B', @datajos=@datajos, @datasus=@datasus, @tert=null, @factura=null
			select @bazaSoldTLILivrari=isnull(round(sum(bazaSoldTLI),0),0), @soldTLILivrari=isnull(round(sum(soldTLI),0),0) from #rapJurnalTvaLaIncasare_Tabela
--	sold TVA la incasare aferent facturilor din ultimele 6 luni / 2 trimestre calendaristice. 
			select @bazaSoldTLILivrariUltLuni=isnull(round(sum(bazaSoldTLI),0),0), @soldTLILivrariUltLuni=isnull(round(sum(soldTLI),0),0) 
			from #rapJurnalTvaLaIncasare_Tabela where data between @datajosPAnt and @datasus and @an>=2016
--	sold achizitii cu TVA la incasare
			delete from #rapJurnalTvaLaIncasare_Tabela
			exec rapJurnalTvaLaIncasare @cFurnBenef='F', @datajos=@datajos, @datasus=@datasus, @tert=null, @factura=null
			select @bazaSoldTLIAchizitii=isnull(round(sum(bazaSoldTLI),0),0), @soldTLIAchizitii=isnull(round(sum(soldTLI),0),0) from #rapJurnalTvaLaIncasare_Tabela
			select @bazaSoldTLIAchizitiiUltLuni=isnull(round(sum(bazaSoldTLI),0),0), @soldTLIAchizitiiUltLuni=isnull(round(sum(soldTLI),0),0) 
			from #rapJurnalTvaLaIncasare_Tabela where data between @datajosPAnt and @datasus and @an>=2016
		End	

--	sterg datele generate anterior
		delete from deconttva where Data=@datasus and nullif(Introdus_manual,0) is null and (@multiFirma=0 or loc_de_munca=@lmUtilizator)

		if exists (select 1 from sysobjects where [type]='P' and [name]='calculDecontTVASP')
			exec calculDecontTVASP @parXML output
--	inserez livrari
--	capitol = 11 = 1 (TVA COLECTATA) + 1 (COMERT INTRACOMUNITAR SI IN AFARA UE) 
		insert into #deconttva (Data, Capitol, Rand_decont, Denumire_indicator, Valoare, Tva, Modif_valoare, Modif_tva)
		select @datasus, '11', '1', 'Livrari intracomunitare de bunuri, scutite conform art. 143 alin.(2) lit.a) si d) din Codul fiscal', scutite_intra_ded_1, 0, 1, 0
		from #dectvavanz
		union all
		select @datasus, '11', '2', 'Regularizari livrari intracomunitare scutite conform art.143 alin.(2) lit.a) si d) din Codul fiscal', 0, 0, 1, 0
		from #dectvavanz
		union all
		select @datasus, '11', '3', 'Livrari de bunuri sau prestari de servicii pentru care locul livrarii/locul prestarii este in afara Romaniei (in UE sau in afara UE), precum si livrari intracomunitare de bunuri, scutite conform art. 143 alin.(2) lit.b) si c) din Codul fiscal , din care:', 
			scutite_intra_ded_2+afara_ded+afara_fara, 0, 1, 0
		from #dectvavanz
		union all
		select @datasus, '11', '3.1', 'Prestari de servicii intracomunitare care nu beneficiaza de scutire in statul membru in care taxa este datorata', afara_ded_serv, 0, 1, 0
		from #dectvavanz
		union all
		select @datasus, '11', '4', 'Regularizari privind prestarile de servicii intracomunitare care nu beneficiaza de scutire in statul membru in care taxa este datorata', 0, 0, 1, 0
		from #dectvavanz
		union all
		select @datasus, '11', '5', 'Achizitii intracomunitare de bunuri pentru care cumparatorul este obligat la plata TVA (taxare inversa), din care:', 
			baza_intra-baza_intra_serv, tva_intra-tva_intra_serv, 1, 1
		from #dectvacump
		union all
		select @datasus, '11', '5.1', 'Achizitii intracomunitare pentru care cumparatorul este obligat la plata TVA (taxare inversa), iar furnizorul este inregistrat in scopuri de TVA in statul membru din care a avut loc livrarea intracomunitara', 
			baza_intra-baza_intra_serv, tva_intra-tva_intra_serv, 1, 1
		from #dectvacump
		union all
		select @datasus, '11', '6', 'Regularizari privind achizitiile intracomunitare de bunuri pentru care cumparatorul este obligat la plata TVA(taxare inversa)', 
			baza_intra_reg-baza_intra_serv_reg, tva_intra_reg-tva_intra_serv_reg, 1, 1
		from #dectvacump
		union all
		select @datasus, '11', '7', 'Achizitii de bunuri, altele decat cele de la rd.5 si 6 si achizitii de servicii pentru care beneficiarul din Romania este obligat la plata TVA (taxare inversa) din care:', 
			baza_intra_serv+baza_oblig_1, tva_intra_serv+tva_oblig_1, 1, 1
		from #dectvacump
		union all
		select @datasus, '11', '7.1', 'Achizitii de servicii intracomunitare pentru care beneficiarul este obligat la plata TVA (taxare inversa)', 
			baza_intra_serv+baza_oblig_1_serv, tva_intra_serv+tva_oblig_1_serv, 1, 1
		from #dectvacump
		union all
		select @datasus, '11', '8', 'Regularizari privind achizitii de servicii intracomunitare pentru care beneficiarul este obligat la plata TVA (taxare inversa)', 
			baza_intra_serv_reg, tva_intra_serv_reg, 1, 1
		from #dectvacump
		union all
--	capitol = 12 = 1 (TVA COLECTATA) + 2 (LIVRARI DE BUNURI/ PRESTARI DE SERVICII IN INTERIORUL TARII SI EXPORTURI) 
		select @datasus, '12', '9', 'Livrari de bunuri si prestari de servicii taxabile cu cota '+convert(varchar(6),@cotatva)+'%', 
			v.baza_19/*-c.baza_oblig_1-c.baza_oblig_2-c.baza_intra*/, v.tva_19/*-c.tva_oblig_1-c.tva_oblig_2-c.tva_intra*/, 1, 1
		from #dectvavanz v
			left outer join #dectvacump c on 1=1
		union all
		select @datasus, '12', '10', 'Livrari de bunuri si prestari de servicii taxabile cu cota 9%', baza_9, tva_9, 1, 1
		from #dectvavanz
		union all
		select @datasus, '12', '11', 'Livrari de bunuri taxabile cu cota 5%', baza_5, tva_5, 1, 1
		from #dectvavanz
		union all
		select @datasus, '12', '12', 'Achizitii de bunuri si servicii supuse masurilor de simplificare pentru care beneficiarul este obligat la plata TVA (taxare inversa)', 
			baza_oblig_2, tva_oblig_2, 1, 1
		from #dectvacump
		union all
		select @datasus, '12', '12.1', 'Achizitii de bunuri si servicii, taxabile cu cota 20%', baza_oblig_2_19, tva_oblig_2_19, 1, 1
		from #dectvacump where @an>=2016
		union all
		select @datasus, '12', '12.2', 'Achizitii de bunuri si servicii, taxabile cu cota 9%', baza_oblig_2_9, tva_oblig_2_9, 1, 1
		from #dectvacump where @an>=2016
		union all
		select @datasus, '12', '12.3', 'Achizitii de bunuri si servicii, taxabile cu cota 5%', baza_oblig_2_5, tva_oblig_2_5, 1, 1
		from #dectvacump where @an>=2016
		union all
		select @datasus, '12', '13', 'Livrari de bunuri si prestari de servicii supuse masurilor de simplificare (taxare inversa)', baza_txinv, 0, 1, 0
		from #dectvavanz
		union all
		select @datasus, '12', '14', 'Livrari de bunuri si prestari de servicii scutite cu drept de deducere, altele decat cele de la rd. 1-3', scutite_ded_alte, 0, 1, 0
		from #dectvavanz
		union all
		select @datasus, '12', '15', 'Livrari de bunuri si prestari de servicii scutite fara drept de deducere', scutite_fara, 0, 1, 0
		from #dectvavanz
		union all
		select @datasus, '12', '16', 'Regularizari taxa colectata', dv.baza_19_reg+isnull(dc.baza_oblig_2_reg,0), dv.tva_19_reg+isnull(dc.tva_oblig_2_reg,0), 1, 1
		from #dectvavanz dv
			left outer join #dectvacump dc on 1=1
		union all
		select @datasus, '12', '17', 'TOTAL TAXA COLECTATA (suma de la rd.1 pana la rd.16, cu exceptia celor de la rd.3.1, 5.1 si 7.1) , din care:', 0, 0, 0, 0
		from #dectvavanz

--	inserez achizitii
--	capitol = 21 = 2 (TVA DEDUCTIBILA) + 1 (ACHIZITII INTRACOMUNITARE DE BUNURI SI ALTE ACHIZITII DE BUNURI SI SERVICII IMPOZABILE IN ROMANIA) 
		insert into #deconttva (Data, Capitol, Rand_decont, Denumire_indicator, Valoare, Tva, Modif_valoare, Modif_tva)
		select @datasus, '21', '18', 'Achizitii intracomunitare de bunuri pentru care cumparatorul este obligat la plata TVA (taxare inversa) (rd.18=rd.5), din care:', 
			baza_intra-baza_intra_serv, tva_intra-tva_intra_serv, 1, 1
		from #dectvacump
		union all
		select @datasus, '21', '18.1', 'Achizitii intracomunitare pentru care cumparatorul este obligat la plata TVA (taxare inversa), iar furnizorul este inregistrat in scopuri de TVA in statul membru din care a avut loc livrarea (rd.18.1=rd.5.1)', 
			baza_intra-baza_intra_serv, tva_intra-tva_intra_serv, 1, 1
		from #dectvacump
		union all
		select @datasus, '21', '19', 'Regularizari privind achizitiile intracomunitare de bunuri pentru care cumparatorul este obligat la plata TVA (taxare inversa) (rd.19=rd.6)', 
			baza_intra_reg-baza_intra_serv_reg, tva_intra_reg-tva_intra_serv_reg, 1, 1
		from #dectvacump
		union all
		select @datasus, '21', '20', 'Achizitii de bunuri, altele decat cele de la rd. 18 si 19, si achizitii de servicii pentru care beneficiarul din Romania este obligat la plata TVA (taxare inversa) (rd.20=rd.7), din care:', 
			baza_intra_serv+baza_oblig_1, tva_intra_serv+tva_oblig_1, 1, 1
		from #dectvacump
		union all
		select @datasus, '21', '20.1', 'Achizitii de servicii intracomunitare pentru care beneficiarul este obligat la plata TVA (taxare inversa) (rd.20.1=rd.7.1)', 
			baza_intra_serv+baza_oblig_1_serv, tva_intra_serv+tva_oblig_1_serv, 1, 1
		from #dectvacump
		union all
		select @datasus, '21', '21', 'Regularizari privind achizitii de servicii intracomunitare pentru care beneficiarul din Romania este obligat la plata TVA (taxare inversa) (rd.21=rd.8)', 
			baza_intra_serv_reg, tva_intra_serv_reg, 1, 1
		from #dectvacump
		union all
		select @datasus, '22', '22', 'Achizitii de bunuri si servicii taxabile cu cota de '+convert(varchar(6),@cotatva)+'%, altele decat cele de la rd.25', baza_19, tva_19, 1, 1
		from #dectvacump
		union all
		select @datasus, '22', '23', 'Achizitii de bunuri si servicii taxabile cu cota de 9%', baza_9, tva_9, 1, 1
		from #dectvacump
		union all
		select @datasus, '22', '24', 'Achizitii de bunuri taxabile cu cota de 5%', baza_5, tva_5, 1, 1
		from #dectvacump
		union all
		select @datasus, '22', '25', 'Achizitii de bunuri si servicii supuse masurilor de simplificare pentru care beneficiarul este obligat la plata TVA (taxare inversa) (rd.25=rd.12)', 
			baza_oblig_2, tva_oblig_2, 1, 1
		from #dectvacump
		union all
		select @datasus, '22', '25.1', 'Achizitii de bunuri si servicii, taxabile cu cota 20%', baza_oblig_2_19, tva_oblig_2_19, 1, 1
		from #dectvacump where @an>=2016
		union all
		select @datasus, '22', '25.2', 'Achizitii de bunuri si servicii, taxabile cu cota 9%', baza_oblig_2_9, tva_oblig_2_9, 1, 1
		from #dectvacump where @an>=2016
		union all
		select @datasus, '22', '25.3', 'Achizitii de bunuri si servicii, taxabile cu cota 5%', baza_oblig_2_5, tva_oblig_2_5, 1, 1
		from #dectvacump where @an>=2016
		union all
		select @datasus, '22', '26', 'Achizitii de bunuri si servicii scutite de taxa sau neimpozabile, din care:', scutite+scutite_intra, 0, 1, 0
		from #dectvacump
		union all
		select @datasus, '22', '26.1', 'Achizitii de servicii intracomunitare scutite de taxa (nu se completeaza la metoda simplificata)', scutite_intra_serv, 0, 1, 0
		from #dectvacump
		union all
		select @datasus, '22', '27', 'TOTAL TAXA DEDUCTIBILA ( suma de la rd.18 pana la rd.25, cu exceptia celor de la rd.18.1 si 20.1), din care:', 0, 0, 0, 0
		from #dectvacump
		union all
--	capitol = 22 = 2 (TVA DEDUCTIBILA) + 2 (ACHIZITII DE BUNURI / SERVICII IN INTERIORUL TARII SI IMPORTURI, ACHIZITII INTRACOMUNITARE, SCUTITE SAU NEIMPOZABILE) 
		select @datasus, '22', '28', 'SUB-TOTAL TAXA DEDUSA CONFORM ART. 145 sI ART. 1451 SAU ART. 147 sI ART. 1451 (rd.28<=rd.27)', 0, 0, 0, 0
		union all
		select @datasus, '22', '29', 'TVA efectiv restituita cumparatorilor straini, inclusiv comisionul unitatilor autorizate', 0, 0, 0, 1
		union all
		select @datasus, '22', '30', 'Regularizari taxa dedusa', baza_19_9_reg, tva_19_9_reg, 1, 1
		from #dectvacump
		union all
		select @datasus, '22', '31', 'Ajustari conform pro-rata / ajustari pentru bunurile de capital', 0, 0, 0, 1
		union all
		select @datasus, '22', '32', 'TOTAL TAXA DEDUSA (rd.28+rd.29+rd.30+rd.31)', 0, 0, 0, 0

--	regularizari
--	capitol = 31 -> REGULARIZARI CONFORM ART. 147(3) DIN CODUL FISCAL
		insert into #deconttva (Data, Capitol, Rand_decont, Denumire_indicator, Valoare, Tva, Modif_valoare, Modif_tva)
		select @datasus, '31', '33', 'Suma negativa a TVA in perioada de raportare (rd.32-rd. 17)', 0, 0, 0, 0
		union all
		select @datasus, '31', '34', 'Taxa de plata in perioada de raportare (rd.17-rd. 32)', 0, 0, 0, 0
		union all
		select @datasus, '31', '35', 'Soldul TVA de plata din decontul perioadei fiscale precedente (rd.41 din decontul perioadei fiscale precedente) neachitate pana la data depunerii decontului de TVA', 
			0, 0, 0, 1
		union all
		select @datasus, '31', '36', 'Diferente de TVA de plata stabilite de organele de inspectie fiscala prin decizie comunicata si neachitate pana la data depunerii decontului de TVA)', 
			0, 0, 0, 1
		union all
		select @datasus, '31', '37', 'TVA de plata cumulat', 0, 0, 0, 0
		union all
		select @datasus, '31', '38', 'Soldul sumei negative a TVA reportate din perioada precedenta pentru care nu s-a solicitat rambursare (rd.42 din decontul perioadei fiscale precedente)', 
			0, @soldneg_ant, 0, 1
		union all
		select @datasus, '31', '39', 'Diferente negative de TVA stabilite de organele de inspectie fiscala prin decizie comunicata pana la data depunerii decontului de TVA', 0, 0, 0, 1
		union all
		select @datasus, '31', '40', 'Suma negativa a TVA cumulate (rd.33+rd.38+rd.39)', 0, 0, 0, 0
		union all
		select @datasus, '31', '41', 'Sold TVA de plata la sfarsitul perioadei de raportare (rd.37-rd.40)', 0, 0, 0, 0
		union all
		select @datasus, '31', '42', 'Soldul sumei negative de TVA la sfarsitul perioadei de raportare (rd.40-rd.37)', 0, 0, 0, 0
		union all
--	capitol = 41 -> Facturi emise dupa inspectia fiscala conform Art. 159 alin (3) din Codul fiscal
		select @datasus, '41', '50', 'Nr. facturi emise dupa inspectia fiscala, conform art. '+(case when @an<=2015 then '159 alin (3) din Cod fiscal' else '303 alin (3) din Cod fiscal' end), 0, 0, 1, 0 
		union all
		select @datasus, '41', '51', 'Total baza de impozitare facturi emise dupa inspectia fiscala', 0, 0, 1, 0
		union all
		select @datasus, '41', '52', 'Total TVA aferenta facturilor emise dupa inspectia fiscala', 0, 0, 0, 1
--	capitol = 42 -> Facturi emise dupa inspectia fiscala conform pct. 108 din Norme de aplicare a legii 227/2015
		union all
		select @datasus, '42', '55', 'Nr. facturi emise dupa inspectia fiscala, conform pct. 108 din Norme de aplicare a legii 227/2015', 0, 0, 1, 0 where @an>=2016
		union all
		select @datasus, '42', '56', 'Total baza de impozitare facturi emise dupa inspectia fiscala', 0, 0, 1, 0 where @an>=2016
		union all
		select @datasus, '42', '57', 'Total TVA aferenta facturilor emise dupa inspectia fiscala', 0, 0, 0, 1 where @an>=2016

--	altele
--	capitol = 51 -> Alte informatii din decont
		insert into #deconttva (Data, Capitol, Rand_decont, Denumire_indicator, Valoare, Tva, Modif_valoare, Modif_tva)
		select @datasus, '51', 'NREVIDPL  ', @nr_evid, 0, 0, 0, 0
		union all
		select @datasus, '51', 'CEREALE   ', @bifa_cereale, 0, 0, 0, 0
		union all
		select @datasus, '51', 'TELEFOANE', @bifa_mob, 0, 0, 0, 0
		union all
		select @datasus, '51', 'DISPOZITIV', @bifa_disp, 0, 0, 0, 0
		union all
		select @datasus, '51', 'CONSOLE', @bifa_cons, 0, 0, 0, 0
		union all
		select @datasus, '51', 'RAMBURSTVA', @solicit_ramb, 0, 0, 0, 0

		if @an>=2013
			insert into #deconttva (Data, Capitol, Rand_decont, Denumire_indicator, Valoare, Tva, Modif_valoare, Modif_tva)
			select @datasus, '52', '53', 'Livrari de bunuri si prestari de servicii efectuate a caror TVA aferenta a ramas neexigibila, existenta in sold la sfarsitul perioadei de raportare, ca urmare a aplicarii sistemului TVA la �ncasare'+(case when @an>=2016 then ', din care:' else '' end), 
				@bazaSoldTLILivrari, @soldTLILivrari, 1, 1
			union all
			select @datasus, '52', '53.1', 'Livrari de bunuri si prestari de servicii realizate in ultimele '+(case when @tip_D300='L' then '6 luni' when @tip_D300='T' then '2 trimestre calendaristice' else '' end), 
				@bazaSoldTLILivrariUltLuni, @soldTLILivrariUltLuni, 1, 1 where @an>=2016
			union all
			select @datasus, '52', '54', 'Achizitii de bunuri si servicii efectuate pentru care nu s-a exercitat dreptul de deducere a TVA aferenta, existenta in sold la sfarsitul perioadei de raportare, ca urmare a aplicarii art. 145 alin.(11) si (12) din Codul fiscal'+(case when @an>=2016 then ', din care:' else '' end), 
				@bazaSoldTLIAchizitii, @soldTLIAchizitii, 1, 1
			union all
			select @datasus, '52', '54.1', 'Achizitii de bunuri si servicii realizate in ultimele '+(case when @tip_D300='L' then '6 luni' when @tip_D300='T' then '2 trimestre calendaristice' else '' end), 
				@bazaSoldTLIAchizitiiUltLuni, @soldTLIAchizitiiUltLuni, 1, 1 where @an>=2016
	
--	am modificat TVA-ul la sumele provenite din D394 - TVA-ul aferent vanzarilor cu taxare	inversa (TVA=2 Neinregistrat) care apare in D394 nu ar trebui sa apara pe randul 17.1
--	s-ar putea ajunge ca TVA-ul de pe randul 17.1 sa fie mai mare decat TVA-ul de pe randul 17 (TVA colectat)
--	am mutat aici insertul intrucat incepand cu anul 2013 aceste 2 randuri nu sunt cuprinse in D300
		if @an<2013
			insert into #deconttva 
			select @datasus, '12', '17.1', 'Livrari de bunuri si/sau prestari de servicii taxabile efectuate in interiorul tarii pentru care au fost emise facturi catre persoane inregistrate in scopuri de TVA in Romania (rd.17.1<=rd.17)', 
				SUM(convert(decimal(15),baza)), SUM(convert(decimal(15),(case when tipop='V' then 0 else tva end))), 0, 0
			from fDeclaratia394 ('', @datajos, @datasus) where tipop in ('L','V')
			union all
			select @datasus, '22', '27.1', 'Achizitii de bunuri si/sau servicii taxabile din interiorul tarii pentru care au fost primite facturi de la persoane inregistrate in scopuri de TVA in Romania (rd.27.1<=rd.27)', 
				SUM(convert(decimal(15),baza)), SUM(convert(decimal(15),tva)), 0, 0
			from fDeclaratia394 ('', @datajos, @datasus) where tipop in ('A','C')

		if exists (select 1 from sysobjects where [type]='P' and [name]='calculDecontTVASP1')
			exec calculDecontTVASP1 @parXML output

		insert into deconttva (Data, Capitol, Rand_decont, Denumire_indicator, Valoare, TVA, Modif_valoare, Modif_tva, Introdus_manual, Loc_de_munca)
		select d.Data, d.Capitol, d.Rand_decont, d.Denumire_indicator, d.Valoare, d.TVA, d.Modif_valoare, d.Modif_tva, 0, @lmUtilizator
		from #deconttva d
		where not exists (select 1 from deconttva d1 where d1.data=d.data and d1.capitol=d.capitol and d1.Rand_decont=d.rand_decont and (@multiFirma=0 or d.Loc_de_munca=d1.Loc_de_munca))
	End

--	calculez randul 35, tot timpul pentru a nu afecta cazurile in care se editeaza decontul de TVA (mai putin randul 35).
--	pentru cine doreste sa editeze randul 35, trebuie facut fictiv un calculDecontTVASP2 apelabil doar cand @calcul=0
		update deconttva set TVA=isnull(@soldpoz_ant_neachitat,tva)
		where data=@datasus and Rand_decont='35' and Introdus_manual=0 and (@multiFirma=0 or Loc_de_munca=@lmUtilizator)

		if exists (select 1 from sysobjects where [type]='P' and [name]='calculDecontTVASP11')
			exec calculDecontTVASP11 @parXML output

--	calculez total TVA colectata
		update deconttva set Valoare=s.Valoare, TVA=s.TVA
			from (select sum(b.Valoare) as Valoare, sum(b.TVA) as TVA from deconttva b where b.data=@datasus and b.Rand_decont in ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16')
				 and (@multiFirma=0 or b.Loc_de_munca=@lmUtilizator)) s
		where data=@datasus and Rand_decont='17' and (@multiFirma=0 or Loc_de_munca=@lmUtilizator)

--	calcul TVA deductibila
		update deconttva set Valoare=(case when Rand_decont='27' then s.Valoare else deconttva.Valoare end), TVA=s.TVA-(case when Rand_decont='28' then @TVAnedeductibil else 0 end)
			from (select sum(b.Valoare) as Valoare, sum(b.TVA) as TVA from deconttva b where b.data=@datasus and b.Rand_decont in ('18','19','20','21','22','23','24','25')
				and (@multiFirma=0 or b.Loc_de_munca=@lmUtilizator)) s
		where data=@datasus and (Rand_decont='27' or Rand_decont='28') and (@multiFirma=0 or Loc_de_munca=@lmUtilizator)

		update a set a.TVA=(select sum(b.TVA) from deconttva b where b.data=@datasus and b.Rand_decont between '28' and '31' and (@multiFirma=0 or b.Loc_de_munca=a.Loc_de_munca))
		from deconttva a
		where a.data=@datasus and a.Rand_decont='32' and (@multiFirma=0 or a.Loc_de_munca=@lmUtilizator)

--	calcul regularizari / totaluri
		update a set TVA=(case when r32.TVA-r17.TVA>0 then r32.TVA-r17.TVA else 0 end)
		from deconttva a
			left outer join deconttva r32 on r32.Data=a.Data and r32.Rand_decont='32' and (@multiFirma=0 or r32.Loc_de_munca=a.Loc_de_munca)
			left outer join deconttva r17 on r17.Data=a.Data and r17.Rand_decont='17' and (@multiFirma=0 or r17.Loc_de_munca=a.Loc_de_munca)
		where a.data=@datasus and a.Rand_decont='33' and (@multiFirma=0 or a.Loc_de_munca=@lmUtilizator)

		update a set a.TVA=(case when r17.TVA-r32.TVA>0 then r17.TVA-r32.TVA else 0 end)
		from deconttva a
			left outer join deconttva r32 on r32.Data=a.Data and r32.Rand_decont='32' and (@multiFirma=0 or r32.Loc_de_munca=a.Loc_de_munca)
			left outer join deconttva r17 on r17.Data=a.Data and r17.Rand_decont='17' and (@multiFirma=0 or r17.Loc_de_munca=a.Loc_de_munca)
		where a.data=@datasus and a.Rand_decont='34' and (@multiFirma=0 or a.Loc_de_munca=@lmUtilizator)

--	calcul TVA de plata la finalul perioadei fiscale precedente neachitate pana la data depunerii decontului curent
		if @calcul=0 and exists (select 1 from sysobjects where [type]='P' and [name]='calculDecontTVASP2')
			exec calculDecontTVASP2 @parXML output
		else
			update a set TVA=(case when a.TVA>0 then (case when abs(a.TVA-r34.TVA)<=1 then 0 else a.TVA-r34.TVA end) else a.TVA end)
			from deconttva a
				left outer join deconttva r34 on r34.Data=a.Data and r34.Rand_decont='34' and (@multiFirma=0 or r34.Loc_de_munca=a.Loc_de_munca)
			where a.data=@datasus and a.Rand_decont='35' and a.Introdus_manual=0 and (@multiFirma=0 or a.Loc_de_munca=@lmUtilizator)

		update a set a.TVA=(select sum(b.TVA) from deconttva b where b.data=@datasus and b.Rand_decont between '34' and '36' and  (@multiFirma=0 or b.Loc_de_munca=a.Loc_de_munca))
		from deconttva a
		where a.data=@datasus and a.Rand_decont='37' and (@multiFirma=0 or a.Loc_de_munca=@lmUtilizator)

		update a set a.TVA=(select sum(b.TVA) from deconttva b where b.data=@datasus and b.Rand_decont in ('33','38','39') and (@multiFirma=0 or b.Loc_de_munca=a.Loc_de_munca))
		from deconttva a
		where a.data=@datasus and a.Rand_decont='40' and (@multiFirma=0 or a.Loc_de_munca=@lmUtilizator)

		update a set a.TVA=(case when r37.TVA-r40.TVA>0 then r37.TVA-r40.TVA else 0 end)
		from deconttva a
			left outer join deconttva r37 on r37.Data=a.Data and r37.Rand_decont='37' and (@multiFirma=0 or r37.Loc_de_munca=a.Loc_de_munca)
			left outer join deconttva r40 on r40.Data=a.Data and r40.Rand_decont='40' and (@multiFirma=0 or r40.Loc_de_munca=a.Loc_de_munca)
		where a.data=@datasus and a.Rand_decont='41' and (@multiFirma=0 or a.Loc_de_munca=@lmUtilizator)

		update a set TVA=(case when r40.TVA-r37.TVA>0 then r40.TVA-r37.TVA else 0 end)
		from deconttva a
			left outer join deconttva r37 on r37.Data=a.Data and r37.Rand_decont='37' and (@multiFirma=0 or r37.Loc_de_munca=a.Loc_de_munca)
			left outer join deconttva r40 on r40.Data=a.Data and r40.Rand_decont='40' and (@multiFirma=0 or r40.Loc_de_munca=a.Loc_de_munca)
		where a.data=@datasus and a.Rand_decont='42' and (@multiFirma=0 or a.Loc_de_munca=@lmUtilizator)
End try

begin catch
	declare @eroare varchar(8000)
	set @eroare=ERROR_MESSAGE() + ' ('+object_name(@@procid)+', linia '+convert(varchar(20),ERROR_LINE())+')'
	raiserror(@eroare, 16, 1)
end catch

if object_id('tempdb.dbo.#dectvacump') is not null drop table #dectvacump
if object_id('tempdb.dbo.#dectvavanz') is not null drop table #dectvavanz
if object_id('tempdb.dbo.#rapJurnalTvaLaIncasare_Tabela') is not null drop table #rapJurnalTvaLaIncasare_Tabela
