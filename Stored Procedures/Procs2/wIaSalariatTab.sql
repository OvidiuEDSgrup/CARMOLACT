--***
CREATE procedure wIaSalariatTab @sesiune varchar(50), @parXML xml
as  
begin 
	declare @tip varchar(2), @marca varchar(6), @mesajeroare varchar(500), @utilizator varchar(20)
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output
	if @utilizator is null
		return -1
	select @tip=isnull(@parXML.value('(/row/@tip)[1]', 'varchar(2)'), ''), 
		@marca=ISNULL(@parXML.value('(/row/@marca)[1]','varchar(6)'), '')

	select @tip as tip, rtrim(p.marca) as marca, rtrim(max(p.Nume)) as densalariat, 
		max(dbo.fVechimeAALLZZ(p.Vechime_totala)) as vechimetotala, max(isnull(p.vechime_la_intrare,ip.vechime_la_intrare)) as vechimelaintrare, 
		max(isnull(p.detalii.value('(/row/@vechimemeserie)[1]','varchar(10)'),ip.Vechime_in_meserie)) as vechimeinmeserie
	from personal p 
		left outer join infoPers ip on ip.Marca=p.Marca
	where p.Marca=@marca
	group by p.Marca
	for xml raw
end 
