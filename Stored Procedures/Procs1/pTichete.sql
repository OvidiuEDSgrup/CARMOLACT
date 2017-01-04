--***
/**	procedura pentru tichete de masa (apelata din mai multe locuri: generare NC salarii, calcul lichidare, rapoarte)	*/
Create procedure pTichete 
	(@dataJos datetime, @dataSus datetime, @marca char(6), @DeLaCalculLichidare int, @parXML xml='<row/>') 
as
/*
	@DeLaCalculLichidare 
		-> 0 din alte locuri decat in afara de calcul lichidare (grupare pe locuri de munca).
		-> 1 de la calcul lichidare (grupare pe marca).
		-> 2 de la generare nota contabila tichete (grupare pe marca si loc de munca, sa se poata in procedura de generare sa se completeze contul debitor functie de activitate).
*/
begin try

	declare @userASiS char(10), @lista_lm int, @multiFirma int, @ValoareTichet decimal(7,2), 
	@SalComenzi int, @TicheteMacheta int, @TichetePersonalizate int, @NCTichete int, @cTabela char(2), @TipDocument char(2), @NCTichComenzi int, @ParcurgTichete int, @Remarul int, 
	@mesaj varchar(1000), @existaTabela int, @tipoperatie char(1)

	set @userASiS=dbo.fIaUtilizator(null)
	set @lista_lm=dbo.f_areLMFiltru(@userASiS)
	set @multiFirma=0
--	daca tabela par este view inseamna ca se lucreaza cu parametrii pe locuri de munca (in aceeasi BD sunt mai multe unitati)	
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1

	set @ValoareTichet=dbo.iauParLN(@dataSus,'PS','VALTICHET')
	set @SalComenzi=dbo.iauParL('PS','SALCOM')
	set @TicheteMacheta=dbo.iauParL('PS','OPTICHINM')
	set @TichetePersonalizate=dbo.iauParL('PS','TICHPERS')
	set @NCTichete=dbo.iauParL('PS','NC-TICHM')
	set @cTabela=(case when len(rtrim(convert(char(2),dbo.iauParN('PS','NC-TICHM'))))>1 then right(rtrim(convert(char(2),dbo.iauParN('PS','NC-TICHM'))),1) else '1' end)
	set @TipDocument=(case when len(rtrim(convert(char(2),dbo.iauParN('PS','NC-TICHM'))))>1 then left(convert(char(2),dbo.iauParN('PS','NC-TICHM')),1) else '2' end) 
	set @NCTichComenzi=dbo.iauParL('PS','NC-TICCOM')
	set @ParcurgTichete=(case when @TicheteMacheta=1 and @cTabela='' or @cTabela='2' then 1 else 0 end)
	set @Remarul=dbo.iauParL('SP','REMARUL')

	set @tipoperatie=@parXML.value('(/row/@tipoperatie)[1]','char(1)')
	
	set @existaTabela=0

	if object_id('tempdb..#tmpTichete') is not null drop table #tmpTichete
	if object_id('tempdb..#realcom_tichete') is not null drop table #realcom_tichete
	if object_id('tempdb..#tmprealcom') is not null drop table #tmprealcom
	if object_id('tempdb..#reptichete') is not null drop table #reptichete

	if object_id('tempdb..#ptichete') is not null 
		set @existaTabela=1
	else 
	begin
		create table #ptichete (data datetime)
		exec CreeazaDiezSalarii @numeTabela='#ptichete'
	end

	select * into #realcom_tichete
	from realcom
	where data between @datajos and @datasus and (isnull(@marca,'')='' or Marca=@marca) 

	if exists (select 1 from sysobjects where name='pTicheteSP' and xtype='P')
		exec pTicheteSP @dataJos=@dataJos, @dataSus=@dataSus, @marca=@marca, @DeLaCalculLichidare=@DeLaCalculLichidare, @parXML=@parXML

	select max(dbo.eom(a.data)) as data, max(a.marca) as marca, (case when @DeLaCalculLichidare in (0,2) then a.Loc_de_munca else isnull(n.Loc_de_munca,p.Loc_de_munca) end) as loc_de_munca, 
		(case when @SalComenzi=1 and @DeLaCalculLichidare in (0,2) then isnull(r.Comanda,'') else '' end) as comanda, 
		'C' as Tip_tichete, round(sum(a.ore__cond_6),(case when @DeLaCalculLichidare=1 then 0 else 2 end)) as numar_tichete, 
		round(round(sum(a.ore__cond_6),(case when @DeLaCalculLichidare=1 then 0 else 2 end))*@ValoareTichet,10,2) as valoare_tichete, 
		isnull(max(r1.Realizat),0) as Realizat, (case when @SalComenzi=1 or @NCTichComenzi=1 then max(a.marca) else '' end) as ordonare,  
		(case when @DeLaCalculLichidare in (0,2) then a.Loc_de_munca else isnull(n.Loc_de_munca,p.Loc_de_munca) end) as ordonare_lm 
	into #tmpTichete
	from pontaj a 
		left outer join #realcom_tichete r on @SalComenzi=1 and r.data=a.data and r.marca=a.marca and substring(r.numar_document,3,10)=convert(char(10),numar_curent) 
		left outer join personal p on a.marca=p.marca
		left outer join net n on a.marca=n.marca and dbo.EOM(a.data)=n.data
		left outer join (select marca, loc_de_munca, sum(cantitate*tarif_unitar) as Realizat from #realcom_tichete r where data between @dataJos and @dataSus
			group by marca, loc_de_munca) r1 on r1.marca=a.marca and r1.loc_de_munca=a.loc_de_munca
		left outer join LMFiltrare lu on lu.utilizator=@userASiS and lu.cod=a.Loc_de_munca
	where @ParcurgTichete=0 and a.data between @dataJos and @dataSus and (isnull(@marca,'')='' or a.Marca=@marca)
		and (dbo.f_areLMFiltru(@userASiS)=0 or @DeLaCalculLichidare=1 and @multiFirma=0 or lu.cod is not null)
	group by (case when @DeLaCalculLichidare in (0,2) then a.Loc_de_munca else isnull(n.Loc_de_munca,p.Loc_de_munca) end), 
		(case when @DeLaCalculLichidare in (1,2) or @SalComenzi=1 or @NCTichComenzi=1 then a.marca else '' end), 
		(case when @SalComenzi=1 and @DeLaCalculLichidare in (0,2) then isnull(r.Comanda,'') else '' end) 
	union all 
	select max(a.data_lunii) as data, max(a.marca) as marca, isnull(n.Loc_de_munca,p.Loc_de_munca), 
		(case when @SalComenzi=1 then max(isnull(p.comanda,ip.Centru_de_cost_exceptie)) else '' end) as comanda, 
		(case when @DeLaCalculLichidare=1 then '' when a.Tip_operatie='S' then 'S' else 'C' end) as Tip_tichete,  
		sum((case when a.tip_operatie='R' then -1 else 1 end)*a.nr_tichete) as numar_tichete, 
		sum((case when a.tip_operatie='R' then -1 else 1 end)*a.nr_tichete*a.valoare_tichet) as valoare_tichete, 
		isnull(max(r.Realizat),0) as Realizat, 
		(case when @DeLaCalculLichidare in (1,2) or @SalComenzi=1 or @NCTichComenzi=1 then max(a.marca) else '' end) as ordonare,  
		(case when @DeLaCalculLichidare in (0,2) then isnull(n.Loc_de_munca,p.Loc_de_munca) else '' end) as ordonare_lm 
	from tichete a 
		left outer join personal p on a.marca=p.marca
		left outer join infopers ip on a.marca=ip.marca
		left outer join net n on a.marca=n.marca and a.data_lunii=n.data
		left outer join (select marca, sum(cantitate*tarif_unitar) as Realizat 
			from #realcom_tichete r where data between @dataJos and @dataSus group by marca) r on r.marca=a.marca
		left outer join LMFiltrare lu on lu.utilizator=@userASiS and lu.cod=isnull(n.Loc_de_munca,p.Loc_de_munca)
	where @ParcurgTichete=1 and a.data_lunii between @dataJos and @dataSus and (isnull(@marca,'')='' or a.Marca=@marca) 
		and (@TichetePersonalizate=1 and (tip_operatie in ('C','S','R') or @Remarul=0 and tip_operatie='P')
			or @TichetePersonalizate=0 and (tip_operatie in ('P','S') 
				or @TicheteMacheta=1 and tip_operatie='C' 
					and not exists (select 1 from tichete b where b.Data_lunii=a.data_lunii and b.Marca=a.Marca and b.Tip_operatie='P' and b.Serie_inceput<>'' and b.Serie_sfarsit<>'')
				or tip_operatie='R' and valoare_tichet<>0))
		and (@tipoperatie is null or a.Tip_operatie=@tipoperatie)
		and (dbo.f_areLMFiltru(@userASiS)=0 or @DeLaCalculLichidare=1 and @multiFirma=0 or lu.cod is not null)
	group by isnull(n.Loc_de_munca,p.Loc_de_munca), 
		(case when @DeLaCalculLichidare in (1,2) or @SalComenzi=1 or @NCTichComenzi=1 then a.marca else '' end), 
		(case when @DeLaCalculLichidare=1 then '' when a.Tip_operatie='S' then 'S' else 'C' end) 
	order by ordonare_lm, ordonare

	/*	Repartizare numar/valoare tichete pe comenzi. */
	if (@DeLaCalculLichidare=0 or @DeLaCalculLichidare=2) and @NCTichComenzi=1
	Begin
		select r.marca, r.loc_de_munca, r.comanda, sum(r.cantitate*r.tarif_unitar) as realizat
		into #tmprealcom
		from #realcom_tichete r
		where r.data between @dataJos and @dataSus 	and r.cantitate<>0 
		group by r.loc_de_munca, r.marca, r.comanda
		order by r.loc_de_munca, r.marca, r.comanda
		
		select t.data, t.marca, t.tip_tichete, t.loc_de_munca, isnull(r.comanda,'') as comanda, t.ordonare, 
			round(t.numar_tichete*isnull(r.realizat/t.realizat,1),(case when @TipDocument='2' then 3 else 2 end)) as numar_tichete_com,
			round(t.valoare_tichete*isnull(r.realizat/t.realizat,1),(case when @TipDocument='2' then 3 else 2 end)) as valoare_tichete_com
		into #reptichete
		from #tmptichete t
		left outer join #tmprealcom r on r.marca=t.marca and (@ParcurgTichete=1 or @ParcurgTichete=0 and r.loc_de_munca=t.loc_de_munca)

		alter table #reptichete add idpozitie int identity

		select data, marca, tip_tichete, ordonare, sum(numar_tichete_com) as numar_tichete_rep, sum(valoare_tichete_com) as valoare_tichete_rep, max(idpozitie) as idpozitie
		into #totalrep
		from #reptichete
		group by data, marca, tip_tichete, ordonare

		/*	Reglare diferente care rezulta din spargere / rotunjiri. */
		update r set r.numar_tichete_com=r.numar_tichete_com+(t.numar_tichete-tr.numar_tichete_rep), 
					r.valoare_tichete_com=r.valoare_tichete_com+(t.valoare_tichete-tr.valoare_tichete_rep)
		from #reptichete r 
			inner join #tmptichete t on t.marca=r.marca and r.tip_tichete=r.Tip_tichete
			inner join #totalrep tr on tr.marca=r.marca and tr.tip_tichete=r.Tip_tichete and tr.idpozitie=r.idpozitie
				
		insert #ptichete
		select data, marca, loc_de_munca, comanda, tip_tichete, numar_tichete_com, valoare_tichete_com, ordonare
		from #reptichete
	End
	else
		insert #ptichete
		select data, marca, loc_de_munca, comanda, tip_tichete, numar_tichete, valoare_tichete, ordonare
		from #tmptichete

	if exists (select 1 from sysobjects where name='pTicheteSP2' and xtype='P')
		exec pTicheteSP2 @dataJos=@dataJos, @dataSus=@dataSus, @marca=@marca, @DeLaCalculLichidare=@DeLaCalculLichidare, @parXML=@parXML

	if @existaTabela=0
		select data, marca, loc_de_munca, comanda, tip_tichete, numar_tichete, valoare_tichete, ordonare
		from #ptichete

end try

begin catch
	set @mesaj = ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror (@mesaj, 11, 1)
end catch
