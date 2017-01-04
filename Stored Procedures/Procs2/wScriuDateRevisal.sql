--***
Create procedure wScriuDateRevisal @sesiune varchar(50), @parXML xml output
as

declare @codMeniu varchar(2), @DouaNivele int, @RowPattern varchar(20), @PrefixAtrMarca varchar(3), @AtrMarca varchar(20), 
@tip char(2),@subtip char(2), @ptupdate int, @marca varchar(6), 
@tip_act_identitate varchar(60), @cetatenie varchar(60), @nationalitate varchar(60), @mentiuni varchar(80),
@localitate varchar(6), @data_incheiere_contract datetime, @data_inceput datetime, @numar_contract varchar(20),
@tip_contract varchar(60), @exceptie_data_sfarsit varchar(60), @repartizareTM varchar(60), @intervalreptm varchar(60), @NrOreInterval int, 
@temei_incetare char(60), @text_temei_incetare char(200), @detalii_contract varchar(200), @data_consemnare datetime, 
@mesaj varchar(254), @userasis varchar(20), @grupa_de_munca char(1), @mod_angajare char(1)

set @codMeniu=isnull(@parXML.value('(/row/@codMeniu)[1]','varchar(2)'),'')
select @DouaNivele = @parXML.exist('/row/row'), 
	@RowPattern = '/row' + (case when @DouaNivele=1 then '/row' else '' end), 
	@PrefixAtrMarca = (case when @DouaNivele=1 then '../' else '' end), 
	@AtrMarca = @PrefixAtrMarca + '@marca'

exec wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS output

declare @iDoc int
EXEC sp_xml_preparedocument @iDoc OUTPUT, @parXML
begin try  
	--exec wValidareDateRevisal @sesiune, @parXML

	select @tip=tip, @subtip=subtip, @Marca=Marca, @tip_act_identitate=tip_act_identitate, 
		@cetatenie=cetatenie, @nationalitate=nationalitate, @mentiuni=mentiuni, @localitate=localitate,
		@numar_contract=numar_contract, @data_incheiere_contract=data_incheiere_contract, @tip_contract=tip_contract, 
		@exceptie_data_sfarsit=exceptie_data_sfarsit, 
		@repartizareTM=repartizaretm, @intervalreptm=intervalreptm, @NrOreInterval=isnull(nroreint,0),
		@temei_incetare=temei_incetare, @text_temei_incetare=text_temei_incetare, @detalii_contract=detalii_contract,
		@data_consemnare=data_consemnare, @ptupdate=isnull(ptupdate,0) 
	from OPENXML(@iDoc, @RowPattern)
	WITH 
		(
		tip char(2) '../@tip', 
		subtip char(2) '@subtip', 
		Marca varchar(6) @AtrMarca, --'../@marca'
		tip_act_identitate varchar(60) '@tipactident',
		cetatenie varchar(60) '@cetatenie',
		nationalitate varchar(60) '@nationalitate',
		mentiuni varchar(80) '@mentiuni',
		localitate varchar(6) '@localitate',
		numar_contract varchar(20) '@nrcontract',
		data_incheiere_contract datetime '@datainchcntr',
		tip_contract varchar(60) '@tipcontract',
		exceptie_data_sfarsit varchar(60) '@excepdatasf',
		repartizaretm varchar(60) '@repartizaretm',
		intervalreptm varchar(60) '@intervalreptm',
		nroreint int '@nroreint',
		temei_incetare char(60) '@temeiincet',
		text_temei_incetare char(80) '@texttemei',
		detalii_contract varchar(80) '@detaliicntr',
		data_consemnare datetime '@dataconsemn',	
		ptupdate int '@update'
		)
	exec sp_xml_removedocument @iDoc 

	begin tran scriuDateRevisal

		select @grupa_de_munca=grupa_de_munca, @mod_angajare=mod_angajare from personal where marca=@marca

		if @numar_contract=''
			raiserror('Numar contract necompletat!',16,1)
		if @tip_contract=''
			raiserror('Tip contract de munca necompletat!',16,1)
		if @cetatenie<>'' and @cetatenie not in (select cod from CatalogRevisal where TipCatalog='Cetatenie')
			raiserror('Cetatenie inexistenta!',16,1)
		if @nationalitate<>'' and @Nationalitate not in (select cod from CatalogRevisal where TipCatalog='Nationalitate')
			raiserror('Nationalitate inexistenta!',16,1)
		if @localitate=''
			raiserror('Localitate necompletata!',16,1)
		if @localitate not in (select cod_oras from localitati)
			raiserror('Localitate inexistenta!',16,1)
		if @mod_angajare='N' and @exceptie_data_sfarsit<>''
			raiserror('Exceptie data sfarsit se completeaza doar pt. salariatii angajati pe perioada determinata!',16,1)
		if @repartizaretm=''
			raiserror('Repartizare timp munca necompletata!',16,1)
		if @intervalreptm in ('OrePeLuna','OrePeSaptamina','OrePeZi') and @Grupa_de_munca in ('N','D','S')
			raiserror('Campul Interval repartizare timp munca trebuie completat doar pt. salariatii cu contract de munca cu timp partial!',16,1)
		if @intervalreptm in ('OrePeLuna','OrePeSaptamina') and @NrOreInterval=0
			raiserror('Numar ore interval repartizare timp munca necompletat!',16,1)
		if @data_consemnare<='01/01/1901'
			raiserror('wValidareDateRevisal: Data consemnarii informatiei necompletata!',16,1)

		if @numar_contract is not null
		begin
			update infoPers set nr_contract=@numar_contract where marca=@marca
			--update personal set nr_contract=@numar_contract where marca=@marca
		end
		if @tip_act_identitate is not null
			exec scriuExtinfop @Marca, 'RTIPACTIDENT', @tip_act_identitate, '01/01/1901', 0, 2
		if isnull(@cetatenie,'')=''
			set @cetatenie='Romana'
		if @cetatenie is not null
			exec scriuExtinfop @Marca, 'RCETATENIE', @cetatenie, '01/01/1901', 0, 2
		if isnull(@nationalitate,'')=''
			set @nationalitate='România'
		if @nationalitate is not null
			exec scriuExtinfop @Marca, 'RCODNATIONAL', @nationalitate, '01/01/1901', 0, 2
		if @mentiuni is not null
			exec scriuExtinfop @Marca, 'MENTIUNI', @mentiuni, '01/01/1901', 0, 2
		if @localitate is not null
			exec scriuExtinfop @Marca, 'CODSIRUTA', @localitate, '01/01/1901', 0, 2
		if @data_incheiere_contract is not null
			exec scriuExtinfop @Marca, 'DATAINCH', @tip_contract, @data_incheiere_contract, 0, 2
		if @repartizareTM is not null
			exec scriuExtinfop @Marca, 'REPTIMPMUNCA', @repartizareTM, '01/01/1901', 0, 2
		if @exceptie_data_sfarsit is not null
			exec scriuExtinfop @Marca, 'EXCEPDATASF', @exceptie_data_sfarsit, '01/01/1901', 0, 2
		if @intervalreptm is not null or @NrOreInterval<>0
			exec scriuExtinfop @Marca, 'TIPINTREPTM', @intervalreptm, '01/01/1901', @NrOreInterval, 2
		if @temei_incetare is not null
			exec scriuExtinfop @Marca, 'RTEMEIINCET', @temei_incetare, '01/01/1901', 0, 2
		if @text_temei_incetare is not null
			exec scriuExtinfop @Marca, 'TXTTEMEIINCET', @text_temei_incetare, '01/01/1901', 0, 2
		if @detalii_contract is not null
			exec scriuExtinfop @Marca, 'CONTRDET', @detalii_contract, '01/01/1901', 0, 2
		if @data_consemnare is not null
			exec scriuExtinfop @Marca, 'MMODIFCNTR', '', @data_consemnare, 0, 2

	commit tran scriuDateRevisal

	if @codMeniu='RV'
		select 0 as 'close' for xml raw, root('Mesaje')

end try  
begin catch
	if @@trancount>0 and EXISTS (SELECT 1 FROM sys.dm_tran_active_transactions WHERE name = 'scriuDateRevisal')
		ROLLBACK TRAN scriuDateRevisal

	set @mesaj=ERROR_MESSAGE()
	raiserror(@mesaj, 16, 1)
end catch
