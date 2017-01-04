CREATE procedure YSO_rapVanzariRetur @data1 date, @data2 date, @tert varchar(15)
as
begin

select 
te.Denumire,
po1.Cod,
nom.Denumire,
isnull(po1.Cantitate,0) as Vanzare,-isnull(po2.Cantitate,0) as Retur
from pozdoc po1 
full join pozdoc po2 on po1.Tert=po2.Tert and po1.Cod=po2.Cod and po2.Cantitate<0
inner join terti te on po1.Tert=te.Tert
inner join nomencl nom on po1.Cod=nom.Cod
where po1.Tip='AP' and po1.Subunitate='1' and po1.Cantitate>0
and (ISNULL(@tert,'')='' or @tert=po1.Tert)
and (ISNULL(@data1,'1901-01-01')='1901-01-01' or (po1.Data>@data1 and po2.Data>@data1))
and (ISNULL(@data2,'1901-01-01')='1901-01-01' or (po1.Data<@data2 and po2.Data>@data2))


end