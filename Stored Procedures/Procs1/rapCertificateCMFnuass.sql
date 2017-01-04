--***
/*	procedura pentru centralizator certificate CM */
Create procedure rapCertificateCMFnuass 
	(@datajos datetime, @datasus datetime, @alfabetic int, @ordonare int=0) 
as
/*
	@ordonare -> 0 Salariati, 1 Locuri de munca, salariati
*/
begin
	declare @utilizator varchar(20), @multiFirma int, @lmUtilizator varchar(9), @lmFiltru varchar(9), @nrLMFiltru int, @perioada varchar(1000)
	
	Set @utilizator = dbo.fIaUtilizator('')
	select @multiFirma=0
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1

--	in cazul BD multifirma stabilesc locul de munca pe care lucreaza utilizatorul
	select @lmFiltru=isnull(min(Cod),''), @nrLMFiltru=count(1) from LMfiltrare where utilizator=@utilizator and cod in (select cod from lm where Nivel=1)
	if @multiFirma=1 or @nrLMFiltru=1
		select @lmUtilizator=@lmFiltru
	select @lmUtilizator=nullif(@lmUtilizator,'')

	set @perioada=''
	select @perioada=@perioada+rtrim(LunaAlfa)+' '+(case when year(@dataJos)<>year(@dataSus) then convert(varchar(4),year(data_lunii)) else '' end)+', '
	from fCalendar(@datajos, @dataSus) where data=Data_lunii
	select @perioada=left(@perioada,len(rtrim(@perioada))-1)
	if year(@datajos)=year(@datasus)
		set @perioada=rtrim(@perioada)+' '+convert(varchar(4),year(@dataSus))

	if object_id('tempdb..#istpers')is not null 
		drop table #istpers

	select p.cod_numeric_personal, max(i.Loc_de_munca) as loc_de_munca
	into #istpers
	from istpers i
		inner join personal p on p.marca=i.marca
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=i.Loc_de_munca
	where i.data=@datasus and (@multiFirma=0 or lu.cod is not null)
	group by p.cod_numeric_personal

	select ROW_NUMBER() over (order by d.data, (case when @alfabetic=1 then a.numeAsig else d.cnpAsig end)) as numar_curent, 
		d.data, rtrim(a.numeAsig)+' '+rtrim(a.prenAsig) as nume, d.cnpasig, isnull(d.D_8,'') as cnp_copil, d.D_1 as serie_cm, d.D_2 as numar_cm, 
		isnull(d.D_3,'') as serie_cm_initial, isnull(d.D_4,'') as numar_cm_initial, d.D_9 as cod_indemnizatie, 
		(case when @alfabetic=1 then a.numeAsig else d.cnpAsig end) as ordonare, 
		(case when dbo.EOM(@dataJos)=dbo.EOM(@dataSus) then 'lunii:' else 'lunilor:' end)+' '+rtrim(@perioada) as perioada
	from D112asiguratD d 
		left outer join D112asigurat a on a.Data=d.Data and a.cnpAsig=d.cnpAsig and (d.Loc_de_munca is null or a.Loc_de_munca=d.Loc_de_munca)
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=d.Loc_de_munca
		left outer join #istpers ip on ip.cod_numeric_personal=d.cnpasig
	where d.data between @datajos and @datasus 
		and (@multiFirma=0 and @lmUtilizator is null or lu.cod is not null)
	order by d.data, (case when @ordonare=1 then ip.loc_de_munca else '' end), ordonare
	return
end

/*
	exec rapCertificateCMFnuass '05/01/2012', '05/31/2012', 0
*/