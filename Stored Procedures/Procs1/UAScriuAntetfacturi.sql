
--***
create procedure UAScriuAntetfacturi(@partip char(2),@parserie char(20),@parcontract int,
@pardata datetime,@pardatascad datetime,@parTipTVA int,@pardatajos datetime,@pardatasus datetime,@paruser char(20),
@parlm char(9),@parid int output,@parNrFact char(8) output,@parContract_strict bit)
as
declare @nrtemp int,@existanumar int,@mesaj varchar(200),@lm char(9)
begin try
	if @partip not in ('FM','FI','FA','AV','AP','IM')
	begin
		raiserror('Tip de factura incorect!',11,1)
		return -1
	end	
	set @existanumar=(select COUNT(id_contract) from UACon where id_contract=@parcontract)
	if @existanumar=0 
	begin
		raiserror('Contract inexistent!',11,1)
		return -1
	end	
	if @parNrFact=''
	begin
		set @nrtemp=0
		exec wIauNrDocUA 'UF',@paruser,@parlm,@nrtemp output
		if @nrtemp>99999999 or @nrtemp=0
		begin
			raiserror('Eroare la generare numar factura!',11,1)
			return -1
		end
		else
			set @parNrFact=(CAST(@nrtemp as CHAR(8)))
	end
	set @existanumar=(select COUNT(factura) from FactAbon where factura=@parNrFact and data between dbo.BOY(@pardata) and dbo.EOY(@pardata))
	if @existanumar>0
	begin
		set @mesaj='Exista deja factura cu numarul generat:'+rtrim(@parnrfact)+'!Verificati plaja!'
		raiserror(@mesaj,11,1)
		return -1
	end		
	set @lm=(select loc_de_munca from uacon where Id_contract=@parcontract)
	
	insert into AntetFactAbon(factura,tip,serie,id_contract,loc_de_munca,data,data_scadentei,tip_tva,Perioada_inceput,Perioada_sfarsit,
	stare,Contract_strict,Utilizator,Data_Operarii,Val1,Val2,Val3,Alfa1,Alfa2,Alfa3,Data1,data2) 
	values(@parNrFact,@partip,'',@parcontract,@lm,@pardata,@pardatascad,@parTipTVA,@pardatajos,@pardatasus,'0',@parContract_strict,@paruser,GETDATE(),
	0,0,0,'','','','1901-01-01','1901-01-01')
	set @parid=(select id_factura from AntetFactAbon where Factura=@parNrFact and id_contract=@parcontract and data=@pardata)
end try
begin catch
	set @mesaj = ERROR_MESSAGE()
	raiserror(@mesaj, 11, 1)	
end catch
--select * from antetfactabon

