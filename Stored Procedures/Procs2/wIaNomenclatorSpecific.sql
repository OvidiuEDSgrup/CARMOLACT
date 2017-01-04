--***
create procedure wIaNomenclatorSpecific @sesiune varchar(30), @parXML XML
as

Declare @iDoc int

Declare @cSub varchar(9), @tert varchar(20), @cautare varchar(100)
exec luare_date_par 'GE','SUBPRO',1,0,@cSub OUTPUT
Set @tert = @parXML.value('(/row/@tert)[1]','varchar(20)')
Set @cautare = @parXML.value('(/row/@_cautare)[1]','varchar(100)')

select  rtrim(n.Tert) as tert, RTRIM(n.cod) as cod,RTRIM(n.Cod_special) as codspecific, RTRIM(n.Denumire) as denumire,
		CONVERT(decimal(12,3),n.Pret) as pret, convert(decimal(12,3),n.Pret_valuta) as pret_valuta,
		convert(decimal(12,2),n.Discount) as discount,rtrim(a.cod)+'-'+RTRIM(a.Denumire) as dencod,
		(case when isnull(n.detalii.value('(/row/@invalid)[1]', 'varchar(200)'), '') = '' then 0 else 1 end) AS este_invalid, --> checkbox in form
		isnull(nullif(n.detalii.value('(/row/@invalid)[1]', 'varchar(200)'), ''), 'Codul este valid') AS invalid,
		convert(varchar(10), isnull(n.detalii.value('(/row/@data_invalid_jos)[1]', 'datetime'), getdate()), 101) AS data_invalidare,
		(CASE WHEN GETDATE() BETWEEN n.detalii.value('(/row/@data_invalid_jos)[1]', 'datetime') AND n.detalii.value('(/row/@data_invalid_sus)[1]', 'datetime') THEN '#C0C0C0'
			  ELSE '#000000'
		END) AS culoare,
		n.detalii AS detalii
from nomspec n,nomencl a	
where  n.tert = @tert
	and n.Cod=a.Cod 
	and (isnull(@cautare,'')='' or n.Cod like '%'+@cautare+'%' or n.Denumire like '%'+@cautare+'%' or n.Cod_special like '%'+@cautare+'%')
order by n.Cod
for xml raw

SELECT 1 AS areDetaliiXml FOR XML RAW, ROOT('Mesaje')
