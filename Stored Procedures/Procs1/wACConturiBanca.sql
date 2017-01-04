--***
create procedure wACConturiBanca @sesiune varchar(50), @parXML XML  
as  
begin  
	declare @searchText varchar(100),@tert varchar(13)

	select @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%'),
		@tert=isnull(@parXML.value('(/row/@tert)[1]','varchar(13)'),'')
	
	select distinct top 100  denumire, cod from
	(
	select top 100	max(rtrim(p.Cont_in_banca)+'-'+rtrim(isnull(c.denumire,p.Banca))) as denumire, rtrim(p.Cont_in_banca) as cod
	from ContBanci p
		left join coduribancare c on substring(replace(p.cont_in_banca,' ',''),5,4)=c.cod
	where (p.Tert=@tert or isnull(@tert,'')='')
		and (p.Cont_in_banca like @searchText+'%' or p.Banca like '%'+@searchText+'%'
				or c.denumire like '%'+@searchText+'%'
			)
	group by p.cont_in_banca
	order by max(isnull(c.denumire,p.Banca)), p.cont_in_banca
	union all
	select top 100	max(rtrim(p.Cont_in_banca)+'-'+rtrim(c.denumire)) as denumire,rtrim(p.Cont_in_banca) as cod
	from terti p
		left join coduribancare c on substring(replace(p.cont_in_banca,' ',''),5,4)=c.cod
	where (p.Tert=@tert or isnull(@tert,'')='')
		and (p.Cont_in_banca like @searchText+'%' or c.denumire like '%'+@searchText+'%')
		and rtrim(isnull(p.cont_in_banca,''))<>''
	group by p.cont_in_banca
	order by max(c.denumire), p.cont_in_banca
	) x
	for xml raw
end
