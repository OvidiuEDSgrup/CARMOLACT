/* operatie pt. generare NC pt. cheltuieli pe locuri de munca (bugetari) */
Create procedure GenNCCheltLMBug
	@dataJos datetime, @dataSus datetime, @pMarca char(6), @Continuare int output, @NrPozitie int output, @NumarDoc char(8)
As
Begin try
	declare @userASiS char(10), @Sub char(9), @CASIndiv decimal(5,2), @SomajInd decimal(5,2), @ProcCASIndiv decimal(5,2), @ProcSomajIndiv decimal(5,2), 
	@NCIndBug int, @NCTaxePLMCh int, @NCSubvSomaj int, 
	@DebitCMUnitate2 varchar(20), @CreditCMUnitate2 varchar(20), @DebitCMCas2 varchar(20), @CreditCMCas2 varchar(20)

	set @userASiS=dbo.fIaUtilizator(null)
	set @Sub=dbo.iauParA('GE','SUBPRO')
	set @CasIndiv=dbo.iauParLN(@dataSus,'PS','CASINDIV')
	set @SomajInd=dbo.iauParLN(@dataSus,'PS','SOMAJIND')
	set @NCIndBug=dbo.iauParL('PS','NC-INDBUG')
	select 
		@NCTaxePLMCh=max(case when Parametru='N-C-TXLMC' then Val_logica else 0 end),
		@NCSubvSomaj=max(case when Parametru='N-SUBVSJD' then Val_logica else 0 end)
	from par where parametru in ('N-C-TXLMC','N-SUBVSJD')

	set @DebitCMUnitate2=dbo.iauParA('PS','N-C-CMU2D')
	set @CreditCMUnitate2=dbo.iauParA('PS','N-C-CMU2C')
	set @DebitCMCas2=dbo.iauParA('PS','N-C-CMC2D')
	set @CreditCMCas2=dbo.iauParA('PS','N-C-CMC2C')

	if object_id('tempdb..#tmpCheltuieli') is not null drop table #tmpCheltuieli
	if object_id('tempdb..#nc_cheltuieli') is not null drop table #nc_cheltuieli
	if object_id('tempdb..#config_nc_ch') is not null drop table #config_nc_ch
	if object_id('tempdb..#brutCMMarca') is not null drop table #brutCMMarca
	if object_id('tempdb..#brutCM') is not null drop table #brutCM
	if object_id('tempdb..#CASbrut') is not null drop table #CASbrut

	select b.data, b.marca, b.loc_de_munca, b.ind_c_medical_cas+b.CMCAS+b.spor_cond_9 as CMCasPoz, b.ind_c_medical_unitate+b.CMunitate+b.ind_c_medical_cas+b.CMCAS+b.spor_cond_9 as CMPoz
	into #brutCM
	from #brut b
	where b.data=@dataSus and (@pMarca='' or b.marca=@pMarca)

	select b.data, b.marca, sum(b.ind_c_medical_cas+b.CMCAS+b.spor_cond_9) as CMCasMarca, sum(b.ind_c_medical_unitate+b.CMunitate+b.ind_c_medical_cas+b.CMCAS+b.spor_cond_9) as CMMarca
	into #brutCMMarca
	from #brut b
	where b.data=@dataSus and (@pMarca='' or b.marca=@pMarca)
	group by b.data, b.marca

	/*	Populare tabela CASbrut pentru generare ulterioara NC contributii pe locuri de munca si comenzi. */
	select top 0 * into #CASbrut from CASbrut
	insert into #CASbrut
		(Loc_de_munca, Marca, Venit_locm, CAS, Somaj_5, Fond_de_risc_1, Camera_de_Munca_1, Asig_sanatate_pl_unitate, CCI, Fond_de_garantare, 
		CAS_individual, Somaj_1, Asig_sanatate_din_net, Impozit, Subventie_somaj, Scutire_somaj)
	select b.loc_de_munca, b.marca, 
		(case when abs(n.Venit_total-b.Venit_total)<2 then n.Venit_total else b.Venit_total end),
		(case when n.Venit_total-(bm.CMMarca+0)=0 then 0 when abs(n.Venit_total-b.Venit_total)<2 then n.CAS+n1.CAS
			else round(round((b.Venit_total-(bcm.CMPoz+0))/(n.Venit_total-(bm.CMMarca+0)),6)*(n.CAS+n1.CAS),2) end), 
		(case when n.Venit_total-(bm.CMCasMarca+0)=0 then 0 when abs(n.Venit_Net-b.Venit_total)<2 then n.Somaj_5 
			else round((b.Venit_total-(bcm.CMCasPoz+0))/(n.Venit_total-(bm.CMCasMarca+0))*n.Somaj_5,2) end), 
		(case when n.Venit_total-(bm.CMMarca+0)=0 then 0 when abs(n.Venit_total-b.Venit_total)<2 then n.Fond_de_risc_1
			else round(round((b.Venit_total-(bcm.CMPoz+0))/(n.Venit_total-(bm.CMMarca+0)),6)*n.Fond_de_risc_1,2) end), 
		(case when n.Venit_total-bm.CMCasMarca=0 then 0 when abs(n.Venit_total-b.Venit_total)<2 then n.Camera_de_munca_1
			else round((b.Venit_total-(bcm.CMCasPoz))/(n.Venit_total-(bm.CMCasMarca))*n.Camera_de_munca_1,2) end), 
		(case when n.Venit_total-(bm.CMCasMarca+0)=0 then 0 when abs(n.Venit_total-b.Venit_total)<2 then (n.Asig_sanatate_pl_unitate+isnull(n1.Asig_sanatate_din_impozit,0))
			else round((b.Venit_total-(bcm.CMCasPoz+0))/(n.Venit_total-(bm.CMCasMarca+0))*(n.Asig_sanatate_pl_unitate+isnull(n1.Asig_sanatate_din_impozit,0)),2) end), 
		(case when n.Venit_total-(bm.CMCasMarca+0)=0 then 0 when abs(n.Venit_total-b.Venit_total)<2 then n.Ded_suplim 
			else round((b.Venit_total-(bcm.CMCasPoz+0))/(n.Venit_total-(bm.CMCasMarca+0))*n.Ded_suplim,2) end), 
		(case when n.Venit_total-(bm.CMCasMarca+0)=0 then 0 when abs(n.Venit_total-b.Venit_total)<2 then isnull(n1.Somaj_5,0) 
			else round((b.Venit_total-(bcm.CMCasPoz+0))/(n.Venit_total-(bm.CMCasMarca+0))*isnull(n1.Somaj_5,0),2) end), 
		0, 0, 0, 0, 
		(case when @NCSubvSomaj=1 and n.Chelt_prof<>0 and n.Venit_total-(bm.CMMarca+0)<>0 
			then (case when abs(n.Venit_total-b.Venit_total)<2 then n.Chelt_prof 
				else round(round((b.Venit_total-(bcm.CMPoz+0))/(n.Venit_total-(bm.CMMarca+0)),6)*n.Chelt_prof,2) end) 
			else 0 end), 
		(case when @NCSubvSomaj=1 and isnull(s.Scutire_art80,0)+isnull(s.Scutire_art85,0)<>0 and n.Venit_total-(bm.CMCasMarca+0)<>0 
			then (case when abs(n.Venit_total-b.Venit_total)<2 then isnull(s.Scutire_art80,0)+isnull(s.Scutire_art85,0) 
				else round((b.Venit_total-(bcm.CMCasPoz+0))/(n.Venit_total-(bm.CMCasMarca+0))*(isnull(s.Scutire_art80,0)+isnull(s.Scutire_art85,0)),2) end) 
			else 0 end)
	from #brut b
		left outer join personal p on p.marca=b.marca
		left outer join istpers i on i.Data=b.Data and i.Marca=b.Marca
		left outer join #brutCMMarca bm on bm.Data=b.Data and bm.Marca=b.Marca
		left outer join #brutCM bcm on bcm.Data=b.Data and bcm.Marca=b.Marca and bcm.loc_de_munca=b.loc_de_munca
		left outer join #net n on n.data=b.data and n.marca=b.marca
		left outer join #net n1 on n1.data=dbo.bom(b.data) and n1.marca=b.marca
		left outer join dbo.fScutiriSomaj (@dataJos, @dataSus, '', 'ZZZ', '', 'ZZZ') s on s.Data=b.Data and s.Marca=b.Marca
	where b.data=@dataSus and (@pMarca='' or b.marca=@pMarca)
	
	if @NCTaxePLMCh=1
	Begin
		alter table #CASbrut add baza_impozit float not null default 0

		update cas set 
			CAS_individual=((cas.Venit_locm-bm.CMMarca)+(case when convert(char(1),b.Loc_munca_pt_stat_de_plata)=1 then isnull(n1.Baza_CAS_cond_norm+n1.Baza_CAS_cond_deoseb+n1.Baza_CAS_cond_spec,0) else 0 end))
				*(case when i.Grupa_de_munca<>'O' then @CasIndiv else 0 end)/100, 
			Somaj_1=(case when n.Somaj_1<>0 then (cas.Venit_locm-bm.CMCasMarca)*(case when p.Somaj_1=1 then @SomajInd else 0 end)/100 else cas.Somaj_1 end), 
			Asig_sanatate_din_net=(cas.Venit_locm-bm.CMMarca)*p.As_sanatate/10/100
		from #CASBrut cas
		inner join personal p on p.marca=cas.marca
		inner join #brut b on b.data=@datasus and b.marca=cas.marca and b.loc_de_munca=cas.Loc_de_munca
		inner join #brutCMMarca bm on bm.data=@datasus and bm.marca=cas.marca and bm.data=b.data
		inner join istPers i on i.marca=cas.marca and i.data=b.data
		left outer join #net n on n.data=@datasus and n.marca=cas.marca
		left outer join #net n1 on n.data=@datajos and n.marca=cas.marca

		update cas set 
			baza_impozit=cas.Venit_locm-(cas.CAS_individual+cas.Somaj_1+cas.Asig_sanatate_din_net)-(case when convert(char(1),b.Loc_munca_pt_stat_de_plata)=1 then n.Ded_baza else 0 end)
		from #CASBrut cas
		inner join #brut b on b.marca=cas.marca and b.loc_de_munca=cas.Loc_de_munca
		left outer join #net n on n.data=@datasus and n.marca=cas.marca

		update #CASBrut set 
			Impozit=dbo.fCalcul_impozit_salarii(baza_impozit, 0, impozit)
	end
	insert into CASbrut 
		(Loc_de_munca, Marca, Venit_locm, CAS, Somaj_5, Fond_de_risc_1, Camera_de_Munca_1, 
		Asig_sanatate_pl_unitate, CCI, Fond_de_garantare, CAS_individual, Somaj_1, Asig_sanatate_din_net,  
		Impozit, Subventie_somaj, Scutire_somaj)
	select Loc_de_munca, Marca, Venit_locm, CAS, Somaj_5, Fond_de_risc_1, Camera_de_Munca_1, 
		Asig_sanatate_pl_unitate, CCI, Fond_de_garantare, CAS_individual, Somaj_1, Asig_sanatate_din_net,  
		Impozit, Subventie_somaj, Scutire_somaj from #CASbrut
	select * into #config_nc_ch from config_nc

	/*	Generare nota contabila de cheltuieli. */
	CREATE TABLE dbo.#tmpCheltuieli
		(Data datetime, TipSuma varchar(30), Marca varchar(6), lm varchar(9), Suma float, Indicator varchar(20), Explicatii varchar(1000), Numar varchar(10), idpoz int) 

	insert into #tmpCheltuieli
	exec calculOrdonantariSalarii @dataJos=@dataJos, @dataSus=@dataSus, @marca=@pmarca, @tipCalcul=5

	select a.Data, a.TipSuma, a.marca, a.lm as loc_de_munca, c.Cont_debitor as Cont_debitor, c.Cont_creditor as Cont_creditor, 
		a.Suma as suma, a.Explicatii, c.numar_pozitie as numar_pozitie
	into #nc_cheltuieli
	from #tmpCheltuieli a
		left outer join net n on n.data=a.data and n.marca=a.marca
		left outer join net n1 on n1.data=dbo.BOM(a.data) and n1.marca=a.marca
		left outer join istPers i on i.data=a.data and i.marca=a.marca
		outer apply (select * from #config_nc_ch c where c.Identificator=a.TipSuma and (a.lm like RTRIM(c.Loc_de_munca)+'%' 
			or c.Loc_de_munca is null and not exists (select 1 from #config_nc_ch c1 where a.lm like RTRIM(c1.Loc_de_munca)+'%'))) c
		left outer join dbo.fScutiriSomaj (@dataJos, @dataSus, '', 'ZZZ', '', 'ZZZ') s on s.Data=a.Data and s.Marca=a.Marca

	if @DebitCMUnitate2<>''
		insert into #nc_cheltuieli 
			(data, tipSuma, marca, loc_de_munca, cont_debitor, cont_creditor, suma, explicatii, numar_pozitie)
		select data, tipSuma, marca, loc_de_munca, @DebitCMCas2, @CreditCMCas2, suma, explicatii, numar_pozitie
		from #nc_cheltuieli
		where tipSuma='CMUNITATE'

	if @DebitCMCas2<>''
	begin
		insert into #nc_cheltuieli 
			(data, tipSuma, marca, loc_de_munca, cont_debitor, cont_creditor, suma, explicatii, numar_pozitie)
		select data, tipSuma, marca, loc_de_munca, @DebitCMCas2, @CreditCMCas2, suma, explicatii, numar_pozitie
		from #nc_cheltuieli
		where tipSuma='CMFNUASS'

		insert into #nc_cheltuieli 
			(data, tipSuma, marca, loc_de_munca, cont_debitor, cont_creditor, suma, explicatii, numar_pozitie)
		select data, tipSuma, marca, loc_de_munca, @DebitCMCas2, @CreditCMCas2, suma, explicatii, numar_pozitie
		from #nc_cheltuieli
		where tipSuma='CORECTIA-R'
	end

	if exists (select * from sysobjects where name ='GenNCCheltLMBugSP1')
		exec GenNCCheltLMBugSP1 @dataJos=@dataJos, @dataSus=@dataSus, @pMarca=@pMarca, @Continuare=@Continuare output, @NrPozitie=@NrPozitie output, @NumarDoc=@NumarDoc

	insert into #docPozncon 
		(Subunitate, Tip, Numar, Data, Cont_debitor, Cont_creditor, Suma, Explicatii, Nr_pozitie, Loc_munca, Comanda, Jurnal)
	select @Sub, 'PS', @NumarDoc, nc.Data, nc.Cont_debitor, nc.Cont_creditor, sum(nc.Suma) as suma, rtrim(nc.Explicatii)+' - '+rtrim(nc.loc_de_munca), 
		(case when @NrPozitie=1 then 0 else @NrPozitie end)+ROW_NUMBER() over(order by nc.loc_de_munca, max(nc.numar_pozitie), nc.Cont_debitor, nc.Cont_creditor), nc.Loc_de_munca, '', ''
	from #nc_cheltuieli nc
		INNER JOIN conturi c on c.Subunitate=@sub and c.cont=nc.Cont_creditor and (case when c.sold_credit>10 then 0 else c.sold_credit end)=0
	group by nc.Data, nc.Loc_de_munca, nc.Cont_debitor, nc.Cont_creditor, nc.Explicatii
	having sum(Suma)<>0

	insert into #docPozadoc 
		(Subunitate, Numar_document, Data, Tert, Tip, Factura_stinga, Factura_dreapta, Cont_deb, Cont_cred, Suma, TVA11, TVA22, 
		Numar_pozitie, Explicatii, Loc_munca, Comanda, Data_fact, Data_scad, Jurnal)
	select @Sub, rtrim(@NumarDoc)+convert(char(3),ROW_NUMBER() over(order by nc.marca)), 
		nc.Data, 'M'+rtrim(nc.Marca), 'FF', '', @NumarDoc, nc.Cont_debitor, nc.Cont_creditor, sum(nc.Suma) as suma, 0, 0, 
		(case when @NrPozitie=1 then 0 else @NrPozitie end)+ROW_NUMBER() over(order by nc.loc_de_munca, max(nc.numar_pozitie), nc.Cont_debitor, nc.Cont_creditor), 
		rtrim(nc.Explicatii)+' - '+rtrim(nc.loc_de_munca), nc.Loc_de_munca, '' as comanda, nc.data, nc.data, ''
	from #nc_cheltuieli nc
		INNER JOIN conturi c on c.Subunitate=@sub and c.cont=nc.Cont_creditor and (case when c.sold_credit>10 then 0 else c.sold_credit end)=1
	group by nc.Data, nc.marca, nc.Loc_de_munca, nc.Cont_debitor, nc.Cont_creditor, nc.Explicatii
	having sum(Suma)<>0

	select @NrPozitie=isnull(max(Nr_pozitie),0)+1 from #docPozncon

	exec completareNCsalarii @dataJos=@dataJos, @dataSus=@dataSus, @NumarDoc=@NumarDoc
End try

begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura GenNCCheltLMBug (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch

/*
	exec GenNCCheltLMBug '02/01/2011', '02/28/2011', '', 1, 309014
*/