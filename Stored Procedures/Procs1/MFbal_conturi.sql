
--***
create procedure MFbal_conturi
 @datajos datetime,@datasus datetime, @cont varchar(20)
 as
/*
declare @datajos datetime, @datasus datetime,@cont char
set @datajos='2006/2/01'
set @datasus='2007/2/28'
--*/
declare @subunitate char(5)
set @subunitate = (select val_alfanumerica from par where parametru='subpro')

select Cont,max([Denumire cont]) as [Denumire cont],
sum([Valoare inceput perioada]) as [Valoare inceput perioada],
sum([Valoare intrari]) as [Valoare intrari],
sum([Valoare iesiri]) as [Valoare iesiri],
sum([Valoare modificari]) as [Valoare modificari]
,sum((isnull([Valoare inceput perioada],0)+isnull([Valoare intrari],0)-isnull([Valoare iesiri],0)+isnull([Valoare modificari],0))) as [Valoare sfarsit perioada],
sum((isnull([Valoare intrari],0)-isnull([Valoare iesiri],0)+isnull([Valoare modificari],0))) as [Rulaj perioada],
tip_cont

from

(select a.cont,
(select b.denumire_cont from conturi b where a.cont=b.cont and b.subunitate=rtrim(@subunitate)) as [Denumire cont]
,isnull((select sum(c.valoare_de_inventar) from fisamf c where c.subunitate=rtrim(@subunitate) and a.numar_de_inventar=c.numar_de_inventar  and a.cont=c.cont_mijloc_fix and c.felul_operatiei='1' and data_lunii_operatiei=dateadd(d,-1,@datajos)),0) as [Valoare inceput perioada]
,isnull((select sum(d.valoare_de_inventar) from fisamf d where d.subunitate=rtrim(@subunitate) and a.numar_de_inventar=d.numar_de_inventar  and a.cont=d.cont_mijloc_fix and d.felul_operatiei='3' and data_lunii_operatiei between @datajos and @datasus),0) as [Valoare intrari]
,isnull((select sum(e.valoare_de_inventar) from fisamf e where e.subunitate=rtrim(@subunitate) and a.numar_de_inventar=e.numar_de_inventar  and a.cont=e.cont_mijloc_fix and e.felul_operatiei='5' and data_lunii_operatiei between @datajos and @datasus),0) as [Valoare iesiri]
,isnull((select sum(f.diferenta_de_valoare) from mismf f where f.subunitate=rtrim(@subunitate) and left(f.tip_miscare,1)='M' and f.data_lunii_de_miscare between @datajos and @datasus  and a.numar_de_inventar=f.numar_de_inventar and exists (select 1 from fisamf g where g.subunitate=rtrim(@subunitate) and g.felul_operatiei='4' and g.numar_de_inventar=f.numar_de_inventar and a.cont=g.cont_mijloc_fix and data_lunii_operatiei between @datajos and @datasus)),0) as [Valoare modificari],'conturi mijloace fixe' as tip_cont

from (select distinct numar_de_inventar, cont_mijloc_fix as cont from fisamf where subunitate=rtrim(@subunitate) and felul_operatiei='1') a 

union all
select m.cod_de_clasificare as Cont,
(select b.denumire_cont from conturi b where m.cod_de_clasificare=b.cont and b.subunitate=rtrim(@subunitate)) as [Denumire cont]
,isnull((select sum(c.valoare_amortizata) from fisamf c where c.subunitate=rtrim(@subunitate) and c.felul_operatiei='1' and m.numar_de_inventar=c.numar_de_inventar and data_lunii_operatiei=dateadd(d,-1,@datajos)),0) as [Valoare inceput perioada]
,isnull((select sum(d.amortizare_lunara) from fisamf d where d.subunitate=rtrim(@subunitate) and d.felul_operatiei='1' and data_lunii_operatiei between @datajos and @datasus and m.numar_de_inventar=d.numar_de_inventar),0)+isnull((select sum(h.valoare_amortizata) from fisamf h where h.subunitate=rtrim(@subunitate) and h.felul_operatiei='3' and data_lunii_operatiei between @datajos and @datasus and m.numar_de_inventar= h.numar_de_inventar),0) as [Valoare intrari]
,isnull((select sum(e.valoare_amortizata) from fisamf e where e.subunitate=rtrim(@subunitate) and e.felul_operatiei='5' and data_lunii_operatiei between @datajos and @datasus and m.numar_de_inventar=e.numar_de_inventar),0) as [Valoare iesiri]
,isnull((select sum(f.pret) from mismf f where f.subunitate=rtrim(@subunitate) and left(f.tip_miscare,1)='M' and f.data_lunii_de_miscare between @datajos and @datasus  and m.numar_de_inventar=f.numar_de_inventar and exists (select 1 from fisamf g where g.subunitate=rtrim(@subunitate) and g.felul_operatiei='4' and g.numar_de_inventar=f.numar_de_inventar 
and data_lunii_operatiei between @datajos and @datasus)),0) as [Valoare modificari],'conturi de amortizare' as tip_cont

from mfix m where m.subunitate='DENS' /* and m.cod_de_clasificare like '%8%'*/)z 
where ([Valoare inceput perioada]<>0 or [Valoare intrari]<>0 or [Valoare iesiri]<>0 or [Valoare modificari]<>0 or (isnull([Valoare inceput perioada],0)+isnull([Valoare intrari],0)-isnull([Valoare iesiri],0)+isnull([Valoare modificari],0))<>0 or (isnull([Valoare intrari],0)-isnull([Valoare iesiri],0)+isnull([Valoare modificari],0))<>0) and (@cont is null or cont like rtrim(@cont)+'%')

group by cont,tip_cont
order by tip_cont desc,cont