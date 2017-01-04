--***
create function yso_cautareCodIntrare (@Cod char(20), @Gestiune char(9), @TipGestiune char(1), @CodIntrarePred varchar(20), 
@PretStoc float, @PretAmanunt float, @ContStoc char(13), @AcCodIPrimitor int, 
@StocPozitiv int, @DataJosStocuri datetime, @DataSusStocuri datetime, 
@Locatie char(13), @LM char(9), @Comanda char(40), @Contract char(20), @Furnizor char(20), @Lot char(20)) 
returns char(13) as 
begin
	declare @CodIntrare char(13), @Sb char(9)
	
	select @codIntrarePred=rtrim(@CodIntrarePred),@StocPozitiv=isnull(@StocPozitiv, 0), @DataJosStocuri=isnull(@DataJosStocuri, '01/01/1901'), @DataSusStocuri=isnull(@DataSusStocuri, '01/01/1901'), 
		@Locatie=isnull(@Locatie, ''), @LM=isnull(@LM, ''), @Comanda=isnull(@Comanda, ''), 
		@Contract=isnull(@Contract, ''), @Furnizor=isnull(@Furnizor, ''), @Lot=isnull(@Lot, '')
	
	set @Sb=isnull((select max(val_alfanumerica) from par where tip_parametru='GE' and parametru='SUBPRO'), '')
	if isnull(@TipGestiune, '')=''
		set @TipGestiune=isnull((select max(tip_gestiune) from gestiuni where subunitate=@Sb and cod_gestiune=@Gestiune), '')
	
		
	--Verificam daca ii putem da pe un cod de intrare existent
	if @AcCodIPrimitor=1
	begin
/*sp	select top 1 @CodIntrare=s.Cod_intrare from stocuri s where subunitate=@Sb and tip_gestiune=@TipGestiune and cod_gestiune=@Gestiune and cod=@Cod 
		and s.pret=@PretStoc and s.pret_cu_amanuntul=@PretAmanunt and s.comanda=@comanda and s.Contract=@Contract -- Contul de stoc nu vine ... and s.cont=@ContStoc 
		if @CodIntrare is not null
			return @CodIntrare  "vezi sesizarea 235483" sp*/
	
		/* Dau cod intrare egal cod CodIntrearePredator daca am acelasi conditii de cont, pret de stoc, pret cu amanuntul, comanda*/
		if exists(select 1 from stocuri s where subunitate=@Sb and tip_gestiune=@TipGestiune and cod_gestiune=@Gestiune and cod=@Cod 
			and s.pret=@PretStoc and s.pret_cu_amanuntul=@PretAmanunt and s.Cod_intrare=@CodIntrarePred
/*sp		and s.comanda=@comanda and s.Contract=@Contract  sp*/) --nu vine bine cont de stoc
			return @CodIntrarePred
			
		/* Daca nu am caut codIntrarePred+litere*/
		select top 1 @CodIntrare=cod_intrare from stocuri where subunitate=@Sb and tip_gestiune=@TipGestiune and cod_gestiune=@Gestiune and cod=@Cod 
			and cod_intrare like rtrim(@CodIntrarePred)+'%' and len(cod_intrare)>len(@CodIntrarePred)
/*sp */		and pret=@PretStoc and pret_cu_amanuntul=@PretAmanunt 
		order by len(rtrim(cod_intrare)) desc,rtrim(cod_intrare) desc
		if @CodIntrare is not null
			return @CodIntrare /* "vezi sesizarea 232899" sp*/
	end

	/* Daca nu am caut codIntrarePred+litere*/
	select top 1 @CodIntrare=cod_intrare from stocuri where subunitate=@Sb and tip_gestiune=@TipGestiune and cod_gestiune=@Gestiune and cod=@Cod 
		and cod_intrare like rtrim(@CodIntrarePred)+ /*sp '%' */ '%[A-Z]' /* "vezi sesizarea 235486" sp*/ and len(cod_intrare)>len(@CodIntrarePred)
	order by len(rtrim(cod_intrare)) desc,rtrim(cod_intrare) desc

	if @CodIntrare is null
		set @CodIntrare=rtrim(@CodIntrarePred)+CHAR(64)
	/* Voi da cod intrare +A pana la ZZZZ*/
	declare @caracter char(1),@i int,@lungInit int
	set @lungInit=len(rtrim(@CodIntrare))
	set @i=@lungInit
	select @caracter=substring(@CodIntrare,@i,1)
	while @i>len(@CodIntrarePred) and @caracter='Z' -- ABZZ ->i va fi 2 pentru a il face ACAA
	begin
		set @i=@i-1
		select @caracter=substring(@CodIntrare,@i,1)
	end
	set @CodIntrare=substring(@CodIntrare,1,@i)
	if @i=len(@CodIntrarePred)
	begin		
		set @lungInit=@lungInit+1
	end
	else
	begin
		set @CodIntrare=substring(@CodIntrare,1,@i-1)+CHAR(ASCII(@caracter)+1)
	end
	/*Adaugam A-uri la final*/
	while @i<@lungInit
	begin
		set @CodIntrare=rtrim(@Codintrare)+'A'
		set @i=@i+1
	end
	return @CodIntrare
end