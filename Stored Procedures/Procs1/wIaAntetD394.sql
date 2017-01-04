--***
create procedure wIaAntetD394 @sesiune varchar(50), @parXML xml
as
begin try
	declare 
		@utilizator varchar(20), @data datetime, @iddeclaratie int, @mesaj varchar(500)

	exec wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator output

	select
		@data = @parXML.value('(/row/@datalunii)[1]','datetime'),
		@iddeclaratie = isnull(@parXML.value('(/row/@iddeclaratie)[1]','int'),0)

	select
		convert(varchar(10),@data,101) as datalunii, @iddeclaratie as iddeclaratie
	for xml raw

end try
begin catch
	set @mesaj = ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 16, 1)
end catch

/*
	exec wIaAntetD394 '', '<row datalunii="2016-07-31"/>'
	select * from declaratii
*/
