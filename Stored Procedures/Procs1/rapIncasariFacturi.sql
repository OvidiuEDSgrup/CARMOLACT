--***
create procedure rapIncasariFacturi(@dataJos datetime, @dataSus datetime
	,@grupare1 varchar(2)=null	--> null=unitate, 'LM' = loc de munca
	,@locm varchar(20)=null,
	@cont varchar(20)=null, @tert varchar(20)=null, @factura varchar(20)=null,
	@intervale varchar(200)=null, @procente varchar(200)=null,	-->@intervale si @procente vor contine lista de intervale si procente, separate prin ";"
	@comanda varchar(200)=null,
	@incasareefecte bit=0,	--> daca se tine cont de incasarea efectelor prin care s-au achitat facturi
	@contcorespondent varchar(20)=null	--> filtru pe cont corespondent
	,@gterti varchar(20)=null
	,@totaluriCoteTVA bit=1	--> daca sa apara la finalul raportului totaluri pe cote TVA luate din pozdoc
	)

as
begin
declare @eroare varchar(2000), @locatieEroare varchar(2000)	--> parametri pentru gestionarea eventualelor erori (de operare parametri in general)
begin try
	declare @utilizator varchar(20), @eLmUtiliz int 
	select @utilizator=dbo.fiautilizator('')
	declare @LmUtiliz table(valoare varchar(200))
	insert into @LmUtiliz(valoare)
	select cod from lmfiltrare where utilizator=@utilizator
	set @eLmUtiliz=isnull((select max(1) from @LmUtiliz),0)

	if object_id('tempdb..#facturi') is not null drop table #facturi
	if object_id('tempdb..#intervale') is not null drop table #intervale
	if object_id('tempdb..#procente') is not null drop table #procente
	if object_id('tempdb..#totaluri') is not null drop table #totaluri
--> pregatirea calculelor sumelor pe intervale si procente:
	select @intervale='-10001;'+@intervale+';10001',@procente=replace(@procente,',','.'), @locatieEroare='Conversii parametri'
	select row_number() over (order by convert(decimal(7),item)) as numar,
		convert(decimal(7),item) as interval
	into #intervale from dbo.split(@intervale,';')
	
	select row_number() over (order by convert(decimal(5,2),(select 1))) as numar,
		convert(decimal(5,2),item) as procent
	into #procente from dbo.split(@procente,';')
	select @locatieEroare='Dupa conversii'
	select i.numar, i.interval start_interval, i2.interval stop_interval,
			isnull(p.procent,0) procent, --space(200) denumire
			'TOTAL ('+(case when i.interval<=-10000 then '1-'+convert(varchar(20),i2.interval)
				when i2.interval>=10000 then '>'+convert(varchar(20),i.interval)
				else convert(varchar(20),i.interval+1)+'-'+
					convert(varchar(20),i2.interval) end)+')' as denumire
			into #totaluri
	from  #intervale i inner join #intervale i2 on i.numar=i2.numar-1
		left join #procente p on i.numar=p.numar
--> organizarea facturilor si incasarilor sub o forma convenabila:
	declare @flt_locm bit, @flt_cont bit, @flt_tert bit, @flt_factura bit, @flt_contcorespondent bit, @flt_gterti bit
	select	@flt_locm=(case when isnull(@locm,'')='' then 0 else 1 end),	--> filtrul pe loc de munca nu functiona de ceva vreme (nu era folosit); adaugat la loc de Luci Maier in 2014-07-14 la cererea Quantum
			@flt_cont=(case when @cont is null then 0 else 1 end),
			@flt_tert=(case when @tert is null then 0 else 1 end),
			@flt_factura=(case when @factura is null then 0 else 1 end),
			@flt_contcorespondent=(case when @contcorespondent is null then 0 else 1 end),
			@contcorespondent=@contcorespondent+'%',
			@flt_gterti=(case when  @gterti is null then 0 else 1 end),
			@locm=@locm+'%'
	select 'IB' tip, rtrim(p.factura) as factura, rtrim(p.tert) tert, rtrim(p.numar) numar,
		max(p.data) as data_inc,sum(p.suma) as suma_inc,
		sum(p.suma)*(case when sum(f.valoare+f.tva_11+f.tva_22)=0 then 1.00/1.24 else sum(f.valoare)/sum(f.valoare+f.tva_11+f.tva_22) end) as suma_inc_faratva,
		max(f.data) as data_facturii, sum(f.valoare+f.tva_11+f.tva_22) as valoare,
		row_number() over (partition by p.tert, p.factura order by p.data) as randFactura,
		max(rtrim(t.denumire)) as den_tert, max(f.data_scadentei) as data_scadentei,
		max(datediff(day,f.data,p.data)) as zileData,
		max(datediff(day,f.data_scadentei,p.data)) as zileScadenta,
		convert(decimal(20,4),0) incasat_efect, convert(varchar(100),'') efect,
		rtrim(p.cont) as cont
		,rtrim(p.loc_de_munca) loc_de_munca
		,convert(varchar(200),'') grupare1
		,convert(varchar(1000),'') den_grupare1
	into #incasari
	from pozplin p
		inner join conturi c on p.subunitate=c.subunitate and p.cont=c.cont
		left join facturi f on f.subunitate=p.subunitate and f.tert=p.tert and f.factura=p.factura and f.tip=0x46
		left join terti t on t.subunitate=p.subunitate and t.tert=p.tert
	where (@flt_locm=0 or p.loc_de_munca like @locm) and
		p.plata_incasare='IB' and p.suma<>0 
		and p.data between @dataJos and @dataSus 
		and (@flt_cont=0 or p.cont like @cont)
		and (@flt_contcorespondent=0 or p.Cont_corespondent like @contcorespondent)
		and (@flt_tert=0 or p.tert like @tert)
		and (@flt_factura=0 or p.factura like @factura)
		and (@flt_gterti=0 or t.grupa like @gterti)
		and (@comanda is null or left(p.comanda,20) like @comanda)
		and (@incasareefecte=0 or c.sold_credit<>'8')
		and (@eLmUtiliz=0 or exists (select 1 from @LmUtiliz u where u.valoare=p.Loc_de_munca))
	group by p.subunitate, p.factura, p.tert, p.numar, p.cont, p.data, p.numar_pozitie, f.tip, p.loc_de_munca
	union all
	select 'IE' tip, rtrim(p.factura) as factura, rtrim(p.tert) tert, rtrim(p.numar) numar,
		max(e.data_decontarii) as data_inc,sum(p.suma) as suma_inc,
		sum(p.suma)*(case when sum(f.valoare+f.tva_11+f.tva_22)=0 then 1.00/1.24 else sum(f.valoare)/sum(f.valoare+f.tva_11+f.tva_22) end) as suma_inc_faratva,
		max(f.data) as data_facturii, sum(f.valoare+f.tva_11+f.tva_22) as valoare,
		row_number() over (partition by p.tert, p.factura order by e.data_decontarii) as randFactura,
		max(rtrim(t.denumire)) as den_tert, max(f.data_scadentei) as data_scadentei,
		max(datediff(day,f.data,e.data_decontarii)) as zileData,
		max(datediff(day,f.data_scadentei,e.data_decontarii)) as zileScadenta,
		max(e.decontat) incasat_efect, max(p.efect) efect,
		rtrim(p.cont) as cont
		,rtrim(p.loc_de_munca) loc_de_munca
		,convert(varchar(200),'') grupare1
		,convert(varchar(1000),'') den_grupare1
	from pozplin p
		inner join conturi c on c.cont=p.cont and c.sold_credit='8' 
		inner join efecte e on e.subunitate=p.subunitate and e.cont=p.cont and e.tert=p.tert and e.nr_efect=p.efect
		left join facturi f on f.subunitate=p.subunitate and f.tert=p.tert and f.factura=p.factura and f.tip=0x46
		left join terti t on t.subunitate=p.subunitate and t.tert=p.tert
	where (@flt_locm=0 or p.loc_de_munca like @locm) and
		@incasareefecte=1
		and p.plata_incasare='IB' and abs(e.sold)<0.01
		and e.data_decontarii between @datajos and @datasus
		and (@flt_contcorespondent=0 or p.Cont_corespondent like @contcorespondent)
		and (@flt_cont=0 or p.cont like @cont)
		and (@flt_tert=0 or p.tert like @tert)
		and (@flt_factura=0 or p.factura like @factura)
		and (@flt_gterti=0 or t.grupa like @gterti)
		and (@comanda is null or left(p.comanda,20) like @comanda)
		and (@eLmUtiliz=0 or exists (select 1 from @LmUtiliz u where u.valoare=p.Loc_de_munca))
	group by p.subunitate, p.factura, p.tert, p.numar, p.cont, e.data_decontarii, p.numar_pozitie, f.tip, p.loc_de_munca

	if @grupare1 is not null
	update i set grupare1=rtrim(i.loc_de_munca),
				den_grupare1=rtrim(l.denumire)
	from #incasari i inner join lm l on i.loc_de_munca=l.cod
	
--> calcul ponderat al incasarilor achitate prin efecte si corectarea sumei facturilor pentru cazul achitarilor prin IB si IE a unei facturi:
	update i set i.suma_inc=i.incasat_efect*(s.suma_inc/(case when abs(s.incasat_efect)>0 then s.incasat_efect when abs(s.suma_inc)>0 then s.suma_inc else 1 end))
	,i.suma_inc_faratva=i.incasat_efect*(s.suma_inc_faratva/(case when abs(s.incasat_efect)>0 then s.incasat_efect when abs(s.suma_inc_faratva)>0 then s.suma_inc_faratva else 1 end))
	from #incasari i
		inner join 
			(select sum(isnull(suma_inc,0)) suma_inc, sum(isnull(incasat_efect,0)) incasat_efect
					,s.efect, s.factura, s.tert, sum(s.suma_inc_faratva) suma_inc_faratva
				from #incasari s where s.tip='IE' group by s.efect, s.factura, s.tert) s
			on s.efect=i.efect and s.tert=i.tert and s.factura=i.factura
	where i.tip='IE'
--> corectarea valorilor facturilor (din cauza celor doua select-uri - pt IB si IE - se dubleaza valorile facturilor care au fost achitate prin ambele metode):
	update i set i.valoare=i.valoare/s.n
	from #incasari i
		inner join (select count(distinct tip) n, s.tert, s.factura from #incasari s group by s.tert, s.factura) s
			on i.tert=s.tert and i.factura=s.factura

	create table #totaluriCoteTva (cota_tva_str varchar(100), cotatva decimal(10), valoare decimal(20,5))
	
	if @totaluriCoteTVA=1
	begin	--> trebuie grupate incasarile deoarece gruparea se face in #incasari pe lucruri in plus fata de factura, de exemplu numar de pozitie de pe incasare:
		select sum(i.suma_inc_faratva) suma_inc_faratva, i.tert, i.factura, i.data_facturii
		into #incasaripefacturi
		from #incasari i group by i.tert, i.factura, i.data_facturii
			
			--> iau sumele grupate din pozdoc, in plus pe cote:
		select p.cota_tva, sum(p.pret_vanzare*p.cantitate) as valpozdoc, convert(decimal(20,5),0) as suma_inc_faratva, p.tert, p.factura, p.data_facturii
		into #pozdocpefacturi
		from #incasaripefacturi i
				inner join pozdoc p on i.tert=p.tert and i.factura=p.factura and i.data_facturii=p.data_facturii
		group by p.tert, p.factura, p.data_facturii, p.cota_tva
		
			--> calculez incasat fara tva pe fiecare factura, proportional cu sumele din pozdoc de pe cotele tva:
		update p set suma_inc_faratva=i.suma_inc_faratva*p.valpozdoc/ps.valpozdoc
		from #pozdocpefacturi p inner join #incasaripefacturi i on p.tert=i.tert and p.factura=i.factura and p.data_facturii=i.data_facturii
				inner join (select sum(ps.valpozdoc) valpozdoc, ps.factura, ps.tert, ps.data_facturii from #pozdocpefacturi ps group by ps.factura, ps.tert, ps.data_facturii) ps
					on ps.tert=p.tert and ps.factura=p.factura and ps.data_facturii=p.data_facturii
			where abs(ps.valpozdoc)>=0.01
		
		insert into #totaluriCoteTva(cota_tva_str, cotatva, valoare)
		select convert(varchar(10), cota_tva) cota_tva_str, cota_tva, sum(suma_inc_faratva) from #pozdocpefacturi p group by cota_tva
		union all
		select 'Fara cota tva', 0, sum(suma_inc_faratva) from #incasaripefacturi i
			where not exists (select 1 from #pozdocpefacturi p where p.tert=i.tert and p.factura=i.factura and p.data_facturii=i.data_facturii)
		having abs(sum(suma_inc_faratva))>0.001
	end

--> selectarea finala a facturilor:
	select	factura, tert, numar, data_inc, suma_inc, suma_inc_faratva, zileData,
			data_facturii, (case when randFactura=1 then valoare else 0 end) valoare,
			valoare valoareDetaliu,	--> valoarea se ia in doua variante (valoare si valoareDetaliu)
								-->	pentru a se putea face usor totalizarea pe grupari
			den_tert, randFactura, data_scadentei, zileScadenta, 0 as date,
			rtrim(factura)+replicate('_',10-len(rtrim(factura)))+'| '
			+convert(varchar(100),data_facturii,103)+' | '
			+convert(varchar(100),data_scadentei,103)+' | '
			+rtrim(numar)+replicate('_',10-len(rtrim(numar)))+'| '
			+rtrim(cont)
				as denDetaliu, tip, cont
			,grupare1, den_grupare1, 0 totaluri
	from #incasari
	union all
--> informatii antet:
	select '<ANTET>' factura,'','','',0,0,0,
			'',0,0,
			'',0,'',0,0,'Factura___| Data facturii | Data scad | Numar_____| Cont','',''
			,'', '', 1 totaluri
	union all
--> urmatoarele doua select-uri iau sumele pentru intervale/procente:
	select	'','Procente','','1901-1-1',isnull(sum(suma_inc),0), isnull(sum(suma_inc_faratva),0), 0,
			'1901-1-1', isnull(sum(case when i.randFactura=1 then i.valoare else 0 end),0),
			isnull(sum(case when i.randFactura=1 then i.valoare else 0 end),0), '',
			1, '1901-1-1', 0, s.numar*2-1 as date, max(s.denumire), max(tip) tip, max(i.cont)
			,'', '', 1 totaluri
	from #totaluri s
		left join #incasari i on i.zileData between s.start_interval+1 and s.stop_interval
	group by s.numar, s.start_interval
	union all
	select	'','Procente','','1902-1-1',(isnull(sum(suma_inc),0)*s.procent)/100, (isnull(sum(suma_inc_faratva),0)*s.procent)/100,
			0, '1901-1-1',
			(isnull(sum(case when i.randFactura=1 then i.valoare else 0 end),0)*s.procent)/100,
			(isnull(sum(case when i.randFactura=1 then i.valoare else 0 end),0)*s.procent)/100,
			'', 1, '1901-1-1', 0, s.numar*2 as date,
			max(s.denumire)+'x'+convert(varchar(20),s.procent)+'%', max(tip) tip, max(i.cont)
			,'','', 1 totaluri
	from #totaluri s
		left join #incasari i on i.zileData between s.start_interval+1 and s.stop_interval
	group by s.numar,s.start_interval, s.procent
--/*	
	union all
--> totaluri valori incasate pe cote tva din pozdoc:
	select '', 'Incasat fara tva pe cote',null, null data_inc, t.valoare suma_inc, 0 suma_inc_faratva, null zileData,
			null data_facturii, null valoare,
			t.cotatva valoareDetaliu,
			null den_tert, null randFactura, null data_scadentei, null zileScadenta, 1000+cotatva as date,
			convert(varchar(10),t.cota_tva_str) as denDetaliu, null tip, null cont
			,'' grupare1, '' den_grupare1, 1 totaluri
	from #totaluriCoteTva t
	where @totaluriCoteTVA=1
--*/	
	order by date, tert, factura, data_facturii, data_inc

end try
begin catch
	select @eroare=error_message()
	set @eroare=rtrim(case when @eroare like 'Error converting data type varchar to numeric.' and @locatieEroare='Conversii parametri'
					then 'Nu sunt permise caractere in parametri "Intervale" si "Procente"!'+char(10)+
					'Acestia se completeaza cu separatorul ";" (de exemplu intervale="10;20;30")!' 
					else @eroare end)
	set @eroare=rtrim(@eroare)+' (rapIncasariFacturi '+convert(varchar(20),error_line())+')'
end catch

if object_id('tempdb..#facturi') is not null drop table #facturi
if object_id('tempdb..#intervale') is not null drop table #intervale
if object_id('tempdb..#procente') is not null drop table #procente
if object_id('tempdb..#totaluri') is not null drop table #totaluri

if len(@eroare)>0
	select 'EROARE' as tip, @eroare as den_tert
end
