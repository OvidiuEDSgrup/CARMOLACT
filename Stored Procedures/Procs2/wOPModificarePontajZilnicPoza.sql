
create procedure wOPModificarePontajZilnicPoza @sesiune varchar(50), @parXML xml
as

declare
	@mesaj varchar(max), @idPontaj int, @marca varchar(20), @dataintrare datetime, @oraintrare varchar(8), @dataiesire datetime, @oraiesire varchar(8)

begin try
	select
		@idPontaj = @parXML.value('(/*/@idPontajElectronic)[1]','int'),
		@marca = @parXML.value('(/*/@marca)[1]','varchar(20)'),
		@dataintrare = @parXML.value('(/*/@dataintrare)[1]','datetime'),
		@oraintrare = @parXML.value('(/*/@oraintrare)[1]','varchar(8)'),
		@dataiesire = @parXML.value('(/*/@dataiesire)[1]','datetime'),
		@oraiesire = @parXML.value('(/*/@oraiesire)[1]','varchar(8)')
	
	if isnull(@marca,'')=''
		raiserror('Marca necompletata!',16,1)

	if isnull(@oraintrare,'')!='' and isdate(@oraintrare)=0
		raiserror('Ora de intrare nu este formatata corect! (hh:mm:ss)',16,1)

	if isnull(@oraiesire,'')!='' and isdate(@oraiesire)=0
		raiserror('Ora de iesire nu este formatata corect! (hh:mm:ss)',16,1)

	set @dataintrare = @dataintrare + ' ' + @oraintrare
	set @dataiesire = @dataiesire + ' ' + @oraiesire

	update pontajelectronic set marca=@marca, data_ora_intrare = @dataintrare, data_ora_iesire=@dataiesire where idPontajElectronic=@idPontaj
end try

begin catch
	set @mesaj = error_message() + ' (' + object_name(@@procid) + ')'
	raiserror(@mesaj,16,1)
end catch