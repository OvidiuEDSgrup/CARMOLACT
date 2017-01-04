--***

create procedure wFrameIauWebConfigFiltre(@sesiune varchar(50), @parXML XML)
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
	--IdUtilizator, TipMacheta, Meniu, Tip, 
		Ordine, Vizibil, TipObiect, Descriere, Prompt1, DataField1, Interval, Prompt2, DataField2,
		isnull(rtrim(w.Tip),'') as tip, (case when Vizibil=0 then '#888888' else '#000000' end) culoare
	from webConfigFiltre w
	where	w.TipMacheta=@TipMacheta and w.Meniu=@Meniu and 
			(w.TipMacheta='D' and isnull(rtrim(w.Tip),'')=@Tip or 
				w.TipMacheta<>'D' and isnull(rtrim(w.Tip),'')=@Meniu and (@tip='' or @tip=@meniu)) and
			@Subtip='' --and (@nivel=1 or isnull(w.Ordine,-1000)=@Ordine)
	order by Ordine
	for xml raw 
end try
begin catch
	set @eroare='wFrameIauWebConfigFiltreC (linia '+convert(varchar(20),ERROR_LINE())+'):'+char(10)+
				ERROR_MESSAGE()
	raiserror(@eroare,16,1)
end catch