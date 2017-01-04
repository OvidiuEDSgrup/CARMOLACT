--***
CREATE procedure [dbo].wIaGarantiiMateriale @sesiune varchar(50), @parXML xml
as
begin
	declare @utilizator varchar(20), @f_marca varchar(6), @f_densalariat varchar(100)

	set @utilizator = dbo.fIaUtilizator(null)

	set @f_marca = @parXML.value('(/*/@f_marca)[1]','varchar(6)')
	set @f_densalariat = @parXML.value('(/*/@f_densalariat)[1]','varchar(100)')

	select top 100 marca, nume, detalii
	from personal p
	where ISNULL(p.detalii.value('(/row/@nrsalgm)[1]','int'),0)<>0 
		  and (@f_marca is null or p.marca like rtrim(@f_marca) + '%') 
		  and (@f_densalariat is null or p.nume like '%' + rtrim(@f_densalariat) + '%') 
		  and (dbo.f_areLMFiltru(@utilizator)=0 or exists (select 1 from lmfiltrare l where l.utilizator=@utilizator and l.cod=p.loc_de_munca))
	order by marca
	for xml raw
	
	select 1 areDetaliiXml for xml raw, root('Mesaje')
end