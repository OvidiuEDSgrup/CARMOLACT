--***
Create procedure wIaDateD394 @sesiune varchar(50)=null	-->	parametrul sesiune nu va avea efect pana ce nu-l vom trimite catre ftert
		,@data datetime=null, @tert varchar(1000)=''
		,@tip_D394 varchar(1)='R'	--> R=Toate
		,@taxainv varchar(1)='1'	--> 1=Toate, 2=fara, 3=doar taxare inversa
		,@iddeclaratie varchar(100)=null
		,@parxml xml='<row/>'
		,@locm varchar(20)=null
		,@dataSet char(1)='D'
as

declare @facturi varchar(1000), @expandare int, @tert_generare varchar(100),
		@raport bit, @codMeniu varchar(10), @tip varchar(10), @update int, @f_codfisc varchar(20), @f_dentert varchar(100)

select	--> filtre:
		 @iddeclaratie=isnull(@parxml.value('(/row/@iddeclaratie)[1]','int'),@iddeclaratie)
		,@data=isnull(@parxml.value('(/row/@datalunii)[1]','datetime'),@data)
		,@codMeniu=isnull(@parxml.value('(/row/@codMeniu)[1]','varchar(10)'),'')
		,@tip=isnull(@parxml.value('(/row/@tip)[1]','varchar(10)'),'')
		,@update=isnull(@parxml.value('(/row/@update)[1]','int'),0)
		,@tip_D394=isnull(@parxml.value('(/row/@f_tip)[1]','varchar(10)'),@tip_D394)
		,@tert=isnull(nullif(@parxml.value('(/row/@f_tert)[1]','varchar(1000)'),''),isnull(@tert,''))+'%' --> filtrarea pe tert se face fara null, nefiltrare = ''
		,@facturi=isnull(@parxml.value('(/row/@facturi)[1]','varchar(1000)'),'1')
		--> specifice machetei:
		,@expandare=(case when isnumeric(isnull(@parxml.value('(/row/@expandare)[1]','varchar(2)'),'3'))<>0 then convert(int,isnull(@parxml.value('(/row/@expandare)[1]','varchar(2)'),'3')) else 10 end)

begin
	declare @eroare varchar(1000), @utilizator varchar(10), @lista_lm int, @multiFirma int, @lmFiltru varchar(9), @lmUtilizator varchar(9), @nrLMFiltru int, @denlmUtilizator varchar(9)
	
	set @utilizator=dbo.fIaUtilizator(null)
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
	
	--	pentru perioade anterioare lui 2016, apelam procedura functionala pana la 31.12.2015 
	if @data<'07/01/2016' and exists (select * from sysobjects where name ='rapDeclaratia394v2015' and xtype='P') and @utilizator<>'chrisys'
		begin
			if @codMeniu='CDL'
				exec rapDeclaratia394v2015 
					@sesiune=@sesiune, @data=@data, @tert=@tert, @tip_D394=@tip_D394, @taxainv=@taxainv, @iddeclaratie=@iddeclaratie, @parxml=@parxml, @locm=@locm
			return 0
		end

	if nullif(@tert,'%') is not null --and not exists (select 1 from terti t where t.denumire like @tert)
		begin
			set @tert_generare=@tert
			select @f_codfisc=replace(replace(replace(isnull(cod_fiscal,''), 'RO', ''), 'R', ''), ' ',''), @f_dentert=denumire, @tert_generare=tert from terti where denumire like @tert
		end
	else set @tert_generare=''
	set @locm=isnull(@locm,'')
	set @facturi=(case when upper(@facturi)='DA' then '1' else '0' end)
	
	-- diez provizoriu filtrat
	if object_id('tempdb..#Decl394') is not null drop table #Decl394
	select d.* 
	into #Decl394
	from d394 d
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=d.lm
	where d.data=dbo.eom(@data)
		and (d.rand_decl like 'A_%' and (@multiFirma=1 and lu.cod is not null or @multiFirma=0 and d.lm is null) or d.rand_decl not like 'A_%' and (@lista_lm=0 or lu.cod is not null))

	-- tabela de denumiri declaratie 394
	if object_id('tempdb..#denDecl394') is null create table #denDecl394 (rand_decl varchar(20), denumire_macheta varchar(800),	denumire_raport varchar(800), ordine int)
	exec pDenumiriD394
	-- tabela nomenclator declaratie 394
	if object_id('tempdb..#codnc394') is null create table #CodNC394 (codnc varchar(20), Denumire varchar(100))
	exec pCoduriNC394
	-- tabela coduri CAEN tab I7 declaratie 394
	if object_id('tempdb..#codCaen394') is null create table #codCaen394 (cod varchar(10), denumire varchar(250))
	exec pCoduriCaenD394
	if object_id('tempdb..#facturi') is null 
		create table #facturi (subunitate varchar(20), tert varchar(20), codfisc varchar(20), tipop char(3), baza float, numar varchar(30), numarD varchar(30), 
					tipD varchar(4), data datetime, factura varchar(30), valoare_factura float, cota_tva int, tva float, invers int, cod_nomenclatura varchar(20))
	if object_id('tempdb..#D394det') is null
	begin
		create table #D394det (subunitate varchar(20))
		exec Declaratia39x_tabela
	end

	--> identific facturile care S-AR PUTEA sa faca parte din declaratia 394 ca valori prin apelarea procedurii de generare - nu se genereaza din nou declaratia, doar se interogheaza baza de date ca si cum s-ar genera:
	if @facturi=1
	exec Declaratia394
		@data=@data
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

-->	date pentru macheta - ierarhie:

	if @codMeniu in ('CDL','') and @tip='YM' -- tab continut
		select
		(
			select left(d.rand_decl,1) tert, max(t.denumire_macheta) as dentert, sum(d.nrfacturi) as nr_facturi, '' as dentip_op, 
				convert(decimal(15),sum(d.baza)) as baza, convert(decimal(15), sum(d.tva)) as tva,	--grup1
				(select d1.rand_decl tert, max(t1.denumire_macheta) as dentert, sum(d1.nrfacturi) as nr_facturi, '' as dentip_op, 
						convert(decimal(15),sum(d1.baza)) as baza, convert(decimal(15), sum(d1.tva)) as tva,	--grup2
						(select   rtrim(d2.cuiP) tert, d2.denP as dentert, d2.nrfacturi as nr_facturi, isnull(c.denumire,'') as dentip_op, --grup3
								  convert(decimaL(15),d2.baza) as baza, convert(decimal(15),d2.tva) as tva, d2.cota_tva as cotatva,
								  ( select rtrim(f.factura) tert, rtrim(f.numarD) dentert, convert(varchar(10), f.data, 104) nr_facturi,   --grup 4 detaliere facturi
										tipD dentip_op, convert(decimal(15), f.baza) baza, convert(decimal(15),f.tva) as tva, f.cota_tva as cotatva
									from #facturi f
									where d2.cuiP=f.codfisc 
										and d2.tipop=f.tipop 
										and d2.cota_tva=f.cota_tva 
										and (f.cod_nomenclatura is null or f.cod_nomenclatura=d2.cod)-- and f.tipD is not null
									for xml raw, type
								  ), 
								  (case when @expandare>3 then 'Da' else 'Nu' end) as _expandat

						from #Decl394 d2
								left outer join #codnc394 c on c.codnc=d2.bun
							where  rtrim(d1.rand_decl)+'.cuiP'=rtrim(d2.rand_decl) and charindex('.cuiP',d2.rand_decl)<>0 --and d1.cota_tva=d2.cota_tva
								and (@facturi=0 or exists (select 1 from #facturi f1 where d2.cuiP=f1.codfisc and d2.tipop=f1.tipop and d2.cota_tva=f1.cota_tva 
													and (f1.cod_nomenclatura is null or f1.cod_nomenclatura=d2.cod)))
							order by d2.cota_tva
						for xml raw, type
						),
						(case when @expandare>2 then 'Da' else 'Nu' end) as _expandat
					from #Decl394 d1
						left outer join #denDecl394 t1 on t1.rand_decl=d1.rand_decl
					where left(d1.rand_decl,1) in ('C','D','E','F') and charindex('.cuiP',d1.rand_decl)=0 and left(d1.rand_decl,1)=left(d.rand_decl,1) 
					group by d1.rand_decl, t1.ordine
					order by t1.ordine
					for xml raw, type
				),
				(case when @expandare>1 then 'Da' else 'Nu' end) as _expandat
			from #Decl394 d
				left outer join #denDecl394 t on rtrim(t.rand_decl)=rtrim(left(d.rand_decl,1))+'+' and charindex('+',t.rand_decl)<>0 
			where left(d.rand_decl,1) in ('C','D','E','F') 
			group by left(d.rand_decl,1)
			order by left(d.rand_decl,1)
			for xml raw, type
		)
		for xml path('Ierarhie'), root('Date')

	if @codMeniu='DTG' -- tab date generale
		select @codMeniu codMeniu, 
				max(case when rand_decl='A_calitate_intocmit' then rtrim(denumire) else '' end) as calitate,
				max(case when rand_decl='A_cif_intocmit' then rtrim(denumire) else '' end) as intocmit,
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
				max(case when rand_decl='A_nrcasemarcat' then rtrim(nrCui) else 0 end) as nrcasemarcat
		from #Decl394 
		where (@multiFirma=1 or lm is null)
		for xml raw, root ('Date')

	if @codMeniu='DT3' -- tab date I.3
		select denumire_macheta as rand, (case when t.are_doc=0 then 'Nu' when t.are_doc=1 then 'Da' end) as chk, t.rand_decl as randdecl, ordine, 
				@codMeniu as codMeniu, @data as datalunii, 'AI' as subtip
		from #denDecl394 d
			left outer join #Decl394 t on d.rand_decl=t.rand_decl 
		where d.rand_decl like 'I.3.%'
		order by ordine
		for xml raw, root ('Date')

	if @codMeniu='DT1' -- tab date I.1
		select max(denumire_macheta) as rand, convert(decimal(15,0),SUM(baza)) as baza, convert(decimal(15,0),sum(tva)) as tva, cota_tva as cotatva,
				@codMeniu as codMeniu, @data as datalunii
		from #Decl394 d
			left outer join #denDecl394 t on d.rand_decl=t.rand_decl
		where d.rand_decl like 'I.1%'
		group by d.rand_decl, d.cota_tva
		order by d.rand_decl, d.cota_tva
		for xml raw, root ('Date')

if @codMeniu='DTH' -- tab date G-H
		select(
			select 'Sectiunea '+left(d.rand_decl,1)+'.' as codop, @codMeniu codMeniu, '' as locm, '' as denlm, --grup1
				(select  rtrim(d1.rand_decl) as codop,	'' as locm, '' as denlm, --grup2, 
						(select   d2.denumire_macheta as tipop, nrfacturi as nrfact, convert(decimaL(15),t.incasari) as incasari, convert(decimaL(15),t.baza) as baza, 
							t.lm as locm, lm.Denumire denlm, convert(decimal(15),t.tva) as tva, t.cota_tva as cotatva, 
							rtrim(d2.rand_decl)+'.'+convert(char(2),t.cota_tva) as cdecl, 'AH' as subtip
								--grup3
							from #Decl394 t 
								left outer join #denDecl394 d2 on 
								d2.rand_decl+'.'+convert(char(2),t.cota_tva)=t.rand_decl++'.'+convert(char(2),t.cota_tva)
													--and t.cota_tva=d1.cota_tva
								left outer join lm on lm.cod=t.lm
							where t.rand_decl=d1.rand_decl 
							for xml raw, type
						),
						(case when @expandare>2 then 'Da' else 'Nu' end) as _expandat, 'AH' as subtip
				from #Decl394 d1 where left(d.rand_decl,1)=left(d1.rand_decl,1)
				group by d1.rand_decl, d1.data
				for xml raw, type),
				(case when @expandare>1 then 'Da' else 'Nu' end) as _expandat, 'AH' as subtip
			from #Decl394 d
			where left(d.rand_decl,1) in ('G','H')
			group by left(d.rand_decl,1)
			order by left(d.rand_decl,1)
			for xml raw, type
		)
		for xml path('Ierarhie'), root('Date')

	if @codMeniu='DT2' --tab date I.2
		select(
			select replace(d.rand_decl,'I.','')+'. '+max(d.denumire_macheta) as tipop, @codMeniu codMeniu, d.rand_decl as cdecl, --grup1
				(select  ' Facturi de la seria/nr. -  la seria/nr.' as tipop, d1.serieI as seriai, d1.nrI as numari, d1.serieF as seriaf, d1.nrF as numarf, d1.rand_decl	as cdecl,	--grup2, 
						(case when @expandare>2 then 'Da' else 'Nu' end) as _expandat, 'A1' as subtip, d1.tip as tipf
				from #Decl394 d1
				where d1.rand_decl=d.rand_decl and right(rtrim(d1.rand_decl),1)<>'F'
				for xml raw, type),
				(select 'Facturi' as tipop, @codMeniu as codMeniu, 'I.2.2.F' as cdecl, 'A2' as subtip, (case when @expandare>1 then 'Da' else 'Nu' end) as _expandat,
				(select * from 
				(select 'Factura '+(case when d2.tip=1 then 'stornata' when d2.tip=2 then 'anulata' when d2.tip=3 then '- autofactura' end) as tipop, 
				(case when d2.tip=1 then 'Facturi stornate' when d2.tip=2 then 'Facturi anulate' when d2.tip=3 then 'Autofacturi' end) as seriaf, 
						d2.seriei as seriai, d2.nri as numari, d2.tip as tipf, d2.rand_decl as cdecl, 'A2' as subtip, d2.baza, d2.tva, d2.cota_tva as cotatva
					from #Decl394 d2 
					where d2.rand_decl='I.2.2.F' and substring(d2.rand_decl,1,5)=d.rand_decl 
				union all 
				 select '', '', '', '', '', 'I.2.2.F', 'A2','','','' where not exists (select 1 from #Decl394 where rand_decl='I.2.2.F' and substring(rand_decl,1,5)=d.rand_decl)
				 ) a
				for xml raw, type) where d.rand_decl like 'I.2.2%' for xml raw, type),
				(case when @expandare>1 then 'Da' else 'Nu' end) as _expandat, 'A1' as subtip
			from #denDecl394 d
			where (d.rand_decl like 'I.2.%')
			group by d.rand_decl
			order by d.rand_decl
			for xml raw, type
		)
		for xml path('Ierarhie'), root('Date')

	if @codMeniu='DT4' --tab date I.4
		select (
		select max(d1.denumire_raport) tipop, convert(decimal(15,2),sum(tva)) tva, max(cota_tva) cota_tva, @codMeniu codMeniu, left(d.rand_decl,3) rand_decl,
			(select d3.denumire_raport tipop, convert(decimal(15,2),tva) tva, cota_tva, d2.rand_decl
				from #Decl394 d2
					left outer join #denDecl394 d3 on d3.rand_decl=d2.rand_decl
				where left(d2.rand_decl,3)=left(d.rand_decl,3)
				for xml raw, type
			), (case when @expandare>1 then 'Da' else 'Nu' end) as _expandat
		from #Decl394 d
			left outer join #denDecl394 d1 on d1.rand_decl=left(d.rand_decl,3)
		where d.rand_decl like 'I.4%' or d.rand_decl like 'I.5%'
		group by left(d.rand_decl,3)
		order by left(d.rand_decl,3)
		for xml raw, type
		)
		for xml path('Ierarhie'), root('Date')

	if @codMeniu='DT6' --tab date I.6
		select d1.denumire_raport tipop,  convert(decimal(15,2),incasari) incasari, convert(decimal(15,2),nrI) cheltuieli, convert(decimal(15,2),baza) marja, convert(decimal(15,2),tva) tva, 
				cota_tva, @codMeniu codMeniu, d.rand_decl randdecl, 'I6' subtip, @data as datalunii
		from #Decl394 d
			left outer join #denDecl394 d1 on d1.rand_decl=d.rand_decl
		where d.rand_decl like 'I.6%'
		order by left(d.rand_decl,3)
		for xml raw, type

	if @codMeniu='DT7' --tab date I.7
		select d.denumire activitate, convert(decimal(15,2),baza) valori, convert(decimal(15,2),tva) tva, 
				cota_tva, @codMeniu codMeniu, d.rand_decl randdecl, @data as datalunii, 'I7' subtip, rtrim(isnull(c.cod,''))+'-'+rtrim(isnull(c.denumire,'')) denactiv
		from #Decl394 d
			left outer join #denDecl394 d1 on d1.rand_decl=d.rand_decl
			left outer join #codCaen394 c on c.cod=d.denumire
		where d.rand_decl like 'I.7%'
		order by left(d.rand_decl,3)
		for xml raw, type
end
