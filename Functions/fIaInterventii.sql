
--***
create function fIaInterventii (@sesiune varchar(50),@parXML XML)
--(@datajos datetime, @datasus datetime, @pMasina varchar(20), @pElement varchar(20))
returns @interventii table (masina varchar(20), den_masina varchar(40), nr_inmatriculare varchar(20), element varchar(20),
		denumire varchar(60), tip varchar(50), fisa varchar(20), data datetime, km decimal(20,2), 
		explicatii varchar(200), tipInterval varchar(50), tipMasina varchar(50))
as
begin

--set transaction isolation level READ UNCOMMITTED
if exists(select * from sysobjects where name='fIaInterventiiSP')
	insert into @interventii(masina, den_masina, nr_inmatriculare, element,
		denumire, tip, fisa, data, km, 
		explicatii, um)
	select masina, den_masina, nr_inmatriculare, element,
		denumire, tip, fisa, data, km, 
		explicatii, um
		from dbo.fIaInterventiiSP(@sesiune,@parXML)

declare @eroare varchar(1000),  @pMasina varchar(20), @pElement varchar(20), @datajos datetime, @datasus datetime, @den_masina varchar(50),
		@codMasina varchar(40), @tipinterventii varchar(50), @cautare varchar(200), @denumire varchar(100), @fltElement varchar(100),
		@tipMasina varchar(100), @dinMacheta int
set @eroare=''

begin
	/*	--tst	pt teste
	declare @pMasina varchar(20), @pElement varchar(20), @datajos datetime, @datasus datetime
	select @datajos='2011-1-1',@datasus='2011-8-31', @pMasina='1'--,@pElement='casco'
		-- precedenta: select * from fisamasina(@datajos, @datasus, @pMasina, @pElement,null)
	--*/
	---------------------------------------
	declare @primazi datetime
	select @primazi='1901-1-1'
	/*dateadd(M,1,
	convert(datetime,
	convert(varchar(4),(select max(val_numerica) from par where par.Parametru='ANULIMPL' and Tip_parametru='GE'))+'-'+
	convert(varchar(2),(select max(val_numerica) from par where par.Parametru='LUNAIMPL' and Tip_parametru='GE'))+'-1')
	)*/

	select 
	@pElement=REPLACE(ISNULL(@parXML.value('(/row/@element)[1]', 'varchar(40)'), ''), ' ', '%'), 
	@den_masina=REPLACE(ISNULL(@parXML.value('(/row/@den_masina)[1]', 'varchar(40)'), ''), ' ', '%'),
	@codMasina=REPLACE(ISNULL(@parXML.value('(/row/@codMasina)[1]', 'varchar(40)'), ''), ' ', '%'),
	@datajos=isnull(@parXML.value('(/row/@datajos)[1]', 'datetime'),'1901-1-1'),
	@datasus=isnull(@parXML.value('(/row/@datasus)[1]', 'datetime'),'2100-1-1'),
	@tipinterventii=isnull(@parXML.value('(/row/@tipinterventii)[1]', 'varchar(50)'),''),
	@cautare=isnull(@parXML.value('(/row/@_cautare)[1]', 'varchar(50)'),''),
	@denumire=isnull(@parXML.value('(/row/@denumire)[1]', 'varchar(50)'),''),
	@fltElement=replace(isnull(@parXML.value('(/row/@fltElement)[1]', 'varchar(100)'),''),' ','%'),
	@tipMasina=replace(isnull(@parXML.value('(/row/@tipMasina)[1]', 'varchar(100)'),''),' ','%'),
	@dinMacheta=(case when isnull(@parXML.value('(/row/@tip)[1]', 'varchar(100)'),'')='' then 0 else 1 end)
	
	if (@dinMacheta=1) set @codMasina=rtrim(@codMasina)+'%'
	if (len(@cautare)=1 or @cautare like 'Recomand%' or @cautare like 'Efectuat%')
	begin
		set @tipinterventii=@cautare
		set @cautare=''
	end
	set @tipinterventii=left(@tipinterventii,1)				--> tipinterventii E/R/<toate>
	declare @efectuate table(masina varchar(50), nr_inmatriculare varchar(50), element varchar(50),
		denumire varchar(200), tip varchar(1), fisa varchar(20), data datetime, km decimal(20,2), 
		ultima int, valoare decimal(20,2), explicatii varchar(1000),um2 varchar(10), data_ultima datetime,
		um varchar(10), numar_pozitie int, tip_activitate varchar(20))
/**	interventii efecutate; se foloseste si pentru a calcula interventiile recomandate */
	insert into @efectuate (masina, nr_inmatriculare, element,
		denumire, tip, fisa, data, km,
		ultima, valoare, explicatii, um2, data_ultima, um, numar_pozitie, tip_activitate)
	select m.cod_masina masina, m.nr_inmatriculare, e.cod element, e.denumire, 
	left(a.tip,1) tip, 
	convert(varchar(20),ea.fisa), ea.data, --dbo.kmbord(m.cod_masina, ea.data, ea.fisa, ea.numar_pozitie) 
	convert(decimal(20,2),0) km,
	0 as ultima,c.Interval as valoare, pa.Explicatii explicatii, e.UM2, ea.data as data_ultima, e.UM,
	ea.numar_pozitie, t.tip_activitate
	from masini m
		inner join grupemasini g on m.grupa=g.Grupa
		inner join tipmasini t on t.Cod=g.tip_masina
		inner join activitati a on m.cod_masina=a.masina
		inner join pozactivitati pa on pa.Tip=a.Tip and pa.Fisa=a.Fisa and pa.Data=a.Data
		inner join elemactivitati ea on a.fisa=ea.fisa and a.data=ea.data and a.tip=ea.tip and pa.Numar_pozitie=ea.Numar_pozitie
		inner join elemente e on e.cod=ea.element
		inner join elemtipm et on g.tip_masina=et.tip_masina and et.element=e.cod
		left join coefmasini c on c.Masina=m.cod_masina and e.Cod=c.Coeficient
	where (isnull(@pMasina, '')='' or rtrim(m.cod_masina)=@pMasina)
		and (@den_masina='' or m.denumire like'%'+@den_masina+'%')
		and (isnull(@pElement, '')='' or e.cod=@pElement) and e.tip='I'
		and substring(a.tip,2,1)='I'
		
	declare @element_km varchar(20), @element_ore varchar(20)
	select @element_km='Kmef', @element_ore='OLE'
	
	update e set e.km=isnull(ea.Valoare,0)
	from @efectuate e 
		left join activitati a on e.masina=a.Masina
		inner join elemactivitati ea on a.fisa=ea.fisa and a.data=ea.data and a.Tip=ea.Tip --and e.Numar_pozitie=ea.Numar_pozitie
					and (e.tip_activitate='P' and ea.Element=@element_km or e.tip_activitate='L' and ea.Element=@element_ore)
	where not exists(select 1 from activitati a1
			inner join elemactivitati ea1 on a1.Fisa=ea1.Fisa and a1.Data=ea1.Data
			where a.masina=a1.masina and ea.Element=ea1.Element and ea.tip=ea1.tip and ea.data<ea1.data)
			
	update e set ultima=1
	from @efectuate e where not exists (select 1 from @efectuate e2 where e.masina=e2.masina and e.element=e2.element and e.Data<e2.Data)
/**	interventii efecutate si recomandate */
	declare @tinterventii table(masina varchar(20), nr_inmatriculare varchar(20), element varchar(20),
		denumire varchar(60), tip varchar(1), fisa varchar(20), data datetime, km decimal(20,2), 
		--ultima int, valoare decimal(20,2), 
		explicatii varchar(100),
		um2 varchar(3), data_ultima datetime, km_ultimi decimal(20,2),
		um varchar(3))
	insert into @tinterventii(masina, nr_inmatriculare, element,
		denumire, tip, fisa, data, km,
		explicatii, um2, data_ultima, km_ultimi, um)
	select e.masina, e.nr_inmatriculare, e.element, e.denumire, 
			convert(varchar(20),e.tip), convert(varchar(20),e.fisa),  e.data, e.km, e.explicatii, 
				e.UM2, data as data_ultima, isnull(km,0) as km_ultimi, e.UM
	from @efectuate e where e.data between @datajos and @datasus
	union all
	select m.cod_masina, m.nr_inmatriculare, e.cod, e.denumire, 
			'R' tip,'<Recomandare>' Fisa
			--,(case when e.um2<>'D' then e.Interval+isnull(i.km,0) else 0 end)
			,(case when i.data is not null and e.um2='D' then dateadd(M,c.Interval,i.data) 
					else '1901-1-1' end) data,(case when e.um2<>'D' then c.Interval+isnull(i.km,0) else 0 end), '' explicatii, e.UM2, i.data as data_ultima, isnull(i.km,0) as km_ultimi,
			e.UM
	from masini m
		inner join grupemasini g on m.grupa=g.Grupa
		inner join coefmasini c on c.Masina=m.cod_masina
		inner join elemente e on e.Cod=c.Coeficient
		left join elemtipm et on g.tip_masina=et.tip_masina and 
		et.Element=c.Coeficient and et.element=e.cod
		left outer join
		@efectuate i
			on m.cod_masina=i.masina and e.cod=i.element and ultima=1 
	where e.tip='I' and 
			(isnull(@pMasina, '')='' or m.cod_masina=@pMasina)
			and (@den_masina='' or m.denumire like'%'+@den_masina+'%')
			and (isnull(@pElement, '')='' or e.cod=@pElement)
	--tst	select masina, nr_inmatriculare, element, denumire, tip, fisa, data, km from #interventii i where i.tip<>'R' or i.data>=@datajos
/**	calcul date estimative (luni daca se masoara in kilometri, kilometri daca se masoara in luni)
		Fie K= numar de kilometri (efectivi) parcursi in total de masina
			L= intervalul (in luni) in care au fost parcursi K
				- L se calculeaza prin diferenta (in zile) max(pozactivitati.data_sosirii)-min(pozactivitati.data_plecarii) din dreptul elem 'KmEf',
					inmultit cu 12 (luni pe an) si impartit la 365 de zile (impartire reala)
		
		Pentru elemente masurate in luni (UM2='D') - se cunoaste LC=numar luni - se pot afla kilometri estimati KE dupa formula
			KE=(LC*K)/L
			
		Pentru elemente masurate in kilometri (UM2='A') - se cunoaste KC=numar kilometri - se pot afla lunile estimate LE dupa formula	
			LE=(KC*L)/K
*/

	declare @date_estimate table(element varchar(20), UM2 varchar(3), masina varchar(20), km_estimati decimal(20,2), luni_estimate decimal(20,2))
	insert into @date_estimate (element ,UM2 ,masina, km_estimati, luni_estimate)
	select e.Cod as element,max(e.um2) UM2, a.masina,
	(case when datediff(d,min(pa.Data_plecarii),max(pa.Data_sosirii))=0 or max(e.UM2)<>'D' then 0 else
	(sum(ea.valoare)*max(c.interval))/(convert(float,datediff(d,min(pa.Data_plecarii),max(pa.Data_sosirii))*12)/365) end) as km_estimati,
	(case when convert(float,sum(ea.valoare))=0 or max(e.UM2)<>'A' then 0 else
	(max(convert(float,c.interval))*
		(convert(float,datediff(d,min(pa.Data_plecarii),max(pa.Data_sosirii))*12)/365))/convert(float,sum(ea.valoare)) end) as luni_estimate
	from elemactivitati ea
	inner join activitati a on ea.Fisa=a.Fisa and ea.Tip=a.Tip
	inner join pozactivitati pa on ea.Fisa=pa.Fisa and ea.Tip=pa.Tip and ea.Numar_pozitie=pa.Numar_pozitie
	inner join coefmasini c on c.Masina=a.Masina
	inner join elemente e on c.Coeficient=e.Cod
	inner join masini m on m.cod_masina=a.Masina
	inner join grupemasini gr on gr.Grupa=m.grupa
	inner join tipmasini t on gr.tip_masina=t.Cod
	where (t.Tip_activitate='P' and rtrim(ea.element)=@element_km or t.Tip_activitate='L' and rtrim(ea.element)=@element_ore)
		and e.UM2 in ('D','A')
	group by ea.element, a.masina, e.Cod
	--/*
	update i set	i.km=(case when e.UM2='D' then i.km_ultimi+round(e.km_estimati,0) else i.km end),
					i.Data=(case when e.UM2='A' then dateadd(M,round(e.luni_estimate,3),i.data_ultima) else i.Data end)
	from @tinterventii i inner join @date_estimate e on i.masina=e.Masina and i.element=e.element
		and i.tip='R' --*/
	delete from @tinterventii where tip='R' and data>@datasus
/**	select-ul final */
	insert into @interventii(masina, den_masina, nr_inmatriculare, element,
		denumire, tip, fisa, data, km,
		explicatii, tipInterval, tipMasina)
    select
    rtrim(i.masina) as masina,
    RTRIM(m.denumire) as den_masina,
    rtrim(i.masina) as nr_inmatriculare,
    rtrim(i.element) as element,
    rtrim(i.denumire) as denumire,
    i.tip,
    --rtrim(case when i.tip='R' then 'Recomandare' else 'Efectuata' end) as tip, 
    rtrim(convert(varchar(20),i.fisa)) as fisa,
    i.data
    /*rtrim(case when isnull(i.data_ultima,'1901-1-1')>'1901-1-1' 
					then convert(varchar(20),i.data,103) else '<'+convert(varchar(20),i.data,103)+'>' end)
		--+(case when UM2='A' then '(Est.)' else '' end)*/
		as data,
    rtrim(i.km)as km,
    rtrim(i.explicatii) explicatii, 
    i.um2 as tipInterval,
    rtrim(t.Denumire) as tipMasina
    from @tinterventii i--where tip<>'R' or data>=@datajos
		inner join masini m on m.cod_masina=i.masina
		left join grupemasini g on m.grupa=g.Grupa
		left join tipmasini t on g.tip_masina=t.Cod
		 where(@den_masina='' or m.denumire like'%'+@den_masina+'%')
			and (@codMasina='' or m.cod_masina like @codMasina)
		 and ((@fltElement='' or i.denumire like '%'+@fltElement+'%') or (@fltElement='' or i.element like '%'+@fltElement+'%'))
		 and (@denumire='' or m.denumire like'%'+@denumire+'%')
		 and (@tipinterventii not in ('E','R') or @tipinterventii='E' and tip<>'R' or @tipinterventii=tip)
		 and (@cautare='' or convert(varchar(20),fisa)=@cautare or element=@cautare)
		 and (@tipMasina='' or t.Denumire like '%'+replace(@tipMasina,' ','%')+'%')
	order by i.data,data_ultima
	
	return
end
end