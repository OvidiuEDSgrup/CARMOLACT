--***
create procedure wacAntetInventar (@sesiune varchar(50), @parXML xml)
as
/*
if exists(select * from sysobjects where name='wACGestiuniSP' and type='P')      
	exec wacAntetInventarSP @sesiune,@parXML
else    */
begin
	declare @searchText varchar(200)
		, @tipgestiune varchar(1)	--> pt inventar comparativa sa se filtreze in functie de tip pe gestiuni sau marci

	select @searchText=replace(rtrim(ISNULL(@parXML.value('(/row/@searchText)[1]', 'varchar(80)'), '')),' ','%')+'%'
		,@tipgestiune=isnull(@parxml.value('(row/@tipgest)[1]','varchar(1)'),'N')
		--> traducere a tipurilor de gestiuni din rapoarte in tipuri de inventare:
	
	select @tipgestiune=(case @tipgestiune when 'D' then 'G' when 'F' then 'M' end)

		select idInventar as cod, rtrim(isnull(g.Denumire_gestiune,m.nume))+' ('+rtrim(gestiune)+') '+convert(varchar(20),a.data,103) as denumire,
			--convert(varchar(20),a.data,103) 
			case when isnull(a.grupa,'')<>'' then 'Grupa: ' +RTRIM(gr.Denumire)+' ('+rtrim(a.grupa)+') ' else '' end
			+case when isnull(a.locatie,'')<>'' then 'Locatia: ' +RTRIM(l.descriere)+' ('+rtrim(a.locatie)+') ' else '' end
			 info
		from antetInventar a 
			left join gestiuni g on a.gestiune=g.Cod_gestiune
			left join personal m on a.gestiune=m.marca
			left join grupe gr on gr.grupa=a.grupa
			left join locatii l on l.cod_locatie=a.locatie
		where 
			(@tipgestiune='N' or @tipgestiune=a.tip)
			and (gestiune like @searchText or isnull(Denumire_gestiune,'') like '%'+@searchText or 
			isnull(m.nume,'') like '%'+@searchText or
			convert(varchar(20),a.data,103) like '%'+@searchText or ltrim(str(idInventar)) like @searchText+'%')
		order by a.data desc
		for xml raw
end
