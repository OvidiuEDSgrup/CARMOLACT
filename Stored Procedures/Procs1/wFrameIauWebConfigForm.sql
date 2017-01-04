--***

create procedure wFrameIauWebConfigForm(@sesiune varchar(50), @parXML XML)
as

declare @eroare varchar(1000)
begin try
	declare @TipMacheta varchar(2), @Meniu varchar(2), @Tip varchar(2), @Subtip varchar(2), @Ordine int, @nivel int
	select	@TipMacheta=isnull(@parXML.value('(/row/@TipMacheta)[1]','varchar(2)'),''),
			@Meniu=isnull(@parXML.value('(/row/@Meniu)[1]','varchar(2)'),''),
			@Tip=isnull(@parXML.value('(/row/@Tip)[1]','varchar(2)'),''),
			@Subtip=isnull(@parXML.value('(/row/@Subtip)[1]','varchar(2)'),''),
			@Ordine=isnull(@parXML.value('(/row/@Ordine)[1]','int'),-1000),
			@nivel=isnull(@parXML.value('(/row/@nivel)[1]','int'),-1000)
	--TipMacheta="D" Meniu="CO" Tip="BF" Subtip="GT" Ordine="1"
	
	select 
	--IdUtilizator, TipMacheta, Meniu, Tip, Subtip, 
	  Ordine, Nume, TipObiect, DataField, LabelField, Latime, Vizibil, Modificabil, ProcSQL, ListaValori, ListaEtichete, 
		Initializare, Prompt, Procesare, Tooltip, 
		(case when Vizibil=0 then '#888888' else '#000000' end) culoare
	from webConfigform w
	where	w.TipMacheta=@TipMacheta and w.Meniu=@Meniu and 
			isnull(rtrim(w.Tip),'')=@Tip and 
			(@subtip='' and isnull(w.subtip,'')='' or @subtip<>'' and isnull(rtrim(w.Subtip),'')=@Subtip)
	order by ordine
	for xml raw 
end try
begin catch
	set @eroare='wFrameIauWebConfigFormC (linia '+convert(varchar(20),ERROR_LINE())+'):'+char(10)+
				ERROR_MESSAGE()
	raiserror(@eroare,16,1)
end catch