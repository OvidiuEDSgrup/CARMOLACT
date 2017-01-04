create view [dbo].[verificari] as 
select factura, tert,gestiune from pozdoc  where factura<>'' and tip='AP' group by factura,tert,gestiune
