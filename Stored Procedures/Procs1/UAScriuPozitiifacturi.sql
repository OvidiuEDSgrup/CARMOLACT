
--***
create procedure UAScriuPozitiifacturi(@parid int ,@parnrpoz int output,@parcod char(20),@parcantitate int,@partarif float,@parlm char(9),@parcomanda char(20),@paruser char(20))
as
begin try
	declare @cota_tva int,@mesaj varchar(200),@nrpozitie int,@comanda char(20),@exista int,@tip_tva int
	set @cota_tva=isnull((select cota_tva from NomenclAbon where cod=@parcod),-1)
	set @tip_tva=isnull((select tip_tva from antetfactabon where id_factura=@parid),0)
	
	if @cota_tva=-1
	begin
		raiserror('Cod inexistent!',11,1)
		return -1
	end	
	else
		set @comanda=isnull((select comanda from NomenclAbon where cod=@parcod),'')
	if @tip_tva=1
		set @cota_tva=0
	if @parlm=''
		set @parlm=(select c.Loc_de_munca from uacon  c inner join antetfactabon f on f.id_contract=c.id_contract and f.Id_factura=@parid)
	set @exista=(select COUNT(cod) from lm where cod=@parlm)
	if @exista=0
	begin
		raiserror('Loc de munca inexistent!',11,1)
		return -1
	end	
	if @parnrpoz=0
	begin
		set @nrpozitie=isnull((select MAX(nr_pozitie) from PozitiiFactAbon where id_factura=@parid),0)+1
		insert into PozitiiFactAbon(Id_factura,nr_pozitie,cod,cantitate,tarif,cota_tva,Loc_de_munca,Comanda,utilizator,data_operarii,Val1,val2,Alfa1,Alfa2,data1)
		values(@parid,@nrpozitie,@parcod,@parcantitate,@partarif,@cota_tva,@parlm,@comanda,@paruser,GETDATE(),0,0,'','','1901-01-01')	
	end
	else
	begin
		update PozitiiFactAbon
		set cod=@parcod,Cantitate=@parcantitate,tarif=@partarif,cota_tva=@cota_tva,Loc_de_munca=@parlm,Comanda=@comanda where id_factura=@parid and nr_pozitie=@parnrpoz
	end
end try
begin catch
	set @mesaj = ERROR_MESSAGE()
	raiserror(@mesaj, 11, 1)	
end catch	
--select * from pozitiifactabon