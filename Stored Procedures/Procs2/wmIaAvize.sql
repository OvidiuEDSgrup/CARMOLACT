	
create procedure wmIaAvize @sesiune varchar(50), @parXML xml as

	declare
		@actiune_adaugare xml, @lista_predari xml, @gestiune_filtru varchar(20), @datajos datetime, @datasus datetime, @lm_filtru varchar(20),
		@utilizator varchar(100), @search varchar(200)


	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator OUTPUT
	select 
		@gestiune_filtru = rtrim(dbo.wfProprietateUtilizator('GESTIUNE', @utilizator)),
		@lm_filtru=rtrim(dbo.wfProprietateUtilizator('LOCMUNCA', @utilizator)),
		@datasus=GETDATE(), @datajos=DATEADD(DAY, -100, GETDATE()),
		@search='%'+ISNULL(@parXML.value('(/*/@searchText)[1]','varchar(200)'),'%')+'%'

	set @actiune_adaugare=
	(
		select 
			'adaugare' cod, 'Adauga' denumire, '0x0000ff' as culoare,'C' as tipdetalii, 
			'wmDetaliiDocument' procdetalii,'assets/Imagini/Meniu/AdaugProdus32.png' as poza
		for xml raw, type
	)
	set @lista_predari=
	(
		select TOP 25
			'Numar '+RTRIM(Numar) as denumire, 'Data '+ convert(varchar(10), data, 103) + ' - ' + convert(varchar(10),Numar_pozitii) + ' pozitii' info,
			RTRIM(Numar) numar, CONVERT(varchar(10), Data,101) data, '1' as toateAtr,
			'C' as tipdetalii, 'wmDetaliiDocument' as procdetalii, rtrim(Cod_tert) tert
		from doc where Cod_gestiune=@gestiune_filtru and Loc_munca=@lm_filtru and data between @datajos and @datasus and Tip='AP'
				and numar LIKE @search
		order BY data desc
		for xml raw, TYPE			
	)
	
	select 
		'AP' as tip, 'wmScriuAntetDocument' as proc_scriere_antet, 'D2' as form_antet, 'MA' as form_pozitie
	for xml RAW('atribute'),ROOT('Mesaje')

		
	select '1' as _areSearch
	for xml RAW, root('Mesaje')

	select @actiune_adaugare, @lista_predari
	for xml PATH('Date')
