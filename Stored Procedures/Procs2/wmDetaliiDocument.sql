	
create procedure wmDetaliiDocument @sesiune varchar(50), @parXML xml as

if exists(select * from sysobjects where name='wmDetaliiDocumentSP' and type='P')
begin
	exec wmDetaliiDocumentSP @sesiune=@sesiune, @parXML=@parXML
	return 0
end

	declare
		@numar varchar(20), @data datetime,@pozitii_predare xml, @antet_predare xml, @adauga_pozitie xml,@utilizator varchar(100), 
		@tip varchar(2), @form_antet varchar(20), @form_pozitie varchar(20), @proc_scriere_antet varchar(20),
		@gestiune varchar(20), @dengestiune varchar(100), @tert varchar(20), @dentert varchar(100), 
		@gestiune_primitoare varchar(20), @dengestiune_primitoare varchar(100), @lm varchar(20), @denlm varchar(100)


	set @numar=@parXML.value('(/*/@numar)[1]','varchar(20)')
	set @data=convert(datetime,@parXML.value('(/*/@data)[1]','varchar(10)'))
	set @tip=@parXML.value('(/*/@tip)[1]','varchar(2)')

	set @form_antet=@parXML.value('(/*/@form_antet)[1]','varchar(20)')
	set @form_pozitie=@parXML.value('(/*/@form_pozitie)[1]','varchar(20)')
	set @proc_scriere_antet=@parXML.value('(/*/@proc_scriere_antet)[1]','varchar(20)')


	if @numar is not null
		select top 1 
			@gestiune=RTRIM(d.cod_gestiune), 
			@tert=RTRIM(d.cod_tert), @dentert=rtrim(t.denumire),
			@lm=rtrim(loc_munca), 
			@gestiune_primitoare=d.Gestiune_primitoare
		from doc d
		LEFT JOIN terti t on t.tert=d.Cod_tert
		where d.Numar=@numar and d.tip=@tip and d.data=@data and d.Subunitate='1'
	/** Daca se adauga un document sugeram de la utilizator */
	else
	begin
		exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator OUTPUT
		select 
			@gestiune = rtrim(dbo.wfProprietateUtilizator('GESTIUNE', @utilizator)),
			@lm=rtrim(dbo.wfProprietateUtilizator('LOCMUNCA', @utilizator))
	end
		
	select top 1 @denlm= rtrim(Denumire) from lm where Cod=@lm
	select top 1 @dengestiune=RTRIM(denumire_gestiune) from gestiuni where cod_gestiune=@gestiune and Subunitate='1'
	select top 1 @dengestiune_primitoare=RTRIM(denumire_gestiune) from gestiuni where cod_gestiune=@gestiune_primitoare and Subunitate='1'

	set @antet_predare=
	(	
		SELECT
			'adaugare' cod, 'Detalii antet' denumire, '0x0000ff' as culoare,'D' as tipdetalii, 
			@proc_scriere_antet procdetalii,'assets/Imagini/Meniu/Contracte.png' as poza,
			'Nr. '+rtrim(@numar)+ ' - Data '+ convert(varchar(10), @data, 103) info, 
			dbo.f_wmIaForm(@form_antet) as form, '1' as toateAtr, 
			@numar numar, @data data, @tip tip,
			@tert tert, @dentert dentert, 
			@gestiune gestiune, @dengestiune dengestiune, 
			@gestiune_primitoare gestiune_primitoare, @dengestiune_primitoare dengestiune_primitoare, 
			@lm lm, @denlm denlm
		for xml RAW,type
	)

	/** La adaugare document se autoselecteaza informatiile de antet, daca am deja antetul, atunci nu */
	if @numar IS NULL
		select 'autoSelect' as actiune for xml raw, ROOT('Mesaje')

	set @adauga_pozitie=
	(
		select top 1
			'adaugare' cod, 'Adauga pozitie' denumire, '0x0000ff' as culoare,'C' as tipdetalii, 
			'wmAlegCodDocumente' procdetalii,'assets/Imagini/Meniu/AdaugProdus32.png' as poza, 'wmScriuPozitieDocument' proc_detalii_next,
			@form_pozitie as meniu_detalii_next,'1' as toateAtr,
			CONVERT(varchar(10),Numar_pozitii) + ' pozitii' info,
			rtrim(Cod_tert) tert, rtrim(Cod_gestiune) gestiune, rtrim(Loc_munca) lm, rtrim(Gestiune_primitoare) gestiune_primitoare
		from doc where tip=@tip and numar=@numar and data=@data
		for xml raw, type
	)

	set @pozitii_predare=
	(
		SELECT 
			rtrim(n.denumire) as denumire, 'Cantitate '+ convert(varchar(10), convert(decimal(15,2),pd.Cantitate)) + ' - Pret '
				 + CONVERT(varchar(10), convert(decimal(15,2),pd.Pret_de_stoc)) as info,
			RTRIM(pd.cod) as cod, convert(decimal(15,2),pd.Cantitate) cantitate, rtrim(pd.numar) numar, convert(varchar(10), pd.data,101) data,'1' as toateAtr,
			'wmScriuPozitieDocument' procdetalii, 'D' as tipdetalii, dbo.f_wmIaForm(@form_pozitie) as form, '1' as [update], pd.Numar_pozitie numarpozitie
		from pozdoc pd
		JOIN nomencl n on pd.cod=n.cod 
		where pd.tip=@tip and pd.numar=@numar and pd.data=@data and pd.subunitate='1'
		for xml raw, TYPE
	)

	select 
		(CASE @tip when 'PP' THEN 'Predarea ' when 'TE' then 'Transferul ' when 'AP' then 'Avizul ' end)+ rtrim(@numar) as titlu
	for xml RAW,ROOT('Mesaje')
	
	select @antet_predare,@adauga_pozitie, @pozitii_predare
	for xml PATH('Date')