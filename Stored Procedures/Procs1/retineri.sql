--***
/**	procedura lista retineri 
	@nOrdonare=2 -> nume
	@nOrdonare=1 -> marca
	@nGrupare=1 -> Tipuri si beneficiari
	@nGrupare=2 -> Locuri de munca
	@nGrupare=2 -> Salariati
**/
Create 
procedure retineri 
	@marcaJos char(6), @marcaSus char(6), @dataJos datetime, @dataSus datetime, @lmJos char(9), @lmSus char(9), @benefJos char(13), @benefSus char(13), 
	@nRetla int, @cTipla char(1), @unSubtipret int, @cSubtipret char(1), @unTipret int, @cTipret char(1), @nGrupare int, @nOrdonare int
as
Begin
	declare @detret int, @tLmJos int, @lMarcaJos int, @lBenefJos int 
	set @tLmJos=(case when isnull(@lmJos,'')<>'' then 1 else 0 end)
	set @lMarcaJos=(case when isnull(@marcaJos,'')<>'' then 1 else 0 end)
	set @lBenefJos=(case when isnull(@benefJos,'')<>'' then 1 else 0 end)
	Set @detret = isnull((select val_logica from par where tip_parametru='PS' and parametru='SUBTIPRET'),0)

	declare @utilizator varchar(20)

	SET @utilizator = dbo.fIaUtilizator(null)
	IF @utilizator IS NULL
		RETURN -1

	select r.Data, r.marca, r.cod_beneficiar, r.Numar_document, r.Data_document, r.Valoare_totala_pe_doc, r.Valoare_retinuta_pe_doc, 
	r.Retinere_progr_la_avans, r.Retinere_progr_la_lichidare, r.procent_progr_la_lichidare, r.Retinut_la_avans, r.Retinut_la_lichidare, 
	isnull(rc.Retinere_progr_la_avans,0) as Numar_chitanta, isnull(rc.Retinut_la_lichidare,0) as Valoare_chitanta, 
	p.nume, p.salar_de_incadrare, convert (int,p.loc_ramas_vacant) as loc_ramas_vacant, 
	isnull(n.loc_de_munca,p.loc_de_munca) as loc_de_munca, isnull(n.Venit_Net,0) as venit_net, 
	r.Retinere_progr_la_lichidare+round((case when substring(b.Cod_fiscal,10,1)='2' then isnull(n.Venit_Net,0) 
	else p.salar_de_incadrare end)*r.procent_progr_la_lichidare/100,0) as retinere_cu_procent,
	(case when r.Valoare_totala_pe_doc=r.Valoare_retinuta_pe_doc then 0 else 
	r.Retinere_progr_la_avans+r.retinere_progr_la_lichidare+round((case when substring(b.Cod_fiscal,10,1)='2' then isnull(n.Venit_Net,0) 
	else p.salar_de_incadrare end)*r.procent_progr_la_lichidare/100,0)-r.retinut_la_avans-r.Retinut_la_lichidare end) as diferenta,
	(case when r.Valoare_totala_pe_doc>0 then r.Valoare_totala_pe_doc-r.Valoare_retinuta_pe_doc else 0 end) as valoare_ramasa,
	b.tip_retinere, b.denumire_beneficiar, b.Obiect_retinere, b.Cod_fiscal, b.banca, b.cont_banca, e.Val_inf, e.Data_inf, 
	f.subtip, f.denumire as denumire_subtip, f.tip_retinere as tip_retinere_din_tipret, f.obiect_subtip_retinere,
	lm.denumire as denumire_lm, (case when r1.afisat<>0 then 1 else 0 end) as afisat, 
	(case when r2.se_afiseaza<>0 then 1 else 0 end) as se_afiseaza,
	(case when @ngrupare=1 then r.cod_beneficiar else '' end) as Ordonare_codb1,
	(case when @ngrupare=2 then r.cod_beneficiar else '' end) as Ordonare_codb2, 
	(case when @ngrupare=2 then isnull(n.loc_de_munca,p.loc_de_munca) else '' end) as Ordonare_lm,
	(case when @ngrupare=1 then (case when @detret=1 then f.tip_retinere+f.subtip else b.Tip_retinere end) else '' end) as Ordonare_tip_retinere,
	(case when @detret=1 then f.tip_retinere else b.tip_retinere end) as tip_retinere_grup, dr.Denumire_tip,
	(case when @detret=0 then b.tip_retinere else f.subtip end) as tip_subtip, 
	RANK () over (PARTITION by r.Cod_beneficiar, r.marca, r.numar_document order by r.data desc) as nr_ordine
	from resal r  
		left outer join personal p on r.marca=p.marca
		left outer join net n on r.data=n.data and r.marca=n.marca 
		left outer join benret b on r.cod_beneficiar=b.cod_beneficiar  
		left outer join extinfop e on r.marca=e.marca and e.cod_inf='CONT2' and e.val_inf<>''
		left outer join tipret f on b.tip_retinere=f.subtip 
		left outer join lm on n.loc_de_munca=lm.cod 
		left outer join fTip_retineri (1) dr on dr.Tip_retinere=b.Tip_retinere
		left outer join (select x.loc_de_munca, sum(y.Retinere_progr_la_avans+y.retinere_progr_la_lichidare-y.retinut_la_avans-y.Retinut_la_lichidare) as afisat 
			from resal y
			left outer join net x on y.marca=x.marca and y.data=x.data group by x.loc_de_munca) r1 on r1.loc_de_munca=isnull(n.loc_de_munca,p.loc_de_munca)
		left outer join (select cod_beneficiar, sum(Retinere_progr_la_avans+retinere_progr_la_lichidare-retinut_la_avans-Retinut_la_lichidare) as se_afiseaza from resal 
			group by cod_beneficiar) r2 on r2.cod_beneficiar=r.cod_beneficiar 
		left outer join resal rc on rc.data=DateAdd(year,1000,r.Data) and rc.Marca=r.Marca and rc.Cod_beneficiar=r.Cod_beneficiar and rc.Numar_document=r.Numar_document
	where r.data between @dataJos and @dataSus and (@lMarcaJos=0 or r.marca=@marcaJos) 
		and (@tLmJos=0 or (isnull(n.loc_de_munca,p.loc_de_munca) like rtrim(@lmJos)+'%'))
		and (@lBenefJos=0 or r.cod_beneficiar=@benefJos) 
		and (@nRetla=0 or @cTipla='A' and r.retinut_la_avans<>0 or @cTipla='L' and r.retinut_la_lichidare<>0) 
		and (not(@detret=1 and @unSubtipret=1) or b.tip_retinere=isnull(@cSubtipret,'')) 
		and (not(not(@detret=1) and @unTipret=1) or b.tip_retinere=@cTipret) 
		and (not(@detret=1 and @unTipret=1) or f.tip_retinere=@cTipret)
		and (dbo.f_areLMFiltru(@utilizator)=0 or exists (select 1 from lmfiltrare l where l.utilizator=@utilizator and l.cod=isnull(n.loc_de_munca,p.loc_de_munca)))
	order by Ordonare_lm, Ordonare_tip_retinere, Ordonare_codb1, (case when @nordonare=2 then p.nume else r.marca end), Ordonare_codb2, r.numar_document, r.data
End
