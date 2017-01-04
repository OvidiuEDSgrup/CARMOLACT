--***
Create procedure wIaStocuriGestiune   @sesiune varchar(30), @parXML XML
as
if exists(select * from sysobjects where name='wIaStocuriGestiuneSP' and type='P')
	exec wIaStocuriGestiuneSP @sesiune, @parXML 
else      
begin

Declare @iDoc int

Declare @cSub varchar(9), @gestiune varchar(20), @cautare varchar(100)
exec luare_date_par 'GE','SUBPRO',1,0,@cSub OUTPUT
Set @gestiune = @parXML.value('(/row/@gestiune)[1]','varchar(20)')
Set @cautare = @parXML.value('(/row/@_cautare)[1]','varchar(100)')

select top 100 
--rtrim(s.tip_gestiune) as tip, rtrim(s.cod_gestiune) as gestiune, 
--rtrim(s.cod_gestiune)+'-'+RTRIM(g.Denumire_gestiune) as dengestiune,
RTRIM(s.cod) as cod, RTRIM(n.denumire) as denumire, 
RTRIM(s.cod_intrare) as codintrare, 
convert(char(10),s.data,101) as data, convert(decimal(12,3),s.stoc) as stoc, RTRIM(s.cont) as cont, convert(decimal(15,5),s.pret) as pret, 
rtrim(t.Tert)+'-'+RTRIM(t.Denumire) as dentert, 
convert(char(10),(case when s.Data_expirarii<=s.data then null else s.Data_expirarii end),101) as dataexpirarii, 
RTRIM(case when 1=0 /*s.lot in ('4427','4012') or s.Lot like rtrim(s.Cod_intrare)+'%'*/ then null else s.lot end) as lot, 
RTRIM(s.locatie) as locatie
from stocuri s
left join nomencl n on s.Cod=n.cod
left outer join terti t on s.Locatie=t.tert
where s.Subunitate = @cSub and s.Cod_gestiune = @gestiune and s.Stoc <> 0
	and (isnull(@cautare,'')='' or s.cod like @cautare+'%' or n.denumire like '%'+@cautare+'%')
order by s.Data
for xml raw
end
