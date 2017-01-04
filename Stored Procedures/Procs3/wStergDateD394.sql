	--***
Create procedure wStergDateD394 @sesiune varchar(50)=null	-->	parametrul sesiune nu va avea efect pana ce nu-l vom trimite catre ftert
		,@data datetime=null, @tert varchar(1000)=''
		,@parxml xml='<row/>'
as

declare @facturi varchar(1000), @expandare int, @tert_generare varchar(100),
	@raport bit, @codMeniu varchar(10), @tip varchar(10), @update int, @subtip varchar(2), @seriei varchar(10), @nri varchar(20), @tipf int, @serief varchar(10), @nrf varchar(20), @cdecl varchar(9)

select	--> filtre:
		 @data=isnull(@parxml.value('(row/@datalunii)[1]','datetime'),@data)
		,@codMeniu=isnull(@parxml.value('(row/@codMeniu)[1]','varchar(10)'),'')
		,@subtip=isnull(@parxml.value('(row/row/@subtip)[1]','varchar(2)'),'')
		,@tip=isnull(@parxml.value('(row/@tip)[1]','varchar(10)'),'')
		,@update=isnull(@parxml.value('(row/@update)[1]','int'),0)
		--> specifice machetei:
		,@expandare=(case left(isnull(@parxml.value('(row/@expandare)[1]','varchar(2)'),'2'),1) when 'd' then 10 when 'n' then 1 when '' then 2 else isnull(@parxml.value('(row/@expandare)[1]','varchar(2)'),2) end)

begin
	declare @cota_tva int, @randdecl varchar(10), @activitate varchar(20)
	set @cdecl=rtrim(@parxml.value('(row/row/@cdecl)[1]','varchar(50)'))
	set @randdecl=rtrim(@parxml.value('(row/row/@randdecl)[1]','varchar(50)'))
	set @activitate=rtrim(@parxml.value('(row/row/@activitate)[1]','varchar(10)'))
	set @cota_tva=isnull(@parxml.value('(row/row/@cota_tva)[1]','int'),0)
	set @seriei=rtrim(isnull(@parxml.value('(row/row/@seriai)[1]','varchar(10)'),''))
	set @nri=isnull(@parxml.value('(row/row/@numari)[1]','varchar(20)'),'')
	set @serief=rtrim(isnull(@parxml.value('(row/row/@seriaf)[1]','varchar(10)'),''))
	set @nrf=isnull(@parxml.value('(row/row/@numarf)[1]','varchar(20)'),'')
	set @tipf=isnull(@parxml.value('(row/row/@tipf)[1]','int'),0)

	--select @codMeniu, @subtip, @seriei, @nri, @serief, @nrf, @cdecl
	if @subtip='A1' --and @codmeniu='DT2'
		delete from d394 
			where rand_decl=@cdecl and isnull(seriei,'')=@seriei and isnull(nri,'')=@nri and isnull(serief,'')=@serief and isnull(nrf,'')=@nrf
	if @subtip='A2' --and @codmeniu='DT2'
		delete from d394 
			where rand_decl=@cdecl and isnull(seriei,'')=@seriei and isnull(nri,0)=@nri and isnull(tip,0)=@tipf and data=dbo.eom(@data)
	if @subtip='I6' --and @codmeniu='DT6'
		delete from d394 
			where rand_decl=@randdecl and isnull(cota_tva,0)=@cota_tva and data=dbo.eom(@data)
	if @subtip='I7' --and @codmeniu='DT7'
		delete from d394 
			where rand_decl=@randdecl and isnull(denumire,'')=@activitate and isnull(cota_tva,0)=@cota_tva and data=dbo.eom(@data)

	set @parXml=(select @codMeniu as codMeniu, @data as datalunii, @subtip as subtip, 10 as expandare for xml raw)
	exec wIaDateD394 @sesiune=@sesiune, @parxml=@parXml

end
