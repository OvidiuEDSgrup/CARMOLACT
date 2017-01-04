
CREATE procedure [dbo].[wACCodIntrareL] @sesiune varchar(50), @parXML XML
as

declare @searchText varchar(100),@nr varchar(100),@codL int,@cod varchar(20)
set @searchText=replace(isnull(@parXML.value('(/row/@searchText)[1]','varchar(100)'),'%'),' ','%')
set @nr=isnull(@parXML.value('(/row/@nrPP)[1]','varchar(100)'),'')
set @cod=isnull(@parXML.value('(/row/row/@cod)[1]','varchar(20)'),'')
set @codL=(select count(*) from pozTehnologii where idp=(select id from poztehnologii where tip='T' and cod=@cod)and cod='L')
if(@codL>0)
begin
select top 100 LTRIM(rtrim(cod_intrare)) as cod,
'Stoc: '+ltrim(rtrim(convert(char(18),convert(decimal(12,2),sum(stoc)))))as info,
--LTRIM(rtrim(cod_intrare))+ ' '+'Stoc: '+ltrim(rtrim(convert(char(18),convert(decimal(12,3),sum(stoc))))) as denumire
LTRIM(rtrim(cod_intrare)) as denumire
from stocuri
where cod='L' and stoc>0
and Cod_intrare like '%'+@searchText+'%'
group by cod_intrare
order by rtrim(Cod_intrare)
for xml raw
end
else
begin
select  'NU CONTINE L' as cod,'NU CONTINE L' as denumire
end

