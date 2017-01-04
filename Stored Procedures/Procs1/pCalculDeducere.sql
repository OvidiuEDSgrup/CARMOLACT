--***
/**	procedura de calcul deducere personala care altereaza tabela #deduceri.	*/
create procedure pCalculDeducere
	@datajos datetime, @datasus datetime
as
begin try
	declare @OreLuna float, @venitBrutCuDed float, @venitBrutFaraDed float, @DeducereLaOreLucrate int

	/*	Citire parametrii. */
	select 
		@DeducereLaOreLucrate=max(case when Parametru='CHINDPON' then Val_logica else 0 end)
	from par where tip_parametru='PS' and parametru in ('CHINDPON')

	select 
		@venitBrutCuDed=max(case when Parametru='VBCUDEDP' then Val_numerica else 0 end),
		@venitBrutFaraDed=max(case when Parametru='VBFDEDP' then Val_numerica else 0 end)
	from (select parametru, val_numerica, RANK() over (partition by parametru order by data Desc) as ordine
		from par_lunari where tip='PS' and parametru in ('VBCUDEDP','VBFDEDP') and data<=@datasus) p
	where Ordine=1

	select @OreLuna=max(case when Parametru='ORE_LUNA' then Val_numerica else 0 end)
	from par_lunari
	where Data=@dataSus and tip='PS' and Parametru in ('ORE_LUNA')

	if object_id('tempdb..#persIntr') is not null
		drop table #persIntr

	select p.Marca, count(1) as nrpersintr
	into #persIntr
	from persintr p
	inner join #deduceri d on d.marca=p.marca  
	where p.data between @dataJos and @dataSus and p.coef_ded<>0
	group by p.marca

--	citire deducere personala conform Grilei de deduceri (functie de persoanele in intretinere)
	update d set d.deducere_pers=(select top 1 i.suma_fixa from impozit i where i.tip_impozit='D' and i.limita <= isnull(p.nrpersintr,0) and i.data<=@datasus order by i.data desc, i.limita desc)
	from #deduceri d
	left join #persIntr p on p.marca=d.marca  
	--inner join impozit i on i.tip_impozit='D' and i.limita=isnull(p.nrpersintr,0)

--	calcul deducere personala conform formulei de calcul prevazuta in lege (Ordinul nr. 19/07.1.2005)
	update #deduceri set deducere_pers=deducere_pers * (1 - (venitBrut - @venitBrutCuDed)/(@venitBrutFaraDed-@venitBrutCuDed))
	where venitBrut > @venitBrutCuDed and venitBrut < @venitBrutFaraDed

--	rotunjire deducere personala conform OMF 1016/2005
	update #deduceri set deducere_Pers=(round(deducere_Pers/10,0,1)+1)*10
	where venitBrut > @venitBrutCuDed and venitBrut < @venitBrutFaraDed and deducere_Pers>0 and cast(ceiling(deducere_Pers) as int) % 10<>0

--	recalculez deducerea personala functie de orele lucrate (in baza setarii)
--	si apoi o rotunjesc din nou la 10 lei (nu stiu daca o fi corect asa, dar daca prin lege deducerea se rotunjeste in favoarea salariatului, atunci sa fie 2 rotunjiri)
	update #deduceri set calculLaOrePontaj=(case when @DeducereLaOreLucrate=1 and oreJustificate<@oreLuna and oreJustificate<>0 then 1 else 0 end)

	update #deduceri 
		set deducere_pers=deducere_pers*oreJustificate/(@Oreluna*(case when grupaMunca='C' then regimLucru/8 else 1 end))
	where calculLaOrePontaj=1

	update #deduceri 
		set deducere_pers=(round(deducere_pers/10,0,1)+1)*10
	where calculLaOrePontaj=1 and venitBrut > @venitBrutCuDed and venitBrut < @venitBrutFaraDed and deducere_pers>0 and cast(ceiling(deducere_pers) as int) % 10<>0

--	rotunjire deducere personala.
	update #deduceri set deducere_pers=ceiling(deducere_pers)

--	anulare deducere personala pentru venit brut > venitul brut maxim fara deducere personala.
	update #deduceri set deducere_pers=0
	where venitBrut >= @venitBrutFaraDed

	if exists (select * from sysobjects where name ='pCalculDeducereSP2')
		exec pCalculDeducereSP2 @datajos=@datajos, @datasus=@datasus
end try

begin catch
	declare @mesaj varchar(1000)
	set @mesaj = ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror (@mesaj, 11, 1)
end catch