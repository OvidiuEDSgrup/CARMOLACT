/* operatie pt. modificare date pozitie in macheta de concedii medicale, Pentru inceput vom trata diverse campuri ce se vor scrie in detalii */
create procedure wOPModificareDateConmed (@sesiune varchar(50), @parXML xml) 
as     
declare @utilizator varchar(10), @Data datetime, @marca varchar(6), @Data_inceput datetime, @mesaj varchar(1000), @detalii xml
begin try
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output

	select	@data = isnull(@parXML.value('(/parametri/@data)[1]','datetime'),''),
			@marca = isnull(@parXML.value('(/parametri/@marca)[1]', 'varchar(6)'),''),	
			@data_inceput = isnull(@parXML.value('(/parametri/@datainceput)[1]', 'datetime'),''),
			@detalii = @parXML.query('/parametri[1]/detalii/row')

	update conmed set detalii = @detalii
	where data=@data and marca=@marca and data_inceput=@Data_inceput
  
end try

begin catch
	set @mesaj = ERROR_MESSAGE() + ' (' + object_name(@@PROCID) + ')'
	raiserror(@mesaj, 11, 1)	
end catch