--***
create procedure wStergPozDecImpl @sesiune varchar(50), @parXML xml
as

declare @decont varchar(20), @data datetime, @marca varchar(20), @Sub char(9), @mesaj varchar(1000),
		@userAsis varchar(20), @an_impl int, @luna_impl int, @mod_impl int, @_cautare varchar(100)		

begin try
	begin transaction
		if exists (select 1 from sysobjects where [type]='P' and [name]='wStergPozDecImplSP')
			exec wStergPozDecImplSP @sesiune, @parXML output

		select
			@decont = isnull(@parXML.value('(/row/row/@decont)[1]','varchar(20)'),''),
			@marca = isnull(@parXML.value('(/row/row/@marca)[1]','varchar(20)'),''),	
			@data=ISNULL(@parXML.value('(/row/row/@data)[1]', 'datetime'), '1901-01-01'),
			@_cautare=isnull(@parXML.value('(/row/@_cautare)[1]', 'varchar(50)'), '')
			
		EXEC wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS OUTPUT
	
		exec luare_date_par 'GE', 'SUBPRO', 0, 0, @sub output	
		exec luare_date_par 'GE', 'ANULIMPL', 0, @an_impl output, ''
		exec luare_date_par 'GE', 'LUNAIMPL', 0, @luna_impl output, ''
		exec luare_date_par 'GE', 'IMPLEMENT', @mod_impl output, 0, ''
	
		if @mod_impl=0
			raiserror('Stergerea poate fi efectuata doar daca sunteti in mod implementare!!',11,1)	
	
		delete from decimpl where Subunitate=@Sub and tip='T' and Decont=@decont and Marca=@Marca
		
		declare @docXML xml
		set @docXML='<row _cautare="'+isnull(@_cautare,'')+'"/>'
		exec wIaPozDecImpl @sesiune=@sesiune, @parXML=@docXML

	commit transaction
end try
begin catch
	ROLLBACK TRAN	
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror(@mesaj, 11, 1)
end catch
