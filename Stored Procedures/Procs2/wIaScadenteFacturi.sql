
create procedure wIaScadenteFacturi @sesiune varchar(50), @parXML xml
as

declare
	@tipfact varchar(10), @tert varchar(20), @factura varchar(20)

select
	@tipfact = @parXML.value('(/row/@dentipfact)[1]','varchar(1)'),
	@tert = @parXML.value('(/row/@tert)[1]','varchar(20)'),
	@factura = @parXML.value('(/row/@factura)[1]','varchar(20)')

select
	s.id,
	convert(varchar(10),s.tip) as tip_factura,
	(case s.tip when 'B' then 'Beneficiari' when 'F' then 'Furnizori' else '' end) as den_tip_factura,
	rtrim(s.factura) as factura,
	convert(varchar(10),s.data_scadentei,101) as data_scadentei,
	convert(decimal(17,2),s.suma) as suma,
	rtrim(s.tertf) as tert,
	rtrim(tt.denumire) as dentertf,
	rtrim(s.facturaf) as facturaf,
	convert(decimal(17,2),s.sumaf) as sumaf
from ScadenteFacturi s
inner join terti t on t.subunitate='1' and t.tert=s.tert
left join terti tt on tt.subunitate='1' and tt.tert=s.tertf
where s.tip=@tipfact and s.tert=@tert and s.factura=@factura
order by s.data_scadentei desc, id desc
for xml raw
