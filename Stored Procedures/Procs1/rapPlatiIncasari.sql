--***
create procedure rapPlatiIncasari (@sesiune varchar(50)='', @dataJos datetime, @dataSus datetime, @cont varchar(4000)=null, @contcoresp varchar(40)=null,
	@gtert varchar(50)=null, @tert varchar(50)=null, @tip char(1)=null, @tipPlata char(2)=null, @valuta varchar(3)=null,
	@grupare varchar(50)='D'	/*=	Data & document,
									Cont & cont corespondent,
									Loc munca & data,
									Indicator bugetar & cont corespondent
							*/
	, @locm varchar(100)=null
	,@comanda varchar(100) = null
	,@indicator varchar(100) = null
	,@numarjos varchar(100) = null, @numarsus varchar(100) = null		--> interval numere de document
	,@jurnal varchar(20)=null
	)
as
set transaction isolation level read uncommitted
declare @eroare varchar(2000)
select @eroare=''
begin try
	declare @utilizator varchar(20), @bugetari int
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output

	exec luare_date_par 'GE','BUGETARI',@bugetari output,0,''
/*
declare @dataJos datetime, @dataSus datetime, @cont varchar(40), @contcoresp varchar(40), @tert varchar(50), @tip char(1), @tipPlata char(2) --PF,PC,PD,PR,PS,IB,IC,ID,IR,IS
select @dataJos='8/1/2014', @dataSus='8/31/2014', @cont=null, @contcoresp=null, @tert=null, @tip='i', @tipPlata=null
exec rapPlatiIncasari @dataJos=@datajos, @dataSus=@dataSus, @grupare='I'
--*/
	select @tip=isnull(@tip,''), @tipPlata=isnull(@tipPlata,'')	--> optimizeaza functionarea procedurii (combo-urile nu pot contine null in valori in rapoartele Ria, altfel functioneaza ciudat)
			, @locm=@locm+'%'
			, @cont=replace(@cont,';',',')	--> sa se poata folosi si separatorul ';' pana cand se rezolva autocomplete-ul

	IF OBJECT_ID('tempdb..#rapPozplin') is not null drop table #rapPozplin
	IF OBJECT_ID('tempdb..#filtre_conturi') is not null drop table #filtre_conturi
	
	select item cont into #filtre_conturi
	from dbo.split(@cont,',')

	--> initializari/conversii parametri:
		declare @z varchar(100)
		select @z='zzzzzzzzzzzzzzzz'
		select @numarjos=replace(isnull(@numarjos,''),'%',''), @numarsus=replace(isnull(@numarsus,@z),'%',@z)
	select 
-->	grupari:	
		rtrim(case @grupare	when 'D' then convert(varchar(20),p.data,102)
							when 'C' then p.cont
							when 'L' then p.loc_de_munca
							when 'I' then ''	--pentru gruparea pe indicatori, indicatorul se completeaza mai jos unde se apeleaza procedura indbugPozitieDocument
					end) grupare1,
		rtrim(case @grupare	when 'D' then convert(varchar(20),p.data,103)
							when 'C' then p.cont
							when 'L' then l.denumire
							when 'I' then ''	--pentru gruparea pe indicatori, indicatorul se completeaza mai jos unde se apeleaza procedura indbugPozitieDocument
					end) denumiregrupare1,
		rtrim(case @grupare	when 'D' then p.numar
							when 'C' then p.cont_corespondent
							when 'L' then convert(varchar(20),p.data,102)
							when 'I' then p.cont_corespondent
					end) grupare2,
		rtrim(case @grupare	when 'D' then p.numar
							when 'C' then p.cont_corespondent
							when 'L' then convert(varchar(20),p.data,103)
							when 'I' then p.cont_corespondent
					end) denumiregrupare2,
-->	sume si alte informatii:
		p.Cont, p.data as data, p.data as datapoz,p.Numar,p.Plata_incasare, RTRIM(p.plata_incasare)+'-'+RTRIM(p.numar) as numarpoz ,p.Tert,
		rtrim(isnull(t.Denumire,p.Explicatii))+(case when p.jurnal<>'' then ' \ '+rtrim(p.jurnal) else '' end) as Denumire,p.Factura,p.Cont_corespondent,
		(case when left(p.plata_incasare,1)='I' then (case when ISNULL(@valuta,'')<>'' then  p.Suma_valuta else p.Suma end) else 0 end) as Incasari,
		(case when left(p.plata_incasare,1)='P' then (case when ISNULL(@valuta,'')<>'' then  p.Suma_valuta else p.Suma end) else 0 end) as Plati,
		p.Valuta,p.Suma_valuta,p.Loc_de_munca,l.denumire as denlm,left(p.Comanda,20) as Comanda,isnull(c.descriere,'') as dencomanda,p.idPozplin,convert(varchar(20),'') as indbug, p.jurnal
	into #rapPozplin
	from pozplin p
		left outer join terti t on t.tert=p.Tert
		left outer join lm l on l.Cod=p.Loc_de_munca
		left outer join comenzi c on c.Comanda=left(p.Comanda,20)
	where p.data between @dataJos and @dataSus
		and (@cont is null or exists (select 1 from #filtre_conturi f where p.cont like f.cont+'%'))
		and (@contcoresp is null or p.Cont_corespondent like rtrim(@contcoresp)+'%')
		and (@tert is null or p.tert=@tert)
		and (@gtert is null or t.grupa=@gtert)
		and (@tipPlata='' or p.Plata_incasare=@tipPlata)
		and (@tip='' or left(p.Plata_incasare,1)=@tip)
		and (@valuta is null or p.Valuta=@valuta)
		and (@locm is null or p.loc_de_munca like @locm)
		and (@comanda is null or left(p.comanda,20)=@comanda)
		and p.numar between @numarjos and @numarsus
		and len(p.numar) between len(@numarjos) and len(@numarsus)	--> filtrarea pe numar de document sa fie si in functie de numarul de caractere specificat
		and (@jurnal is null or rtrim(p.jurnal)=@jurnal)
	order by 1,3

	/* apelam procedura unica de stabilire a indicatorului bugetar pentru fiecare pozitie de document */
	if @Bugetari=1 and exists (select * from sysobjects where name ='indbugPozitieDocument' and xtype='P')
	begin
		select '' as furn_benef, 'pozplin' as tabela, idPozplin as idPozitieDoc, indbug into #indbugPozitieDoc 
		from #rapPozplin
		exec indbugPozitieDocument @sesiune=@sesiune, @parXML=null
		update p set p.indbug=ib.indbug, 
			p.grupare1=rtrim((case @grupare when 'I' then ib.indbug else p.grupare1 end)),
			p.denumiregrupare1=rtrim((case @grupare when 'I' then ib.indbug else p.denumiregrupare1 end))
		from #rapPozplin p
			left outer join #indbugPozitieDoc ib on ib.idPozitieDoc=p.idPozplin
		
		if @indicator is not null
		delete r from #rapPozPlin r where r.indbug<>@indicator
	end

	select rtrim(grupare1) as grupare1, rtrim(denumiregrupare1) as denumiregrupare1, rtrim(grupare2) as grupare2, rtrim(denumiregrupare2) as denumiregrupare2,
		Cont, data, datapoz, Numar, Plata_incasare, numarpoz, Tert, Denumire, Factura, Cont_corespondent,
		Incasari, Plati, Valuta, Suma_valuta, Loc_de_munca, denlm, Comanda, dencomanda, jurnal
	from #rapPozplin
	order by 1,3
	
end try
begin catch
	select @eroare=error_message()+' (rapPlatiIncasari)'
end catch
if len(@eroare)>0
	select '<EROARE>' as grupare1, @eroare as denumiregrupare1, '' as grupare2, '' as denumiregrupare2,
		'' Cont, '' data, '' datapoz, '' Numar, '' Plata_incasare, '' numarpoz, '' Tert, '' Denumire, '' Factura, '' Cont_corespondent,
		'' Incasari, '' Plati, '' Valuta, '' Suma_valuta, '' Loc_de_munca, '' denlm, '' Comanda, '' dencomanda, '' jurnal
