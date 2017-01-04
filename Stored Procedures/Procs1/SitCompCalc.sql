
--***
create procedure SitCompCalc (@dDataJos datetime, @dDataSus datetime, @cLM char(9), @cComanda char(20),@Terminate int, @Facturate int, @GrupaCom char(20), @ArtCalc varchar(300), @ArtCalcExcep varchar(300),@lExact int,@beneficiar char(13) =null, @siSemif bit) 
as 
begin 
declare @nLm int,@subunitate char(9)
set @subunitate = (select val_alfanumerica from par where tip_parametru = 'GE' and parametru = 'SUBPRO')

set @nLm=isnull((select max(lungime) from strlm where costuri=1), 9) 
insert into #sitcom 
--cost efectiv 
select 'CO', left(s.lm_sup, @nLm), max(isnull(c.tip_comanda,'')), s.comanda_sup, max(isnull(c.descriere,'')),0 as cantitativ, sum(s.cantitate*s.valoare) as valoric 
from costsql s 
left outer join comenzi c on s.comanda_sup=c.comanda 
where c.subunitate = @subunitate and s.lm_sup like rtrim(@cLM)+'%' and (@cComanda='' or s.comanda_sup=@cComanda) and s.data between @dDataJos and @dDataSus 
and exists (select 1 from #tccpc tc where tc.tip=c.tip_comanda) 
and not (s.tip in ('IT','IE')) 
and (isnull(@ArtCalc,'')='' or charindex(','+rtrim((case when s.art_sup='T' then s.art_inf else s.art_sup end))+',',','+@ArtCalc+',')>0) 
and (isnull(@ArtCalcExcep,'')='' or charindex(','+rtrim((case when s.art_sup='T' then s.art_inf else s.art_sup end))+',',','+@ArtCalcExcep+',')=0) 
and exists (select 1 from #tccpc tc where c.tip_comanda=tc.tip) 
and (s.art_inf<>'N' or s.data=(case when @Terminate=2 then dbo.bom(@dDataSus) else dbo.bom(@dDataJos) end)) 
and (@Terminate=1 and ( 
 --s.comanda_sup not in (select comanda_inf from costsql where data=@ddatasus and lm_sup='' and comanda_sup='' and art_sup='N') 
 not exists (select 1 from costsql tq where s.comanda_sup=tq.comanda_inf and data=@ddatasus and lm_sup='' and comanda_sup='' and art_sup='N') 
or data between @ddatajos and isnull((select max(data_lunii) from calstd left outer join costsql c1 on c1.lm_sup='' and c1.comanda_sup='' and c1.art_sup='N' and c1.comanda_inf=s.comanda_sup and c1.data=calstd.data_lunii 
 where calstd.data_lunii=calstd.data and calstd.data_lunii between @ddatajos and @ddatasus and c1.comanda_inf is null),'01/01/1901')) 
or (@Terminate=2 and not ( 
 --s.comanda_sup not in (select comanda_inf from costsql where data=@ddatasus and lm_sup='' and comanda_sup='' and art_sup='N') 
 not exists (select 1 from costsql tq where s.comanda_sup=tq.comanda_inf and data=@ddatasus and lm_sup='' and comanda_sup='' and art_sup='N') 
or data between @ddatajos and isnull((select max(data_lunii) from calstd left outer join costsql c1 on c1.lm_sup='' and c1.comanda_sup='' and c1.art_sup='N' and c1.comanda_inf=s.comanda_sup and c1.data=calstd.data_lunii 
 where calstd.data_lunii=calstd.data and calstd.data_lunii between @ddatajos and @ddatasus and c1.comanda_inf is null),'01/01/1901'))) 
or @Terminate=0) 
group by left(s.lm_sup, @nLm), s.comanda_sup 
union all 
--neterminata 
select 'NE', left(s.lm_inf, @nLm), max(isnull(c.tip_comanda,'')), s.comanda_inf, max(isnull(c.descriere,'')), sum(cantitate) as cantitativ, sum(s.cantitate*s.valoare) as valoric 
from costsql s 
left outer join comenzi c on s.comanda_inf=c.comanda 
where c.subunitate = @subunitate and s.lm_inf like rtrim(@cLM)+'%' and (@cComanda='' or s.comanda_inf=@cComanda) 
--and s.data between @dDataJos and @dDataSus 
and s.data=(case when @Terminate=2 then dbo.eom(@dDataSus) else dbo.eom(@dDataJos) end) 
and --c.tip_comanda in (select tip from #tccpc) 
 exists (select 1 from #tccpc tc where c.tip_comanda=tc.tip) 
and not (s.tip in ('IT','IE')) 
and lm_sup='' and comanda_sup='' and art_sup='N' 
group by lm_inf,comanda_inf 
--marja 
insert into #sitcom 
select 'MA',isnull(s1.loc_de_munca,s2.loc_de_munca),isnull(s1.tip_comanda,isnull(s2.tip_comanda,'')),isnull(s1.comanda,isnull(s2.comanda,'')), 
isnull(s1.descriere, isnull(s2.descriere,'')), 
isnull(s1.cantitativ,0)-isnull(s2.cantitativ,0),isnull(s1.valoric,0)-isnull(s2.valoric,0) 
from (select distinct loc_de_munca,comanda from #sitcom where tip in ('CA','FA') and loc_de_munca<>'' and comanda<>'') as cm 
left outer join #sitcom s1 on s1.comanda=cm.comanda and s1.loc_de_munca=cm.loc_de_munca and s1.tip='FA' 
left outer join #sitcom s2 on s2.comanda=cm.comanda and s2.loc_de_munca=cm.loc_de_munca and s2.tip='CA' 
--profit brut 
insert into #sitcom 
select 'PB',isnull(s1.loc_de_munca,isnull(s2.loc_de_munca,'')),isnull(s1.tip_comanda,isnull(s2.tip_comanda,'')),isnull(s1.comanda,isnull(s2.comanda,'')), 
isnull(s1.descriere, isnull(s2.descriere,'')), 
isnull(s1.cantitativ,0),isnull(s1.valoric,0)-isnull(s2.valoric,0) 
from (select distinct loc_de_munca,comanda from #sitcom where tip in ('MA','CO') and loc_de_munca<>'' and comanda<>'') as cm 
left outer join #sitcom s1 on s1.comanda=cm.comanda and s1.loc_de_munca=cm.loc_de_munca and s1.tip='MA' 
left outer join #sitcom s2 on s2.comanda=cm.comanda and s2.loc_de_munca=cm.loc_de_munca and s2.tip='CO' 
--diferenta pret 
insert into #sitcom 
select 'DP',isnull(s1.loc_de_munca,isnull(s2.loc_de_munca,'')),isnull(s1.tip_comanda,isnull(s2.tip_comanda,'')),isnull(s1.comanda,isnull(s2.comanda,'')), 
isnull(s1.descriere, isnull(s2.descriere,'')), 
isnull(s1.cantitativ,0),isnull(s1.valoric,0)-isnull(s2.valoric,0) 
from (select distinct loc_de_munca,comanda from #sitcom  where tip in ('PP','CO','NE') and loc_de_munca<>'' and comanda<>'') as cm 
left outer join (select s1.loc_de_munca,s1.comanda,s1.tip_comanda,s1.descriere,sum(s1.cantitativ) as cantitativ, sum(s1.valoric)as valoric 
from #sitcom  s1 where s1.tip in ('PP','NE') 
group by s1.loc_de_munca,s1.comanda,s1.tip_comanda,s1.descriere) s1 on s1.comanda=cm.comanda and s1.loc_de_munca=cm.loc_de_munca
left outer join #sitcom  s2 on s2.comanda=cm.comanda and s2.loc_de_munca=cm.loc_de_munca and s2.tip='CO'
end