--***

create procedure wFrameIauWebConfigGrid(@sesiune varchar(50), @parXML XML)
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
	select @TipMacheta, @meniu, @Tip
	select 
	--IdUtilizator, TipMacheta, Meniu, Tip, Subtip, 
	InPozitii, NumeCol, DataField, TipObiect, Latime, Ordine, Vizibil
	from webConfigGrid w
	where	@subtip='' and w.TipMacheta=@TipMacheta and w.Meniu=@Meniu 
			and isnull(w.tip,'')=@Tip
			and rtrim(isnull(w.subtip,''))='' and (@TipMacheta<>'D' or w.InPozitii=0)
	for xml raw 
end try
begin catch
	set @eroare='wFrameIauWebConfigGridC (linia '+convert(varchar(20),ERROR_LINE())+'):'+char(10)+
				ERROR_MESSAGE()
	raiserror(@eroare,16,1)
end catch