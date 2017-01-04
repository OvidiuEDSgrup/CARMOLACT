--***
Create procedure scriuDeclaratii
	@cod varchar(20), 
	@tip varchar(1),	-- TipDeclaratie=0 Initiala, 1 Rectificativa
	@data datetime,	
	@detalii xml=null, 
	@continut xml 
as  
Begin try
	declare @utilizator varchar(20), @lista_lm int, @multiFirma int, @lmUtilizator varchar(9)
	set @utilizator=dbo.fIaUtilizator(null)

	set @lista_lm=dbo.f_areLMFiltru(@utilizator)
	set @multiFirma=0
	if exists (select * from sysobjects where name ='par' and xtype='V')
		set @multiFirma=1
	if @multiFirma=1 
	begin
		select @lmUtilizator=isnull(min(Cod),'') from LMfiltrare where utilizator=@utilizator and cod in (select cod from lm where Nivel=1)
	end

	set @tip=(case when @tip='0' then '' when @tip='1' then 'R' else @tip end)

	if exists (select 1 from declaratii where cod=@cod and tip=@tip and data=@data 
			and (cod not like 'INTRASTAT_%' or detalii.value('/row[1]/@flux', 'varchar(1)')=@detalii.value('/row[1]/@flux', 'varchar(1)')))
		delete from declaratii where cod=@cod and tip=@tip and data=@data and (@multiFirma=0 or loc_de_munca=@lmUtilizator)

	insert into declaratii (loc_de_munca, cod, tip, data, utilizator, data_operarii, detalii, continut)
	select @lmUtilizator, @cod, @tip, @data, @utilizator, getdate(), @detalii, @continut
End try

begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura scriuDeclaratii (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
