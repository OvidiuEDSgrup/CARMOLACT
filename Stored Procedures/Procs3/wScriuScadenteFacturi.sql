
create procedure wScriuScadenteFacturi @sesiune varchar(50), @parXML xml
as

declare
	@mesaj varchar(max), @tipfact varchar(1), @tert varchar(20), @factura varchar(20), @data_scadentei datetime, @suma decimal(17,5), 
	@tertf varchar(20), @facturaf varchar(20), @sumaf decimal(17,5), @update bit, @id int

begin try
	select
		@id = @parXML.value('(/row/row/@id)[1]','int'),
		@tipfact = @parXML.value('(/row/@dentipfact)[1]','varchar(1)'),
		@tert = @parXML.value('(/row/@tert)[1]','varchar(20)'),
		@factura = @parXML.value('(/row/@factura)[1]','varchar(20)'),
		@data_scadentei = @parXML.value('(/row/row/@data_scadentei)[1]','datetime'),
		@suma = @parXML.value('(/row/row/@suma)[1]','decimal(17,5)'),
		@tertf = @parXML.value('(/row/row/@tert)[1]','varchar(20)'),
		@facturaf = @parXML.value('(/row/row/@facturaf)[1]','varchar(20)'),
		@sumaf = @parXML.value('(/row/row/@sumaf)[1]','decimal(17,5)'),
		@update = isnull(@parXML.value('(/row/row/@update)[1]','bit'),0)

	if @update=0
	begin
		insert into ScadenteFacturi(tip,tert,factura,data_scadentei,suma,tertf,facturaf,sumaf)
		select @tipfact, rtrim(@tert), rtrim(@factura), @data_scadentei, @suma, nullif(@tertf,''), nullif(@facturaf,''), nullif(@sumaf,0)
	end
	else
	begin
		update scadentefacturi
		set data_scadentei=@data_scadentei, suma=@suma, tertf=nullif(@tertf,''), facturaf=nullif(@facturaf,''), sumaf=nullif(@sumaf,0)
		where id=@id
	end
end try

begin catch
	set @mesaj = error_message() + ' (' + object_name(@@procid) + ')'
	raiserror(@mesaj,16,1)
end catch
