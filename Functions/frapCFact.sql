CREATE function [dbo].[frapCFact](@dataInceput datetime,@dataSfarsit datetime/*, @gestiune char(200)*/)
returns @rapCFact table
( cod char(15),
  denumire char(45),
  um char(3),
gestiune char(10),	
cant float,
valoare float)

begin

insert into @rapCFact
select d.cod,n.denumire,
		n.um,	
		d.gestiune,			
		sum(round(convert(decimal(17,5),d.cantitate), 2.00000000 )) as cant,
		sum(round(convert(decimal(17,5),d.cantitate* d.pret_vanzare), 2.00000000 )) as valoare
	from pozdoc as d, nomencl n
where d.tip in ( 'ap', 'as', 'ac' )
		and d.factura in ( select factura from facturi f where subunitate = '1' and tip = 0x46 and d.tert =f.tert 
		  				and f.data between @dataInceput and @dataSfarsit)
		and not (d.factura  is null) and (d.factura!='')
		and d.subunitate = '1'
		and d.tip_miscare in ('E', 'V')		
--		and d.gestiune in (select cod_gestiune from gestiuni)                               
		and d.cod=n.cod
		group by  d.cod,n.denumire, n.um,d.gestiune

return
end
