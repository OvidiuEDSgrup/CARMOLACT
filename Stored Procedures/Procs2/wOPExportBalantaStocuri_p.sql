
create procedure wOPExportBalantaStocuri_p @sesiune varchar(50), @parXML xml
as

select 
	convert(varchar(10),dbo.BOM(getdate()),101) as datajos, 
	convert(varchar(10),dbo.EOM(getdate()),101) as datasus,
	'wOPExportBalantaStocuri'  procedura
for xml raw
