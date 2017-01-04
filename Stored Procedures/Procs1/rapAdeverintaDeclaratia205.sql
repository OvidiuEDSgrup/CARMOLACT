/**
	Procedura este folosita pentru a lista Adeverinte privind date din declaratia 205. 
**/
create procedure rapAdeverintaDeclaratia205 
	(@sesiune varchar(50)='', @marca varchar(6)=null, @cnp varchar(13)=null, @datalunii datetime, @locm varchar(20)=null,
	@angajatiPrinDetasare int=null, @unitateprecedenta varchar(20)=null, @ticheteInVenitBrut int=0, @alfabetic int=0)
AS
/*
	exec rapAdeverintaDeclaratia205 @datalunii='07/24/2015', @marca='0564', @cnp='2670719252321'
*/
begin try 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	DECLARE @denunit VARCHAR(100), @adrunit VARCHAR(100), @codfisc VARCHAR(100), @ordreg VARCHAR(100), @caen VARCHAR(100), @judet VARCHAR(100), @localit varchar(100), @contbanca VARCHAR(100), 
		@banca varchar(100), @dirgen varchar(100), @direc varchar(100), @sefpers varchar(100), @telefon varchar(100), @email varchar(100), 
		@compartiment varchar(100), @functierepr varchar(100), @numerepr varchar(100), @numec varchar(100), @functc varchar(100), 
		@tip varchar(2), @mesaj varchar(1000), @utilizator varchar(50), @lista_lm int, @dataJos datetime, @dataSus datetime
	
	if @sesiune<>''
		exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output
	else 
		set @utilizator=dbo.fIaUtilizator(null)

	set @lista_lm=dbo.f_areLMFiltru(@utilizator)

	set @dataJos=dateadd("M",1-month(@datalunii),dateadd("D",1-day(@datalunii),@datalunii))
	set @dataSus=dateadd("M",12-month(@dataJos),dateadd("D",-1,dateadd("M",1,@dataJos)))

--  Date declaratie 205
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

--	Date impozit
	create table #date
		(data datetime, tip_venit char(2), denumire varchar(1000), nr_beneficiari int, tip_salar char(1), tip_impozit char(1), CNP char(13), nume char(200), tip_functie char(1), 
		venit_brut decimal(10), deduceri_personale decimal(10), deduceri_alte decimal(10), baza_impozit decimal(10), impozit decimal(10), venit_net decimal(10), detalii varchar(max), ordonare varchar(100))

	insert into #date
	exec rapDeclaratia205 @datajos=@datajos, @datasus=@datasus, @tipdecl=0, @tipVenit='010207', @ticheteInVenitBrut=@ticheteInVenitBrut, 
		@contImpozit=null, @contFactura=null, @contImpozitDividende=null, @lm=null, @strict=0, @grupare='', @alfabetic=0, @marca=@marca, 
		@angajatiPrinDetasare=@angajatiPrinDetasare, @cnp=@cnp, @sirDeMarci=null, @dinAdeverinta=1

--	Date salariat
	select p.nume, p.cod_numeric_personal, s.tip_act, convert(char(10),p.Data_nasterii,104) as data_nasterii, s.serie_bul, s.nr_bul, 
		s.elib, s.data_elib, convert(char(10),p.data_angajarii_in_unitate,104) as data_angajarii, p.Localitate, s.adresa, s.judet, 
		isnull((select count(distinct cod_personal) from persintr pe where pe.data between @datajos and @datasus and pe.Marca=p.Marca),0) as nr_persintr, 
		s.den_functie
	into #salariat
	from personal p 
		outer apply (select * from fDateSalariati (p.Marca,@dataSus)) s
	where (@marca is null or p.marca=@marca) or (@cnp is null or p.cod_numeric_personal=@cnp)
	union all 
	select z.nume, z.cod_numeric_personal, 
		(case when upper(left(z.buletin,2))='SX' or charindex('X',z.buletin)<>0 then 'CI' else 'BI' end) as tip_act, convert(char(10),z.Data_nasterii,104) as data_nasterii,
		left(z.buletin,2) as serie_bul, 
		ltrim(substring(z.buletin,3,8)) nr_bul, 
		isnull((select ', eliberat de '+rtrim(val_inf) from extinfop where cod_inf='ELIB' and extinfop.marca=z.marca),'') as elib,
		', la data de '+convert(char(10),z.Data_eliberarii,104) as data_elib,
		convert(char(10),z.data_angajarii,104) as data_angajarii,z.Localitate,
		(case when z.strada<>'' then ' str. ' else '' end)+rtrim(z.strada)+(case when z.numar<>'' then ' nr. ' else '' end)+rtrim(z.numar)
			+(case when z.bloc<>'' then ' bl. ' else '' end)+rtrim(z.bloc)+(case when z.scara<>'' then ' sc: ' else '' end)+rtrim(z.scara) as adresa,
		(case when z.judet<>'' then ' judetul ' else '' end)+rtrim(z.Judet)+(case when z.sector<>0 then ' sector '+rtrim(convert(char(10),z.Sector)) else '' end) as judet, 0 as nr_persintr, 
		rtrim(f.denumire)+' (COR: '+rtrim(cf.Val_inf)+')' as den_functie
	from zilieri z 
		left outer join functii f on z.Cod_functie=f.Cod_functie
		left outer join extinfop cf on cf.Marca=z.Cod_functie
	where (z.marca=@marca or z.cod_numeric_personal=@cnp)
		and not exists (select 1 from personal p where p.marca=@marca or p.cod_numeric_personal=@cnp)

	if @marca is not null
		update s
			set cnp=p.cod_numeric_personal
		from #selectieD205 s
		inner join personal p on s.marca=p.marca

--  select-ul de baza
	select s.*, rtrim(dbo.fDenumireLuna(d.data)) as luna, (case when d.tip_functie=1 then 'Functia de baza' else 'In afara fct. de baza' end) as tip_functie, 
		d.venit_brut, d.deduceri_personale, d.deduceri_alte, d.baza_impozit, d.impozit, d.venit_net
	from #salariat s
	inner join #date d on d.CNP=s.cod_numeric_personal
	inner join #selectieD205 d2 on s.Cod_numeric_personal=d2.cnp 
	order by (case when @alfabetic=1 then s.nume else isnull(d2.marca,s.cod_numeric_personal) end), d.data

end try
begin catch
	set @mesaj=ERROR_MESSAGE()+ ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror(@mesaj, 11, 1)
end catch