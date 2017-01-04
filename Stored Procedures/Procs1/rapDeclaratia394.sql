--***
Create procedure rapDeclaratia394 @sesiune varchar(50)=null	-->	parametrul sesiune nu va avea efect pana ce nu-l vom trimite catre ftert
		,@data datetime=null, @tert varchar(1000)=''
		,@tip_D394 varchar(1)='R'	--> R=Toate
		,@taxainv varchar(1)='1'	--> 1=Toate, 2=fara, 3=doar taxare inversa
		,@iddeclaratie varchar(100)=null
		,@parxml xml='<row/>'
		,@locm varchar(20)=null
		,@dataSet char(3)='D'
as

declare @utilizator varchar(10), @lista_lm int, @facturi varchar(1000), @expandare int, @tert_generare varchar(100),
		@raport bit, @codMeniu varchar(10), @tip varchar(10), @update int, @cgplus int, @totalPlata_A decimal(15), @f_codfisc varchar(20), @f_dentert varchar(100),
		@multiFirma int, @nrFacturi int
set @data=dbo.eom(@data)
exec wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator output
set @lista_lm=dbo.f_areLMFiltru(@utilizator)
set @multiFirma=0
if exists (select * from sysobjects where name ='par' and xtype='V')
	set @multiFirma=1

if @tert is not null and not exists (select 1 from terti t where t.denumire like @tert)
begin
	set @tert_generare=@tert
	select @f_codfisc=replace(replace(replace(isnull(cod_fiscal,''), 'RO', ''), 'R', ''), ' ',''), @f_dentert=denumire from terti where tert like @tert
end
else set @tert_generare=''

set @locm=isnull(@locm,'')

select	@raport=(case when isnull(@parxml.value('(row/@iddeclaratie)[1]','varchar(100)'),'')='' then 1 else 0 end)
		--> filtre:
		,@iddeclaratie=isnull(@parxml.value('(row/@iddeclaratie)[1]','int'),@iddeclaratie)
		,@data=isnull(@parxml.value('(row/@datalunii)[1]','datetime'),@data)
		,@codMeniu=isnull(@parxml.value('(row/@codMeniu)[1]','varchar(10)'),'')
		,@tip=isnull(@parxml.value('(row/@tip)[1]','varchar(10)'),'')
		,@update=isnull(@parxml.value('(row/@update)[1]','int'),0)
		,@tip_D394=isnull(@parxml.value('(row/@f_tip)[1]','varchar(10)'),@tip_D394)
		,@tert=isnull(nullif(@parxml.value('(row/@f_tert)[1]','varchar(1000)'),''),isnull(@tert,''))+'%' --> filtrarea pe tert se face fara null, nefiltrare = ''
		,@facturi=isnull(@parxml.value('(row/@facturi)[1]','varchar(1000)'),'1')
		--> specifice machetei:
		,@expandare=(case left(isnull(@parxml.value('(row/@expandare)[1]','varchar(2)'),'2'),1) when 'd' then 10 when 'n' then 1 when '' then 2 
			else isnull(@parxml.value('(row/@expandare)[1]','varchar(2)'),2) end)
		,@cgplus=isnull(@parxml.value('(row/@cgplus)[1]','int'),0)

select @facturi=(case when left(@facturi,1)='d' or @raport=1 and @cgplus=0 then '1' else '0' end)

--	pentru perioade anterioare lui iulie 2016, apelam procedura functionala pana la 30.06.2016
if @data<'07/01/2016' and exists (select * from sysobjects where name ='rapDeclaratia394v2015' and xtype='P') and @utilizator not in ('chrisys','lucian')
	begin
		exec rapDeclaratia394v2015 
			@sesiune=@sesiune, @data=@data, @tert=@tert, @tip_D394=@tip_D394, @taxainv=@taxainv, @iddeclaratie=@iddeclaratie, @parxml=@parxml, @locm=@locm
		return 0
	end

begin
	declare @eroare varchar(1000), @xmlD394 xml, @solicit_ramb int, @sistemTVA int
	
	-- diez provizoriu filtrat
	if object_id('tempdb..#Decl394') is not null drop table #Decl394
	select d.* 
	into #Decl394
	from d394 d
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=d.lm
	where d.data=@data
		and (@lista_lm=0 or lu.cod is not null or @multiFirma=0 and nullif(d.lm,'') is null) 
		and (d.rand_decl not like 'A%' or (@lista_lm=1 and lu.cod is not null or @lista_lm=0 and nullif(d.lm,'') is null or @multiFirma=0 and nullif(d.lm,'') is null))

	if exists (select 1 from #Decl394 where rand_decl='I.2.2')
		set @nrFacturi=isnull((select sum(nrFacturi) from #Decl394 where tip_partener in (1,2,3,4) and cuiP is null and tipop in ('L','V','LS')),0)
			+isnull((select count(nrI) from #Decl394 where rand_decl='FACTURI'),0)
	set @nrFacturi=isnull(@nrFacturi,0)

	-- tabela de denumiri declaratie 394
	if object_id('tempdb..#denDecl394') is null 
		create table #denDecl394 (rand_decl varchar(20), denumire_macheta varchar(800),	denumire_raport varchar(800), ordine int)
	exec pDenumiriD394
	-- tabela nomenclator declaratie 394
	if object_id('tempdb..#codnc394') is null 
		create table #CodNC394 (codnc varchar(20), Denumire varchar(100))
	exec pCoduriNC394
	-- tabela pentru defalcarea pe facturi
	if object_id('tempdb..#detaliere') is null 
		create table #detaliere (data datetime, den_rand varchar(800), den_head varchar(800), rand_decl varchar(20), tipop char(3), tli int, codtert varchar(20), cuiP varchar(20), 
					denP varchar(200), cod varchar(20), bun varchar(8), den_nomencl varchar(800), den_nom varchar(800), baza float , tva float, cota_tva int, nrfact int, 
					den_head_detalii varchar(800), nrCui int)
	-- tabela pentru gruparea pe loc de munca la CNADR
	if object_id('tempdb..#grupare') is null 
		create table #grupare (data datetime, den_rand varchar(800), den_head varchar(800), rand_decl varchar(20), tipop char(3), tli int, codtert varchar(20), cuiP varchar(20), 
					denP varchar(200), cod varchar(20), bun varchar(8), den_nomencl varchar(800), den_nom varchar(800), baza float , tva float, cota_tva int, nrfact int, 
					den_head_detalii varchar(800), nrCui int)
	-- tabela cu facturi
	if object_id('tempdb..#facturi') is null 
		create table #facturi (subunitate varchar(20), tert varchar(20), codfisc varchar(20), tipop char(3), baza float, numar varchar(30), numarD varchar(30), 
					tipD varchar(4), data datetime, factura varchar(30), valoare_factura float, cota_tva int, tva float, invers int, cod_nomenclatura varchar(20))

	if @iddeclaratie is null
		select top 1 @iddeclaratie=d.iddeclaratie
		from declaratii	d
			left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=d.Loc_de_munca
		where d.cod='394' and d.data=@data
			and (@lista_lm=0 or lu.cod is not null) 
		order by Data_operarii desc

	select @xmlD394 = continut from declaratii where cod='394'and idDeclaratie=@iddeclaratie
	set @sistemTVA = @xmlD394.value('(*/@sistemTVA)[1]','int')
	select @solicit_ramb = max(case when rand_decl='A_solicit_ramb' then convert(int,denumire) else 0 end) from #Decl394
	set @totalPlata_A = @xmlD394.value('(*/@totalPlata_A)[1]','decimal(15)')

	if object_id('tempdb..#D394det') is null
	begin
		create table #D394det (subunitate varchar(20))
		exec Declaratia39x_tabela
	end

	--> identific facturile care S-AR PUTEA sa faca parte din declaratia 394 ca valori prin apelarea procedurii de generare - nu se genereaza din nou declaratia, doar se interogheaza baza de date ca si cum s-ar genera:
	if @facturi=1
	exec Declaratia394
		@sesiune=@sesiune
		,@data=@data
		,@nume_declar='Maier', @prenume_declar='Lucian', @functie_declar='program_test'
		,@caleFisier='c:\websites\ria\formulare\D394_luci'
		,@tip_D394='L'
		,@genRaport=2
		,@tert=@tert_generare
		,@locm=@locm
	
	insert into #facturi (subunitate, tert, codfisc, tipop, baza, numar, numarD, tipD, data, factura, valoare_factura, cota_tva, tva, invers, cod_nomenclatura)
	select subunitate, rtrim(tert) tert, codfisc, 
			(case	when d.invers=1 and d.tipop='L' then 'V'
					when d.invers=1 and d.tipop='A' then 'C' else d.tipop end) tipop, 
			convert(decimal(15,0),sum(baza)) baza, max(numar) numar, max(numarD) numarD, max(tipD) tipD, data, factura, 
			convert(decimal(15,0),sum(baza))+convert(decimal(15,0),sum(tva)), cota_tva, convert(decimal(15,0),sum(tva)) tva, invers, max(p.valoare)
	from #D394det d
	left join proprietati p on p.tip='nomencl' and p.cod_proprietate='codnomenclatura'	and p.cod=d.codnomenclator
	group by subunitate, tert, codfisc, d.invers, tipop, factura, numar, numard, data, p.valoare, cota_tva

--> date pentru raport:
	if @raport=1
	begin
		if @dataSet='CF'
		begin
			if object_id('tempdb..#sectiuneCF') is not null
				drop table #sectiuneCF
			select left(d.rand_decl,1)+(case when d.tipop='N' then '.' else '' end) as sectiune, d.data, t1.denumire_raport as den_rand, t2.denumire_raport as den_head, d.rand_decl, d.tipop, isnull(d.tli,0) as tli, 
					isnull(d.bun,'') as bun, isnull(c.denumire,'') as den_nomencl, d.baza, d.tva, d.cota_tva, d.nrfacturi as nrfact, 
					t3.denumire_raport as den_head_detalii, d.nrCui, t1.ordine, 
					d.tip_document, (case when d.tip_document=1 then 'Factura' when d.tip_document=2 then 'Borderou' when d.tip_document=3 then 'Carnet comercializare' 
						when d.tip_document=4 then 'Contract' end) as dentipdoc
			into #sectiuneCF
			from #Decl394 d
				left outer join #denDecl394 t1 on rtrim(d.rand_decl)+(case when @sistemTVA=1 and d.rand_decl='C.L' then 'I' else '' end)=rtrim(t1.rand_decl)
				left outer join #denDecl394 t2 on left(d.rand_decl,1)=rtrim(t2.rand_decl) and len(rtrim(t2.rand_decl))=1
				left outer join #denDecl394 t3 on left(d.rand_decl,1)=left(t3.rand_decl,1) and charindex('+',t3.rand_decl)<>0
				left outer join #codnc394 c on c.codnc=d.bun
			where left(d.rand_decl,2) in ('C.','D.','E.','F.') and charindex('.cuiP',d.rand_decl)=0 
			
			update a set nrCui=(select count(distinct cuiP) from #Decl394 b where b.cuiP is not null and left(b.rand_decl,1)=left(a.rand_decl,1))
			from #sectiuneCF a

			select sectiune, data, den_rand, den_head, rand_decl, tipop, tli, bun, den_nomencl, baza, tva, cota_tva, nrfact, den_head_detalii, nrCui, tip_document, dentipdoc
			from #sectiuneCF
			order by sectiune, ordine, tipop, cota_tva, isnull(tip_document,0), bun
		end

		if @dataSet='D' or @dataSet='DF'
		begin
			insert into #detaliere (data, den_rand, den_head, rand_decl, tipop, tli, codtert, cuiP,	denP, cod, bun, den_nomencl, den_nom, baza, tva, cota_tva, nrfact, den_head_detalii, nrCui)
			select d.data, t1.denumire_raport as den_rand, t2.denumire_raport as den_head, d.rand_decl, d.tipop, isnull(d.tli,0) as tli, 
					d1.codtert, d1.cuiP, d1.denP, d1.cod as cod, d1.bun as bun, isnull(c.denumire,'') as den_nomencl, isnull(c1.denumire,'') as den_nom,
					(case when d.rand_decl='D_EXCEPTII' then d.baza else d1.baza end) as baza, (case when d.rand_decl='D_EXCEPTII' then d.tva else d1.tva end) as tva, 
					(case when d.rand_decl='D_EXCEPTII' then d.cota_tva else d1.cota_tva end) as cota_tva, (case when d.rand_decl='D_EXCEPTII' then d.nrfacturi else d1.nrfacturi end) as nrfact, 
					t3.denumire_macheta as den_head_detalii, 0
			from #Decl394 d
				left outer join #Decl394 d1 on rtrim(d.rand_decl)+'.cuiP'=rtrim(d1.rand_decl) and charindex('.cuiP',d1.rand_decl)<>0 and d.cota_tva=d1.cota_tva and isnull(d.lm,'')=isnull(d1.lm,'') 
					and isnull(d.tip_document,0)=isnull(d1.tip_document,0) 
				left outer join #denDecl394 t1 on rtrim(d.rand_decl)+(case when @sistemTVA=1 and d.rand_decl='C.L' then 'I' else '' end)=rtrim(t1.rand_decl)
				left outer join #denDecl394 t2 on left(d.rand_decl,1)=rtrim(t2.rand_decl) and len(rtrim(t2.rand_decl))=1
				left outer join #denDecl394 t3 on left(d.rand_decl,1)=left(t3.rand_decl,1) and charindex('+',t3.rand_decl)<>0
				left outer join #codnc394 c on c.codnc=isnull(nullif(d1.cod,''),d1.bun)
				left outer join #codnc394 c1 on c1.codnc=d1.bun
			where left(d.rand_decl,2) in ('C.','D.','E.','F.','D_') and charindex('.cuiP',d.rand_decl)=0 and d.bun is null
				and (@tert_generare = '' or rtrim(d1.cuiP) like '%' + @f_codfisc + '%' 
						or rtrim(d1.denP) like '%' + @f_dentert + '%')
				--and d1.cuiP='113301'
			order by left(d.rand_decl,1), t1.ordine, d.tipop, d1.cuiP, d1.cod

			update a set nrCui=(select count(distinct cuiP) from #detaliere b where left(b.rand_decl,1)=left(a.rand_decl,1) and cuiP is not null)
			from #detaliere a
			insert into #grupare (data, den_rand, den_head, rand_decl, tipop, tli, codtert, cuiP,	denP, cod, bun, den_nomencl, den_nom, baza, tva, cota_tva, nrfact, den_head_detalii, nrCui)
			select max(data), max(den_rand), max(den_head), rand_decl, tipop, max(tli), max(codtert), cuiP, max(denP), cod, bun, max(den_nomencl), max(den_nom), sum(baza), sum(tva), cota_tva, sum(nrfact), 
				max(den_head_detalii), max(nrcui)
			from #detaliere
			group by rand_decl, tipop, cuip, cod, bun, cota_tva

			truncate table #detaliere
			insert into #detaliere
			select * from #grupare

			if @dataSet='D' 
				select * from #detaliere
			else
				select d.data, den_rand, den_head, rand_decl, d.tipop, tli, codtert, cuiP,	denP, cod, bun, den_nomencl, den_nom, d.baza, d.tva, d.cota_tva, nrfact, den_head_detalii, nrCui,
					f.baza baza_f, numar, numarD, tipD, f.data data_f, factura, valoare_factura, f.cota_tva cota_tva_f, f.tva tva_f
				from #detaliere d
					left outer join #facturi f on d.cuiP=f.codfisc and d.tipop=f.tipop and d.cota_tva=f.cota_tva and (f.cod_nomenclatura is null or f.cod_nomenclatura=d.cod)
				where tipd is not null and bun is null
		end
		if @dataSet='G'
			select max(case when rand_decl='A_calitate_intocmit' then rtrim(denumire) else '' end) as calitate,
				max(case when rand_decl='A_cif_intocmit' then rtrim(denumire) else '' end) as cif_intocmit,
				max(case when rand_decl='A_den_intocmit' then rtrim(denumire) else '' end) as den_intocmit,
				max(case when rand_decl='A_functie_intocmit' then rtrim(denumire) else '' end) as functie_intocmit,
				max(case when rand_decl='A_optiune' then convert(int,denumire) else 0 end) as optiune,
				max(case when rand_decl='A_schimb_optiune' then convert(int,isnull(nullif(denumire,''),0)) else 0 end) as schimb_optiune,
				max(case when rand_decl='A_solicit_ramb' then convert(int,denumire) else 0 end) as solicit_ramb,
				max(case when rand_decl='A_tip_intocmit' then convert(int,denumire) else 0 end) as tip_intocmit, 
				max(case when rand_decl='A_adresaR' then rtrim(denumire) else '' end) as adresaR,
				max(case when rand_decl='A_cifR' then rtrim(denumire) else '' end) as cifR,
				max(case when rand_decl='A_denR' then rtrim(denumire) else '' end) as denR,
				max(case when rand_decl='A_functieR' then rtrim(denumire) else '' end) as functieR,
				max(case when rand_decl='A_telefonR' then rtrim(denumire) else '' end) as telefonR,
				max(case when rand_decl='A_faxR' then rtrim(denumire) else '' end) as faxR,
				max(case when rand_decl='A_mailR' then rtrim(denumire) else '' end) as mailR,
				max(p.dirgen) as dirgen, max(p.fdirgen) as fdirgen, year(@data) as anul, 
				--date din XML
				max(tip_D394) tip_D394, max(sistemTVA) sistemTVA, max(op_efectuate) op_efectuate, max(cui) cui, max(caen) caen,
				max(den) den, max(adresa) adresa, max(telefon) telefon, max(fax) fax, max(mail) mail
			from #Decl394 d
				inner join 
				(select max(case when tip_parametru='GE' and parametru='DIRGEN' then val_alfanumerica else '' end) as dirgen,
					    max(case when tip_parametru='GE' and parametru='FDIRGEN' then val_alfanumerica else '' end) as fdirgen
				 from par
				 where Tip_parametru='GE' and parametru in ('DIRGEN','FDIRGEN')) p on 1=1
				 inner join
				 (select @xmlD394.value('(*/@tip_D394)[1]','varchar(2)') tip_D394, 
						 @xmlD394.value('(*/@sistemTVA)[1]','int') sistemTVA, 
						 @xmlD394.value('(*/@op_efectuate)[1]','int') op_efectuate,
						 @xmlD394.value('(*/@cui)[1]','varchar(20)') cui, 
						 @xmlD394.value('(*/@caen)[1]','varchar(20)') caen, 
						 @xmlD394.value('(*/@den)[1]','varchar(200)') den, 
						 @xmlD394.value('(*/@adresa)[1]','varchar(300)') adresa, 
						 @xmlD394.value('(*/@telefon)[1]','varchar(40)') telefon, 
						 @xmlD394.value('(*/@fax)[1]','varchar(40)') fax, 
						 @xmlD394.value('(*/@mail)[1]','varchar(40)') mail 
				 ) x on 1=1
		
		if @dataSet='T' or @cgplus=1 and @dataSet in ('I1','I2','I3','I45','I6','I7')
		begin
			if object_id('tempdb..#taburi') is not null 
				drop table #taburi
			create table #taburi 
				(nr_tab int, vizibil int, [rand] varchar(800), chk varchar(1), randdecl varchar(20), ordine int, rand2 varchar(800), chk2 varchar(1), randdecl2 varchar(20), ordine2 int,
				baza decimal(15,2), tva decimal(15,2), cota_tva int, serieI varchar(10), nrI varchar(20), serieF varchar(10), nrF varchar(20), tip int, header varchar(800), incasari float, cheltuieli float, 
				cod_caen varchar(6), tipop varchar(2), dentipop varchar(100), sectiune varchar(10), idplaja int)

			-- date tab 3
			insert into #taburi(nr_tab, vizibil, [rand], chk, randdecl, ordine, rand2, chk2, randdecl2, ordine2)
			select 3, @solicit_ramb vizibil, d.denumire_macheta as rand, (case when t.are_doc=0 then '' when t.are_doc=1 then 'X' end) as chk, t.rand_decl as randdecl, d.ordine, d1.denumire_macheta as rand2, 
				(case when t1.are_doc=0 then '' when t1.are_doc=1 then 'X' end) as chk2, t1.rand_decl as randdecl2, d.ordine-22 as ordine2
			from #denDecl394 d
				left outer join #denDecl394 d1 on d1.ordine=d.ordine-22 and d1.rand_decl like 'I.3.%'
				left outer join #Decl394 t on d.rand_decl=t.rand_decl 
				left outer join #Decl394 t1 on d1.rand_decl=t1.rand_decl 
			where d.rand_decl like 'I.3.%' and d.ordine>22 and (@cgplus=0 or @dataSet='I3')
			order by ordine

			-- date tab 1
			insert into #taburi(nr_tab, [rand], baza, tva, cota_tva, randdecl)
			select 1, rtrim(substring(d.rand_decl,3,10))+'. '+max(denumire_macheta) as rand, SUM(baza) as baza, sum(tva) as tva, cota_tva as cotatva, d.rand_decl as randdecl
			from #Decl394 d
				left outer join #denDecl394 t on d.rand_decl=t.rand_decl
			where d.rand_decl like 'I.1%' and (@cgplus=0 or @dataSet='I1')
			group by d.rand_decl, d.cota_tva
			order by d.rand_decl, d.cota_tva

			-- date tab 2
			select 2 as nr_tab, d.rand_decl as randdecl, isnull(nullif(rtrim(d.serieI),''),'-') as serieI, isnull(nullif(rtrim(d.serieF),''),'-') as serieF, d.nrI, d.nrF, convert(int,d.tip) as tip
				,(case when t.denumire_raport is not null then rtrim(substring(d.rand_decl,3,10))+'. '+rtrim(t.denumire_raport)
						+(case when d.rand_decl='I.2.2' then rtrim(convert(varchar(10),@nrFacturi)) else '' end)
					else (case when nullif(d.nrF,'') is not null then space(20)+'de la seria '+rtrim(isnull(d.serieI,''))
							+' numarul '+rtrim(isnull(d.nrI,''))+' la seria '+rtrim(isnull(d.serieF,''))+' numarul '+rtrim(isnull(d.nrF,'')) 
						else space(20)+(case when d.tip=1 then ' - facturi stornate' when d.tip=2 then ' - facturi anulate' when d.tip=3 then ' - autofacturare' else '' end)
							+' seria '+rtrim(isnull(d.serieI,''))+' numarul '+rtrim(isnull(d.nrI,'')) end) end) as [rand]
				,(case when t.denumire_raport is not null then 0 else 1 end) as ordine, d.cuiP, d.denP, d.idplaja, d.baza, d.tva, d.cota_tva
			into #tmpTaburi
			from #Decl394 d
				left outer join #denDecl394 t on t.rand_decl=d.rand_decl
			where d.rand_decl like 'I.2.%' and (@cgplus=0 or @dataSet='I2')
			union all 
			select 2, d.rand_decl as randdecl, isnull(nullif(rtrim(d.serieI),''),'-') as serieI, isnull(nullif(rtrim(d.serieF),''),'-') as serieF, d.nrI, d.nrF, convert(int,d.tip)
				,(case when d.rand_decl like 'I.2.3' or d.rand_decl like 'I.2.4' 
					then space(20)+'seria '+rtrim(isnull(d.serieI,'-'))+' numarul '+rtrim(d.nrI)+', denumire tert '+rtrim(d.denP)+', CUI '+rtrim(d.cuiP)
					else space(20)+'de la seria '+rtrim(d.serieI)+' numarul '+rtrim(d.nrI)+' la seria '+rtrim(d.serieF)+' numarul '+rtrim(d.nrF) end) as rand, 
				1 as ordine, d.cuiP, d.denP, d.idplaja, d.baza, d.tva, d.cota_tva
			from #Decl394 d
				left outer join #denDecl394 t on t.rand_decl=d.rand_decl
			where (d.rand_decl like 'I.2.1' or d.rand_decl like 'I.2.2' or d.rand_decl like 'I.2.3' or d.rand_decl like 'I.2.4') and (@cgplus=0 or @dataSet='I2')

			insert into #taburi (nr_tab, randdecl, serieI, serieF, nrI, nrF, tip, [rand], ordine, idplaja, baza, tva, cota_tva)
			-->	Pun mai intai grupare pe rand declaratie si apoi detaliile in cadrul fiecarui rand.
			select nr_tab, randdecl, '' as serieI, '' as serieF, '' as nrI, '' as nrF, tip, [rand], ordine, null as idplaja, null baza, null tva, null cota_tva
			from #tmpTaburi
			where Ordine=0
			Group by nr_tab, randdecl, tip, [rand], Ordine
			union all
			select nr_tab, randdecl, serieI, serieF, nrI, nrF, tip, [rand], ordine, idplaja, baza, tva, cota_tva
			from #tmpTaburi
			where Ordine<>0
			order by ordine, idplaja, randdecl, rand, tip

			-- date tab 4-5
			insert into #taburi (nr_tab, vizibil, [rand], tva, cota_tva, randdecl, header, sectiune) 
			select 4, (case when @sistemTVA=0 and substring(d.rand_decl,3,1)='4' or @sistemTVA=1 and substring(d.rand_decl,3,1)='5' then 1 else 0 end) vizibil,  
					rtrim(substring(d.rand_decl,3,10))+'. '+max(t.denumire_macheta) as rand, sum(tva) as tva, cota_tva as cotatva, d.rand_decl as randdecl, 
					rtrim(substring(d.rand_decl,3,2))+' '+max(t1.denumire_macheta) as header, left(d.rand_decl,3) as sectiune
			from #Decl394 d
				left outer join #denDecl394 t on d.rand_decl=t.rand_decl
				left outer join #denDecl394 t1 on substring(d.rand_decl,1,3)=t1.rand_decl
			where (d.rand_decl like 'I.4.%' or d.rand_decl like 'I.5.%') and (@cgplus=0 or @dataSet='I45')
			group by d.rand_decl, d.cota_tva
			order by d.rand_decl, d.cota_tva
			
			-- date tab 6, sectiunea I.6
			insert into #taburi (nr_tab, [rand], baza, tva, cota_tva, incasari, cheltuieli, randdecl)
			select 6, max(denumire_raport) as rand, SUM(baza) as baza, sum(tva) as tva, cota_tva as cotatva, sum(incasari) incasari, 
				sum(convert(decimal(15),d.cheltuieli)) cheltuieli, d.rand_decl as randdecl
			from #Decl394 d
				left outer join #denDecl394 t on d.rand_decl=t.rand_decl
			where d.rand_decl like 'I.6%' and (@cgplus=0 or @dataSet='I6')
			group by d.rand_decl, d.cota_tva
			order by d.rand_decl, d.cota_tva
			
			-- date tab 7, sectiunea I.7
			insert into #taburi (nr_tab, [rand], baza, tva, cota_tva, cod_caen, tipop, dentipop, randdecl, sectiune)
			select 7, max(denumire_raport) as rand, SUM(baza) as baza, sum(tva) as tva, cota_tva as cotatva, d.denumire cod_caen, 
				d.tipop, (case when d.tipop='1' then 'Livrari bunuri' else 'Prestari servicii' end) as dentipop, d.rand_decl as randdecl, left(d.rand_decl,3) as sectiune
			from #Decl394 d
				left outer join #denDecl394 t on d.rand_decl=t.rand_decl
			where d.rand_decl like 'I.7%' and (@cgplus=0 or @dataSet='I7') 
			group by d.rand_decl, d.cota_tva, d.denumire, d.tipop
			order by d.rand_decl, d.cota_tva

			select * from #taburi
			order by (case when randdecl like 'I.2.2%' then 'I.2.2' else randdecl end), ordine, (case when randdecl like 'I.2.2%' then idplaja else 0 end)
		end

		if @dataSet='GH' or @cgplus=1 and @dataSet in ('SG','SGD') or @cgplus=1 and @dataSet='SH'
			select t.denumire_raport, left(d.rand_decl,1) as sectiune, d.rand_decl, (case when @dataSet in ('GH','SGD') then d.denumire else '' end) as luna, d.tipop, 
				sum(d.nrfacturi) as nrfacturi, sum(d.baza) as baza, sum(d.tva) as tva, d.cota_tva, sum(d.incasari) as incasari, 
				max(case when d.tipop='I1' then isnull(amef.nrCui,0) else 0 end) as nrAMEF, @totalPlata_A as totalPlata_A
			from #Decl394 d
				left outer join #denDecl394 t on t.rand_decl=d.rand_decl
				left outer join #Decl394 amef on amef.rand_decl='A_nrcasemarcat'
			where left(d.rand_decl,1) in ('G','H') 
				and (@cgplus=0 or @dataSet in ('SG','SGD') and left(d.rand_decl,1)='G' and (d.incasari<>0 or d.nrfacturi<>0) or @dataSet='SH' and left(d.rand_decl,1)='H')
			group by t.denumire_raport, left(d.rand_decl,1), d.rand_decl, 
				(case when @dataSet in ('GH','SGD') then d.denumire else '' end), d.tipop, d.cota_tva
			order by d.cota_tva desc
	end
end

/*
	exec rapDeclaratia394 @sesiune='D14526C398FF6', @data='06/30/2016', @tert=null, @tip_d394=null, @locm=null, @iddeclaratie='412', @dataSet='T'
*/
