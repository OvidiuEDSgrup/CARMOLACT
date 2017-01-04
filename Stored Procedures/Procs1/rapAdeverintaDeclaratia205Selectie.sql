/**
	Procedura este folosita pentru a lista Adeverinte privind date din declaratia 205. 
**/
create procedure rapAdeverintaDeclaratia205Selectie 
	(@sesiune varchar(50), @datalunii datetime, @marca varchar(6)=null, @cnp varchar(13)=null, @locm varchar(20)=null, 
	@angajatiPrinDetasare int, @unitateprecedenta varchar(20)=null, @alfabetic int=0, @parXML xml='<row/>')
AS
/*
	exec rapAdeverintaDeclaratia205Selectie '', '12/31/2015', null, null, null, null, '<row />'
*/
begin try 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	DECLARE @tip varchar(2), @mesaj varchar(1000), @utilizator varchar(50), @lista_lm int
	
	if @sesiune<>''
		exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output
	else 
		set @utilizator=dbo.fIaUtilizator(null)

	set @lista_lm=dbo.f_areLMFiltru(@utilizator)

	if OBJECT_ID('tempdb..#selectieD205') is not null 
		drop table #selectieD205

	select distinct (case when @marca is not null then n.marca else null end) as marca, (case when @marca is null then p.Cod_numeric_personal else null end) as cnp, p.nume as nume
	into #selectieD205
	from net n
		left outer join istpers i on i.Data=n.Data and i.Marca=n.Marca
		left outer join personal p on p.Marca=n.Marca
		left outer join infopers ip on ip.Marca=n.Marca
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=i.Loc_de_munca
	where year(n.data)=year(@datalunii) and n.Data=dbo.EOM(n.Data)
		and (@locm is null or i.Loc_de_munca like rtrim(@locm)+'%')
		and (isnull(@angajatiprindetasare,0)=0 and isnull(i.Mod_angajare,'')<>'R' or isnull(@angajatiprindetasare,0)=1 and i.Mod_angajare='R')
		and (@marca is null or n.Marca=@marca) 
		and (@cnp is null or p.cod_numeric_personal=@cnp)
		and (@unitateprecedenta is null or ip.Loc_munca_precedent=@unitateprecedenta)
		and (@lista_lm=0 or lu.cod is not null)
	union all 
	select distinct (case when @marca is not null then s.marca else null end) as marca, (case when @marca is null then z.Cod_numeric_personal else null end) as cnp, z.nume as nume 
	from SalariiZilieri s
		left outer join zilieri z on z.Marca=s.Marca
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=s.Loc_de_munca
	where year(s.data)=year(@datalunii) 
		and (@locm is null or z.Loc_de_munca like rtrim(@locm)+'%')
		and (@marca is null or s.Marca=@marca) 
		and (@cnp is null or z.cod_numeric_personal=@cnp)
		and (@lista_lm=0 or lu.cod is not null)
	union all 
	select distinct (case when @marca is not null then d.marca else null end) as marca, (case when @marca is null then isnull(p.Cod_numeric_personal,d.cnp) else null end) as cnp,
		isnull(nullif(d.Nume,''),p.nume)
	from DateD205 d
		left outer join personal p on p.Marca=d.Marca
		left outer join LMFiltrare lu on lu.utilizator=@utilizator and lu.cod=d.Loc_de_munca
	where An=year(@datalunii) and d.marca not in (select distinct marca from net where year(net.data)=year(@datalunii))
		and (@cnp is null or isnull(p.cod_numeric_personal,d.cnp)=@cnp)
		and (@locm is null or p.Loc_de_munca like rtrim(@locm)+'%')
		and (isnull(@angajatiprindetasare,0)=0 and isnull(p.Mod_angajare,'')<>'R' or isnull(@angajatiprindetasare,0)=1 and p.Mod_angajare='R')
		and (@marca is null or d.Marca=@marca)
		and (@lista_lm=0 or lu.cod is not null)

	select marca, cnp, nume
	from #selectieD205
	order by (case when @alfabetic=1 then nume else isnull(marca,cnp) end)

end try
begin catch
	set @mesaj=ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror(@mesaj, 11, 1)
end catch