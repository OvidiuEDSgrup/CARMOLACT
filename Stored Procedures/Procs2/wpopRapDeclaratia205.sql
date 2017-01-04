create procedure wpopRapDeclaratia205 (@sesiune varchar(50), @parXML xml='<row/>')
as
begin
	set transaction isolation level read uncommitted
	declare @subunitate varchar(20), @data datetime, @utilizatorASiS varchar(50), 
		@contImpozit char(30), @contFactura char(30), @contImpozitDividende char(30)

	select @contImpozit=max((case when parametru='D205CTIMP' then Val_alfanumerica else '' end)),
		@contFactura=max((case when parametru='D205CTFAC' then Val_alfanumerica else '' end)),
		@contImpozitDividende=max((case when parametru='D205CTDIV' then Val_alfanumerica else '' end))
	from par where tip_parametru='PS' and parametru in ('D205CTIMP','D205CTFAC','D205CTDIV')

	select @data=isnull(@parXML.value('(/row/@data)[1]','datetime'),'')

	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizatorASiS output
	select convert(char(10),@data,101) datalunii, 
		(case when @contImpozit<>'' then @contImpozit end) contimpozit, 
		(case when @contFactura<>'' then @contFactura end) contfactura, 
		(case when @contImpozitDividende<>'' then @contImpozitDividende end) contimpozitdividende

	for xml raw
end