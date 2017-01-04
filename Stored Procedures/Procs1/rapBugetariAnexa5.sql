
--***
create procedure rapBugetariAnexa5 (@datajos datetime,@datasus datetime,@prefix varchar(40),@ign_pb nvarchar(1),--@grupa varchar(20), 
			@nivCent varchar(20), @locm varchar(9), @doar_sume int, @in_tabela_temporara int=0
			,@cont varchar(13)=null,@cont_debitor varchar(13)=null,@cont_creditor varchar(13)=null, @valuta varchar(3)=null)
as
begin
/*	Executie bugetara anexa 5 (si 16): scriptul de luare date
--select max(rtrim(descriere)) as label,comanda as value from comenzi where len(comanda)=8 group by comanda
declare @datajos datetime,@datasus datetime,@prefix varchar(20),@ign_pb bit, @locm varchar(9), @nivcent varchar(20), @doar_sume int
select @prefix='1 0', @datajos='2011-1-1', @datasus='2011-3-31', @ign_pb=1, @nivCent='6,8', @doar_sume=1
--*/
declare @q_datajos datetime,@q_datasus datetime,@q_prefix varchar(20),@q_tmp datetime,@q_ign_pb bit,
		@q_doar_sume int, @problema bit, @masca varchar(18)
select @q_datajos=@datajos	,@q_datasus=@datasus ,@q_prefix=rtrim(isnull(@prefix,'')) ,@q_tmp=convert(varchar(4),year(@q_datasus)-1)+'-12-31' 
		,@q_ign_pb=@ign_pb, @q_doar_sume=@doar_sume
		,@problema=0

set @masca=@q_prefix+REPLICATE('X',18-LEN(@q_prefix))		/**	cu @masca si @nivcent stabilesc centralizarea datelor*/
/** daca nu se ruleaza fortat raportul (@ign_pb=1) si se gasesc probleme la configurarea legaturilor dintre indicatori se anuleaza rularea rap.: */
					
if @q_ign_pb=0 and exists (select 1 from indbugcomp p where not exists (
		select 1 from indbug c where c.indbug=p.compindbug or p.compindbug='')
								and exists (select 1 from indbug c where c.indbug=p.indbug))
begin	set @problema=1
			insert into #tmp(denumire, cod, prev_bug_init, prev_bug_trim_def, drept_cnst_a_p, drept_cnst_a_c, inc_real, s_a_inc, tip_pb) 
				select rtrim(p.indbug) as denumire, p.compindbug as cod, 0 as prev_bug_init, 
				0 as prev_bug_trim_def, 0 as drept_cnst_a_p, 0 as drept_cnst_a_c, 0 as inc_real, 0 as s_a_inc, 1 as tip_pb
			from indbugcomp p where not exists (select 1 from indbug c where c.indbug=p.compindbug or p.compindbug='')
		and exists (select 1 from indbug c where c.indbug=p.indbug)
		goto final
end
	/**	Pregatire filtrare pe proprietati utilizatori*/
declare @eLmUtiliz int
declare @LmUtiliz table(valoare varchar(200), cod_proprietate varchar(20))
insert into @LmUtiliz(valoare, cod_proprietate)
select valoare, cod_proprietate from fPropUtiliz() where valoare<>'' and cod_proprietate='LOCMUNCA'
set @eLmUtiliz=isnull((select max(1) from @LmUtiliz),0)
	/**	Se iau sume din documente - pe anul precedent (#f_ap) si anul curent (#f_ac)*/
select substring(comanda,21,20) as indbug,tip,sum(tva) as tva, sum(valoare) as valoare,sum(achitat) as achitat into #f_ap -- an precedent
	from dbo.fTert('B', '01/01/1901', @q_tmp,null,null,null,0,1,1,null) f
	where (@locm is null or f.loc_de_munca like @locm+'%')
			and (@cont is null or f.cont_de_tert like @cont+'%' or f.cont_coresp like @cont+'%')
			and (@cont_debitor is null or f.cont_de_tert like @cont_debitor+'%')
			and (@cont_creditor is null or f.cont_coresp like @cont_creditor+'%')
			and (@valuta is null or f.Valuta=@valuta)
	group by tip,substring(comanda,21,20)
	
set @q_tmp=dateadd(dd,1,@q_tmp)
select substring(comanda,21,20) as indbug,tip,sum(tva) as tva, sum(valoare) as valoare,sum(achitat) as achitat into #f_ac -- an curent
	from dbo.fTert('B', @q_tmp,@q_datasus,null,null,null,0,1,1,null) f
	where (@locm is null or f.loc_de_munca like @locm+'%')
			and (@cont is null or f.cont_de_tert like @cont+'%' or f.cont_coresp like @cont+'%')
			and (@cont_debitor is null or f.cont_de_tert like @cont_debitor+'%')
			and (@cont_creditor is null or f.cont_coresp like @cont_creditor+'%')
			and (@valuta is null or f.Valuta=@valuta)
	group by tip,substring(comanda,21,20)

		/**	se iau sume	previzionate pe trimestre */
select p.suma,p.numar_document,c.indbug,c.denumire,p.cont_debitor,p.data into #com 
		from indbug c left join pozincon p on substring(p.comanda,21,20)=c.indbug
			and (@locm is null or p.loc_de_munca like @locm+'%')
			and (@cont is null or p.cont_debitor like @cont+'%' or p.cont_creditor like @cont+'%')
			and (@cont_debitor is null or p.cont_debitor like @cont_debitor+'%')
			and (@cont_creditor is null or p.cont_creditor like @cont_creditor+'%')
			and (@valuta is null or p.Valuta=@valuta)
			and (@eLmUtiliz=0 or p.Loc_de_munca='' or exists (select 1 from @LmUtiliz u where u.valoare=p.Loc_de_munca))
	where dbo.indicatorCheltuieli(c.indbug)<>1
-- Ghita: aici ar trebui filtrati indicatorii bugetari ca lumea!
		/**	se unifica si se aranjeaza datele culese mai sus conform regulilor stabilite pentru bugetari*/
select c.indbug,c.denumire,c.cod,c.prev_bug_init,c.prev_bug_trim_def,
		f_ap.drept_cnst_a_p,f_ac.drept_cnst_a_c,f_ac.inc_real,f_ac.s_a_inc
		,0 as tip_pb
		into #an7 from 
	(select indbug,max(c.denumire) as denumire, rtrim(c.indbug) as cod --!!!!!!!
		,sum(case when c.cont_debitor='8060' and (left(c.numar_document,2)='ba' or left(c.numar_document,2)='rb') and year(c.data) between year(@q_datajos) and year(@q_datasus) then c.suma else 0 end) as prev_bug_init
		,sum(case when c.cont_debitor='8060' and (left(c.numar_document,2)='ba' or left(c.numar_document,2)='rb') and c.data between 
			(case when month(@q_datajos) between 1 and 3 then convert(datetime,convert(char(4),year(@q_datajos))+'-1-1')
			 when month(@q_datajos) between 4 and 6 then convert(datetime,convert(char(4),year(@q_datajos))+'-4-1')
			 when month(@q_datajos) between 7 and 9 then convert(datetime,convert(char(4),year(@q_datajos))+'-7-1')
			 when month(@q_datajos) between 10 and 12 then convert(datetime,convert(char(4),year(@q_datajos))+'-10-1') else 0 end)
		 and (case when month(@q_datasus) between 1 and 3 then dateadd("d",-1,convert(datetime,convert(char(4),year(@q_datasus))+'-4-1'))
			 when month(@q_datasus) between 4 and 6 then dateadd("d",-1,convert(datetime,convert(char(4),year(@q_datasus))+'-7-1'))
			 when month(@q_datasus) between 7 and 9 then dateadd("d",-1,convert(datetime,convert(char(4),year(@q_datasus))+'-9-1'))
			 when month(@q_datasus) between 10 and 12 then dateadd("d",-1,convert(datetime,convert(char(4),year(@q_datasus)+1)+'-1-1')) else 0 end)
		 then c.suma else 0 end) as prev_bug_trim_def from #com c group by indbug) c	
left join (select indbug,sum(isnull(#f_ap.valoare,0)+isnull(#f_ap.tva,0)) as drept_cnst_a_p 
			from #f_ap where #f_ap.tip in ('AP','AS','FB','IF','ME','AC') group by indbug) as f_ap on f_ap.indbug=c.indbug
left join (select indbug, 
			sum(isnull((case when #f_ac.tip in ('AP','AS','FB','IF','ME','AC') 
				then isnull(#f_ac.valoare,0)+isnull(#f_ac.tva,0) else 0 end),0)) as drept_cnst_a_c
		,sum(isnull((case when #f_ac.tip in ('IB','IR','PS') then #f_ac.achitat else 0 end),0)) as inc_real
		,sum(isnull((case when #f_ac.tip in ('CO','BX','C3','CF','CB') then #f_ac.achitat else 0 end),0)) as s_a_inc
		from #f_ac group by indbug) as f_ac on f_ac.indbug=c.indbug
order by c.indbug
	/**	elimin sumele de pe nivelele superioare pentru a nu incurca in continuare*/
update #an7 set prev_bug_init=0, prev_bug_trim_def=0, drept_cnst_a_p=0, drept_cnst_a_c=0, inc_real=0, s_a_inc=0 
where exists(select 1 from #an7 b where len(rtrim(b.cod))>len(rtrim(#an7.cod)) and rtrim(b.cod) like rtrim(#an7.cod)+'%') or cod not like @q_prefix+'%'

	/**	urmeaza calculul sumelor in sus, pe arborele indicatorilor*/
select top 0 denumire, cod, prev_bug_init, prev_bug_trim_def, drept_cnst_a_p, drept_cnst_a_c, inc_real, s_a_inc, tip_pb into #tmp from #an7

begin
	declare @q_lung int ,@iterator int,@numarator int,@bucla bit set @q_lung=16 set @iterator=0 set @bucla=0
	while (select count(*) from #an7)>0 and @iterator<100
	begin
	--	print @q_lung
		delete from #an7 from #an7 a, #tmp t where a.cod=t.cod
		insert into #tmp 
			select max(a.denumire) ,a.cod ,sum(a.prev_bug_init)+sum(isnull(t.prev_bug_init,0))
					,sum(a.prev_bug_trim_def)+sum(isnull(t.prev_bug_trim_def,0))
					,sum(a.drept_cnst_a_p)+sum(isnull(t.drept_cnst_a_p,0)) 
					,sum(a.drept_cnst_a_c)+sum(isnull(t.drept_cnst_a_c,0)) 
					,sum(a.inc_real)+sum(isnull(t.inc_real,0)),sum(a.s_a_inc)+sum(isnull(t.s_a_inc,0))
					,0 as tip_pb
				from #an7 a left join #tmp t on left(t.cod,len(rtrim(t.cod))-2)=a.cod and not exists(select 1 from indbugcomp p where t.cod=p.compindbug
												and p.indbug<>p.compindbug and p.compindbug<>'')
				where not exists(select 1 from indbugcomp p where a.cod=p.indbug and p.indbug<>p.compindbug and p.compindbug<>'')
						and len(a.cod) between @q_lung-1 and @q_lung
			group by a.cod
		while (select count(*) from #an7 where len(rtrim(cod)) between @q_lung-1 and @q_lung)>0 and 
			@numarator<(select count(*) from #tmp where len(rtrim(cod)) between @q_lung-1 and @q_lung)
		begin
			set @numarator=(select count(*) from #an7 where len(rtrim(cod)) between @q_lung-1 and @q_lung)
			delete from #an7 from #an7 a, #tmp t where a.cod=t.cod
			insert into #tmp 
				select
					max(a.denumire) ,a.cod ,sum(t.prev_bug_init),sum(t.prev_bug_trim_def),sum(t.drept_cnst_a_p),
						sum(t.drept_cnst_a_c),sum(t.inc_real),sum(t.s_a_inc),0 as tip_pb
					from #an7 a inner join indbugcomp p on a.cod=p.indbug and p.indbug<>p.compindbug and p.compindbug<>''
								inner join #tmp t on p.compindbug=t.cod
						 where len(rtrim(a.cod)) between @q_lung-1 and @q_lung
			group by a.cod
		end
		if (@numarator=(select count(*) from #tmp where len(rtrim(cod)) between @q_lung-1 and @q_lung)) set @bucla=1
		set @iterator=@iterator+(case when @q_lung<0 then 100-@iterator else 1 end)
		set @q_lung=@q_lung-2
	end
	if	((@iterator>=100 or @bucla=1) and @q_ign_pb=0)
	begin
		set @problema=1
		truncate table #tmp
		insert into #tmp(denumire, cod, prev_bug_init, prev_bug_trim_def, drept_cnst_a_p, drept_cnst_a_c, inc_real, s_a_inc, tip_pb) 
				select 'Problema nedeterminata' as denumire, 'bucla infinita' as cod, 0 as prev_bug_init, 
				0 as prev_bug_trim_def, 0 as ang_bug, 0 as ang_leg, 0 as pl_ef, 0 as chelt_ef, 2 as tip_pb
	end
end
 --*/
final:--/*	se grupeaza sumele in functie de nivelele de centralizare selectate:
select (case when max(denumire)=MIN(denumire) then max(denumire) else '----' end) as denumire, max(cod1) as cod1, max(cod) as cod, 
		sum(prev_bug_init) as prev_bug_init, sum(prev_bug_trim_def) as prev_bug_trim_def, 
		sum(isnull(drept_cnst_a_p,0)) drept_cnst_a_p, sum(isnull(drept_cnst_a_c,0)) drept_cnst_a_c, sum(isnull(inc_real,0)) inc_real,
		sum(isnull(s_a_inc,0)) s_a_inc,	max(isnull(tip_pb,0)) as tip_pb,
		max(codGrupare) as codGrupare into #final
from
(
select max(rtrim(t.denumire)) denumire,max(cod) as cod1,max(rtrim(case when len(cod)<=8 then ''--right(rtrim(cod),2) 
		else right(rtrim(substring(cod,9,15)),6) end)) as cod
		,max(prev_bug_init) prev_bug_init,max(prev_bug_trim_def) prev_bug_trim_def, max(drept_cnst_a_p) drept_cnst_a_p, 
		max(drept_cnst_a_c) drept_cnst_a_c, max(inc_real) inc_real,
		max(s_a_inc) s_a_inc, max(tip_pb) as tip_pb,
		max((case when CHARINDEX(',4,',','+@nivCent+',')>0 then substring(t.cod,1,4) else substring(@masca,1,4) end)+
		(case when CHARINDEX(',6,',','+@nivCent+',')>0 then substring(t.cod,5,2) else substring(@masca,5,2) end)+
		(case when CHARINDEX(',8,',','+@nivCent+',')>0 then substring(t.cod,7,2) else substring(@masca,7,2) end)+
		(case when CHARINDEX(',10,',','+@nivCent+',')>0 then substring(t.cod,9,2) else substring(@masca,9,2) end)+
		(case when CHARINDEX(',12,',','+@nivCent+',')>0 then substring(t.cod,11,2) else substring(@masca,11,2) end)+
		(case when CHARINDEX(',14,',','+@nivCent+',')>0 then substring(t.cod,13,2) else substring(@masca,13,2) end)+
		(case when CHARINDEX(',16,',','+@nivCent+',')>0 then substring(t.cod,15,2) else substring(@masca,15,2) end)) as codGrupare
		from #tmp t
	where cod like rtrim(@q_prefix)+'%'
			and (@nivCent is null or CHARINDEX(','+rtrim(convert(varchar(2),
					 ROUND(((case when LEN(t.cod)<4 then 4 else LEN(t.cod) end)+1)/2,0)*2
					))+',',','+@nivCent+',')>0)
			or (@problema=1 and @q_ign_pb=0)
	group by cod
) z 
where (@q_doar_sume=0 or abs(isnull(prev_bug_init,0))+abs(isnull(prev_bug_trim_def,0))+
			abs(isnull(drept_cnst_a_p,0))+abs(isnull(drept_cnst_a_c,0))+abs(isnull(inc_real,0))+abs(isnull(s_a_inc,0)+abs(isnull(tip_pb,0)))
		>0)
group by codGrupare
order by cod1 

	/**	daca se foloseste tabela temporara (apel din anexa16) scrie in tabela, altfel aduce datele direct */
if (@in_tabela_temporara=0)	
	select denumire, cod1, cod, prev_bug_init, prev_bug_trim_def, drept_cnst_a_p, drept_cnst_a_c, inc_real, s_a_inc, tip_pb, codGrupare from #final
	else if object_id('tempdb.dbo.tRapBugetariAnexa5') is null
		select denumire, cod1, cod, prev_bug_init, prev_bug_trim_def, drept_cnst_a_p, drept_cnst_a_c, inc_real, s_a_inc, 
				tip_pb, codGrupare, host_id() hostid
			into tempdb.dbo.tRapBugetariAnexa5 from #final
		else begin delete from tempdb.dbo.tRapBugetariAnexa5 where hostid=host_id()
				insert into tempdb.dbo.tRapBugetariAnexa5(denumire, cod1, cod, prev_bug_init, prev_bug_trim_def, 
							drept_cnst_a_p, drept_cnst_a_c, inc_real, s_a_inc, tip_pb, codGrupare, hostid)
				select denumire, cod1, cod, prev_bug_init, prev_bug_trim_def, drept_cnst_a_p, drept_cnst_a_c, inc_real, 
					s_a_inc, tip_pb, codGrupare, host_id() hostid from #final
				order by codGrupare
			end

drop table #f_ac	drop table #f_ap	drop table #an7	drop table #tmp	drop table #com
drop table #final
end