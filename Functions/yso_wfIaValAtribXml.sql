--***

create function yso_wfIaValAtribXml (@parXML xml, @attr varchar(max))
returns nvarchar(200)
with schemabinding
as 
begin
	return @parXML.value('(/*/@*[local-name()=sql:variable("@attr")])[1]','nvarchar(max)')
end