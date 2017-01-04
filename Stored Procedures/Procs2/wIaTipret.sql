--***
Create procedure wIaTipret @sesiune varchar(50), @parXML xml
as
begin
	Declare @filtruSubtipRet varchar(13), @filtruDenumireSubtip varchar(30), @filtruTipRet varchar(100), @filtruDenumireTipret varchar(30)
 
	set @filtruSubtipRet = isnull(@parXML.value('(/row/@f_subtipret)[1]','varchar(13)'),'')
	set @filtruDenumireSubtip = isnull(@parXML.value('(/row/@f_densubtipret)[1]','varchar(30)'),'')
	set @filtruTipRet = isnull(@parXML.value('(/row/@f_tipret)[1]','varchar(13)'),'')
	set @filtruDenumireTipret = isnull(@parXML.value('(/row/@f_dentipret)[1]','varchar(30)'),'')

	set @filtruDenumireSubtip=Replace(@filtruDenumireSubtip,' ','%')
	set @filtruDenumireTipret=Replace(@filtruDenumireTipret,' ','%')
  
	select top 100 rtrim(tr.Subtip) as subtipret, rtrim(tr.Denumire) as densubtipret, 
		rtrim(tr.Tip_retinere) as tipret, rtrim(ft.Denumire_tip) as dentipret
	from tipret tr
		left outer join fTip_retineri (1) ft on ft.Tip_retinere=tr.Tip_retinere
	where tr.Subtip like @filtruSubtipRet+'%' and tr.Denumire like '%'+@filtruDenumireSubtip+'%' 
		and tr.Tip_retinere like @filtruTipRet+'%' and ft.Denumire_tip like '%'+@filtruDenumireTipret+'%' 
	order by tr.subtip, tr.Tip_retinere
	for xml raw
end
