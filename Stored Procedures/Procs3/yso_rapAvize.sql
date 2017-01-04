--***
CREATE procedure [dbo].[yso_rapAvize](@datajos datetime,@datasus datetime, @tert varchar(50)=null, @cod varchar(50)=null,
					@gestiune varchar(50)=null, @lm varchar(50)=null, @factura varchar(50)=null, @comanda varchar(50)=null,@zona varchar(50)=null,
				@Nivel1 varchar(2), @Nivel2 varchar(2), @Nivel3 varchar(2), @Nivel4 varchar(2), @Nivel5 varchar(2), @ordonare int, @categoriepret varchar(20))
as
-- test          
--declare @datajos datetime,@datasus datetime,@tert nvarchar(4000),@cod nvarchar(4000),@gestiune nvarchar(4000),@lm nvarchar(4000),@factura nvarchar(4000),@comanda nvarchar(4000)
--		,@Nivel1 varchar(2) ,@Nivel2 varchar(2) ,@Nivel3 varchar(2) ,@Nivel4 varchar(2), @Nivel5 varchar(2), @alfabetic int, @ordonare int
--select @datajos='2012-02-14',@datasus='2012-02-14',@tert=null,@cod='TIH',@gestiune='04',@lm=NULL,@factura=NULL,@comanda=NULL
--		,@Nivel1='TE', @Nivel2='CO'--, @Nivel3=null, @Nivel4=null, @Nivel5=null
--		,@ordonare=2	

	/**	Pregatire filtrare pe proprietati utilizatori*/
declare @eLmUtiliz int,@eGestUtiliz int
declare @LmUtiliz table(valoare varchar(200), cod_proprietate varchar(20))
declare @GestUtiliz table(valoare varchar(200), cod_proprietate varchar(20))
insert into @LmUtiliz(valoare, cod_proprietate)
select valoare, cod_proprietate from fPropUtiliz(null) where valoare<>'' and cod_proprietate='LOCMUNCA'
set @eLmUtiliz=isnull((select max(1) from @LmUtiliz),0)
insert into @GestUtiliz(valoare, cod_proprietate)
select valoare, cod_proprietate from fPropUtiliz(null) where valoare<>'' and cod_proprietate='GESTIUNE'
set @eGestUtiliz=isnull((select max(1) from @GestUtiliz),0)

if object_id('tempdb.dbo.#filtrate') is not null drop table #filtrate
if object_id('tempdb.dbo.#f') is not null drop table #f
if object_id('tempdb.dbo.#1') is not null drop table #1
if object_id('tempdb.dbo.#date_brute') is not null	drop table #date_brute

select p.data,isnull(rtrim(p.tip),'') as tip ,isnull(rtrim(p.tert),'') as tert, isnull(rtrim(p.cod),'') as cod, isnull(rtrim(p.gestiune),'') as gestiune,
		isnull(rtrim(p.numar),'') as numar, isnull(p.numar_pozitie,0) as numar_pozitie, isnull(p.cantitate,0) as cantitate,
		isnull(p.cantitate*p.pret_vanzare,0) as pfTVA,
		isnull(p.cantitate*p.pret_vanzare+p.tva_deductibil,0) as pcuTVA,
		isnull(p.cantitate*p.pret_de_stoc,0) as valCost, 
		(case when p.adaos=0 then 0 else isnull(p.cantitate*(p.pret_vanzare-p.pret_de_stoc),0)  end)as adaos,
		rtrim(p.loc_De_munca) as loc_de_munca,rtrim(p.Numar_DVI) as Numar_DVI
	into #filtrate from pozdoc p
	where (p.data between @datajos and @datasus) and (p.gestiune=@gestiune or @gestiune is null) and (p.Loc_de_munca=@lm or @lm is null) 
			and (p.factura = @factura or @factura is null) and (p.comanda = @comanda or @comanda is null)
			and p.tip in ('AP'/*,'AC','AS'*/)
			and (@eLmUtiliz=0 or exists (select 1 from @LmUtiliz u where u.valoare=p.Loc_de_munca))
			and (@eGestUtiliz=0 or p.tip in ('RS','AS') or exists (select 1 from @GestUtiliz u where u.valoare=p.Gestiune))

CREATE UNIQUE NONCLUSTERED INDEX unic ON #filtrate (data,tip,tert,cod,gestiune,numar,loc_de_munca,numar_pozitie)

select isnull(month(p.data),0) as luna, isnull(p.data,'1/1/1901') as data, 
	(select rtrim(MAX(c.LunaAlfa)) from CalStd c where c.Luna=month(p.data))+' '+convert(varchar(4),
	YEAR(p.data)) as denluna, p.tip, p.tert, p.cod, isnull(rtrim(n.denumire)+','+rtrim(n.um),'') as denumire, isnull(rtrim(n.um),'') as um, 
	isnull(rtrim(g.denumire),'') as grupa, isnull(lm.cod ,'') as loc,
	isnull(rtrim(lm.denumire),'') as locm, isnull(rtrim(t.denumire),'') as client, 
	isnull(rtrim(ge.denumire_gestiune),'') as DenGes, p.gestiune, p.numar,p.numar_pozitie,p.cantitate,
	p.pfTVA, p.pcuTVA, p.valCost, p.adaos, p.cantitate*n.greutate_specifica as greutate,n.greutate_specifica,
	substring(numar_dvi,14,5) as punct_livrare, isnull(rtrim(i.descriere),'') as descrPctLivr
/*,isnull(p.factura,'') as factura, isnull(p.comanda,'') as comanda*/
into #date_brute
from #filtrate p
	left outer join nomencl n on p.cod=n.cod
	left outer join grupe g on n.grupa=g.grupa
	left outer join terti t on p.tert=t.tert
	left outer join infotert i on i.subunitate=t.subunitate and i.tert=t.tert and i.identificator=substring(numar_dvi,14,5)
	left outer join gestiuni ge on p.gestiune=ge.cod_gestiune
	left outer join lm on p.loc_De_munca=lm.cod
--	left outer join nomencl on n.cod=isnull(@cod,'')
--	left outer join terti on t.tert=isnull(@tert,'')
where (@tert is null or p.tert=@tert) /*or (terti.tert is null and t.denumire like '%'+replace(isnull(@tert,' '),' ','%')+'%')*/ 
	and (@cod is null or p.cod=@cod) /*or (nomencl.cod is null and n.denumire like '%'+replace(isnull(@cod,' '),' ','%')+'%')*/
	and (@categoriepret is null or t.Sold_ca_beneficiar=@categoriepret)
	and (@zona is null or exists (select 1 from judzone jz where jz.zona=@zona and jz.judet=(case when isnull(i.telefon_fax2,'')='' then isnull(t.judet,'') else i.telefon_fax2 end)))
--order by luna--,tert,denumire

CREATE UNIQUE NONCLUSTERED INDEX unic ON #date_brute (data,tip,tert,punct_livrare,cod,gestiune,numar,numar_pozitie)

select	-- construiesc recursiv gruparile pentru a nu mai avea probleme pe Rep 2008
	'Total' as niv0,
	(case @Nivel1 when 'TE' then tert when 'PL' then punct_livrare when 'CO' then cod when 'GE' then gestiune when 'LU'
		then convert(varchar(2),luna) when 'LO' then loc when 'DA' then convert(varchar(10),data,102) end) as niv1,
	(case @Nivel2 when 'TE' then tert when 'PL' then punct_livrare when 'CO' then cod when 'GE' then gestiune when 'LU'
		then convert(varchar(2),luna) when 'LO' then loc when 'DA' then convert(varchar(10),data,102) end) as niv2,
	(case @Nivel3 when 'TE' then tert when 'PL' then punct_livrare when 'CO' then cod when 'GE' then gestiune when 'LU'
		then convert(varchar(2),luna) when 'LO' then loc when 'DA' then convert(varchar(10),data,102) end) as niv3,
	(case @Nivel4 when 'TE' then tert when 'PL' then punct_livrare when 'CO' then cod when 'GE' then gestiune when 'LU'
		then convert(varchar(2),luna) when 'LO' then loc when 'DA' then convert(varchar(10),data,102) end) as niv4,
	(case @Nivel5 when 'TE' then tert when 'PL' then punct_livrare when 'CO' then cod when 'GE' then gestiune when 'LU'
		then convert(varchar(2),luna) when 'LO' then loc when 'DA' then convert(varchar(10),data,102) end) as niv5,
	tip+' '+rtrim(numar)+' '+convert(varchar(10),data,103) as niv6,	
	cantitate, greutate, greutate_specifica, pfTVA, pcuTVA, valCost, adaos,
	'Total' as nume0,
	(case @Nivel1 when 'TE' then client when 'PL' then descrPctLivr when 'CO' then denumire when 'GE' then denges when 'LU' then denluna
		when 'LO' then locm when 'DA' then convert(varchar(10),data,103) end) as nume1,
	(case @Nivel2 when 'TE' then client when 'PL' then descrPctLivr when 'CO' then denumire when 'GE' then denges when 'LU' then denluna
		when 'LO' then locm when 'DA' then convert(varchar(10),data,103) end) as nume2,
	(case @Nivel3 when 'TE' then client when 'PL' then descrPctLivr when 'CO' then denumire when 'GE' then denges when 'LU' then denluna
		when 'LO' then locm when 'DA' then convert(varchar(10),data,103) end) as nume3,
	(case @Nivel4 when 'TE' then client when 'PL' then descrPctLivr when 'CO' then denumire when 'GE' then denges when 'LU' then denluna
		when 'LO' then locm when 'DA' then convert(varchar(10),data,103) end) as nume4,
	(case @Nivel5 when 'TE' then client when 'PL' then descrPctLivr when 'CO' then denumire when 'GE' then denges when 'LU' then denluna
		when 'LO' then locm when 'DA' then convert(varchar(10),data,103) end) as nume5
	into #1
from #date_brute

select 'Total' as tip_nivel, niv0 as cod,'' as parinte,sum(cantitate) as cantitate, sum(greutate) as greutate, 
		sum(pfTVA) as pfTVA, sum(pcuTVA) as pcuTVA, SUM(valCost) as valCost, SUM(adaos) as adaos, 0 as nivel, 
		max(nume0) as nume, max(greutate_specifica) as greutate_specifica, space(100) as ordine into #f 
			from #1 where niv0 is not null group by niv0 union all
select @Nivel1 as tip_nivel, niv1 as cod,niv0+'|' as parinte,sum(cantitate) as cantitate, sum(greutate) as greutate, 
		sum(pfTVA) as pfTVA, sum(pcuTVA) as pcuTVA, SUM(valCost) as valCost, SUM(adaos) as adaos,1 as nivel, 
		max(nume1) as nume, max(greutate_specifica) as greutate_specifica, '' as ordine
-- into #f
			from #1 where niv1 is not null group by niv1,niv0 union all
select @Nivel2 as tip_nivel, niv2, niv1+'|'+niv0+'|' as parinte,sum(cantitate) as cantitate, sum(greutate) as greutate, sum(pfTVA) as pfTVA, 
			sum(pcuTVA) as pcuTVA, SUM(valCost) as valCost, SUM(adaos) as adaos,2, max(nume2), max(greutate_specifica) as greutate_specifica, '' as ordine 
from #1 where niv2 is not null group by niv2,niv1,niv0 union all
select @Nivel3 as tip_nivel, niv3, niv2+'|'+niv1+'|'+niv0+'|' as parinte,sum(cantitate) as cantitate, sum(greutate) as greutate, sum(pfTVA) as pfTVA, 
		sum(pcuTVA) as pcuTVA, SUM(valCost) as valCost, SUM(adaos) as adaos,3,max(nume3), max(greutate_specifica) as greutate_specifica, '' as ordine 
from #1 where niv3 is not null group by niv3,niv2,niv1,niv0 union all
select @Nivel4 as tip_nivel, niv4, niv3+'|'+niv2+'|'+niv1+'|'+niv0+'|' as parinte,sum(cantitate) as cantitate, sum(greutate) as greutate, sum(pfTVA) as pfTVA, 
		sum(pcuTVA) as pcuTVA, SUM(valCost) as valCost, SUM(adaos) as adaos,4,MAX(nume4), max(greutate_specifica) as greutate_specifica, '' as ordine 
from #1 where niv4 is not null group by niv4,niv3,niv2,niv1,niv0 union all
select @Nivel5 as tip_nivel, niv5, niv4+'|'+niv3+'|'+niv2+'|'+niv1+'|'+niv0+'|' as parinte,sum(cantitate) as cantitate, sum(greutate) as greutate, sum(pfTVA) as pfTVA, 
		sum(pcuTVA) as pcuTVA, SUM(valCost) as valCost, SUM(adaos) as adaos,5,MAX(nume5), max(greutate_specifica) as greutate_specifica, '' as ordine 
from #1 where niv5 is not null group by niv5,niv4,niv3,niv2,niv1,niv0 union all
select '' as tip_nivel, niv6, isnull(niv5+'|','')+isnull(niv4+'|','')+isnull(niv3+'|','')+isnull(niv2+'|','')+niv1+'|'+niv0+'|' as parinte, 
			cantitate, greutate, pfTVA, pcuTVA, valCost, adaos,6,niv6, greutate_specifica, '' as ordine from #1
--order by (case when @alfabetic=1 then cod else nume end)

update #f set ordine=(case when tip_nivel='DA' or @ordonare=1 then cod else nume end)

select cod, parinte, cantitate, greutate, pfTVA, pcuTVA, valCost, adaos, nivel, nume, greutate_specifica, tip_nivel, ordine
 from #f 
	--where cod like 'AP 0318109%'
	--or cod like 'AP 16014817%'
	--or cod+'|'+parinte like 'LE35|UN   |11191348|2016.05.12|Total|'
	--or cod+'|'+parinte like 'IE4|UN   |11191348|2016.05.12|Total|'
	--or cod+'|'+parinte like '11191348|2016.05.12|Total|'
	order by ordine

if object_id('tempdb.dbo.#filtrate') is not null drop table #filtrate
if object_id('tempdb.dbo.#f') is not null drop table #f
if object_id('tempdb.dbo.#1') is not null drop table #1
if object_id('tempdb.dbo.#date_brute') is not null	drop table #date_brute
--
--select * from #filtrate
--select * from #date_brute
