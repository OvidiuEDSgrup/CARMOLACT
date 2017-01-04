--***
create procedure inregDocMF @sesiune varchar(50), @parXML xml 
as
declare @Sub char(9), @invamreev int, @ctrezrep varchar(40)
exec luare_date_par 'GE', 'SUBPRO', 0, 0, @Sub output
exec luare_date_par 'MF', 'INVCTREEV', @invamreev output, 0, ''
exec luare_date_par 'MF', 'CTREZREP', 0, 0, @ctrezrep output

begin try
	IF OBJECT_ID('tempdb..#pozdocMF') IS NOT NULL
		drop table #pozdocMF
	/*	pun conturile specifice MF in tabela temporara, doar aici ca sa nu mai modific inregDoc. Daca e ok asa poate ar fi bine sa le mutam si restul din inregDoc */
	select p.idPozdoc, 
		nullif(p.detalii.value('(/row/@contpatrimiesire)[1]','varchar(40)'),'') as ContPatrimIesire, 
		nullif(p.detalii.value('(/row/@contpatrimintrare)[1]','varchar(40)'),'') as ContPatrimIntrare,
		nullif(p.detalii.value('(/row/@contvenitpatrim)[1]','varchar(40)'),'') as contvenitpatrim,
		nullif(c.detalii.value('(/row/@indicator)[1]','varchar(40)'),'') as indbugContStoc,
		isnull(p.detalii.value('(/row/@valinv)[1]','decimal(12,2)'),0) as valinv,
		isnull(p.detalii.value('(/row/@valam)[1]','decimal(12,2)'),0) as valam,
		isnull(p.detalii.value('(/row/@valam8045)[1]','decimal(12,2)'),0) as valam8045 
	into #pozdocMF
	from pozdoc p
		inner join #pozdoc pd on pd.idPozdoc=p.idPozdoc
		left outer join conturi c on c.subunitate=@sub and c.cont=p.Numar_dvi
	where p.tip in ('AI','AP') and p.Jurnal='MFX'

	/*	
		Inregistrarea de baza pentru AI-uri 
	*/
	insert into #pozincon(TipInregistrare,Subunitate, Tip, Numar, Data, Valuta, Curs, Suma_valuta, Utilizator, Loc_de_munca, Comanda, Jurnal,Cont_debitor, Cont_creditor, Suma, Explicatii, Data_operarii, Ora_operarii, Indbug)
	select 'IMF',p.subunitate,p.tip,p.numar,p.data,p.valuta,p.curs,sum(round(convert(decimal(17,5),p.cantitate*p.PretFurnizorValuta),2)),max(p.utilizator),p.loc_de_munca,p.comanda,p.jurnal,
	(case when p.factura='MRE' and sum(p.cantitate*p.Pret_de_stoc)<0 and @invamreev=0 then p.ContCorespondentIntrare else isnull(nullif(pmf.ContPatrimIesire,''),p.Cont_de_stoc) end),
	(case when p.factura='MRE' and sum(p.cantitate*p.Pret_de_stoc)<0 and @invamreev=0 then p.Cont_de_stoc else p.ContCorespondentIntrare end),
	sum(round(convert(decimal(17,5),p.cantitate*(case when p.factura='MRE' and p.cantitate*p.pret_de_stoc<0 and @invamreev=0 then -1 else 1 end)
		*(case when p.factura='MTP' and 1=0 then p.ValAmortizata else p.Pret_de_stoc-(case when p.factura='MTP' then p.ValAmortizata else 0 end) end))
		-(case when p.factura='MRE' and @invamreev=1 then p.ValAmortizata else 0 end),2)) as valoare,
	isnull(max(p.explicatiidindetalii),isnull(max(p.explicatii_old),max(n.denumire))) as explicatii,
	max(p.data_operarii), max(p.ora_operarii), p.indbug
	from #pozdoc p
		inner join nomencl n on p.cod=n.cod
		left outer join #pozdocMF pmf on pmf.idPozdoc=p.idPozdoc
	where p.tip='AI' and p.jurnal='MFX'
	group by p.subunitate,p.tip,p.numar,p.data,p.loc_de_munca,p.comanda,p.valuta,p.curs,
		p.factura,p.Cont_de_stoc,isnull(nullif(pmf.ContPatrimIesire,''),p.Cont_de_stoc),p.ContCorespondentIntrare,p.valuta,p.curs,p.jurnal,p.indbug

	/*	
		Inregistrarea pentru intrarea in patrimoniu Privat/Public aferenta documentelor de tip MTP (modificare tip patrimoniu).
		La MTP (trecere din public in privat in campul p.ValAmortizata este valoarea amortizata - valoarea amortizata 8045.
	*/
	insert into #pozincon(TipInregistrare,Subunitate, Tip, Numar, Data, Valuta, Curs, Suma_valuta, Utilizator, Loc_de_munca, Comanda, Jurnal,Cont_debitor, Cont_creditor, Suma, Explicatii, Data_operarii, Ora_operarii, Indbug)
	select 'IMF',p.subunitate,p.tip,p.numar,p.data,p.valuta,p.curs,sum(round(convert(decimal(17,5),p.cantitate*p.PretFurnizorValuta),2)),max(p.utilizator),p.loc_de_munca,p.comanda,p.jurnal,
	p.Cont_de_stoc,	pmf.ContPatrimIntrare,
	sum(round(convert(decimal(17,5),p.cantitate*p.Pret_de_stoc-(case when pmf.valinv=pmf.valam then p.ValAmortizata else (p.Pret_de_stoc-pmf.valam) end)),2)) as valoare,
	isnull(max(p.explicatiidindetalii),isnull(max(p.explicatii_old),max(n.denumire))) as explicatii,
	max(p.data_operarii), max(p.ora_operarii), p.indbug
	from #pozdoc p
		inner join nomencl n on p.cod=n.cod
		left outer join #pozdocMF pmf on pmf.idPozdoc=p.idPozdoc
	where p.tip='AI' and p.jurnal='MFX' and p.Factura='MTP' and nullif(pmf.ContPatrimIntrare,'') is not null
	group by p.subunitate,p.tip,p.numar,p.data,p.loc_de_munca,p.comanda,p.valuta,p.curs,
		p.factura,p.Cont_de_stoc,pmf.ContPatrimIntrare,p.valuta,p.curs,p.jurnal,p.indbug

	/*	Intrari - inregistrari din inregAI */
	/*	
		Val. amortizata pt. mfixe 
	*/
	insert into #pozincon (TipInregistrare, Subunitate, Tip, Numar, Data, Valuta, Curs, Suma_valuta, Utilizator, Loc_de_munca, Comanda, Jurnal, 
		Cont_debitor, Cont_creditor, Suma, Explicatii, Data_operarii, Ora_operarii, Indbug)
	select 'MFIAM', p.Subunitate, p.Tip, p.Numar, p.Data, '', 0, 0, max(p.utilizator), p.Loc_de_munca, p.Comanda, p.jurnal,
		(case when p.Factura='MRE' and @invamreev=1 then p.Cont_corespondent 
			when p.Factura='MTP' and sum(p.ValAmortizata)<>0 then p.Cont_de_stoc else p.gestiune_primitoare end), 
		(case when p.Factura='MRE' and @invamreev=1 then p.gestiune_primitoare else p.Cont_factura end), 
		sum(round(convert(decimal(17,5),(case when p.factura='MRE' and @invamreev=1 then -1 else 1 end)*p.ValAmortizata),2)) as valoare, 
		'Val. amortizata', max(p.data_operarii), max(p.ora_operarii), p.Indbug
	from #pozdoc p
		inner join nomencl n on n.cod=p.cod and n.Tip='F'
	where p.tip='AI' and p.ValAmortizata<>0 and p.jurnal='MFX'
		and not (p.Factura='MTP' and p.ValAmortizata=0)
	group by p.subunitate,p.tip,p.numar,p.data,p.loc_de_munca,p.comanda,p.valuta,p.curs,
		p.factura,p.Cont_de_stoc,p.Cont_corespondent,p.gestiune_primitoare,p.Cont_factura,p.numar_dvi,p.jurnal,p.indbug

	/*	
		Inregistrarea pentru valoarea neamortizata aferenta mijloacelor fixe trecute din patrimoniu public in privat (documente de tip MTP).
		Aceasta valoare este inregistratata pe contul de venit operat in macheta.
	*/
	insert into #pozincon(TipInregistrare,Subunitate, Tip, Numar, Data, Valuta, Curs, Suma_valuta, Utilizator, Loc_de_munca, Comanda, Jurnal,Cont_debitor, Cont_creditor, Suma, Explicatii, Data_operarii, Ora_operarii, Indbug)
	select 'IMF',p.subunitate,p.tip,p.numar,p.data,p.valuta,p.curs,0,max(p.utilizator),p.loc_de_munca,p.comanda,p.jurnal,
	p.Cont_de_stoc,	pmf.contvenitpatrim,
	sum(round(convert(decimal(17,5),pmf.valinv-pmf.valam),2)) as valoare,
	isnull(max(p.explicatiidindetalii),isnull(max(p.explicatii_old),max(n.denumire))) as explicatii,
	max(p.data_operarii), max(p.ora_operarii), p.indbug
	from #pozdoc p
		inner join nomencl n on p.cod=n.cod
		inner join #pozdocMF pmf on pmf.idPozdoc=p.idPozdoc and pmf.valinv<>pmf.valam
	where p.tip='AI' and p.jurnal='MFX' and p.Factura='MTP' and nullif(pmf.contvenitpatrim,'') is not null
	group by p.subunitate,p.tip,p.numar,p.data,p.loc_de_munca,p.comanda,p.valuta,p.curs,
		p.factura,p.Cont_de_stoc,pmf.contvenitPatrim,p.valuta,p.curs,p.jurnal,p.indbug
	
	/*	
		rezultat reportat am. istorica mfixe 
	*/
	insert into #pozincon (TipInregistrare, Subunitate, Tip, Numar, Data, Valuta, Curs, Suma_valuta, Utilizator, Loc_de_munca, Comanda, Jurnal, 
		Cont_debitor, Cont_creditor, Suma, Explicatii, Data_operarii, Ora_operarii, Indbug)
	select 'MFREZREP', p.Subunitate, p.Tip, p.Numar, p.Data, '', 0, 0, max(p.utilizator), p.Loc_de_munca, p.Comanda, p.jurnal,
		p.tert, 
		p.Cont_venituri, 
		sum(round(convert(decimal(17,5),p.RezerveReevaluare*(case when p.Tert like '482%' and p.RezerveReevaluare>0 then p.Cantitate 
			when left(p.tert,3)='105' and p.RezerveReevaluare<0 then -1 else 1 end)),2)) as valoare, 
		'Rezerve din reev. sau ajustari', max(p.data_operarii), max(p.ora_operarii), p.Indbug
	from #pozdoc p
		inner join nomencl n on n.cod=p.cod and n.Tip='F'
	where p.tip='AI' and p.RezerveReevaluare<>0 and p.jurnal='MFX' 
		and p.tert<>'' and p.Cont_venituri<>''
	group by p.subunitate,p.tip,p.numar,p.data,p.loc_de_munca,p.comanda,p.valuta,p.curs,
		p.Tert,p.Cont_venituri,p.jurnal,p.indbug


	/*	Iesiri - inregistrari din inregAE / inregAvize */
	/*	
		Val. amortizata pt. mfixe 
	*/
	insert into #pozincon (TipInregistrare, Subunitate, Tip, Numar, Data, Valuta, Curs, Suma_valuta, Utilizator, Loc_de_munca, Comanda, Jurnal, 
		Cont_debitor, Cont_creditor, Suma, Explicatii, Data_operarii, Ora_operarii, Indbug)
	select 'MFDAM', p.Subunitate, p.Tip, p.Numar, p.Data, '', 0, 0, max(p.utilizator), p.Loc_de_munca, p.Comanda, p.jurnal,
		p.gestiune_primitoare, 
		(case when p.tip='AI' and p.Factura='MTP' then p.cont_corespondent else p.numar_dvi end), 
		sum(round(convert(decimal(17,5),p.ValAmortizata),2)) as valoare, 
		'Stornare amortizare', max(p.data_operarii), max(p.ora_operarii), isnull(nullif(pmf.indbugContStoc,''),p.Indbug)
	from #pozdoc p
		inner join nomencl n on n.cod=p.cod and n.Tip='F'
		left outer join #pozdocMF pmf on pmf.idPozdoc=p.idPozdoc
	where (p.tip in ('AE','AP') or p.tip='AI' and p.Factura='MTP') and p.ValAmortizata<>0 and p.jurnal='MFX'
	group by p.subunitate,p.tip,p.numar,p.data,p.loc_de_munca,p.comanda,p.valuta,p.curs,
		p.gestiune_primitoare,(case when p.tip='AI' and p.Factura='MTP' then p.cont_corespondent else p.numar_dvi end),p.jurnal,isnull(nullif(pmf.indbugContStoc,''),p.Indbug)
	
	/*	
		rezultat reportat am. istorica mfixe (Alte iesiri si Avize) 
	*/
	insert into #pozincon (TipInregistrare, Subunitate, Tip, Numar, Data, Valuta, Curs, Suma_valuta, Utilizator, Loc_de_munca, Comanda, Jurnal, 
		Cont_debitor, Cont_creditor, Suma, Explicatii, Data_operarii, Ora_operarii, Indbug)
	select 'MFREZREP', p.Subunitate, p.Tip, p.Numar, p.Data, '', 0, 0, max(p.utilizator), p.Loc_de_munca, p.Comanda, p.jurnal,
		p.ContMFIstoric, 
		(case when p.tip='AP' or p.factura='ESU' then p.ContCorespMF else isnull(nullif(ContCorespMF,''),@ctrezrep) end), 
		sum(round(convert(decimal(17,5),p.RezerveReevaluare),2)) as valoare, 
		'Rezerve reev.sau rezultat rep.', max(p.data_operarii), max(p.ora_operarii), p.Indbug
	from #pozdoc p
		inner join nomencl n on n.cod=p.cod and n.Tip='F'
	where (p.tip='AP' and @ctrezrep<>'' or p.tip='AE' and (@ctrezrep<>'' or p.factura='ESU'))
		and p.RezerveReevaluare<>0 and p.jurnal='MFX' 
	group by p.subunitate,p.tip,p.numar,p.data,p.loc_de_munca,p.comanda,p.valuta,p.curs,
		p.factura,p.ContMFIstoric,p.ContCorespMF,p.Cont_venituri,p.jurnal,p.indbug

	/*	Intrari / iesiri - Aceasta inregistrare este preluata din AI si AE. Se inverseaza doar conturile */
	/*	
		rezerve mfixe ct. 106 
	*/
	insert into #pozincon (TipInregistrare, Subunitate, Tip, Numar, Data, Valuta, Curs, Suma_valuta, Utilizator, Loc_de_munca, Comanda, Jurnal, 
		Cont_debitor, Cont_creditor, Suma, Explicatii, Data_operarii, Ora_operarii, Indbug)
	select 'MFREZ106', p.Subunitate, p.Tip, p.Numar, p.Data, '', 0, 0, max(p.utilizator), p.Loc_de_munca, p.Comanda, p.jurnal,
		(case when p.tip='AI' then p.Cont_corespondent else @ctrezrep end), 
		(case when p.tip='AI' then @ctrezrep else p.Cont_corespondent end),
		sum(round(convert(decimal(17,5),p.cantitate*p.pret_amanunt_predator),2)) as valoare, 'Rezerve', max(p.data_operarii), max(p.ora_operarii), p.Indbug
	from #pozdoc p
		inner join nomencl n on n.cod=p.cod and n.Tip='F'
	where p.tip in ('AI','AE') and p.pret_amanunt_predator<>0 and p.jurnal='MFX'
	group by p.subunitate,p.tip,p.numar,p.data,p.loc_de_munca,p.comanda,p.valuta,p.curs,
		p.Cont_corespondent,p.jurnal,p.indbug

	/*	Intrari / iesiri - Aceasta inregistrare este preluata din AI, AE, AP. Se inverseaza doar conturile */
	/*	
		amortizare cls. 8 pt. mfixe. Aici am tratat si iesirile prin AP. 
	*/
	insert into #pozincon (TipInregistrare, Subunitate, Tip, Numar, Data, Valuta, Curs, Suma_valuta, Utilizator, Loc_de_munca, Comanda, Jurnal, 
		Cont_debitor, Cont_creditor, Suma, Explicatii, Data_operarii, Ora_operarii, Indbug)
	select 'MFAMCL8', p.Subunitate, p.Tip, p.Numar, p.Data, '', 0, 0, max(p.utilizator), p.Loc_de_munca, p.Comanda, p.jurnal,
		(case when p.tip='AI' then p.ContMF8045 else '' end), 
		(case when p.tip in ('AE','AP') then p.ContMF8045 else '' end), 
		sum(round(convert(decimal(17,5),(case when p.Factura='MEP' and p.AmortGradNeutiliz<0 then -1 else 1 end)*p.AmortGradNeutiliz),2)) as valoare, 
		'Amortizare af. grd. neutilizare', max(p.data_operarii), max(p.ora_operarii), p.Indbug
	from #pozdoc p
		inner join nomencl n on n.cod=p.cod and n.Tip='F'
	where p.tip in ('AI','AE','AP') and LEFT(p.ContMF8045,1)='8' and p.AmortGradNeutiliz<>0 and p.jurnal='MFX'
	group by p.subunitate,p.tip,p.numar,p.data,p.loc_de_munca,p.comanda,p.valuta,p.curs,
		p.ContMF8045,p.jurnal,p.indbug

	/* 
		Val. amortizata pt. obiecte de inventar returnate din gestiune de imobilizari 
	*/
	insert into #pozincon (TipInregistrare, Subunitate, Tip, Numar, Data, Valuta, Curs, Suma_valuta, Utilizator, Loc_de_munca, Comanda, Jurnal, 
		Cont_debitor, Cont_creditor, Suma, Explicatii, Data_operarii, Ora_operarii, Indbug)
	select 'MFDAM', p.Subunitate, p.Tip, p.Numar, p.Data, '', 0, 0, max(p.utilizator), p.Loc_de_munca, p.Comanda, p.jurnal,
		p.ContAm, 
		p.Cont_de_stoc, 
		sum(round(convert(decimal(17,5),p.ValAmortizata),2)) as valoare, 
		'Stornare amortizare', max(p.data_operarii), max(p.ora_operarii), p.Indbug
	from #pozdoc p
	where p.tip='TE' and p.Subtip='TR' and p.ContAm is not null
	group by p.subunitate,p.tip,p.numar,p.data,p.loc_de_munca,p.comanda,p.valuta,p.curs,
		p.Cont_de_stoc,p.ContAm,p.jurnal,p.indbug

	if exists (select 1 from sysobjects where [type]='P' and [name]='inregDocMFSP2')
		exec inregDocMFSP2 @sesiune=@sesiune, @parXML=@parXML
	
end try

begin catch
	declare @mesaj varchar(500)
	set @mesaj = ERROR_MESSAGE() + ' (inregDocMF)'
	raiserror(@mesaj, 11, 1)
end catch
