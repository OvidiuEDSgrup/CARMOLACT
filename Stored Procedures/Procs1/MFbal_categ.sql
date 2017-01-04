
--***
create procedure MFbal_categ 
 @datajos datetime,@datasus datetime, @tipimob int ,@lista int 
/*set @datajos='2006-05-01' 
set @datasus='2006-05-31' 
set @tipimob = 1 
set @lista = 1*/ 
 
as 
 
declare @subunitate char(5) 
set @subunitate = (select val_alfanumerica from par where parametru='subpro') 
 
select * into #mf_categ from ( 
select 'Valoare de inventar la '+convert(varchar ,@datajos,103) as Explicatii, 
isnull(round(sum(case when categoria='1' then valoare_de_inventar else 0 end),2),0) as c1, 
isnull(round(sum(case when categoria='21' then valoare_de_inventar else 0 end),2),0) as c21, 
isnull(round(sum(case when categoria='22' then valoare_de_inventar else 0 end),2),0) as c22, 
isnull(round(sum(case when categoria='23' then valoare_de_inventar else 0 end),2),0) as c23, 
isnull(round(sum(case when categoria='24' then valoare_de_inventar else 0 end),2),0) as c24, 
isnull(round(sum(case when categoria='3' then valoare_de_inventar else 0 end),2),0) as c3, 
isnull(round(sum(case when categoria='7' then valoare_de_inventar else 0 end),2),0) as c7, 
isnull(round(sum(case when categoria='8' then valoare_de_inventar else 0 end),2),0) as c8, 
isnull(round(sum(case when categoria='9' then valoare_de_inventar else 0 end),2),0) as c9, 
1 as nr 
from fisamf f 
inner join mfix m on f.numar_de_inventar = m.numar_de_inventar 
where rtrim(felul_operatiei)='1' and data_lunii_operatiei=dateadd(day,-1,@datajos) and ltrim(rtrim(f.subunitate))=rtrim(ltrim(@subunitate)) 
and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '') then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and f.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and f.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1 
union all 
select 'Intrari in perioada '+convert(varchar ,@datajos,103)+' - '+ convert(varchar ,@datasus,103)as Explicatii, 
isnull(round(sum(case when categoria='1' then valoare_de_inventar else 0 end),2),0) as c1, 
isnull(round(sum(case when categoria='21' then valoare_de_inventar else 0 end),2),0) as c21, 
isnull(round(sum(case when categoria='22' then valoare_de_inventar else 0 end),2),0) as c22, 
isnull(round(sum(case when categoria='23' then valoare_de_inventar else 0 end),2),0) as c23, 
isnull(round(sum(case when categoria='24' then valoare_de_inventar else 0 end),2),0) as c24, 
isnull(round(sum(case when categoria='3' then valoare_de_inventar else 0 end),2),0) as c3, 
isnull(round(sum(case when categoria='7' then valoare_de_inventar else 0 end),2),0) as c7, 
isnull(round(sum(case when categoria='8' then valoare_de_inventar else 0 end),2),0) as c8, 
isnull(round(sum(case when categoria='9' then valoare_de_inventar else 0 end),2),0) as c9, 
2 as nr 
from fisamf f 
inner join mfix m on f.numar_de_inventar = m.numar_de_inventar 
where felul_operatiei='3' and data_lunii_operatiei between @datajos and @datasus 
and ltrim(rtrim(f.subunitate))=rtrim(ltrim(@subunitate)) and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '') then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and f.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and f.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1 
union all 
select 'Iesiri in perioada '+convert(varchar ,@datajos,103)+' - '+ convert(varchar ,@datasus,103)as Explicatii, 
isnull(round(sum(case when categoria='1' then valoare_de_inventar else 0 end),2),0) as c1, 
isnull(round(sum(case when categoria='21' then valoare_de_inventar else 0 end),2),0) as c21, 
isnull(round(sum(case when categoria='22' then valoare_de_inventar else 0 end),2),0) as c22, 
isnull(round(sum(case when categoria='23' then valoare_de_inventar else 0 end),2),0) as c23, 
isnull(round(sum(case when categoria='24' then valoare_de_inventar else 0 end),2),0) as c24, 
isnull(round(sum(case when categoria='3' then valoare_de_inventar else 0 end),2),0) as c3, 
isnull(round(sum(case when categoria='7' then valoare_de_inventar else 0 end),2),0) as c7, 
isnull(round(sum(case when categoria='8' then valoare_de_inventar else 0 end),2),0) as c8, 
isnull(round(sum(case when categoria='9' then valoare_de_inventar else 0 end),2),0) as c9, 
3 as nr 
from fisamf f 
inner join mfix m on f.numar_de_inventar = m.numar_de_inventar 
where felul_operatiei='5' and data_lunii_operatiei between @datajos and @datasus 
and ltrim(rtrim(f.subunitate))=rtrim(ltrim(@subunitate)) and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '' ) then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and f.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and f.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1 
union all 
select 'Modificari in perioada '+convert(varchar ,@datajos,103)+' - '+ convert(varchar ,@datasus,103)as Explicatii, 
(select isnull(round(sum(f.diferenta_de_valoare),2),0) 
from mismf f, fisamf g, mfix m 
where f.numar_de_inventar = m.numar_de_inventar and f.subunitate=rtrim(@subunitate) and left(f.tip_miscare,1)='M' and 
f.data_lunii_de_miscare between @datajos and @datasus and g.subunitate=rtrim(@subunitate) 
and g.felul_operatiei='4' and g.numar_de_inventar=f.numar_de_inventar and f.data_lunii_de_miscare=g.data_lunii_operatiei
and data_lunii_operatiei between @datajos and @datasus and g.categoria='1' and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '') then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and g.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and g.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1) as c1, 
(select isnull(round(sum(f.diferenta_de_valoare),2),0) 
from mismf f, 
(select distinct f.numar_de_inventar, cont_mijloc_fix,categoria from fisamf f 
inner join mfix m on f.numar_de_inventar = m.numar_de_inventar 
where f.subunitate=rtrim(@subunitate) and felul_operatiei='1' 
and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '' ) then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and f.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and f.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1) g 
--fisamf g 
where f.subunitate=rtrim(@subunitate) and left(f.tip_miscare,1)='M' and 
f.data_lunii_de_miscare between @datajos and @datasus --and g.subunitate=rtrim(@subunitate) 
--and g.felul_operatiei='4' 
and g.numar_de_inventar=f.numar_de_inventar 
and g.categoria='21' 
and exists (select 1 from fisamf a where 
		(case when (@tipimob = 1 and @lista = 1) then 1 --MF toate 
		 when (@tipimob = 1 and @lista = 2 and a.obiect_de_inventar=0) then 1 --MF propriu-zise 
		 when (@tipimob = 1 and @lista = 3 and a.obiect_de_inventar=1) then 1 --MF de nat. ob. inv. 
		 when (@tipimob = 2 and @lista = 1) then 1 --OB. inv. - lista 
		 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
		else 0 
		end )=1
and a.subunitate=rtrim(@subunitate) and a.felul_operatiei='4' 
 and a.numar_de_inventar=g.numar_de_inventar and g.cont_mijloc_fix=a.cont_mijloc_fix and 
 data_lunii_operatiei between @datajos and @datasus) ) as c21, 
(select isnull(round(sum(f.diferenta_de_valoare),2),0) 
from mismf f, fisamf g, mfix m 
where f.numar_de_inventar = m.numar_de_inventar and f.subunitate=rtrim(@subunitate) and left(f.tip_miscare,1)='M' and 
f.data_lunii_de_miscare between @datajos and @datasus and g.subunitate=rtrim(@subunitate) 
and g.felul_operatiei='4' and g.numar_de_inventar=f.numar_de_inventar and f.data_lunii_de_miscare=g.data_lunii_operatiei
and data_lunii_operatiei between @datajos and @datasus and g.categoria='22' and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '') then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and g.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and g.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1) as c22, 
(select isnull(round(sum(f.diferenta_de_valoare),2),0) 
from mismf f, fisamf g, mfix m 
where f.numar_de_inventar = m.numar_de_inventar /*and g.obiect_de_inventar = 0*/ and f.subunitate=rtrim(@subunitate) and left(f.tip_miscare,1)='M' and 
f.data_lunii_de_miscare between @datajos and @datasus and g.subunitate=rtrim(@subunitate) 
and g.felul_operatiei='4' and g.numar_de_inventar=f.numar_de_inventar 
and data_lunii_operatiei between @datajos and @datasus and g.categoria='23' and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '') then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and g.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and g.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1) as c23, 
(select isnull(round(sum(f.diferenta_de_valoare),2),0) 
from mismf f, fisamf g, mfix m 
where f.numar_de_inventar = m.numar_de_inventar /*and g.obiect_de_inventar = 0*/ and f.subunitate=rtrim(@subunitate) and left(f.tip_miscare,1)='M' and 
f.data_lunii_de_miscare between @datajos and @datasus and g.subunitate=rtrim(@subunitate) 
and g.felul_operatiei='4' and g.numar_de_inventar=f.numar_de_inventar 
and data_lunii_operatiei between @datajos and @datasus and g.categoria='24' and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '') then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and g.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and g.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1) as c24, 
(select isnull(round(sum(f.diferenta_de_valoare),2),0) 
from mismf f, fisamf g, mfix m 
where f.numar_de_inventar = m.numar_de_inventar /*and g.obiect_de_inventar = 0*/ and f.subunitate=rtrim(@subunitate) and left(f.tip_miscare,1)='M' and 
f.data_lunii_de_miscare between @datajos and @datasus and g.subunitate=rtrim(@subunitate) 
and g.felul_operatiei='4' and g.numar_de_inventar=f.numar_de_inventar 
and data_lunii_operatiei between @datajos and @datasus and g.categoria='3' and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '' ) then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and g.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and g.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1) as c3, 
(select isnull(round(sum(f.diferenta_de_valoare),2),0) 
from mismf f, fisamf g, mfix m 
where f.numar_de_inventar = m.numar_de_inventar /*and g.obiect_de_inventar = 0*/ and f.subunitate=rtrim(@subunitate) and left(f.tip_miscare,1)='M' and 
f.data_lunii_de_miscare between @datajos and @datasus and g.subunitate=rtrim(@subunitate) 
and g.felul_operatiei='4' and g.numar_de_inventar=f.numar_de_inventar and f.data_lunii_de_miscare=g.data_lunii_operatiei
and data_lunii_operatiei between @datajos and @datasus and g.categoria='7' and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '' ) then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and g.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and g.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1) as c7, 
(select isnull(round(sum(f.diferenta_de_valoare),2),0) 
from mismf f, fisamf g, mfix m 
where f.numar_de_inventar = m.numar_de_inventar /*and g.obiect_de_inventar = 0*/ and f.subunitate=rtrim(@subunitate) and left(f.tip_miscare,1)='M' and 
f.data_lunii_de_miscare between @datajos and @datasus and g.subunitate=rtrim(@subunitate) 
and g.felul_operatiei='4' and g.numar_de_inventar=f.numar_de_inventar 
and data_lunii_operatiei between @datajos and @datasus and g.categoria='8' and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '' ) then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and g.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and g.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1) as c8, 
(select isnull(round(sum(f.diferenta_de_valoare),2),0) 
from mismf f, fisamf g, mfix m 
where f.numar_de_inventar = m.numar_de_inventar /*and g.obiect_de_inventar = 0*/ and f.subunitate=rtrim(@subunitate) and left(f.tip_miscare,1)='M' and 
f.data_lunii_de_miscare between @datajos and @datasus and g.subunitate=rtrim(@subunitate) 
and g.felul_operatiei='4' and g.numar_de_inventar=f.numar_de_inventar 
and data_lunii_operatiei between @datajos and @datasus and g.categoria='9' and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '' ) then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and g.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and g.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1) as c9 , 
4 as nr) as t 
 
select * into #mfa_categ from ( 
select 'Amortizare cumulata la '+convert(varchar ,@datajos,103) as Explicatii, 
isnull(round(sum(case when categoria='1' then valoare_amortizata else 0 end),2),0) as c1, 
isnull(round(sum(case when categoria='21' then valoare_amortizata else 0 end),2),0) as c21, 
isnull(round(sum(case when categoria='22' then valoare_amortizata else 0 end),2),0) as c22, 
isnull(round(sum(case when categoria='23' then valoare_amortizata else 0 end),2),0) as c23, 
isnull(round(sum(case when categoria='24' then valoare_amortizata else 0 end),2),0) as c24, 
isnull(round(sum(case when categoria='3' then valoare_amortizata else 0 end),2),0) as c3, 
isnull(round(sum(case when categoria='7' then valoare_amortizata else 0 end),2),0) as c7, 
isnull(round(sum(case when categoria='8' then valoare_amortizata else 0 end),2),0) as c8, 
isnull(round(sum(case when categoria='9' then valoare_amortizata else 0 end),2),0) as c9, 
1 as nr 
from fisamf f 
inner join mfix m on f.numar_de_inventar = m.numar_de_inventar 
where m.subunitate = 'DENS' and data_lunii_operatiei=dateadd(day,-1,@datajos) 
and ltrim(rtrim(f.subunitate))=rtrim(ltrim(@subunitate)) and felul_operatiei='1' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '' ) then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and f.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and f.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1 
union all 
select 'Amortizare calculata in perioada '+convert(varchar ,@datajos,103)+' - '+ convert(varchar ,@datasus,103)as Explicatii, 
isnull(round(sum(case when categoria='1' then amortizare_lunara else 0 end),2),0) as c1, 
isnull(round(sum(case when categoria='21' then amortizare_lunara else 0 end),2),0) as c21, 
isnull(round(sum(case when categoria='22' then amortizare_lunara else 0 end),2),0) as c22, 
isnull(round(sum(case when categoria='23' then amortizare_lunara else 0 end),2),0) as c23, 
isnull(round(sum(case when categoria='24' then amortizare_lunara else 0 end),2),0) as c24, 
isnull(round(sum(case when categoria='3' then amortizare_lunara else 0 end),2),0) as c3, 
isnull(round(sum(case when categoria='7' then amortizare_lunara else 0 end),2),0) as c7, 
isnull(round(sum(case when categoria='8' then amortizare_lunara else 0 end),2),0) as c8, 
isnull(round(sum(case when categoria='9' then amortizare_lunara else 0 end),2),0) as c9, 
2 as nr 
from fisamf f 
inner join mfix m on f.numar_de_inventar = m.numar_de_inventar 
where m.subunitate = 'DENS' and data_lunii_operatiei between @datajos and @datasus and felul_operatiei='1' 
and ltrim(rtrim(f.subunitate))=rtrim(ltrim(@subunitate)) 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '' ) then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and f.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and f.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1 
union all 
select 'Amortizare intrari in perioada '+convert(varchar ,@datajos,103)+' - '+ convert(varchar ,@datasus,103)as Explicatii, 
isnull(round(sum(case when categoria='1' then valoare_amortizata else 0 end),2),0) as c1, 
isnull(round(sum(case when categoria='21' then valoare_amortizata else 0 end),2),0) as c21, 
isnull(round(sum(case when categoria='22' then valoare_amortizata else 0 end),2),0) as c22, 
isnull(round(sum(case when categoria='23' then valoare_amortizata else 0 end),2),0) as c23, 
isnull(round(sum(case when categoria='24' then valoare_amortizata else 0 end),2),0) as c24, 
isnull(round(sum(case when categoria='3' then valoare_amortizata else 0 end),2),0) as c3, 
isnull(round(sum(case when categoria='7' then valoare_amortizata else 0 end),2),0) as c7, 
isnull(round(sum(case when categoria='8' then valoare_amortizata else 0 end),2),0) as c8, 
isnull(round(sum(case when categoria='9' then valoare_amortizata else 0 end),2),0) as c9, 
3 as nr 
from fisamf f 
inner join mfix m on f.numar_de_inventar = m.numar_de_inventar 
where m.subunitate = 'DENS' and data_lunii_operatiei between @datajos and @datasus and felul_operatiei='3' 
and ltrim(rtrim(f.subunitate))=rtrim(ltrim(@subunitate)) 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '') then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and f.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and f.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1 
union all 
select 'Amortizare cedata la iesiri in perioada '+convert(varchar ,@datajos,103)+' - '+ convert(varchar ,@datasus,103)as Explicatii, 
isnull(round(sum(case when categoria='1' then valoare_amortizata else 0 end),2),0) as c1, 
isnull(round(sum(case when categoria='21' then valoare_amortizata else 0 end),2),0) as c21, 
isnull(round(sum(case when categoria='22' then valoare_amortizata else 0 end),2),0) as c22, 
isnull(round(sum(case when categoria='23' then valoare_amortizata else 0 end),2),0) as c23, 
isnull(round(sum(case when categoria='24' then valoare_amortizata else 0 end),2),0) as c24, 
isnull(round(sum(case when categoria='3' then valoare_amortizata else 0 end),2),0) as c3, 
isnull(round(sum(case when categoria='7' then valoare_amortizata else 0 end),2),0) as c7, 
isnull(round(sum(case when categoria='8' then valoare_amortizata else 0 end),2),0) as c8, 
isnull(round(sum(case when categoria='9' then valoare_amortizata else 0 end),2),0) as c9, 
4 as nr 
from fisamf f 
inner join mfix m on f.numar_de_inventar = m.numar_de_inventar 
where m.subunitate = 'DENS' and data_lunii_operatiei between @datajos and @datasus and felul_operatiei='5' 
and ltrim(rtrim(f.subunitate))=rtrim(ltrim(@subunitate)) 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '') then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and f.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and f.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1 
union all 
select 'Modificari amortizare in perioada '+convert(varchar ,@datajos,103)+' - '+ convert(varchar ,@datasus,103)as Explicatii, 
isnull(round(sum(case when categoria='1' then f.pret else 0 end),2),0) as c1, 
isnull(round(sum(case when categoria='21' then f.pret else 0 end),2),0) as c21, 
isnull(round(sum(case when categoria='22' then f.pret else 0 end),2),0) as c22, 
isnull(round(sum(case when categoria='23' then f.pret else 0 end),2),0) as c23, 
isnull(round(sum(case when categoria='24' then f.pret else 0 end),2),0) as c24, 
isnull(round(sum(case when categoria='3' then f.pret else 0 end),2),0) as c3, 
isnull(round(sum(case when categoria='7' then f.pret else 0 end),2),0) as c7, 
isnull(round(sum(case when categoria='8' then f.pret else 0 end),2),0) as c8, 
isnull(round(sum(case when categoria='9' then f.pret else 0 end),2),0) as c9, 
5 as nr 
from mismf f,fisamf a, mfix m 
where f.numar_de_inventar = m.numar_de_inventar /*and a.obiect_de_inventar = 0*/ and ltrim(rtrim(a.subunitate))=rtrim(ltrim(@subunitate)) and left(f.tip_miscare,1)='M' and f.data_lunii_de_miscare between @datajos and @datasus 
and f.numar_de_inventar=a.numar_de_inventar and f.subunitate='DENS' and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '') then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and a.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and a.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1 
 and exists (select 1 from fisamf g ,mfix m where g.numar_de_inventar = m.numar_de_inventar and m.subunitate = 'DENS' 
and (case when (@tipimob = 1 and @lista = 1 and m.serie = '' ) then 1 --MF toate 
 when (@tipimob = 1 and @lista = 2 and g.obiect_de_inventar=0 and m.serie = '') then 1 --MF propriu-zise 
 when (@tipimob = 1 and @lista = 3 and g.obiect_de_inventar=1 and m.serie = '') then 1 --MF de nat. ob. inv. 
 when (@tipimob = 2 and @lista = 1 and m.serie = 'O') then 1 --OB. inv. - lista 
 --when (@tipimob = 3 and @lista = 1 and c.serie = 'C') then 1 --MF dupa casare -lista 
else 0 
end )=1 
and g.subunitate=rtrim(@subunitate) and g.felul_operatiei='4' and g.numar_de_inventar=f.numar_de_inventar 
and data_lunii_operatiei between @datajos and @datasus)) as s 
 
 
select explicatii,tip, c1,c21,c22,c23,c24,c3,c7,c8,c9, c1+c21+c22+c23+c24+c3+c7+c8+c9 as total from ( 
select explicatii, c1,c21,c22,c23, c24, c3,c7,c8,c9,'Inventar' as tip from #mf_categ 
union all 
select 'Valoare de inventar la '+convert(varchar ,@datasus,103) as Explicatii, 
sum(case when nr<>3 then c1 else -c1 end) as c1, 
sum(case when nr<>3 then c21 else -c21 end) as c21, 
sum(case when nr<>3 then c22 else -c22 end) as c22, 
sum(case when nr<>3 then c23 else -c23 end) as c23, 
sum(case when nr<>3 then c24 else -c24 end) as c24, 
sum(case when nr<>3 then c3 else -c3 end) as c3, 
sum(case when nr<>3 then c7 else -c7 end) as c7, 
sum(case when nr<>3 then c8 else -c8 end) as c8, 
sum(case when nr<>3 then c9 else -c9 end) as c9, 
'Inventar' as tip from #mf_categ 
union all 
select explicatii, c1,c21,c22,c23,c24,c3,c7,c8,c9,'Amortizare' as tip from #mfa_categ 
union all 
select 'Amortizare cumulata la '+convert(varchar ,@datasus,103) as Explicatii, 
sum(case when nr<>4 then c1 else -c1 end) as c1, 
sum(case when nr<>4 then c21 else -c21 end) as c21, 
sum(case when nr<>4 then c22 else -c22 end) as c22, 
sum(case when nr<>4 then c23 else -c23 end) as c23, 
sum(case when nr<>4 then c24 else -c24 end) as c24, 
sum(case when nr<>4 then c3 else -c3 end) as c3, 
sum(case when nr<>4 then c7 else -c7 end) as c7, 
sum(case when nr<>4 then c8 else -c8 end) as c8, 
sum(case when nr<>4 then c9 else -c9 end) as c9, 
'Amortizare' as tip from #mfa_categ 
)z 
 
 
--drop table #mf_categ 
--drop table #mfa_categ