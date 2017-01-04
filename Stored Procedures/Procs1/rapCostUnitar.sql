--***
create procedure [dbo].[rapCostUnitar] @sesiune varchar(50), @datajos datetime, @datasus datetime, @grupare varchar(1),
	@lm char(9), @comanda char(13), @TipComanda varchar(1), @artcalc char(9), @produs varchar(50)
as

	declare 
		@subunitate varchar(20)

	select 
		@subunitate = val_alfanumerica from par where tip_parametru = 'GE' and parametru = 'SUBPRO'
	
	if @produs is null
		set @produs = ''

	select 
		left(cs.data_lunii,3) as data_lunii, convert(varchar(4), cs.an) as an, s.lm_sup as Loc_de_munca, c.tip_comanda as Tip_comanda, s.comanda_sup as Comanda, 
		max(c.descriere) as Denumire,sum(s.cantitate*s.valoare) as cheltuieli_totale, a.articol_de_calculatie as articol, max(a.denumire) as DenArt,
		max(a.ordinea_in_raport) as ordinea_in_raport, isnull(rtrim(pozcom.cod_produs)+'-'+grupe.denumire,'') as grupa,
		max(costuriSQL.cantitate) as cantitate, max(rtrim(n.Denumire)) as denProdus,
		(case when @grupare='L' then s.lm_sup else isnull(rtrim(pozcom.cod_produs)+'-'+grupe.denumire,'') end) as grupare,
		pozcom.Cod_produs
	from costsql s
	inner join calstd cs on cs.data=s.data
	left outer join comenzi c on s.comanda_sup=c.comanda
	left outer join pozcom on pozcom.subunitate='GR' and s.comanda_sup=pozcom.comanda
	left outer join nomencl n on n.cod = pozcom.Cod_produs
	left outer join grupe on pozcom.cod_produs=grupe.grupa
	inner join artcalc a on (case when s.art_inf='T' then s.art_sup else s.art_inf end )=a.articol_de_calculatie
	left outer join costurisql on costurisql.Data=cs.Data_lunii and costuriSQL.lm=s.LM_SUP and costuriSQL.comanda=s.COMANDA_SUP
	where s.lm_sup like rtrim(@lm)+'%' 
		and s.data between @datajos and @datasus 
		and c.tip_comanda in (select item from dbo.Split(@TipComanda, ','))
		and (nullif(@artcalc,'') is null or a.articol_de_calculatie=@artcalc) 
		and s.comanda_sup like rtrim(@comanda)+'%'
		and (@produs = '' or n.Denumire like '%' + @produs + '%' or pozcom.Cod_produs like '%' + @produs + '%')
		/*and (@pref_prod is null or exists (select 1 from pozcom pc 
			left join nomencl n on pc.cod_produs=n.cod
			where pc.subunitate=@subunitate and s.comanda_sup=pc.comanda and (@produs is null and 
				(n.denumire like '%'+@pref_prod+'%' or pc.cod_produs like '%'+@pref_prod+'%') 
				or pc.cod_produs=@produs))*/
	group by cs.data_lunii, cs.An, s.lm_sup, s.comanda_sup, c.tip_comanda,
		isnull(rtrim(pozcom.cod_produs)+'-'+grupe.denumire,''),a.articol_de_calculatie, pozcom.Cod_produs
	order by cs.data_lunii, cs.An, s.COMANDA_SUP,a.Articol_de_calculatie
/*
	exec rapCostUnitar '','2011-01-01','2014-03-19','L','1214A','','P',null,null
*/
