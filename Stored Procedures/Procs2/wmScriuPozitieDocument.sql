
CREATE procedure wmScriuPozitieDocument @sesiune varchar(50), @parXML xml
as

	declare
		@numar varchar(20), @tip varchar(2), @data datetime, @cod varchar(20), @cantitate decimal(15,2), @gestiune varchar(20), @lm varchar(20),
		@utilizator varchar(100),@update bit, @numarpozitie int, @tert varchar(20),@gestiune_primitoare varchar(20),
		@doc XML


	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator OUTPUT
	select 
		@numar=@parXML.value('(/*/@numar)[1]','varchar(20)'),
		@data=@parXML.value('(/*/@data)[1]','datetime'),
		@tip=@parXML.value('(/*/@tip)[1]','varchar(2)'),
		@cod=@parXML.value('(/*/@cod)[1]','varchar(20)'),
		@tert=@parXML.value('(/*/@tert)[1]','varchar(20)'),
		@numarpozitie=@parXML.value('(/*/@numarpozitie)[1]','int'),
		@cantitate=@parXML.value('(/*/@cantitate)[1]','decimal(15,2)'),
		@update=ISNULL(@parXML.value('(/*/@update)[1]','bit'),0),
		@gestiune = @parXML.value('(/*/@gestiune)[1]','varchar(20)'),
		@gestiune_primitoare = @parXML.value('(/*/@gestiune_primitoare)[1]','varchar(20)')



	set @doc=
	(
		select 
			@tip tip, @numar numar, convert(varchar(10),@data,101) data, '1' subunitate, @lm lm, @gestiune gestiune,'1' fara_luare_date,@update [update],
			@tert tert,@gestiune_primitoare gestprim,
			(
				SELECT
					@cod cod, @cantitate cantitate, @update [update], @numarpozitie numarpozitie, 0 as pvaluta
				for xml raw, TYPE
			)
		for xml raw
	)

	exec wScriuPozdoc @sesiune=@sesiune, @parXML=@doc

	select 'back(1)' as actiune
	for xml RAW, ROOT('Mesaje')