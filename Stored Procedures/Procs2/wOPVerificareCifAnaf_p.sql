Create procedure wOPVerificareCifAnaf_p @sesiune varchar(50)=null, @parXML xml
as

begin try

	declare @data datetime, @datajos datetime, @datasus datetime, @luna int, @an int, @tipdecl varchar(1)

	select @luna=month(getdate()), @an=year(getdate())

	select top 1 @tipdecl = ISNULL(continut.value('(/*/@tip_D394)[1]', 'varchar(1)'), 'L')
	from declaratii 
	where cod='394' and data<=getdate()
	order by data desc

	select @luna as luna, @an as an, @tipdecl as tipdecl
	for xml raw

end try 

begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura '+'(' + OBJECT_NAME(@@PROCID) + ')'+ '(linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
