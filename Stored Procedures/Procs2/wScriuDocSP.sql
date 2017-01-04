--***
Create PROCEDURE wScriuDocSP @sesiune VARCHAR(50), @parXML XML output
	AS
BEGIN TRY

	if ISNULL(@parXML.value('(//@doarCuStoc)[1]', 'bit'), 0)=1
	begin
		delete d
		from #documente d 
		where (tip_miscare='E' and cantitate>0 or tip='TE' and cantitate<0 or tip_miscare='I' and cantitate<0) and isnull(ptUpdate,0)=0
			and isnull(cod_intrare,'')='' 
		
		delete d
		from #documente d left join stocuri s on s.Subunitate='1' and s.Cod=d.cod and s.Cod_gestiune=d.gestiune and s.Cod_intrare=d.cod_intrare
		where (tip_miscare='E' and cantitate>0 or tip_miscare='I' and cantitate<0) and isnull(ptUpdate,0)=0
			and isnull(s.cod_intrare,'')='' 
		
		delete d
		from #documente d left join stocuri s on s.Subunitate='1' and s.Cod=d.cod and s.Cod_gestiune=d.gestiune_primitoare and s.Cod_intrare=d.codiPrim
		where (tip='TE' and cantitate<0) and isnull(ptUpdate,0)=0
			and isnull(s.cod_intrare,'')=''  
	end
	
end try
begin catch
	declare @mesaj varchar(2000)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
end catch
