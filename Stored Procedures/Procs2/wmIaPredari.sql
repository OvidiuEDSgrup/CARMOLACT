	
create procedure wmIaPredari @sesiune varchar(50), @parXML xml as
begin try
	declare
		@actiune_adaugare xml, @lista_predari xml, @gestiune_filtru varchar(20), @datajos datetime, @datasus datetime, @lm_filtru varchar(20),
		@utilizator varchar(100), @search varchar(200), @nrGestProp int, @nrLmProp int, @msgEroare varchar(4000)

	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator OUTPUT
	
	declare @gestProp table(gest varchar(50))
	insert into @gestProp(gest)
	select rtrim(p.Valoare)
	from proprietati p
	where p.Tip='UTILIZATOR' and p.Tip='GESTIUNE' and p.Cod=@utilizator and p.Valoare<>''
	set @nrGestProp = isnull((select count(*) from @gestProp),0)
	
	declare @lmProp table(lm varchar(50))
	insert into @lmProp(lm)
	select rtrim(p.Valoare)
	from proprietati p
	where p.Tip='UTILIZATOR' and p.Tip='LOCMUNCA' and p.Cod=@utilizator and p.Valoare<>''
	set @nrLmProp = isnull((select count(*) from @lmProp),0)
	
	
	
	select 
		/* ar trebui filtrate cu join, pot fi mai multe */
		@gestiune_filtru = rtrim(dbo.wfProprietateUtilizator('GESTIUNE', @utilizator)),
		@lm_filtru=rtrim(dbo.wfProprietateUtilizator('LOCMUNCA', @utilizator)),
		@datasus=GETDATE(), @datajos=DATEADD(DAY, -100, GETDATE()),
		@search='%'+ISNULL(@parXML.value('(/*/@searchText)[1]','varchar(200)'),'%')+'%'

	set @actiune_adaugare=
	(
		select 
			'adaugare' cod, 'Adauga predare noua' denumire, '0x0000ff' as culoare,'C' as tipdetalii, 
			'wmDetaliiDocument' procdetalii,'assets/Imagini/Meniu/AdaugProdus32.png' as poza
		for xml raw, type
	)
	set @lista_predari=
	(
		SELECT TOP 25
			'Predarea '+RTRIM(d.Numar)+ ' - '+ convert(varchar(10), d.data, 103) as denumire, (case when @nrGestProp<>1 then RTRIM(g.Denumire_gestiune)+ ' - ' else '' end) + convert(varchar(10),d.Numar_pozitii) + ' pozitii' info,
			RTRIM(d.Numar) numar, CONVERT(varchar(10), d.Data,101) data, '1' as toateAtr,
			'C' as tipdetalii, 'wmDetaliiDocument' as procdetalii, RTRIM(d.cod_gestiune) gestiune, rtrim(g.Denumire_gestiune) dengestiune
		from doc d 
		LEFT JOIN gestiuni g ON g.Cod_gestiune=d.Cod_gestiune
		left join @gestProp gp on gp.gest=d.Cod_gestiune
		left join @lmProp l on l.lm=d.Loc_munca
		where d.Subunitate='1' and d.data between @datajos and @datasus and d.Tip='PP'
		and (@nrGestProp=0 or gp.gest is not null)
		and (@nrLmProp=0 or l.lm is not null)
		and numar LIKE @search
		order BY data desc, numar desc
		for xml raw, TYPE
	)
	
	select 
		'PP' as tip, 'wmScriuAntetDocument' as proc_scriere_antet, 'D1' as form_antet, 'MP' as form_pozitie, 'wmIaPredari' as detalii
	for xml RAW('atribute'),ROOT('Mesaje')
	
	select '1' as _areSearch
	for xml RAW, root('Mesaje')

	select @actiune_adaugare, @lista_predari
	for xml PATH('Date')

end try
begin catch
	set @msgEroare=ERROR_MESSAGE()+ ' (wmIaPredari)'
	raiserror (@msgEroare, 11, 1)
end catch
