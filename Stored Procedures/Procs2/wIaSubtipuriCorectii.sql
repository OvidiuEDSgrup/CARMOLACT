--***
Create procedure wIaSubtipuriCorectii @sesiune varchar(50), @parXML xml
as
begin
	Declare @filtruSubtipCor varchar(13), @filtruDenumireSubtip varchar(30), @filtruTipCor varchar(100), @filtruDenumireTipcor varchar(30)
 
	set @filtruSubtipCor = isnull(@parXML.value('(/row/@f_subtipcor)[1]','varchar(13)'),'')
	set @filtruDenumireSubtip = isnull(@parXML.value('(/row/@f_densubtipcor)[1]','varchar(30)'),'')
	set @filtruTipCor = isnull(@parXML.value('(/row/@f_tipcor)[1]','varchar(13)'),'')
	set @filtruDenumireTipcor = isnull(@parXML.value('(/row/@f_dentipcor)[1]','varchar(30)'),'')

	set @filtruDenumireSubtip=Replace(@filtruDenumireSubtip,' ','%')
	set @filtruDenumireTipcor=Replace(@filtruDenumireTipcor,' ','%')
  
	select top 100 rtrim(s.Subtip) as subtipcor, rtrim(s.Denumire) as densubtipcor, 
		rtrim(t.Tip_corectie_venit) as tipcor, rtrim(t.Denumire) as dentipcor
	from subtipcor s
		left outer join tipcor t on t.Tip_corectie_venit=s.Tip_corectie_venit
	where s.Subtip like @filtruSubtipCor+'%' and s.Denumire like '%'+@filtruDenumireSubtip+'%' 
		and t.Tip_corectie_venit like @filtruTipCor+'%' and t.Denumire like '%'+@filtruDenumireTipcor+'%' 
	order by t.Tip_corectie_venit, s.subtip
	for xml raw
end
