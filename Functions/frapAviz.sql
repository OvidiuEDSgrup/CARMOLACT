
CREATE function [dbo].[frapAviz](@dataInceput datetime,@dataSfarsit datetime/*, @gestiune char(200)*/)
returns @rapCF table
(aviz char(20),dataAviz datetime,factura char(20),  data  datetime,  cod_tert char(13), denumire_tert char (40),
denumire_punct_livrare char(40), 
cod_pct_liv char(20),
valoare float, 
tva float,
val_cu_amanuntul float, 
g char (10),
tip_doc char(10))
begin

insert into @rapCF
select *
from(
select d.numar,   max(d.data) as data,d.factura as factura,
  
		(select min(ff.data) from facturi ff where ff.factura=d.factura and ff.tert=d.tert and ff.subunitate='1' and ff.tip=(0x46) and d.Factura!='') as dataF,
		d.tert as cod_tert,
		(select max(t.denumire) from terti as t where t.subunitate = max(d.subunitate) and t.tert = max(d.tert)) as denumire_tert,
		(select max(it.descriere) from infotert it 
				where it.tert = max(d.tert) 
					and it.identificator = ((select max(gestiune_primitoare) from doc as dd where dd.tip in ( 'ap', 'as', 'ac' )
									and dd.factura = d.factura and dd.cod_tert = d.tert
									and dd.subunitate = '1' ))) as denumire_punct_livrare,
		max(d.gestiune_primitoare) cod_pct_liv,
		sum(round(convert(decimal(17,5),cantitate* pret_vanzare), 2.00000000 )) as valoare,
		sum(round(convert(decimal(17,5),cantitate* pret_vanzare*0.24), 2.00000000 )) as tva,
		sum(round(convert(decimal(17,5),cantitate* pret_vanzare + cantitate* pret_vanzare*0.24), 2.00000000 )) as val_cu_amanuntul,
		--(select max(doc.cod_gestiune) from doc where factura = d.factura) as g
		d.gestiune as g,
		(select max(tip_miscare) from doc as dd where dd.tip in ( 'ap', 'as', 'ac' )
									and dd.factura = d.factura and dd.cod_tert = d.tert
									and dd.subunitate = '1' ) tip_doc
from pozdoc as d 
where d.tip in ( 'ap', 'as', 'ac' )
		--and d.data_facturii between @dataInceput and @dataSfarsit
		--and factura in ( select factura from facturi f where subunitate = '1' and tip = 0x46 and d.tert =f.tert 
									and d.data between @dataInceput and @dataSfarsit
	
		and d.subunitate = '1'

		group by  d.numar,d.factura, d.tert, gestiune--, d.numar_dvi		
) as rezultat

order by  Numar

return
end
