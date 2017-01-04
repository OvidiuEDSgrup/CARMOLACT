	
create procedure wmScriuAntetDocument @sesiune varchar(50), @parXML xml 
as
begin try
	declare 
		@gestiune varchar(20), @numar varchar(20),@lm varchar(20), @data datetime, @utilizator varchar(100), @fXML xml, @tip varchar(2),
		@gestiune_primitoare varchar(20), @tert varchar(20), @aviznefacturat bit, @eroare varchar(4000)
	
	
	SELECT 
		@tip=@parXML.value('(/*/@tip)[1]','varchar(2)'),
		@numar=@parXML.value('(/*/@numar)[1]','varchar(20)'),	
		@data=convert(datetime,isnull(@parXML.value('(/*/@data)[1]','varchar(10)'),CONVERT(char(10),getdate(),101))),
		@gestiune =@parXML.value('(/*/@gestiune)[1]','varchar(20)'),
		@lm=@parXML.value('(/*/@lm)[1]','varchar(20)'),
		@tert=@parXML.value('(/*/@tert)[1]','varchar(20)'),
		@aviznefacturat=@parXML.value('(/*/@tip_aviz)[1]','bit'),
		@gestiune_primitoare=@parXML.value('(/*/@gestiune_primitoare)[1]','varchar(20)')	

	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator OUTPUT

	if @numar is null
	begin
		set @fXML=(select @tip as tip, @utilizator utilizator, @lm lm  for xml RAW)

		exec wIauNrDocFiscale @parXML=@fXML, @Numar=@numar OUTPUT

		INSERT INTO doc(
			Subunitate, Tip, Numar, Cod_gestiune, Data, Cod_tert, Factura, Contractul, Loc_munca, Comanda, Gestiune_primitoare, Valuta, Curs, Valoare,
			Tva_11, Tva_22, Valoare_valuta, Cota_TVA, Discount_p, Discount_suma, Pro_forma, Tip_miscare, Numar_DVI, Cont_factura, Data_facturii,
			Data_scadentei, Jurnal, Numar_pozitii, Stare, detalii )

		select 
			'1', @tip,@numar, isnull(@gestiune,''),@data,isnull(@tert,''),'','',isnull(@lm,''),'',ISNULL(@gestiune_primitoare,''),'',0,0,0,0,0,1,0,0,0,(CASE when @tip in ('PP','RM') then 'I' when @tip in ('AP','AS','TE','CM') then 'E' end),
			'','',@data,@data,'',0,0,NULL
	end	
	else
	begin
		-- de tratat update si pe pozdoc daca se doreste - de discutat
		-- momentan nu las modificare antet daca sunt pozitii operate
		if exists (select * from pozdoc p where Subunitate='1' and tip=@tip and Numar=@numar and data=@data)
			raiserror('Nu se poate modifica antetul daca exista pozitii pe document!', 16, 1)
			
		update doc
			set Cod_gestiune= ISNULL(@gestiune,Cod_gestiune), 
				Cod_tert = ISNULL(@tert, Cod_tert),
				Loc_munca = ISNULL(@lm, Loc_munca),
				Gestiune_primitoare = ISNULL(@gestiune_primitoare, Gestiune_primitoare)
		where Subunitate='1' and tip=@tip and Numar=@numar and data=@data
		and (Cod_gestiune<>@gestiune or Cod_tert<>@tert or Loc_munca<>@lm or Gestiune_primitoare<>@gestiune_primitoare)
	end
	
	select 
		@numar numar, @data data
	for xml raw('atribute'),root('Mesaje')

	select 'back(1)' as actiune
	for xml raw, ROOT('Mesaje')

end try
begin catch
	set @eroare=ERROR_MESSAGE() + ' (wmScriuAntetDocument)'
	raiserror(@eroare, 16, 1) 
end catch