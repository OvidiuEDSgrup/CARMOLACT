--***
/**	procedura calcul ded. pers	*/
create procedure calcul_deducere
	@venitBrut float, @nrPersIntr int, @dedPers decimal(12,3) output, 
	@oreJustificate int=0, @oreLuna float=0, @grupaMunca char(1)='N', @regimLucru float=8, 
	@venitBrutCuDed float=null, @venitBrutFaraDed float=null, @DeducereLaOreLucrate int=null, @data datetime=null
as
begin
	if nullif(@venitBrutCuDed,0) is null
		select 
			@venitBrutCuDed=max(case when Parametru='VBCUDEDP' then Val_numerica else 0 end),
			@venitBrutFaraDed=max(case when Parametru='VBFDEDP' then Val_numerica else 0 end)
		from (select parametru, val_numerica, RANK() over (partition by parametru order by data Desc) as ordine
			from par_lunari where tip='PS' and parametru in ('VBCUDEDP','VBFDEDP') and data<=@data) p
		where Ordine=1

	/*	Pana asezam solutia cu par_lunari pentru parametru @venitBrutCuDed mai citim si din par, daca nu s-a populat par_lunari. */
	if nullif(@venitBrutCuDed,0) is null
		select 
			@venitBrutCuDed=max(case when Parametru='VBCUDEDP' then Val_numerica else 0 end),
			@venitBrutFaraDed=max(case when Parametru='VBFDEDP' then Val_numerica else 0 end)
		from par 
		where tip_parametru='PS' and parametru in ('VBCUDEDP','VBFDEDP')

	if @DeducereLaOreLucrate is null
		select 
			@DeducereLaOreLucrate=max(case when Parametru='CHINDPON' then Val_logica else 0 end)
		from par where tip_parametru='PS' and parametru in ('CHINDPON')

--	citire deducere personala conform Grilei de deduceri (functie de persoanele in intretinere)
	set @dedPers = (select top 1 suma_fixa from impozit where tip_impozit='D' and limita <= @nrPersIntr and data<=@data order by data desc, limita desc)

--	calcul deducere personala conform formulei de calcul prevazuta in lege (Ordinul nr. 19/07.1.2005)
	if @venitBrut > @venitBrutCuDed and @venitBrut < @venitBrutFaraDed
		Set @dedPers=@dedPers * (1 - (@venitBrut - @venitBrutCuDed)/(@venitBrutFaraDed-@venitBrutCuDed))

--	rotunjire deducere personala conform OMF 1016/2005
	if @venitBrut > @venitBrutCuDed and @venitBrut < @venitBrutFaraDed and @dedPers>0 and cast(ceiling(@dedPers) as int) % 10<>0
		Set @dedPers=(round(@dedPers/10,0,1)+1)*10

--	recalculez deducerea personala functie de orele lucrate (in baza setarii)
--	si apoi o rotunjesc din nou la 10 lei (nu stiu daca o fi corect asa, dar daca prin lege deducerea se rotunjeste in favoarea salariatului, atunci sa fie 2 rotunjiri)
	if @DeducereLaOreLucrate=1 and @oreJustificate<@oreLuna and @oreJustificate<>0
	begin
		set @dedPers=@dedPers*@oreJustificate/(@Oreluna*(case when @grupaMunca='C' then @regimLucru/8 else 1 end))
		select @dedPers=(round(@dedPers/10,0,1)+1)*10
			where (@venitBrut < @venitBrutCuDed or @venitBrut > @venitBrutCuDed and @venitBrut < @venitBrutFaraDed) and @dedPers>0 and cast(ceiling(@dedPers) as int) % 10<>0
		set @dedPers=ceiling(@dedPers)
	end	

	Set @dedPers=ceiling(@dedPers)
	if @venitBrut >= @venitBrutFaraDed
		Set @dedPers=0
end
