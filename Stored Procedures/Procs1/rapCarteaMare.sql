--***
create procedure rapCarteaMare
	/**	--	Procedura folosita de raportul CG/Contabilitate/Cartea mare
	--	model apel:
	
	declare @DataJos datetime,@DataSus datetime,@CCont nvarchar(4000),@CuSoldRulaj int,@locm nvarchar(4000)
	select @DataJos='2012-01-01 00:00:00',@DataSus='2012-01-31 00:00:00',@CCont='581',@CuSoldRulaj=0,@locm=NULL

	exec rapCarteaMare @DataJos=@DataJos, @DataSus=@DataSus, @CCont=@CCont, @CuSoldRulaj=@CuSoldRulaj, @locm=@locm
*/
--***
	--> parametri obligatorii:
	(@DataJos datetime,@DataSus datetime,
	-->	filtre:
		@CCont varchar(40)=null, @CuSoldRulaj int=2,	--> 1= Nu = Toate, 2= Da = Doar cu sold sau rulaj, 3=cu sold, 4 = cu rulaj
		@locm varchar(20) = null
	,@contcorespondent varchar(40)=null		
	,@centralizare varchar(10) = 2	--> 0=cont, 1=cont corespondent, 2=detalii
	)
as
	/*	Cartea mare
	declare @DataJos datetime,@DataSus datetime,@CCont nvarchar(4000),@CuSoldRulaj int,@locm nvarchar(4000)
	select @DataJos='2009-11-01 00:00:00',@DataSus='2011-11-30 00:00:00'--,@CCont='101%'
			,@CuSoldRulaj=2
			--,@locm='10%'

	--*/
--exec fainregistraricontabile @datasus=@DataSus
set transaction isolation level read uncommitted
if object_id('tempdb..#date') is not null drop table #date
if object_id('tempdb..#LmUtiliz') is not null drop table #LmUtiliz
if object_id('tempdb..#solduri') is not null drop table #solduri
declare @eroare varchar(500)
begin try
	
	select @contcorespondent=@contcorespondent+'%'
	declare @utilizator varchar(20), @subunitate varchar(9),@EOMDataSus datetime, @eLmUtiliz int
	select	@EOMDataSus=DateAdd(day, -1, DateAdd(MONTH, Month(@DataSus), DateAdd(Year, Year(@DataSus)-1901, '1901-1-1')))
	set @subunitate=(select max(val_alfanumerica) from par where tip_parametru='GE' and parametru='SUBPRO')

	select @utilizator=dbo.fIaUtilizator('')
	select cod as valoare into #LmUtiliz from lmfiltrare where utilizator=@utilizator
	set @eLmUtiliz=isnull((select max(1) from #LmUtiliz),0)

	select @CCont=isnull(@CCont,'')+'%'
	if exists (select 1 from par where Tip_parametru='GE' and Parametru='rulajelm' and Val_logica=1)
		set @locm=ISNULL(@locm,'')
		else set @locm=''
	set @locm=@locm+'%'
	
	if object_id('tempdb..#pRulajeConturi_t') is not null
	drop table #pRulajeConturi_t
	create table #pRulajeConturi_t (Subunitate varchar(10) default 1)
	exec pRulajeConturi_tabela
	exec pRulajeConturi @nivelPlanContabil=1, @ccont=@ccont, @cValuta='', @dData=@DataJos, @cLM=@locm
	select * into #solduri from #prulajeconturi_t s where left(s.Cont,1) not in ('8','9')
--	select * into #solduri from dbo.fRulajeConturi(1,@ccont, '', @DataJos, '',@locm, default, null) s where left(s.Cont,1) not in ('8','9')
	select @eroare=(select top 1 rtrim(cont)+' - '+lower(rtrim(s.Denumire_cont)) from #solduri s where s.Denumire_cont='Cont configurat gresit! (Nu are analitice!)')
	if len(@eroare)>0 raiserror(@eroare,16,1)
	
			--> conturi cu rulaj debit:
	select a.subunitate, cont_debitor as cont, isnull(c.denumire_cont, '') as denumire_cont, isnull(c.cont_parinte, '') as cont_parinte, tip_document,
			numar_document as numar_document,
			  data, cont_debitor, cont_creditor, suma as suma_deb, 0 as suma_cred, 0 as sold_deb, 0 as sold_cred,
			  explicatii,
			  (case when tip_document='PI' then str(numar_pozitie,13) else numar_document end) as numar, jurnal, left(explicatii,2) as ID, 
			  isnull(c.tip_cont, '') as tip_cont, isnull(c.are_analitice, 0) as are_analitice, 'CR: '+cont_creditor as grupare,isnull((select denumire_cont from conturi cc where cc.subunitate=subunitate and cc.cont=cont_creditor),'') as den_grupare, 
			  0 as s_db_rulaje, 0 as s_cr_rulaje , 0 as rulaj_db_sint, 0 as rulaj_cr_sint,
			  0 as nivel
			  ,a.numar_pozitie
			  ,convert(varchar(100),'') numarPI
			  into #date
			from pozincon a left outer join conturi c on c.subunitate=a.subunitate and 
			  a.cont_debitor=c.cont
			  where a.subunitate=@subunitate and a.data between @DataJos and @DataSus 
			  and (((@CCont='' and left(a.cont_debitor,1) not in ('8','9') and left(a.cont_creditor,1) not in ('8','9')) or  (@CCont<>'' and exists (select 1 from #solduri ac where ac.cont=a.cont_debitor))))
				and (@eLmUtiliz=0 or exists (select 1 from #LmUtiliz u where u.valoare=a.Loc_de_munca))
				and a.Loc_de_munca like @locm
				and (@contcorespondent is null or a.cont_creditor like @contcorespondent)
	union all 
			--> conturi cu rulaj credit:
	select a.subunitate, cont_creditor as cont, isnull(c.denumire_cont, '') as denumire_cont, isnull(c.cont_parinte, '') as cont_parinte, tip_document,
	(case when tip_document<>'PI' then numar_document else '' end) as numar_document,
			  data, cont_debitor, cont_creditor, 0, suma, 0 as sold_deb, 0 as sold_cred, explicatii,
			  (case when tip_document='PI' then str(numar_pozitie,13) else numar_document end) as numar, jurnal, left(explicatii,2), /*(case when @PeJurnale=1 then jurnal else '' end),*/
			  isnull(c.tip_cont, '') as tip_cont, isnull(c.are_analitice, 0) as are_analitice, 'DB: '+cont_debitor as grupare, isnull((select denumire_cont from conturi cc where cc.subunitate=subunitate and cc.cont=cont_debitor),'') as den_grupare,
			  0 s_db_rulaje, 0 s_cr_rulaje /*, (case when len(ltrim(rtrim(cont_creditor)))>3 and @ContSint=1 then 'DB: '+left(cont_debitor,3) else '' end)*/, /*0,*/ 0, 0,
			  0 as nivel
			  ,a.numar_pozitie
			  ,convert(varchar(100),'') numarPI
			from pozincon a left outer join conturi c on c.subunitate=a.subunitate and 
			  a.cont_creditor=c.cont
			where a.subunitate=@subunitate and a.data between @DataJos and @DataSus and 
			  (((@CCont='' and left(a.cont_creditor,1) not in ('8','9') and left(a.Cont_debitor,1) not in ('8','9')) or (@CCont<>'' and 
			  exists (select 1 from #solduri ac where ac.cont=a.cont_creditor))))
			  and (@eLmUtiliz=0 or exists (select 1 from #LmUtiliz u where u.valoare=a.Loc_de_munca))
			  and a.Loc_de_munca like @locm
			  and (@contcorespondent is null or a.cont_debitor like @contcorespondent)
			--> conturi fara rulaj:
	union all
	select 'totaluri' subunitate, c.cont, c.denumire_cont, c.cont_parinte, '', '', '01/01/1901', '', '', 0, 0,
		(case c.tip_cont when 'A' then s.suma_debit when 'P' then 0 
			else (case when s.suma_debit>0 then s.suma_debit else 0 end) end) as sold_cred,
		(case c.tip_cont when 'P' then s.suma_credit when 'A' then 0 
			else (case when s.suma_credit>0 then s.suma_credit else 0 end) end) as sold_deb,
		'', '', '', '', /*'',*/ c.tip_cont, c.are_analitice, 
		'','',
		--0,0,0,0
		isnull((select sum(rulaj_debit) from rulaje r1 where r1.subunitate=c.subunitate and r1.cont=c.cont and r1.data between dbo.eom(@datajos) and @EOMDataSus and r1.valuta='' and r1.Loc_de_munca like @locm
			and (@eLmUtiliz=0 or exists (select 1 from #LmUtiliz u where u.valoare=r1.Loc_de_munca))),0),
		isnull((select sum(rulaj_credit) from rulaje r1 where r1.subunitate=c.subunitate and r1.cont=c.cont and r1.data between dbo.eom(@datajos) and @EOMDataSus and r1.valuta='' and r1.Loc_de_munca like @locm
			and (@eLmUtiliz=0 or exists (select 1 from #LmUtiliz u where u.valoare=r1.Loc_de_munca))),0)/*,''*/,
		(case when c.cont_parinte='' then isnull(
				(select sum(rulaj_debit) from rulaje r1 where r1.subunitate=c.subunitate and r1.cont=c.cont and r1.data between dbo.eom(@datajos) and @EOMDataSus and r1.valuta=''
						and (@locm is null or r1.Loc_de_munca like @locm+'%') and (@eLmUtiliz=0 or exists (select 1 from #LmUtiliz u where u.valoare=r1.Loc_de_munca))),0) else 0 end) s_db_rulaje,
		(case when c.cont_parinte='' then isnull(
				(select sum(rulaj_credit) from rulaje r1 where r1.subunitate=c.subunitate and r1.cont=c.cont and r1.data between dbo.eom(@datajos) and @EOMDataSus and r1.valuta=''
						and (@locm is null or r1.Loc_de_munca like @locm+'%') and (@eLmUtiliz=0 or exists (select 1 from #LmUtiliz u where u.valoare=r1.Loc_de_munca))),0) else 0 end) s_cr_rulaje,
		2 as nivel, 0 numar_pozitie, '' numarPI
	from conturi c inner join #solduri s on c.Cont=s.cont
	where c.subunitate=@subunitate and left(c.cont,1) not in ('8','9')
	order by cont, grupare, data, Tip_document, numar_document, numar
	--*/

	--> luarea numarului de document pentru tip PI:
		update d set numarPI=p.numar
			from #date d
				cross apply (select top 1 p.numar from pozplin p where p.subunitate=d.subunitate and p.cont=d.cont_debitor and p.data=d.data and p.numar_pozitie=d.numar_pozitie) p
			where d.tip_document='PI' --and numar_document=''
		
		update d set numarPI=p.numar
			from #date d
				cross apply (select top 1 p.numar from pozplin p where p.subunitate=d.subunitate and p.cont=(case when left(d.explicatii,1)='I' then d.cont_debitor else d.cont_creditor end)
										and p.data=d.data and p.numar_pozitie=d.numar_pozitie) p
			where d.tip_document='PI' and isnull(numarPI,'')=''
		
		update d set numar_document=numarPI from #date d where d.tip_document='PI' and isnull(numarPI,'')<>''

--> completez cu totaluri in nivel>=2 pentru a se putea genera cu centralizare:
	update d set suma_deb=isnull(t.suma_deb,0), suma_cred=isnull(t.suma_cred,0)
		from #date d cross apply (select sum(suma_deb) suma_deb, sum(suma_cred) suma_cred from #date t where t.nivel=0 and rtrim(t.cont)=rtrim(d.cont)) t
	where d.nivel>=2
	
	--> calculez rulajele pe conturi cu analitice:
	declare @lungime_conturi int
	select @lungime_conturi=50
	while @lungime_conturi>0
	begin		
		update d set suma_deb=isnull(x.suma_deb,0), suma_cred=isnull(x.suma_cred,0)
		from #date d
			cross apply (select sum(isnull(a.suma_deb,0)) suma_deb, sum(isnull(a.suma_cred,0)) suma_cred, max(a.cont) uncont from #date a where a.cont_parinte=d.cont and a.nivel=2) x
		where d.nivel=2 and len(d.cont)=@lungime_conturi and uncont is not null
		select @lungime_conturi=@lungime_conturi-1
	end
	--> adaug o linie de total general de pe liniile superioare de nivel 2 (conturi fara parinte):
	insert into #date(subunitate, cont, denumire_cont, cont_parinte, tip_document, numar_document, data, cont_debitor, cont_creditor, suma_deb, suma_cred, sold_deb, sold_cred, explicatii, numar, jurnal, ID, tip_cont, are_analitice, grupare, den_grupare, s_db_rulaje, s_cr_rulaje, rulaj_db_sint, rulaj_cr_sint, nivel, numar_pozitie, numarPI)
	select '1' subunitate, '' cont, 'Total -' denumire_cont, '' cont_parinte, '' tip_document, '' numar_document, '' data, '' cont_debitor, '' cont_creditor,
		isnull(sum(isnull(suma_deb,0)),0) suma_deb, isnull(sum(isnull(suma_cred,0)),0) suma_cred, isnull(sum(isnull(sold_deb,0)),0) sold_deb, isnull(sum(isnull(sold_cred,0)),0) sold_cred,
		'' explicatii, '' numar, '' jurnal, 0 ID, 'B' tip_cont, '1' are_analitice, '' grupare, '' den_grupare,
			0 s_db_rulaje, 0 s_cr_rulaje, 0 rulaj_db_sint, 0 rulaj_cr_sint, 3 nivel, 0 numar_pozitie, '' numarPI
	from #date d where d.cont_parinte='' and d.nivel=2--not exists (select 1 from #date c where c.cont=d.cont_parinte)
	
	if (@CuSoldRulaj=1)	--> daca e cazul se elimina randurile care nu au sume
	delete d
		from #date d inner join (select sum(abs(s.sold_cred)+abs(s.sold_deb)+abs(s.suma_cred)+abs(s.suma_deb)) as suma, s.cont from #date s group by s.cont) s on d.cont=s.cont
		where not (isnull(s.suma,0)>0.005)
		
	if (@CuSoldRulaj=3)	--> daca e cazul se elimina randurile care nu au sold
	delete d
		from #date d inner join (select sum(abs(s.sold_cred)+abs(s.sold_deb)+abs(s.suma_cred-s.suma_deb)) as suma, s.cont from #date s group by s.cont) s on d.cont=s.cont
		where not (isnull(s.suma,0)>0.005)
	
	if (@CuSoldRulaj=4)	--> daca e cazul se elimina randurile care nu au rulaj
	delete d
		from #date d inner join (select sum(abs(s.suma_cred)+abs(s.suma_deb)) as suma, s.cont from #date s group by s.cont) s on d.cont=s.cont
		where not (isnull(s.suma,0)>0.005)
	
--	select * from #date d-- where d.nivel=2

	--> elimin toate datele care nu au legatura cu filtrarea pe cont corespondent:
	if @contcorespondent is not null
	delete d from #date d where not exists (select 1 from #date p where p.grupare<>'' and d.cont=p.cont)
	
	
-->formarea de grupari recursive:
--> conturi
	select '' cod_parinte, rtrim(cont) as cod,
		--cont, 
			rtrim(cont)+isnull(' - '+max(rtrim(denumire_cont)),'') denumire,
			max(x.sold_initial) sold_initial,
			max(case when abs(sold_initial)=0 then ''
					when debit=1 then
						convert(varchar(30),convert(money,sold_initial),1)+' DB'
						else convert(varchar(30),convert(money,-sold_initial),1)+' CR' end)
				sold_initial_str,
			
			(case	when abs(max(suma_deb)-max(suma_cred)+max(sold_initial))<0.01 then ''
					when tip_cont='A' or tip_cont='B' and Sum(suma_deb)-Sum(suma_cred)+max(sold_initial)>0
						then convert(varchar(30),convert(money, Sum(suma_deb)-Sum(suma_cred)+max(sold_initial)),1)+' DB'
					else convert(varchar(30),convert(money, Sum(suma_cred)-Sum(suma_deb)-max(sold_initial)),1)+' CR' end) sold_final_str,
					
			max(s_db_rulaje) s_db_rulaje, max(s_cr_rulaje) s_cr_rulaje, d.tip_cont tip_cont, '1901-1-1' data, max(nivel) nivel,
			max(x.debit) debit, sum(d.rulaj_db_sint) rulaj_db_sint, sum(d.rulaj_cr_sint) rulaj_cr_sint,
			sum(suma_deb) suma_debit, sum(suma_cred) suma_credit, '' explicatii, '' tip
	from #date d
		cross apply(			--> cross apply cu singurul scop de a nu repeta aceeasi expresie de mai multe ori
			select
				(d.sold_deb-d.sold_cred) as sold_initial,
				(case when d.tip_cont='A' or d.tip_cont='B' and d.sold_deb-d.sold_cred>0 then 1 else -1 end) debit
		) x
		where nivel>=2 group by cont, tip_cont
	union all
-->		conturi corespondente
	select 
		max(rtrim(d.cont)) as cod_parinte, max(rtrim(d.cont))+'|'+rtrim(d.grupare),
		rtrim(d.grupare)+' - '+max(rtrim(d.den_grupare)) denumire, 0 sold_initial, '' sold_initial_str, '' sold_final_str,
		sum(d.suma_deb) s_db_rulaje, sum(d.suma_cred) s_cr_rulaje,
		d.tip_cont tip, '1901-1-1' data, 1 nivel,
		(case when d.tip_cont='A' or d.tip_cont='B' and max(d.sold_deb-d.sold_cred)>0 then 1 else -1 end) debit, 0 as rulaj_db_sint, 0 as rulaj_cr_sint,
		sum(d.suma_deb) s_db_rulaje, sum(d.suma_cred) s_cr_rulaje,
		'' explicatii, '' tip
	from #date d where grupare<>'' and nivel=0 and @centralizare>=1 group by d.grupare, d.tip_cont, d.cont
	union all
-->		detalii
	select 
		rtrim(d.cont)+'|'+rtrim(d.grupare), rtrim(d.cont)+'|'+rtrim(d.grupare)+'|'+rtrim(convert(varchar(20),d.data,102))+'|'+rtrim(d.tip_cont)+'|'+rtrim(d.numar) as cod,
		rtrim(d.numar) as denumire, 0 sold_initial, '' sold_initial_str, '' sold_final_str,
		d.suma_deb s_db_rulaje, d.suma_cred s_cr_rulaje, d.tip_cont, d.data, 0 nivel,
		(case when d.tip_cont='A' or d.tip_cont='B' and d.sold_deb-d.sold_cred>0 then 1 else -1 end) debit, 0 rulaj_db_sint, 0 rulaj_cr_sint,
		suma_deb suma_debit, suma_cred suma_credit, rtrim(d.explicatii) explicatii, d.tip_document tip
	from #date d where nivel=0 and @centralizare>=2
	order by nivel, cod
--	*/
end try
begin catch
	set @eroare=ERROR_MESSAGE()+'(rapCarteaMare)'
end catch

if len(@eroare)>0 --raiserror(@eroare,16,1)
	select '<EROARE>' as cod_parinte, @eroare as cod

if object_id('tempdb..#date') is not null drop table #date
if object_id('tempdb..#LmUtiliz') is not null drop table #LmUtiliz
if object_id('tempdb..#solduri') is not null drop table #solduri
