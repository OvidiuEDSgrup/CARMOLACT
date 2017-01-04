--***
create procedure rapcategoriiIndicatori (@calcul int, @categ char(9), @data_jos datetime, @data_sus datetime, @indicator varchar(20), @tip_coloana int
					, @element_1 varchar(20) = null, @element_2 varchar(20) = null)
as
/*
declare @calcul int, @categ char(9), @data_jos datetime, @data_sus datetime, @indicator varchar(20), @tip_coloana int
set @calcul=0 set @categ='FLO' set @data_jos='2008-1-1' set @data_sus='2009-10-30' set @indicator='FLO.T' set @tip_coloana=0

declare @q_calcul int, @q_categ char(9), @q_data_jos datetime, @q_data_sus datetime, @q_indicator varchar(20), @q_tip_coloana int
select @q_calcul=@calcul, @q_categ=@categ, @q_data_jos=@data_jos, @q_data_sus=@data_sus, @q_indicator=@indicator, @q_tip_coloana=@tip_coloana
--*/

If @calcul = 1 begin 
exec dbo.CalcCategInd @pCateg=@categ,@pDataJos=@data_jos,@pDataSus=@data_sus,@lTipSold=0,@lFaraStergere=0 
end

/**	Se aranjeaza datele pentru a putea lua valori calculate si previzionate: */
	set transaction isolation level read uncommitted
select cod_indicator,sum(valoare) as valoare,0 as semn,
		rtrim(case @tip_coloana when 0 then convert(varchar(20),data,103) when 1 then v1.Element_1 when 2 then v1.Element_2 end) as coloana,
		rtrim(case @tip_coloana when 0 then convert(varchar(20),data,102) when 1 then v1.Element_1 when 2 then v1.Element_2 end) as ordonare,
		tip 
	into #expval 
	from expval v1 
	inner join compcategorii c on c.cod_ind = v1.cod_indicator and c.cod_categ=@categ
	where v1.data between @data_jos and @data_sus and (@element_1 is null or v1.element_1 like @element_1+'%')
		and (@element_2 is null or v1.element_2 like @element_2+'%')
	group by v1.cod_indicator, v1.tip, v1.data, v1.element_1, v1.element_2
union all -- mai jos "inventez" tipul de valori "D=Diferenta"
select cod_indicator,sum(valoare*(case tip when 'P' then 1 when 'E' then -1 else 0 end)) as valoare,
		(case max(tip) when 'P' then 1 else 0 end)+(case min(tip) when 'E' then -1 else 0 end) as semn,
		rtrim(case @tip_coloana when 0 then convert(varchar(20),data,103) when 1 then v1.Element_1 when 2 then v1.Element_2 end) as coloana,
		rtrim(case @tip_coloana when 0 then convert(varchar(20),data,102) when 1 then v1.Element_1 when 2 then v1.Element_2 end) as ordonare,
		'D' as tip 
	from expval v1 
	inner join compcategorii c on c.cod_ind = v1.cod_indicator and c.cod_categ=@categ 
	where v1.data between @data_jos and @data_sus and (@element_1 is null or v1.element_1 like @element_1+'%')
		and (@element_2 is null or v1.element_2 like @element_2+'%')
	group by v1.cod_indicator, v1.data, v1.element_1, v1.element_2
/**		coloana = denumire/grupare pe coloane;		ordonare = ordinea in care se iau datele */

;with x as (
select Cod_Categ, Cod_Ind, Rand, parinte from compcategorii 
		where rtrim(cod_categ)=rtrim(@categ) and (rtrim(cod_ind)=rtrim(@indicator) or @indicator is null) union all
select c.Cod_Categ, c.Cod_Ind, c.Rand, c.Parinte from compcategorii c, x 
		where x.cod_ind=c.parinte and @indicator is not null
)
select i.cod_indicator,
			max(case when i.denumire_indicator!='' then rtrim(i.cod_indicator)+' - '+rtrim(i.denumire_indicator) else i.cod_indicator end) as descriere_expresie,
			c.cod_categ, max(cat.denumire_categ) as denumire_categ,c.rand,sum(cast(isnull(v1.valoare,0) as decimal(15,2))) as valoare,
			v1.coloana, isnull(v1.tip,null) as tip,
			sum(v1.semn) as semn,max(c.parinte) as cod_parinte, max(v1.ordonare) ordonare
from indicatori i 
inner join x c on c.cod_ind = i.cod_indicator
inner join categorii cat on cat.cod_categ = c.cod_categ
left outer join #expval v1 on i.cod_indicator = v1.cod_indicator --and v1.data between @data_jos and @data_sus
group by i.cod_indicator,c.cod_categ,c.rand,v1.coloana,v1.tip
union all		/**	ultima coloana e de totaluri: */
select i.cod_indicator,
			max(case when i.denumire_indicator!='' then rtrim(i.cod_indicator)+' - '+rtrim(i.denumire_indicator) else i.cod_indicator end) as descriere_expresie,
			@categ cod_categ, max(cat.denumire_categ) as denumire_categ,c.rand,sum(cast(isnull(v1.valoare,0) as decimal(15,2))) as valoare,
			'<|Total|>', isnull(v1.tip,null) as tip,
			sum(v1.semn) as semn,max(c.parinte) as cod_parinte, 'ZZZZZZ' ordonare
from indicatori i 
inner join x c on c.cod_ind = i.cod_indicator
inner join categorii cat on cat.cod_categ = c.cod_categ
left outer join #expval v1 on i.cod_indicator = v1.cod_indicator --and v1.data between @data_jos and @data_sus
group by i.cod_indicator, c.rand,v1.tip
order by ordonare

drop table #expval