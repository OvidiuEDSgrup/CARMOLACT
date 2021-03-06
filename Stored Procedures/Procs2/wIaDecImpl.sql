﻿--***
create procedure [dbo].wIaDecImpl @sesiune varchar(30), @parXML XML
AS  
begin  
	declare @data_implementare datetime, @data_jos datetime, @data_sus datetime, @an_impl int, @luna_impl int, @mod_impl int, @lista_lm int, @userASiS varchar(20)

	EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS OUTPUT

	select  @data_implementare='1901-01-01',
			@data_jos=isnull(@parXML.value('(/row/@datajos)[1]', 'datetime'), '1901-01-01') ,
			@data_sus=isnull(@parXML.value('(/row/@datasus)[1]', 'datetime'), '2901-01-01') 

	exec luare_date_par @tip='GE', @par='ANULIMPL', @val_l=0, @val_n=@an_impl output, @val_a=''
	exec luare_date_par @tip='GE', @par='LUNAIMPL', @val_l=0, @val_n=@luna_impl output, @val_a=''
	exec luare_date_par @tip='GE', @par='IMPLEMENT', @val_l=@mod_impl output, @val_n=0, @val_a=''		

	if exists (select * from LMFiltrare l where l.utilizator=@userASiS)
		set @lista_lm=1
	else 
		set @lista_lm=0

	select top 100 'T' as tip, 'Deconturi' as dentip, convert(decimal(17,4),sum(a.Valoare)) as t_valoare, convert(decimal(17,4),sum(a.sold)) as t_sold,
			convert(decimal(17,4),sum(a.Decontat)) as t_decontat, COUNT(*) as nr_deconturi, @data_sus as datasus, @data_jos as datajos
	from decimpl a
	where a.Data between @data_jos and @data_sus	
		and (@lista_lm=0 or  exists (select * from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=a.Loc_de_munca))	
	group by a.tip
	order by a.Tip desc
	for xml raw
end
