--***

create procedure wFramePopulezWebConfigMeniu(@sesiune varchar(50), @parXML XML)
as
begin
	declare @TipMacheta varchar(10), @Meniu varchar(10), @Tip varchar(10), @Subtip varchar(10), @update varchar(10)
	select	@TipMacheta=isnull(@parXML.value('(row/@TipMacheta)[1]','varchar(10)'),''),
			@Meniu=isnull(@parXML.value('(row/@Meniu)[1]','varchar(10)'),''),
			@Tip=isnull(@parXML.value('(row/@Tip)[1]','varchar(10)'),''),
			@Subtip=isnull(@parXML.value('(row/@Subtip)[1]','varchar(10)'),''),
			@update=isnull(@parXML.value('(row/@update)[1]','varchar(10)'),'')
	
	if @update=1
	select '1' as _tipmod, w.Nume NumeMeniu, w.Modul, w.Id, w.idParinte, 
		(select max(wp.Nume) from webConfigMeniu wp where wp.Id=w.idParinte) as MeniuParinte, w.Icoana, wt.*
			from webconfigmeniu w
				left join webconfigtipuri wt on 
					ISNULL(w.Meniu,'')=isnull(wt.Meniu,'') and isnull(w.TipMacheta,'')=isnull(wt.TipMacheta,'')
		where isnull(wt.Tip,'')=@Tip and isnull(wt.Subtip,'')=@Subtip and w.TipMacheta=@TipMacheta and isnull(w.Meniu,'')=@Meniu
	union all
	select '1' as _tipmod, '<Fara meniu>', '', '', '', '', '', wt.*
			from webconfigtipuri wt where not exists (select 1 from webConfigMeniu w where w.meniu=wt.meniu and w.TipMacheta=wt.TipMacheta)
				and isnull(wt.Tip,'')=@Tip and isnull(wt.Subtip,'')=@Subtip and wt.TipMacheta=@TipMacheta and isnull(wt.Meniu,'')=@Meniu
	for xml raw
end