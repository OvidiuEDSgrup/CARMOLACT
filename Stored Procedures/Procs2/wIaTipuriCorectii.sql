--***
Create procedure wIaTipuriCorectii @sesiune varchar(50), @parXML xml
as
begin
	Declare @filtruTipCor varchar(13), @filtruDenumire varchar(30)
 
	set @filtruTipCor = isnull(@parXML.value('(/row/@f_tipcor)[1]','varchar(13)'),'')
	set @filtruDenumire = isnull(@parXML.value('(/row/@f_denumire)[1]','varchar(30)'),'')

	set @filtrudenumire=Replace(@filtrudenumire,' ','%')    
  
	select top 100 rtrim(Tip_corectie_venit) as tipcor, rtrim(Denumire) as denumire
	from tipcor    
	where Tip_corectie_venit like @filtruTipCor+'%' and Denumire like '%'+@filtruDenumire+'%' 
	order by Tip_corectie_venit
	for xml raw
end