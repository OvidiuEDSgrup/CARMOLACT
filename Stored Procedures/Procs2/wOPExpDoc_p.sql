
create procedure wOPExpDoc_p @sesiune varchar(50), @parXML xml
as

select 
	convert(char(10),dbo.BOM(getdate()), 101) datajos, 
	convert(char(10), dbo.EOM(getdate()), 101) datasus,
	'wOPExpDoc' as procedura
for xml raw
