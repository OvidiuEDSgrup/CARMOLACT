
CREATE PROCEDURE wOPAlocarePlajaDocumente_p @sesiune VARCHAR(50), @parXML XML
AS
BEGIN TRY
	declare
		@datajos datetime, @datasus datetime
	
	select
		@datajos = isnull(@parXML.value('(/*/@datajos)[1]','datetime'),@parXML.value('(/*/*/@datajos)[1]','datetime')),
		@datasus = isnull(@parXML.value('(/*/@datasus)[1]','datetime'),@parXML.value('(/*/*/@datasus)[1]','datetime'))
	
	select convert(varchar(10),@datajos,101) as datajos, convert(varchar(10),@datasus,101) as datasus
	for xml raw
		
END TRY
BEGIN CATCH
	declare
		@mesaj varchar(500)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
END CATCH
