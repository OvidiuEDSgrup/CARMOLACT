--***
CREATE procedure rapReceptiiSosiriFacturi
/**	Procedura folosita de rapoartele de documente: CG\Stocuri : Receptii, Avize, Transferuri si Intrari iesiri
	exemplu apel:
		exec rapReceptiiSosiriFacturi @datajos='2015-1-1', @datasus='2015-12-31', @detalii=0
			, @nivel1='GE', @nivel2='TE'
*/
		(@sesiune varchar(50)=null,@datajos datetime,@datasus datetime,
				@detalii int=1,	--> 1=in detalii datele vin asa cum sunt in pozdoc, 2=doar gruparile superioare, 3=grupat pe document
				@tipRaport varchar(200)='Avize',	--> Avize, Receptii sau Intrari iesiri
				@ordonare int=1,	--> 1=cod/tip & numar & data, 2=denumire/data & tip & numar, Z-{1,2} = valoare
				@top int=null,		--> daca sa apara primele @top grupari superioare
				@nrmaximdetalii bigint=100000,	--> numarul maxim de randuri returnat (pentru a evita timpul indelungat de asteptare); daca este 0 se considera ca este nelimitat
				@Nivel1 varchar(2)='GE', @Nivel2 varchar(2)='TE', @Nivel3 varchar(2)=null, @Nivel4 varchar(2)=null, @Nivel5 varchar(2)=null,	--> nivelele de centralizare
				/*	Grupari  - lista alfabetica a codificarilor:
					GE	= Gestiune
					TE	= Tert
					
					Deocamdata doar nivel1 si nivel2 au efect, restul le-am lasat ca poate ne vor trebui
					--*/
			--> filtrele, in ordine alfabetica (va rog) pt ca sunt prea multe:
				@cod varchar(50)=null, @codintrare varchar(100)=null, @comanda varchar(50)=null,
				@comanda_beneficiar varchar(50)=null,
				@contCor varchar(40)=null, @contFactura varchar(40)=null, @contvenituri varchar(40)=null, @ctstoc varchar(100)=null,
				@factura varchar(50)=null, @Furnizor varchar(20)=null, -->@furnizor = filtru pe furnizorul documentului de intrare
				@furnizor_nomenclator varchar(30)=null,
				@gestiune varchar(50)=null, @gestiuneprim varchar(50)=null, @greutate bit=0, --> daca sa apara greutatea
				@grupa varchar(20)=null,	--> filtru pe grupa de nomenclator
				@grupaTerti varchar(20)=null,
				@indicator varchar(20)=null,
				@lm varchar(50)=null,
				@locatia varchar(30)=null,
				@lot varchar(200)=null,
				@nrdoc varchar(200)=null,	--> filtru pe numar document
				@puncteLivrare bit=0,	--> daca @puncteLivrare=1 gruparile pe terti vor fi de fapt grupari pe terti + puncte livrare
				@pret_cu_amanuntul bit=0,
				@stare_comanda varchar(1)= null,	--> stare comenzi de productie: [L]ansata, [P]regatire, [I]nchisa, A[N]ulata, [B]locata
				@tert varchar(50)=null, 
				@tip_doc_str varchar(1000)=',AP,AC,AS,',	--> tipurile de documente concatenate, setat default pentru avize
				@tipArticole varchar(1000)='',	--> tipuri articole:	ST=Stocabile, SE=Servicii, sau tipurile de nomenclator "consacrate"
				@tipTert varchar(1)=null,	--> I=0=intracomunitar, U=1=UE, E=2=Extern
				@valneg bit=0,		--> daca sa aduca doar pozitiile de stornare, adica valoarea sa fie negativa; folosit in Avize
				@valuta varchar(20)=null,	--> null =  fara filtrare pe valuta, '' = doar valute, completat = valuta completata
				@umalt varchar(200)=null,	--> daca se completeaza:	se recalculeaza cantitatile, fara a afecta valorile, folosind coeficientul de conversie din nomenclator;
													-->		pentru codurile de nomenclator care nu au respectiva unitate de masura se va pune cantitate 0
				@inPretCost int=0 --> Sa apara pretul de cost in loc de pretul de stoc
				,@stareAviz int=0 --> stare aviz: null, 0=toate, 1="Facturate", 2="Nefacturate" prin alte documente
										--> daca @stareAviz<>"toate" automat se aplica filtrarea pe cont 408/418 - in functie de tip receptii / avize
				,@jurnal varchar(20)=null)
as

declare @eroare varchar(max)
begin try
set transaction isolation level read uncommitted

	if object_id('tempdb..#pozitii_RSF') is not null drop table #pozitii_RSF
	
	declare @nr_randuri bigint, @cSub varchar(20), @utilizator varchar(20), @eLmUtiliz int, @eGestUtiliz int
	select @cSub=val_alfanumerica from par where Tip_parametru='GE' and Parametru='SUBPRO'
	
	select @grupa=@grupa+(case when isnull((select val_logica from par where tip_parametru='GE' and parametru='GRUPANIV'),0)=1 then '%' else '' end)
			,@lm=@lm+'%'
			,@eLmUtiliz=0
	
	select @utilizator=dbo.fIaUtilizator(@sesiune), @eLmUtiliz=0, @eGestUtiliz=0
	if isnull(@utilizator,'')='' raiserror('Utilizatorul nu a fost identificat!',15,1)
	select @eLmUtiliz=1 from lmfiltrare where utilizator=@utilizator
	select @eGestUtiliz=1 from fPropUtiliz(@sesiune) where valoare<>'' and cod_proprietate='GESTIUNE'
	
	declare @GestUtiliz table(valoare varchar(200), cod_proprietate varchar(20))
	if @eGestUtiliz=1
	insert into @GestUtiliz(valoare, cod_proprietate)
	select valoare, cod_proprietate from fPropUtiliz(@sesiune) where valoare<>'' and cod_proprietate='GESTIUNE'

	declare @contStingere varchar(200)
	select @stareAviz=isnull(@stareAviz,0)	--> ma asigur ca nu e null
		,@contStingere=(case when @tipRaport='Avize' then '418%' when @tipRaport='Receptii' then '408%' else '' end)

		create table #pozitii_RSF (--utilizator varchar(200),
	
	nivel1 varchar(200), nivel2 varchar(200)
	, numeNivel1 varchar(2000), numeNivel2 varchar(2000)
	, cod varchar(200), den_nomenclator varchar(500)
	, tert varchar(100)
	, factura varchar(100), aviz varchar(100)
	, gestiune varchar(100)
	, tip varchar(20), numar varchar(20), data datetime
	, grupa_nomenclator varchar(500)
	, detalii_factura varchar(4000)
	, pret decimal(20,5)
	, cantitate_aviz decimal(15,3)
	, valoare_aviz decimal(20,5)
	, cantitate_sosire decimal(15,3)
	, valoare_sosire decimal(20,5)
	, tva_sosire decimal(20,5)
	, cod_sosire varchar(200)
	, idpozdoc_f int
	, idpozdoc int
	, punctlivrare varchar(200)
	, den_punctlivrare varchar(4000)
	, data_facturii datetime
	, data_facturii_avizului datetime
	, av_cont_de_stoc_stareaviz varchar(100)
	, p_cont_factura_stareaviz varchar(100)
	)
--	cod_f, pret_de_stoc=pret_de_stoc_f, cantitate=cantitate_f
--			,valoare_furn=valoare_furn_f, tva=tva_f

	insert into #pozitii_RSF(--utilizator, 
	nivel1, nivel2
	, numeNivel1, numeNivel2
	, cod, den_nomenclator
	, tert
	, factura, aviz
	, gestiune
	, tip, numar, data
	, grupa_nomenclator
	, detalii_factura
	, pret
	
	, cantitate_aviz
	, valoare_aviz
	, cantitate_sosire
	, valoare_sosire
	, tva_sosire
	, cod_sosire
	, idpozdoc_f
	, idpozdoc
	, punctlivrare
	, data_facturii
	, data_facturii_avizului
	, av_cont_de_stoc_stareaviz
	, p_cont_factura_stareaviz
	)
select --@utilizator, 
		'', '', '', ''
		, max(av.cod) cod, max(rtrim(isnull(nav.denumire,n.denumire)))
		, max(p.tert)
		, max(rtrim(p.factura)+' '+convert(varchar(20),p.data_facturii,103)) factura
		, max(rtrim(av.factura)+' '+convert(varchar(20),av.data_facturii,103)) aviz
		, max(p.gestiune) gestiune
		, max(av.tip) tip, max(av.numar) numar, max(av.data) data
		--, max(f.tip) tip, max(f.numar) numar, max(f.data) data
		, max(isnull(nav.grupa,n.grupa)) grupa_nomenclator
		, max(d.detalii.value('(row/@raportare)[1]','varchar(1000)')) detalii_factura
		, max(av.pret_de_stoc) pret
		, sum(av.cantitate) as cantitate_aviz
		, --max(round(p.cantitate*p.pret_valuta*(case when p.valuta<>'' then p.curs else 1 end),5))
			sum(av.cantitate*av.pret_de_stoc) as valoare_aviz
		--, sum(av.cantitate)/count(1) as cantitate_aviz
		, sum(p.cantitate) as cantitate_sosire, sum(p.cantitate*p.pret_de_stoc) as valoare_sosire
		, sum(p.tva_deductibil) as tva_sosire
		, max(p.cod) cod_sosire
		, max(p.idpozdoc) 
		, max(av.idpozdoc)
		, max(isnull(avd.detalii.value('(row/@punctlivrare)[1]','varchar(200)'),'')) punctlivrare
		, max(p.data_facturii)
		, max(av.data_facturii) data_facturii_avizului
		, max(av.cont_de_stoc) as av_cont_de_stoc_stareaviz
		, max(p.cont_factura) as p_cont_factura_stareaviz
	from pozdoc p		--> facturi
		left join pozdoc  av on p.Subunitate=av.Subunitate and p.Tert=av.tert and p.cod_intrare=av.Factura		--> avize
					and av.tip in ('RM','RS')
					--and p1.cont_de_stoc like "'+@contStingere+'")
		left join doc d on p.subunitate=d.subunitate and p.tip=d.tip and p.data=d.data and p.numar=d.numar
		left join doc avd on av.subunitate=avd.subunitate and av.tip=avd.tip and av.data=avd.data and av.numar=avd.numar
		left join nomencl nav on av.cod=nav.cod
		left join nomencl n on p.cod=n.cod
		left join terti t on t.subunitate=@csub and t.tert=p.tert
		left join infotert i on i.subunitate='1' and i.tert=t.tert and i.identificator=''
	where p.Subunitate=@cSub and (p.data between convert(char(10),@datajos,101) and (convert(char(10),@datasus,101)))
		and p.tip='RM' and p.subtip='SF' and n.tip='R'
		and (@cod is null or av.cod like @cod)
		and (@nrdoc is null or p.numar = @nrdoc)
		and (@codintrare is null or p.Cod_intrare=@codintrare)
		and (@comanda is null or left(av.Comanda,20)=@comanda)
		and (@contCor is null or av.cont_factura like @contCor)
		and (@ctstoc is null or av.cont_de_stoc like @ctstoc)
		and (@contFactura is null or p.cont_factura like @contFactura)
		and (@factura is null or p.factura=@factura or av.factura=@factura)
		and (@furnizor_nomenclator is null or isnull(nav.furnizor,n.furnizor)=@furnizor_nomenclator)
		and (@gestiune is null or p.gestiune like @gestiune)
		and (@gestiuneprim is null or p.gestiune_primitoare=@gestiuneprim)
		and (@grupa is null or isnull(nav.grupa,n.grupa) like @grupa)
		and (@tipArticole='' or charindex(','+rtrim(isnull(nav.tip,n.tip))+',',@tipArticole)>0)
		and (@grupaTerti is null or t.Grupa=@grupaTerti)
		and (@lm is null or p.loc_de_munca like @lm or av.loc_de_munca like @lm)
		and (@locatia is null or p.locatie=@locatia or av.locatie=@locatia)
		and (@tert is null or p.tert=@tert)
			--and (@lot is null or isnull(nullif(rtrim(s.lot),''),p.lot) like @lot)	--> are sens? expresia e complicata, poate nu e prea optim sa fie activa
		and (@eLmUtiliz=0 or exists (select 1 from lmfiltrare u where u.cod=p.Loc_de_munca and u.utilizator=@utilizator))
		and (@eGestUtiliz=0 or exists (select 1 from @GestUtiliz u where u.valoare=p.Gestiune))
		and (@tipTert is null or i.zile_inc=@tipTert)
		and (@valuta is null or p.valuta='' and p.valuta<>'' or p.valuta=@valuta)
	 GROUP BY --p.idpozdoc, 
		--isnull(av.idpozdoc,p.idpozdoc)
		av.idpozdoc,p.idpozdoc
--/*

	--> aplic filtrul pe stare aviz; il aplic aici sa nu complic selectul initial:
	if @stareaviz=1
		delete p from #pozitii_RSF p
			--where av_cont_de_stoc_stareaviz like @contstingere and isnull(p_cont_factura_stareaviz,'') like @contstingere
			where not (p.p_cont_factura_stareaviz like @contStingere and (exists (select top 1 1 from pozdoc p1 where '1'=p1.Subunitate and p.Tert=p1.tert and p.Factura=p1.cod_intrare
					and p1.cont_de_stoc like @contStingere)))
			
	if @stareaviz=2
		delete p from #pozitii_RSF p
			--where av_cont_de_stoc_stareaviz like @contstingere and isnull(p_cont_factura_stareaviz,'') like @contstingere
			where not (p.p_cont_factura_stareaviz like @contStingere and (not exists (select top 1 1 from pozdoc p1 where '1'=p1.Subunitate and p.Tert=p1.tert and p.Factura=p1.cod_intrare
				and p1.cont_de_stoc like @contStingere)))

	--> iau denumirile punctelor de livrare:
	update p set den_punctlivrare=isnull(rtrim(i.descriere),'')
	from #pozitii_RSF p
		left join infotert i on i.subunitate='1' and i.tert=p.tert and i.identificator=p.punctlivrare
	where p.punctlivrare<>''
	
	--> completez cu date de pe facturi daca nu exista avize:
	update p
		set cod=cod_sosire --pret=pret_sosire
			, cantitate_aviz=cantitate_sosire
			, valoare_aviz=valoare_sosire
			--,valoare_furn=valoare_furn_f, tva=tva_f
	from #pozitii_RSF p where p.cod is null
--*/

	/*	Valorile din avize raman neschimbate; se altereaza cantitatea pe sosire astfel incat valoarea sosirii sa fie reala: */
		--> calculez ponderat valorile luate pentru avize:

	update p set cantitate_sosire=p.cantitate_aviz*p.valoare_sosire/p.valoare_aviz
	from #pozitii_RSF p
			where p.valoare_aviz<>0	
			
	--> stabilesc gruparile optionale:
	update p
	set nivel1=rtrim(case @nivel1 when 'TE' then p.tert when 'GE' then p.gestiune else '' end),
		nivel2=rtrim(case @nivel2 when 'TE' then p.tert when 'GE' then p.gestiune else '' end),
		numenivel1=(case @nivel1 when 'TE' then t.denumire when 'GE' then g.denumire_gestiune else '' end),
		numenivel2=(case @nivel2 when 'TE' then t.denumire when 'GE' then g.denumire_gestiune else '' end)
	from #pozitii_RSF p
		left join terti t on @cSub=t.subunitate and p.tert=t.tert
		left join gestiuni g on p.gestiune=g.cod_gestiune

	select p.nivel1, p.numenivel1, p.nivel2, p.numenivel2
		, p.factura, p.grupa_nomenclator, p.aviz, p.cod
		, p.tip, p.numar, p.data
		, p.detalii_factura
		, p.pret
--		, p.cantitate_aviz, p.valoare_aviz
		, p.cantitate_aviz/isnull(nullif(c.cateFacturi,0),1) as cantitate_aviz, p.valoare_aviz/isnull(nullif(c.cateFacturi,0),1) as valoare_aviz	--> e nevoie de o impartire a valorilor avizelor pe nr de facturi din cauza ca se poate sa fie mai multe sosiri de facturi pe un aviz
		, p.cantitate_aviz/isnull(nullif(c.cateFacturi,0),1) as cantitate_aviz_sus, p.valoare_aviz/isnull(nullif(c.cateFacturi,0),1) as valoare_aviz_sus	--> e nevoie de o impartire a valorilor avizelor pe nr de facturi din cauza ca se poate sa fie mai multe sosiri de facturi pe un aviz
		/*
		, p.cantitate_sosire, p.valoare_sosire, p.tva_sosire
		, p.valoare_sosire+p.tva_sosire val_tva_sosire
		*/
		, p.cantitate_sosire*p.valoare_aviz/isnull(nullif(cf.total_aviz,0),1) cantitate_sosire, p.valoare_sosire*p.valoare_aviz/isnull(nullif(cf.total_aviz,0),1) valoare_sosire
		, p.tva_sosire*p.valoare_aviz/isnull(nullif(cf.total_aviz,0),1) tva_sosire, (p.valoare_sosire+p.tva_sosire)*p.valoare_aviz/isnull(nullif(cf.total_aviz,0),1) val_tva_sosire
		
		, p.cantitate_sosire*p.valoare_aviz/isnull(nullif(cf.total_aviz,0),1) cantitate_sosire_sus, p.valoare_sosire*p.valoare_aviz/isnull(nullif(cf.total_aviz,0),1) valoare_sosire_sus
		, p.tva_sosire*p.valoare_aviz/isnull(nullif(cf.total_aviz,0),1) tva_sosire_sus, (p.valoare_sosire+p.tva_sosire)*p.valoare_aviz/isnull(nullif(cf.total_aviz,0),1) val_tva_sosire_sus
		, p.den_nomenclator
		, isnull(p.idpozdoc,p.idpozdoc_f)
		, p.punctlivrare, p.den_punctlivrare
	from #pozitii_RSF p
		left join nomencl n on p.cod=n.cod
		left join (select idpozdoc, count(1) as catefacturi from #pozitii_RSF group by idpozdoc) c on p.idpozdoc=c.idpozdoc
		left join (select idpozdoc_f, sum(valoare_aviz) as total_aviz from #pozitii_RSF group by idpozdoc_f) cf on p.idpozdoc_f=cf.idpozdoc_f
	order by p.nivel1, p.nivel2, p.data_facturii, p.data_facturii_avizului, p.data, p.factura, p.aviz, p.cod
	--select 'test',* from #pozitii_RSF
end try
begin catch
	select @eroare='Eroare:'+char(10)+error_message()+' ('+object_name(@@procid)+')'
	select '<Eroare>' nivel1, @eroare numenivel1
end catch

if object_id('tempdb..#pozitii_RSF') is not null drop table #pozitii_RSF
if len(@eroare)>0 raiserror(@eroare,16,1)

/*
--	apel din raport:

declare @datajos datetime,@sesiune nvarchar(14),@datasus datetime,@tert nvarchar(4000),@cod nvarchar(4000),@gestiune nvarchar(4000),@lm nvarchar(4000),@factura nvarchar(4000),@comanda nvarchar(4000),@Nivel1 nvarchar(2),@Nivel2 nvarchar(2),@Nivel3 nvarchar(4000),@Nivel4 nvarchar(4000),@Nivel5 nvarchar(4000),@ordonare int,@tip_doc_str nvarchar(10),@grupaTerti nvarchar(4000),@grupaNomenclator nvarchar(4000),@puncteLivrare bit,@furnizor nvarchar(4000),@locatie nvarchar(4000),@furnizor_nomenclator nvarchar(4000),@detalii int,@greutate bit,@top nvarchar(4000),@nrmaximdetalii nvarchar(6),@tiptert nvarchar(4000),@contfactura nvarchar(4000),@tipArticole nvarchar(4000),@indicator nvarchar(4000),@ctstoc nvarchar(4000),@stareAviz nvarchar(4000),@valuta nvarchar(4000)
select @datajos='2016-06-01 00:00:00',@sesiune=N'0066F979BC0F5 ',@datasus='2016-08-31 00:00:00',@tert=NULL,@cod=NULL,@gestiune=NULL,@lm=NULL,@factura=NULL,@comanda=NULL,@Nivel1=N'FA',@Nivel2=N'CO',@Nivel3=NULL,@Nivel4=NULL,@Nivel5=NULL,@ordonare=0,@tip_doc_str=N',RM,RS,FF,',@grupaTerti=NULL,@grupaNomenclator=NULL,@puncteLivrare=0,@furnizor=NULL,@locatie=NULL,@furnizor_nomenclator=NULL,@detalii=2,@greutate=0,@top=NULL,@nrmaximdetalii=N'100000',@tiptert=N'',@contfactura=NULL,@tipArticole=N'',@indicator=NULL,@ctstoc=NULL,@stareAviz=NULL,@valuta=NULL

exec rapReceptiiSosiriFacturi @sesiune=@sesiune,
	@datajos=@datajos, @datasus=@datasus, @tert=@tert, @cod=@cod,
	@gestiune=@gestiune, @lm=@lm, @factura=@factura, @comanda=@comanda,
	@Nivel1=@Nivel1, @Nivel2=@Nivel2, @Nivel3=@Nivel3, @Nivel4=@Nivel4, @Nivel5=@Nivel5, @ordonare=@ordonare,
	@grupaTerti=@grupaTerti, @grupa=@grupaNomenclator, @puncteLivrare=@puncteLivrare, @furnizor=@furnizor, @locatia=@locatie,
	@furnizor_nomenclator=@furnizor_nomenclator, @detalii=@detalii, @greutate=@greutate, @top=@top, @tipRaport='Receptii',
	@nrmaximdetalii=@nrmaximdetalii, @tiptert=@tiptert, @contfactura=@contfactura, @tip_doc_str=@tip_doc_str
	,@tipArticole=@tipArticole, @indicator=@indicator, @ctstoc=@ctstoc, @stareAviz=@stareAviz, @valuta=@valuta
--*/
