--***
/* procedura pentru populare rapoarte de salarii deschise dinspre macheta de date salarii. */
Create procedure wpopRapoarteSalarii @sesiune varchar(50), @parXML xml 
as  
begin
	declare @data datetime, @Luna int, @An int, @datajos datetime, @datasus datetime,  @utilizator varchar(10)

	exec wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator output

	set @data = @parXML.value('(/*/@data)[1]','datetime')

	set @datajos=dbo.BOM(@data)
	set @datasus=dbo.eom(@data)

	select convert(char(10),@data,101) as data, convert(char(10),@data,101) as datalunii, 
		convert(varchar(10),@datajos,101) as datajos, convert(varchar(10),@datasus,101) as datasus
	for xml raw
end