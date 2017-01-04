--***
Create procedure wDeclaratia205 @sesiune varchar(50), @parXML xml
as

declare @data datetime, @datajos datetime, @datasus datetime, @lunaalfa varchar(15), @luna int, @an int, @userASiS varchar(10)

select @an=ISNULL(@parXML.value('(/row/@an)[1]','int'),0),
	@luna=ISNULL(@parXML.value('(/row/@luna)[1]','int'),0),
	@data=ISNULL(@parXML.value('(/row/@data)[1]','datetime'),'')

exec wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS output

set @datajos = ISNULL(@parXML.value('(/row/@datajos)[1]', 'datetime'), dbo.BOM(@data))
set @datasus = ISNULL(@parXML.value('(/row/@datasus)[1]', 'datetime'), dbo.EOM(@data))

begin try  
	select distinct convert(char(10),Data_lunii,101) as data, rtrim(LunaAlfa) as numeluna, Luna as luna, convert(char(4),an) as an, data as data_ord
	from fCalendar(@datajos,@datasus)
	where Data=dbo.EOY(Data_lunii)
	order by data_ord desc
	for XML raw
end try  

begin catch
	declare @eroare varchar(254)
	set @eroare='Procedura wDeclaratia205 (linia '+convert(varchar(20),ERROR_LINE())+'): '+ERROR_MESSAGE()
	raiserror(@eroare, 16, 1)
end catch
