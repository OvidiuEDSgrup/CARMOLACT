--***
create procedure InsertFisaPeCont @dDataJos datetime,@dDataSus datetime  
as  
begin  
declare @pas int,@pasmax int  
  
delete from FisaPeCont where data between @dDataJos and @dDataSus  
  
insert into FisaPeCont (Data,Tip,LM,Comanda,Cont,Suma)
select @dDataSus,'D',lm_sup,comanda_sup,comanda_inf,sum(cantitate*valoare) from  
costsql where data between @dDataJos and @dDataSus  
and parcurs=1 and lm_inf=''  
group by lm_sup,comanda_sup,comanda_inf  
  
set @pas=2  
set @pasmax=(select max(parcurs) from costsql where data between @dDataJos and @dDataSus)  
while @pas<@pasmax  
begin  
 select lm_sup,comanda_sup,lm_inf,comanda_inf,sum(costsql.cantitate*costsql.valoare)/max(costurisql.costuri) as pondere  
 into #pond  
 from costsql   
 inner join costurisql on lm_inf=lm and comanda_inf=comanda and costurisql.data=@dDataSus  
 where costsql.data between @dDataJos and @dDataSus and parcurs=@pas  
 and not (lm_sup='' and comanda_sup='' and art_sup in ('P','R','S','A','N'))  
 group by lm_sup,comanda_sup,lm_inf,comanda_inf  
  
 select p.lm_sup,p.comanda_sup,p.lm_inf,p.comanda_inf,p.pondere,  
 f.cont,f.suma*p.pondere as 'SumaCont'  
 into #p1  
 from #pond p  
 inner join FisaPeCont f on p.lm_inf=f.lm and p.comanda_inf=f.comanda and f.data=@dDataSus 
   
 insert into FisaPeCont (Data,Tip,LM,Comanda,Cont,Suma) 
 select distinct @dDataSus,'D',lm_sup,comanda_sup,cont,0  
 from #p1 p1  
 where not exists(select data from FisaPeCont f1 where f1.data=@dDataSus and f1.lm=p1.lm_sup and f1.comanda=p1.comanda_sup and f1.cont=p1.cont)  
   
 update FisaPeCont  
 set suma=suma+isnull((select sum(#p1.sumacont)  
 from #p1 where FisaPeCont.Data=@dDataSus and FisaPeCont.tip='D' and FisaPeCont.lm=#p1.lm_sup and FisaPeCont.comanda=#p1.comanda_sup and FisaPeCont.cont=#p1.cont),0)  
 where data=@dDataSus
 
 insert into FisaPeCont (Data,Tip,LM,Comanda,Cont,Suma) 
 select distinct @dDataSus,'D',lm_sup,comanda_sup,cont,0  
 from #p1 p1  
 where not exists(select data from FisaPeCont f1 where f1.data=@dDataSus and f1.tip='D' and f1.lm=p1.lm_sup and f1.comanda=p1.comanda_sup and f1.cont=p1.cont)  
  
 insert into FisaPeCont (Data,Tip,LM,Comanda,Cont,Suma) 
 select distinct @dDataSus,'C',lm_inf,comanda_inf,cont,0  
 from #p1 p1  
 where not exists(select data from FisaPeCont f1 where f1.data=@dDataSus and f1.tip='C' and f1.lm=p1.lm_inf and f1.comanda=p1.comanda_inf and f1.cont=p1.cont)  
  
 update FisaPeCont  
 set suma=suma-isnull((select sum(#p1.sumacont)  
 from #p1 where FisaPeCont.Data=@dDataSus and FisaPeCont.tip='C' and FisaPeCont.lm=#p1.lm_inf and FisaPeCont.comanda=#p1.comanda_inf and FisaPeCont.cont=#p1.cont),0)  
 where data=@dDataSus
  
 drop table #pond  
 drop table #p1  
 set @pas=@pas+1  
end  
end
