--***
Create PROCEDURE wScriuDocFiltruStocSpargereSP @sesiune VARCHAR(50), @parXML XML
	AS
BEGIN TRY
--/*
	if ISNULL(@parXML.value('(//@doarCuStoc)[1]', 'bit'), 0)=1
		delete st
		from #stoctotal st join #pozd pd on st.cod=pd.cod and st.Cod_gestiune=pd.gestiune 
		where Stoc_initial=100000000 and Intrari=100000000 and Iesiri=0 and Stoc=100000000
			and (tip_miscare='E' and cantitate>0 or tip_miscare='I' and cantitate<0 or tip='TE' and cantitate<0)
--*/	
	alter table #stoctotal alter column stoctotal decimal(17,5)
	alter table #pozd alter column cumulat decimal(17,5)

end try
begin catch
	declare @mesaj varchar(2000)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
end catch
