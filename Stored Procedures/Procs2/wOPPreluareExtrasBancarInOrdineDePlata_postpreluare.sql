
Create procedure wOPPreluareExtrasBancarInOrdineDePlata_postpreluare @sesiune varchar(50)=null, @parXML xml
/**
	Procedura de procesare a datelor de pe transferuri; se executa dupa importul si distribuirea informatiilor - cate un transfer bancar pe linie din extraseBancare
*/
as
declare @eroare varchar(2000)	
select @eroare=''
begin try
	if object_id('tempdb..#deprocesat') is not null drop table #deprocesat
	declare @formula_extragere varchar(max), @comanda_sql varchar(max)
		, @idOP int, @contcor_pos varchar(100), @contcomision varchar(100)
		,@filtrare varchar(max)
	
	select @idOP=@parxml.value('(*/@idOP)[1]','int')
		,@contcor_pos='5125', @contcomision='622'
	
	-->	filtrez + extrag codul mt940 din detalii pentru procesarea ulterioara:
	select *, p.detalii.value('(row/@date)[1]','varchar(max)') as date, 0 as stare_operatiune, convert(decimal(15,2),0) as comision
	into #deprocesat
	from pozordinedeplata p
	where (@idop is not null and p.idop=@idop)
			and isnull(p.detalii.value('(row/@e_comision)[1]','varchar(1)'),'0')<>'1'
	
	--> completez prin detalii cu ce atribute am nevoie pe viitor:
		update d set detalii.modify('insert attribute contcor {""} into (row)[1]')
		from --pozordinedeplata p inner join 
			#deprocesat d --on p.idpozop=d.idpozop
		where d.detalii.exist('(row/@contcor)[1]')=0
		
		--> stare e o variabila prin care sa cunosc cum e linia - daca e gata pt pozplin sau ii lipsesc diverse
		update d set detalii.modify('insert attribute stare {"0"} into (row)[1]')
		from #deprocesat d
		where d.detalii.exist('(row/@stare)[1]')=0
		
		--> ordin e numarul operatiunii si va fi numarul in pozplin:
		update d set detalii.modify('insert attribute ordin {"0"} into (row)[1]')
		from #deprocesat d
		where d.detalii.exist('(row/@ordin)[1]')=0
	--<--------------------------->
	--> extrag datele:
	update d
			set d.data_scadentei=convert(datetime,substring(d.date,5,6))
				,d.tip=i.tip	--(case substring(d.date,11,2) when 'CN' then 'I' when 'DN' then 'P' else '' end)
				,d.suma=replace(substring(d.date,i.indx,charindex('N',d.date,i.indx)-i.indx),',','.')
				,d.explicatii=
					dbo.iaInfoDinMT940(d.date,'~25')+
					dbo.iaInfoDinMT940(d.date,'~26')+
					dbo.iaInfoDinMT940(d.date,'~27')+
					dbo.iaInfoDinMT940(d.date,'~28')+
					dbo.iaInfoDinMT940(d.date,'~29')+
					dbo.iaInfoDinMT940(d.date,'~30')+
					dbo.iaInfoDinMT940(d.date,'~31')
				,d.marca=substring(date,charindex('-',date,charindex('//',date))+1,charindex(':',date,5)-charindex('//',date))	--> temporar marca va retine numarul ordinului de plata
				,d.tert=''
				,d.factura=''
		from #deprocesat d
			cross apply(select (case when charindex('CN',d.date)>charindex('DN',d.date) and charindex('DN',d.date)<>0 or charindex('CN',d.date)=0 then charindex('DN',d.date) else charindex('CN',d.date) end)+2 indx
									,(case when charindex('CN',d.date)=0 or charindex('CN',d.date)>charindex('DN',d.date) and charindex('DN',d.date)<>0 then 'P' else 'I' end) as tip ) i
		
		declare @exista_linie_comision bit	--> daca exista o linie de comision in extrasul bancar nu voi mai lua comisionul de operatiune de pe fiecare linie deoarece consider ca e deja luat in calcul
					--> comisionul POS FEE e altceva, se ia fara legatura cu aceasta linie
		if exists (select 1 from #deprocesat d where dbo.iaInfoDinMT940(d.date,'~21') like '%total charges%')
			set @exista_linie_comision=1
		else set @exista_linie_comision=0
		
		--> al doilea update e necesar deoarece am nevoie de informatii extrase abia in primul:
		update d set comision=
				(case when @exista_linie_comision=0 and isnumeric(rtrim(substring(dbo.iaInfoDinMT940(d.date,'~21'),13,20)))=1
					then convert(decimal(15,2),
							replace(rtrim(substring(dbo.iaInfoDinMT940(d.date,'~21'),13,20)),',','.')
						)
					else 0 end)
				,d.marca=isnull(left(d.marca,charindex(':',d.marca)-1),'')	--> temporar marca va retine numarul ordinului de plata - aici finalizez extragerea lui
				,iban=rtrim(case when left(d.tip,1)<>'I' then dbo.iaInfoDinMT940(d.date,'~31') else dbo.iaInfoDinMT940(d.date,'~33')
						end)
		from #deprocesat d

		--> elimin conturile nevalide:
	update d set IBAN=''
	from #deprocesat d
	where len(d.IBAN)<>24
		
		--> completez banca:
	update d set banca=substring(replace(d.iban,' ',''),5,4)
			,suma=d.suma-d.comision
	from #deprocesat d
		
		--> identific tertii in functie de conturi:
			--> intai direct din tabela de terti
	update d set tert=rtrim(t.tert)
	from #deprocesat d
			inner join terti t on d.IBAN=replace(t.cont_in_banca,' ','') and replace(t.cont_in_banca,' ','')<>''
			--> a doua sansa din contbanci
	update d set tert=rtrim(c.tert)
	from #deprocesat d
		inner join contbanci c on d.IBAN=replace(c.cont_in_banca,' ','') and replace(c.cont_in_banca,' ','')<>''
		where rtrim(isnull(d.tert,''))=''
			
		--> adaug comisionul de la pos la totalul operatiunii (s-ar putea sa fie chestie specifica):
	update d set 
		suma=suma+convert(decimal(10,2),substring(x.datepos1,charindex('pos fee',x.datepos1)+7, 100)+left(x.datepos2,charindex(' ',x.datepos2)-1))
		,comision=comision+convert(decimal(10,2),substring(x.datepos1,charindex('pos fee',x.datepos1)+7, 100)+left(x.datepos2,charindex(' ',x.datepos2)-1))
	from #deprocesat d
		cross apply(select replace(dbo.iaInfoDinMT940(d.date,'~27'),',','.') as datepos1,
							replace(dbo.iaInfoDinMT940(d.date,'~28'),',','.') as datepos2)x
	where d.tert='' and x.datepos1 like '% POS FEE%'
	
-------------------------------
	--> linia de comision:
	if not exists(select 1 from #deprocesat p where isnull(p.detalii.value('(row/@e_comision)[1]','varchar(1)'),'0')='1')
	insert into #deprocesat(idOP, tert, marca, factura, decont, banca, IBAN, tip, explicatii, suma, stare, detalii, data_scadentei, soldscadent, stare_operatiune, comision)
	select @idop, '', 'CE'+replace(convert(varchar(10),max(isnull(d.data_scadentei,'1901-1-1')),102),'.',''), '', '', '','', 'P', 'Comision bancar', sum(isnull(d.comision,0)), 1 stare,
		(select '0' ordin, 0 comision, 1 e_comision, @contcomision as contcor, 2 stare for xml raw), max(d.data_scadentei), null, 0,0
	from #deprocesat d having abs(sum(isnull(d.comision,0)))>=0.001

-------------------------------
	--> incerc identificare de factura - doar pentru terti completati:

		--> cautare de secventa care sa gaseasca inceputul numarului de factura in baza secventei care este [prefix din cuvantul "factura"] + un eventual caracter separator:
		declare @prefix varchar(100), @separatori_pauza varchar(100), @separatori_final varchar(100)
		select @prefix='factura'
				,@separatori_pauza=' .:	'		--> aici se completeaza lista de separatori daca e cazul
				,@separatori_final=' .:,;	/\'	--> separatori care ar putea marca finalul numarului de factura

		if object_id('tempdb..#idfacturi') is not null drop table #idfacturi
		--select secventa, count(1), max(explicatii) explicatii from(
		select 
			p.idpozop
			,p.explicatii
			,s.n s	--> start secventa
			,f.n+(case when substring(p.explicatii,f.n,1) between '0' and '9' then 0 else 1 end) f	--> stop secventa + eventualul separator
			,substring(p.explicatii,s.n,f.n-s.n) secventa
			,convert(varchar(100),'') factura
			into #idfacturi
		from tally s, tally f, --pozordinedeplata 
			#deprocesat p
		where s.n between 1 and len(p.explicatii)
			and f.n between 1 and len(p.explicatii)		--> cele doua margini ale secventei sa fie din sir
			and f.n-s.n>0						--> finalul intervalului sa fie mai mare decat inceputul
			and f.n-s.n<=len(@prefix)			--> intervalul sa respecte lungimea marcajului
			and left(@prefix,f.n-s.n)=substring(p.explicatii,s.n,f.n-s.n)	--> continutul intervalului sa respecte regula
			and (
				charindex(substring(p.explicatii,f.n,1),@separatori_pauza
					+'0123456789')>0		--> intrebare: Oare sa consider si cazul "fact1234" sau nu? Deocamdata il consider, dar sunt posibile probleme pentru explicatii de genul "Factura F12345", daca exista ambele facturi (F12345 si 12345) in baza de date
				)
			and (s.n=1 or charindex(substring(p.explicatii,s.n-1,1),@separatori_pauza)>0)
		and p.idop=@idop and p.tert<>''		--> doar pentru terti completati
		order by idpozop
		
		--> extrag numarul de factura propriu-zis:
		update i set factura=x.factura
			from #idfacturi i
			cross apply(
				select substring(i.explicatii, f, min(t.n)-f+1) factura
				from tally t
				where (charindex(substring(i.explicatii,t.n+1,1),@separatori_final)>0 or t.n=len(i.explicatii))	--> ne oprim fie la separator, fie la sfarsitul explicatiilor
					and t.n between i.f and len(i.explicatii)
		--		group by i.idpozop
			)x

		update d set factura=f.factura,
			detalii.modify(('replace value of (row/@contcor)[1] with (sql:column("f.cont_de_tert"))'))
		from #deprocesat d
			inner join #idfacturi i on d.idpozop=i.idpozop
			inner join facturi f on f.tert=d.tert and f.factura=i.factura
			
		if object_id('tempdb..#idfacturi') is not null drop table #idfacturi
-------------------------------
	--> pun cont pentru inregistrarile de tip POS dupa regula: liniile de POS nu au beneficiar si au in explicatii sirul de caractere " POS "
				--> de existenta atributului m-am asigurat mai devreme in procedura

	update d set detalii.modify('replace value of (row/@contcor)[1] with (sql:variable("@contcor_pos"))')
	from #deprocesat d
	where d.tert='' and d.explicatii like '% pos %'
	
-------------------------------
		
		--> pregatesc tipul pentru preluare in pozplin + completez in detalii informatiile inainte de a le actualiza in tabela principala:
		update d set tip=(case	when left(tip,1)='I' and tert<>'' then 'IB'
								when left(tip,1)='I' and tert='' then 'ID'
								when left(tip,1)='P' and tert<>'' then 'PF'
								when left(tip,1)='P' and tert='' then 'PD'
							end)
			,detalii.modify('replace value of (row/@ordin)[1] with (sql:column("d.marca"))')
			,marca=''
		from #deprocesat d
		
-------------------------------
	--> identific plati de salarii - pt tip='PD':
	update d set detalii.modify('replace value of (row/@contcor)[1] with "421"'), marca=m.marca
		from #deprocesat d
			left join personal m on d.iban=m.cont_in_banca
		where tip='PD' and rtrim(dbo.iaInfoDinMT940(d.date,'~25'))='SALARY PAYMENT'

/*		
		update d set detalii.modify('replace value of (row/@comision)[1] with (sql:column("d.comision"))')
		from #deprocesat d
*/		
		if object_id('wOPPreluareExtrasBancarInOrdineDePlata_postpreluareSP') is not null
			exec wOPPreluareExtrasBancarInOrdineDePlata_postpreluareSP @sesiune=@sesiune, @parxml=@parxml
		
		--> actualizez starea:
		update d set stare_operatiune=
			(case	when d.tert<>'' and d.factura='' then 12		-->12 = nu exista factura
					when isnull(rtrim(d.detalii.value('(row/@contcor)[1]','varchar(200)')),'')='' then 11	--> 11= nu exista cont
					else 0				--> altfel consider ca e bine, starea sa fie preluat
			end)
			from #deprocesat d

		--> actualizez detalii din #deprocesat:
		update d set detalii.modify('replace value of (row/@stare)[1] with (sql:column("d.stare_operatiune"))')
		from #deprocesat d

		--> actualizez datele in tabela permanenta:
		update e set detalii=d.detalii,
			tert=d.tert, marca=d.marca, factura=d.factura, decont=d.decont, banca=d.banca, IBAN=d.IBAN,
			tip=d.tip, explicatii=d.explicatii, suma=d.suma, stare=d.stare, data_scadentei=d.data_scadentei, soldscadent=d.soldscadent
		from pozordinedeplata e inner join #deprocesat d on e.idpozop=d.idpozop
	
		--> comisionul a fost adaugat ulterior, deci trebuie adaugat ca linie noua si in tabela permanenta - bineinteles, daca nu exista deja:
		insert into pozordinedeplata(idOP, tert, marca, factura, decont, banca, IBAN, tip, explicatii, suma, stare, detalii, data_scadentei, soldscadent)
		select idOP, tert, '' marca, factura, decont, banca, IBAN, tip, explicatii, suma, stare, detalii, data_scadentei, soldscadent
		from #deprocesat d
		where not exists (select 1 from pozordinedeplata p where d.idpozop=p.idpozop)
			and not exists (select 1 from pozordinedeplata p where isnull(p.detalii.value('(row/@e_comision)[1]','varchar(1)'),'0')='1' and p.idop=d.idop)
end try

begin catch
	set @eroare=ERROR_MESSAGE() + char(10)+' (' + OBJECT_NAME(@@PROCID) + ')'
end catch
if len(@eroare)>0 raiserror(@eroare,16,1)
