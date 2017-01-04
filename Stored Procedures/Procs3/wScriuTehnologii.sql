


CREATE procedure  [dbo].[wScriuTehnologii]  @sesiune varchar(50), @parXML XML
as
declare @cod_tehn varchar(20), @denumire varchar(50), @denNou varchar(50)

	select	@cod_tehn = rtrim(isnull(@parXML.value('(/parametri/@cod_tehn)[1]', 'varchar(20)'), '')),
			@denNou = rtrim(isnull(@parXML.value('(/parametri/@denNou)[1]', 'varchar(50)'), '')),
			@denumire = rtrim(isnull(@parXML.value('(/parametri/@denumire)[1]', 'varchar(50)'), ''))

UPDATE tehnologii SET Denumire=@denNou WHERE COD=@cod_tehn AND Denumire=@denumire



