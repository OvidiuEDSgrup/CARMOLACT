--***
create procedure wIaPlin @sesiune varchar(50), @parXML xml
as
if isnull(@parXML.value('(/row/@tip)[1]', 'varchar(2)'), '')='DE'
begin
	exec wIaDeconturi @sesiune=@sesiune, @parXML=@parXML
	return 
end

declare @Sub char(9), @userASiS varchar(10), @lista_lm bit, @lista_conturi bit, @DecGrCont int, 
	@tip varchar(2), @cont varchar(40), @data_jos datetime, @data_sus datetime, @data datetime, 
	@tplati_jos float, @tplati_sus float, @tinc_jos float, @tinc_sus float, 
	@fcont varchar(40), @fdencont varchar(80), @flm varchar(9),@f_cont_corespondent varchar(13), @fdentert varchar(80), @lista_jurnale bit, @jurnal varchar(20)
	, @tipRegistru int -- null=toate (compatibilitate in urma), 0=Lei, 1=Valuta
	
exec luare_date_par 'GE', 'SUBPRO', 0, 0, @Sub output
exec luare_date_par 'GE', 'DECMARCT', @DecGrCont output, 0, ''

if object_id('tempdb..#decalculat') is not null drop table #decalculat
if object_id('tempdb..#pozincon_debit') is not null drop table #pozincon_debit
if object_id('tempdb..#pozincon_credit') is not null drop table #pozincon_credit
if object_id('tempdb..#fltdec') is not null drop table #fltdec
if object_id('tempdb..#test') is not null drop table #test

select @tip = isnull(@parXML.value('(/row/@tip)[1]', 'varchar(2)'), ''), 
	@cont = isnull(@parXML.value('(/row/@cont)[1]', 'varchar(40)'), ''), 
	@jurnal = isnull(@parXML.value('(/row/@jurnal)[1]', 'varchar(20)'), ''), 
	@fcont = isnull(@parXML.value('(/row/@f_cont)[1]', 'varchar(40)'), ''), 
	@flm = ISNULL(@parXML.value('(/row/@f_lm)[1]', 'varchar(9)'),''),
	@fdencont = isnull(@parXML.value('(/row/@f_dencont)[1]', 'varchar(80)'),''), 
	@data_jos = isnull(@parXML.value('(/row/@datajos)[1]', 'datetime'), '01/01/1901'),
	@data_sus = isnull(@parXML.value('(/row/@datasus)[1]', 'datetime'), '12/31/2999'), 
	@data = @parXML.value('(/row/@data)[1]', 'datetime'), 
	@tplati_jos = isnull(@parXML.value('(/row/@f_tplatijos)[1]', 'float'), -99999999999),
	@tplati_sus = isnull(@parXML.value('(/row/@f_tplatisus)[1]', 'float'), 99999999999), 
	@tinc_jos = isnull(@parXML.value('(/row/@f_tincjos)[1]', 'float'), -99999999999),
	@tinc_sus = isnull(@parXML.value('(/row/@f_tincsus)[1]', 'float'), 99999999999), 
	@f_cont_corespondent = isnull(@parXML.value('(/row/@f_cont_corespondent)[1]', 'varchar(13)'), ''), 
	@fdentert = isnull(@parXML.value('(/row/@f_dentert)[1]', 'varchar(80)'),''), 
	@tipRegistru = @parXML.value('(/row/@tipRegistru)[1]', 'int')

if @data_sus<='01/01/1901' 
	set @data_sus='12/31/2999'

EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS OUTPUT
select @lista_lm=dbo.f_arelmfiltru(@userASiS), @lista_conturi=0
if exists (select 1 from proprietati where tip='UTILIZATOR' and cod=@userASiS and cod_proprietate='CONTPLIN' and valoare<>'')
	set @lista_conturi=1
IF EXISTS (select * from PropUtiliz where utilizator=@userASiS and proprietate='JURNAL')
	select @lista_jurnale = 1
if @lista_jurnale = 1 and (select count(1) from PropUtiliz where utilizator=@userASiS and proprietate='JURNAL')=1
begin
	select top 1 @jurnal=valoare from PropUtiliz where utilizator=@userASiS and proprietate='JURNAL'
	set @lista_jurnale=0
end

select top 100
	rtrim(p.subunitate) as subunitate, @tip tip,
	rtrim(p.cont) as cont, 
	rtrim(max(isnull(c.denumire_cont, ''))) as dencont, 
	convert(char(10), p.data, 101) as data, 
	rtrim(max(p.loc_de_munca)) as lm, 
	--(case when rtrim(max(p.valuta))='' and max(isnull(pr.valoare,''))<>'' then 
		rtrim(max(isnull(pr.valoare,''))) 
		--else rtrim(max(p.valuta)) end) 
		as valuta, 
	convert(decimal(15,4), max(p.curs)) as curs, 
	sum(convert(decimal(15,2), (case when left(p.plata_incasare, 1)='P' then p.suma else 0 end))) as totalplati, 
	sum(convert(decimal(15,2),(case when left(p.plata_incasare, 1)='P' then (case when p.valuta='' then 0 else p.suma_valuta end) else 0 end))) as totalplativaluta, 
	sum(convert(decimal(15,2), (case when left(p.plata_incasare, 1)='I' then p.suma else 0 end))) as totalincasari, 
	sum(convert(decimal(15,2), (case when left(p.plata_incasare, 1)='I' then (case when p.valuta='' then 0 else p.suma_valuta end) else 0 end))) as totalincasarivaluta,
	sum(p.suma) suma,
	sum(case when left(p.Plata_incasare,1)='I' then p.suma else -p.suma end) as total,

	convert(decimal(15,2),0) totalsold, 
	convert(decimal(15,2),0) soldinitial,
	convert(decimal(15,2),0) soldinitialvaluta,
	convert(decimal(15,2),0) rulajdebit,
	convert(decimal(15,2),0) rulajcredit,
	convert(decimal(15,2),0) soldfinal,
	convert(decimal(15,2),0) soldfinalvaluta,
	convert(decimal(15,2),0) rulajdebitvaluta,
	convert(decimal(15,2),0) rulajcreditvaluta,
	sum(1) as numarpozitii,
		
	--pentru tabul de inregistrari contabile:
	'PI' tipdocument,rtrim(p.Cont) as 'nrdocument', 
	(case when p.cont like '442%' then '#808080' when p.cont not like '5%' then '#0000FF' else '#000000' end) as culoare,
	ISNULL(p.jurnal,'') jurnal, 
	(case when p.cont like '5%' then '1' when p.cont like '442%' then '3' else '2' end) as ordonare
into #decalculat
from pozplin p
	left outer join conturi c on c.subunitate = p.subunitate and c.cont = p.cont 
	left outer join personal pers on pers.marca=p.marca
	left outer join terti t on t.subunitate=p.subunitate and t.tert=p.tert
	left outer join proprietati pr on pr.tip='CONT' and pr.cod=p.cont and pr.cod_proprietate='INVALUTA'
where p.subunitate=@Sub
	and (@tipRegistru is null or @tipRegistru=0 and isnull(pr.valoare,'')='' or @tipRegistru=1 and isnull(pr.valoare,'')!='')
	and not (p.Plata_incasare in ('PF','IB') and p.efect is not null) -- sa nu aduca date de pozplin legate de efecte - acestea sunt tratate in wIaEfecte
	and isnull(c.sold_credit, 0) not in (9)/*,8)*/
	and (@cont='' or p.cont=@cont) 
	and (@data is null or p.data=@data) 
	and (@jurnal = '' or p.jurnal=@jurnal)
	-- mai jos sunt filtre si auto-filtre
	and p.cont like @fcont + '%'
	and p.data between @data_jos and @data_sus
	and (@lista_lm=0 or /*lu.cod is not null*/ exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=p.Loc_de_munca ))
	and (@lista_conturi=0 or exists (select 1 from proprietati lc where RTrim(p.cont) like RTrim(lc.valoare)+'%' and lc.tip='UTILIZATOR' and lc.cod=@userASiS and lc.cod_proprietate='CONTPLIN'))
	and (@fdencont='' or (c.Denumire_cont like '%'+replace(@fdencont,' ','%')+'%'))
	and (@f_cont_corespondent='' or p.Cont_corespondent like '%'+@f_cont_corespondent+'%')
	and (@fdentert='' or (t.Denumire like '%'+replace(@fdentert,' ','%')+'%'))
	and ( ISNULL(@lista_jurnale,0) = 0 OR EXISTS (select 1 from PropUtiliz pu where pu.utilizator=@userASIS and pu.proprietate='JURNAL' and pu.valoare=p.jurnal))
	and (@flm='' or p.loc_de_munca like @flm + '%') -- acest filtru este foarte costisitor!
group by p.subunitate, p.cont, p.data, ISNULL(p.jurnal,'') --, p.Valuta 
-- Ghita: Oare sunt necesare astea de mai jos?	
/*having sum(convert(decimal(15,2), (case when left(p.plata_incasare, 1)='P' and p.plata_incasare<>'PS' then p.suma else 0 end))) between @tplati_jos and @tplati_sus
	and sum(convert(decimal(15,2), (case when left(p.plata_incasare, 1)='I' and p.plata_incasare<>'IS' then p.suma else 0 end))) between @tinc_jos and @tinc_sus */
order by p.cont, p.data desc


create table #conturi(cont varchar(20),valuta varchar(20) default '',data datetime,sid float,sic float,rd float,rc float,sd float,sc float)
insert into #conturi (cont,valuta, data)
	select distinct cont, '', data -- solduri in lei pt. toate conturile 
	from #decalculat
union all -- la registrul in valuta se iau si sumele in valuta 
	select distinct cont, valuta, data -- solduri in valuta la care au valuta pe cont 
	from #decalculat d 
	where valuta<>''
	--inner join proprietati pr on pr.tip='CONT' and pr.cod=d.cont and pr.cod_proprietate='INVALUTA'
	--where @tipRegistru=1 --and pr.valoare<>''

exec CalculSoldConturiPeZile @sesiune=@sesiune, @parXML=@parXML
-- => #conturi (cont varchar(20),valuta varchar(20) default '',data datetime,sid float,sic float,rd float,rc float,sd float,sc float)

update d -- soldurile in lei
set soldinitial=isnull(c.sid-c.sic,0), rulajdebit=isnull(c.rd,0), rulajcredit=isnull(c.rc,0), soldfinal=isnull(c.sd-c.sc,0)
	from #decalculat d
	left join #conturi c on c.cont=d.cont and c.data=d.data and c.valuta='' 

--if @tip='RV'
	update d -- soldurile in valuta 
	set soldinitialvaluta=isnull(c.sid-c.sic,0), rulajdebitvaluta=isnull(c.rd,0), rulajcreditvaluta=isnull(c.rc,0), soldfinalvaluta=isnull(c.sd-c.sc,0)
		from #decalculat d
		left join #conturi c on c.cont=d.cont and c.data=d.data and c.valuta=d.valuta 
		where c.valuta<>''

drop table #conturi

-->	calcul solduri finale:
update #decalculat set
	totalsold=soldinitial-totalplati+totalincasari

select subunitate, @tip tip, cont, dencont, data, lm, valuta, curs, 
	totalplati, totalplativaluta, totalincasari, totalincasarivaluta, totalsold, soldinitial, 
	soldinitialvaluta, rulajdebit, rulajcredit, soldfinal, soldfinalvaluta, numarpozitii, tipdocument, nrdocument, 
	(case when p.cont like '5%' and soldfinal<0 then '#FF0000' else culoare end) as culoare, jurnal
from #decalculat p
order by ordonare, cont, convert(datetime, data) desc 
for xml raw

if object_id('tempdb..#pozincon') is not null drop table #pozincon
if object_id('tempdb..#pozincon_debit') is not null drop table #pozincon_debit
if object_id('tempdb..#pozincon_credit') is not null drop table #pozincon_credit
if object_id('tempdb..#fltdec') is not null drop table #fltdec
if object_id('tempdb..#test') is not null 
begin
	select * from #test 
	drop table #test
end
