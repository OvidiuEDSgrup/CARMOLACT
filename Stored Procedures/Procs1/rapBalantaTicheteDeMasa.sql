/**	procedura pentru raportul de Balanta tichete de masa. */
Create procedure rapBalantaTicheteDeMasa
	(@dataJos datetime, @dataSus datetime, 
	@marca char(6)=null, @locm char(9)=null, @strict int=0, @mandatar char(6)=null, @tipstat varchar(30)=null, 
	@listaDrept char(1)='T', @ordonare char(1), @alfabetic bit)
as
/*
	Exemplu de apel:
	declare @dataJos datetime, @dataSus datetime, @marca char(6)=null, @locm char(9)=null, @strict int=0, @mandatar char(6)=null, 
			@tipstat varchar(30)=null, @listaDrept char(1)='T', @ordonare char(1), @alfabetic bit
	select @dataJos='01/01/2015', @dataSus='01/31/2015', @marca=null, @locm=null, @strict=0, @mandatar=null, 
			@tipstat=null, @listaDrept='T', @ordonare='1' , @alfabetic=1

	exec rapBalantaTicheteDeMasa @dataJos=@dataJos, @dataSus=@dataSus, @marca=@marca, @locm=@locm, @strict=@strict, @mandatar=@mandatar, 
		@tipstat=@tipstat, @listaDrept=@listaDrept, @ordonare=@ordonare, @alfabetic=@alfabetic
*/
begin try

	set transaction isolation level read uncommitted
	declare @utilizator varchar(20), @dreptConducere int, @areDreptCond int, @lista_drept char(1)

	set @utilizator=dbo.fIaUtilizator(null)

	set @dreptConducere=dbo.iauParL('PS','DREPTCOND')

--	verific daca utilizatorul are/nu are dreptul de Salarii conducere (SALCOND)
	set @lista_drept=@listaDrept
	set @areDreptCond=0
	if  @dreptConducere=1 
	begin
		set @areDreptCond=isnull((select dbo.verificDreptUtilizator(@utilizator,'SALCOND')),0)
		if @areDreptCond=0
			set @lista_drept='S'
	end

	if object_id('tempdb..#baltichete') is not null
		drop table #baltichete

	select a.Data_lunii as data, a.Marca, 
		max(isnull(i.Nume,p.Nume)) as nume, max(p.Cod_numeric_personal) as cnp, 
		max(isnull(i.Loc_de_munca,p.Loc_de_munca)) as Loc_de_munca, max(lm.Denumire) as Denumire_lm,
		convert(decimal(12),sum(case when tip_operatie='C' then Nr_tichete else 0 end)) as nr_tichete_cuvenite, 
		convert(decimal(12),sum(case when tip_operatie='S' then Nr_tichete else 0 end)) as nr_tichete_suplim, 
		convert(decimal(12),sum(case when tip_operatie='P' then Nr_tichete else 0 end)) as nr_tichete_din_stoc, 
		convert(decimal(12),sum(case when tip_operatie='R' then Nr_tichete else 0 end)) as nr_tichete_retinute, 
		convert(decimal(12),sum(case when tip_operatie in ('P','C','S') then Nr_tichete else -Nr_tichete end)) as nr_tichete_primite,
		sum((case when tip_operatie in ('P','C','S') then Nr_tichete else -Nr_tichete end)*a.Valoare_tichet) as val_tichete_primite
	into #baltichete
	from tichete a
		left outer join personal p on a.Marca=p.Marca
		left outer join istpers i on a.Data_lunii=i.Data and a.Marca=i.Marca
		left outer join infopers b on a.Marca=b.Marca
		left outer join lm on lm.Cod=isnull(i.Loc_de_munca,p.Loc_de_munca)
		left outer join mandatar m on m.loc_munca=isnull(i.Loc_de_munca,p.Loc_de_munca)
		left outer join personal p1 on m.Mandatar=p1.Marca
		left outer join functii f on isnull(i.Cod_functie,p.Cod_functie)=f.Cod_functie
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=isnull(i.Loc_de_munca,p.Loc_de_munca)
	where (@marca is null or a.marca=@marca) and a.data_lunii between @dataJos and @dataSus 
		and (dbo.f_areLMFiltru(@utilizator)=0 or lu.cod is not null)
		and (@locm is null or isnull(i.Loc_de_munca,p.Loc_de_munca) like rtrim(@locm)+(case when @strict=1 then '' else '%' end)) 
		and (@mandatar is null or m.mandatar=@mandatar) and (@tipstat is null or b.religia=@tipstat)
		and (@dreptConducere=0 or (@aredreptcond=1 and (@lista_drept='T' or @lista_drept='C' and p.pensie_suplimentara=1 
			or @lista_drept='S' and p.pensie_suplimentara<>1)) or (@aredreptcond=0 and p.pensie_suplimentara<>1))
	group by a.Data_lunii, a.marca

	if exists (select 1 from sysobjects where name='rapBalantaTicheteDeMasaSP' and xtype='P')
		exec rapBalantaTicheteDeMasaSP @dataJos=@dataJos, @dataSus=@dataSus, @marca=@marca, @locm=@locm, @strict=@strict, @mandatar=@mandatar, @tipstat=@tipstat, 
				@listaDrept=@listaDrept, @ordonare=@ordonare, @alfabetic=@alfabetic

	select data, marca, nume, cnp, loc_de_munca, denumire_lm,
		nr_tichete_cuvenite as nr_tichete_pontaj, nr_tichete_cuvenite, nr_tichete_suplim, nr_tichete_din_stoc, nr_tichete_retinute, nr_tichete_primite, val_tichete_primite
	from #baltichete
	where nr_tichete_cuvenite<>0 or nr_tichete_suplim<>0 or nr_tichete_din_stoc<>0 or nr_tichete_retinute<>0
	order by (case when @ordonare='1' then loc_de_munca else '' end), (case when @alfabetic=1 then nume else marca end)

end try 
begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura rapBalantaTicheteDeMasa (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
