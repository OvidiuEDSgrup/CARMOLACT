
create function [dbo].[genereazaTreeElemAntec] (@id int, @parinte varchar(20))
returns xml
as
begin
	declare @curs float
	set @curs=(select curs from antecalculatii where cod=(select cod from pozTehnologii where id=@id))
	return 
	(	
		select 
			RTRIM(e.element) as cod, RTRIM(e.descriere) as _grupare,(case when e.procent=1 then '( '+RTRIM(e.formula)+' )*'+CONVERT(varchar(5),p.cantitate) else RTRIM(e.formula) end) as pret,
			convert(decimal(10,2),p.pret) as valoare,CONVERT(varchar(6),p.cantitate*100)+'%' as cantitate, (case when e.procent=1 then 'E' else '' end) as subtip,
			(case when procent=1 then 'Procent' else '-' end) as um,'E' as tip,convert(decimal(10,2),p.pret/@curs) as valuta,
			(RTRIM(e.descriere) +' ('+rtrim(cod)+')') as denumireCod,dbo.genereazaTreeElemAntec(@id, e.element),RTRIM(descriere) as denumire			
		from pozTehnologii p, elemantec e 
		where e.element=p.cod and p.idp=@id and p.tip='E' and e.element_parinte=@parinte 
		order by element
		for xml raw,type
	)
end
