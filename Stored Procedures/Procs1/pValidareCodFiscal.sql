--***  
create procedure pValidareCodFiscal 
as
declare @cheieCUI varchar(10), @cheieCNP varchar(13)
set @cheieCUI='753217532'
set @cheieCNP='279146358279'


if object_id('tempdb..#cifre') is not null drop table #cifre
if object_id('tempdb..#cifreInsumate') is not null drop table #cifreInsumate
if object_id('tempdb..#validCUI') is null 
begin
	create table #validCUI (cui varchar(20))
	exec CreazaDiezTerti @numeTabela='#validCUI'
end

create table #cifre (cui varchar(20), cifre int, areCaracter int)
insert into #cifre (cui, cifre, areCaracter)
select cui, 
	convert(int,(case when substring(cui,n,1) like '[0-9]' then substring(cui,n,1) else 0 end))*
	convert(int,(case when len(cui)=13 then substring(@cheieCNP,n+len(@cheieCNP)-len(cui)+1,1) else substring(@cheieCUI,n+len(@cheieCUI)-len(cui)+1,1) end)) cifre,
	(case when substring(cui,n,1) like '[0-9]' then 0 else 1 end) areCaracter
from #validCUI 
	inner join tally on n<len(cui)
where len(cui)<=13  
order by n desc

-->	inseram si cui-urile necompletate
insert into #cifre
select cui, 0 cifre, 0 areCaracter
from #validCui where cui=''

--select * from #cifre where cui='2501026123131'
--select cui, sum(cifre) from #cifre where cui='2501026123131' group by cui

select cui, sum(cifre)*(case when len(cui)=13 then 1 else 10 end)%11 ctrl, sum(areCaracter) areCaracter
into #cifreInsumate
from #cifre group by cui
update #cifreInsumate
	set ctrl=(case when ctrl<10 then ctrl else (case when len(cui)=13 then 1 else 0 end) end)

update vc
	set vc.cod_eroare=(case when len(vc.cui)=0 then 1 
							when c.areCaracter!=0 then 3
							when right(c.cui,1)!=convert(varchar(2),ctrl) then 2
							when t.tert is not null then 4
							else 0 end),
		vc.den_eroare=(case when len(vc.cui)=0 then 'Cod fiscal necompletat'
							when c.areCaracter!=0 then (case when len(vc.cui)=13 
															 then 'Cod numeric personal' 
															 else 'Cod fiscal' end)+' eronat - caractere nepermise'
							when right(c.cui,1)!=convert(varchar(2),ctrl) then 
														(case when len(vc.cui)=13 
															  then 'Cod numeric personal' 
															  else 'Cod fiscal' end)+' eronat - cifra de control incorecta! Cifra corecta:'+convert(varchar(2),ctrl)
							when t.tert is not null then (case when len(vc.cui)=13 
															   then 'Cod numeric personal' 
															   else 'Cod fiscal' end)+' existent la tertul ' + RTrim(t.denumire)
							else (case when len(vc.cui)=13 then 'Cod numeric personal' else 'Cod fiscal' end)+' corect' end)
from #validCUI vc
	inner join #cifreInsumate c on c.cui=vc.cui
	left outer join terti t on vc.cui=replace(replace(replace(isnull(t.cod_fiscal,''), 'RO', ''), 'R', ''), ' ','')
select * from #validCUI
/*
	exec pValidareCodFiscal
*/
