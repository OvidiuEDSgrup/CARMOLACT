--***
create procedure wStergCoduriBancare @sesiune varchar(50), @parXML XML  
--> procedura de scriere/modificare date pentru macheta de banci (ASiSRia --> Configurari --> Banci (meniu banci, nu cel vechi, B))
as  

declare @eroare varchar(4000)
select @eroare=''
BEGIN TRY
	
	declare @cod varchar(200), @tert varchar(100), @dentert varchar(2000), @in_detaliereTerti bit
	select @cod=@parxml.value('(row/@cod)[1]','varchar(200)')
			
	--> validari
		select	@tert=rtrim(t.tert)
				,@dentert=rtrim(t.denumire)
				,@in_detaliereTerti=(case when substring(replace(t.cont_in_banca,' ',''),5,4)=@cod then 0 else 1 end)
			from terti t
			where substring(replace(t.cont_in_banca,' ',''),5,4)=@cod
				or exists (select 1 from contbanci c where c.tert=t.tert and substring(replace(c.cont_in_banca,' ',''),5,4)=@cod)
		select @tert
		if @tert is not null
		select @eroare='Tertul " '+isnull(@tert,'')+' " cu denumirea " '+isnull(@dentert,'')+' " are configurat '+(case when isnull(@in_detaliereterti,1)=1 then 'in detalierea "Conturi in banca" din' else 'in' end)
			+' macheta terti un cont de pe banca de sters!'
			+char(10)+'Nu se pot sterge bancile ale caror conturi sunt configurate pe terti!'
		if len(@eroare)>0 raiserror(@eroare,16,1)
	
	--> stergere
		delete c from coduribancare c where c.cod=@cod

END TRY
BEGIN CATCH
	SET @eroare = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	RAISERROR(@eroare, 11, 1)
END CATCH
