--***
/* procedura pentru populare macheta de gen. D394 si raport D394 */
create procedure wOPGenerareD394_p @sesiune varchar(50), @parXML xml 
as  
declare @numedecl varchar(150), @prendecl varchar(50), @functiedecl varchar(50), @siXMLPDF int

exec luare_date_par 'GE', 'NDECLTVA', 0, 0, @numedecl output
exec luare_date_par 'GE', 'FDECLTVA', 0, 0, @functiedecl output
exec luare_date_par 'GE', 'XMLPDF394', @siXMLPDF output, 0, ''

select rtrim(@functiedecl) as functiedecl, rtrim(LEFT(@numedecl,(case when CHARINDEX(' ',@numedecl)<>0 then CHARINDEX(' ',@numedecl)-1 else 0 end))) as numedecl, 
	rtrim(right(rtrim(@numedecl),len(rtrim(@numedecl))-CHARINDEX(' ',rtrim(@numedecl)))) as prendecl, @siXMLPDF as sixmlpdf, 
	convert(varchar(20),@parxml.value('(row/@datalunii)[1]','datetime'),101) as datajos,
	@parxml.value('(row/@iddeclaratie)[1]','int') as iddeclaratie
for xml raw
