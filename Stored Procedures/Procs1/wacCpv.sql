--***
create procedure wacCpv (@sesiune varchar(50)=null, @parxml xml=null)
	--> autocomplete de coduri cpv
as
declare @eroare varchar(4000)
select @eroare=null
begin try

	declare @searchText varchar(1000), @denumire varchar(1000), @cod varchar(1000), @cusearchText bit
	select @searchText = isnull(@parXML.value('(/row/@searchText)[1]','varchar(20)'),'')
	
	select @cusearchText=(case when @searchText='' then 0 else 1 end)
		,@denumire='%'+replace(@searchtext,' ','%')+'%'
		,@cod=replace(@searchtext,' ','%')+'%'

	select top 100 rtrim(c.cod) cod, rtrim(c.denumire) denumire from cpv c
		where
			(@cusearchText=0 or c.denumire like @denumire or c.cod like @cod)
	for xml raw
end try
begin catch
	set @eroare=ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
end catch

if @eroare is not null raiserror(@eroare,16,1)
