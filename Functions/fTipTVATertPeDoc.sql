--***
create function fTipTVATertPeDoc (@parXML xml)
returns char(1)
as
begin
	declare @TipPlataTVA char(1), @DataFact datetime, @tert varchar(13)
	set @tert=isnull(@parXML.value('(/row/@tert)[1]', 'varchar(13)'),'')
	set @DataFact=isnull(@parXML.value('(/row/@datafact)[1]', 'datetime'),'')

	select top 1 @TipPlataTVA=tip_tva from TvaPeTerti --Verific daca este cu Tva La Incasare
		where tert is null and tipf='B' and dela<=@DataFact
	order by dela desc

	if @TipPlataTVA is null and @tert<>'' --Daca nu e (null) cu TVA la incasare se va studia furnizorul; @tert<>'' inseamna ca se apeleaza functia din intrari
		select top 1 @TipPlataTVA=tip_tva from TvaPeTerti 
			where tert=@Tert and tipf='F' and dela<=@DataFact and factura is null
				order by dela desc

	if @TipPlataTVA is null
		set @TipPlataTVA='P'

	return @TipPlataTVA
end