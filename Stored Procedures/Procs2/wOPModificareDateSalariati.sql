create procedure wOPModificareDateSalariati (@sesiune varchar(50), @parXML xml='<row/>')
as
begin try 

	set transaction isolation level read uncommitted
	declare @dataivig datetime, @o_nract varchar(20), @nract varchar(20), @dataact datetime, 
			@marca varchar(6), @nume varchar(50), @o_nume varchar(50), @functie varchar(6), @o_functie varchar(6), @lm varchar(9), @o_lm varchar(9), 
			@grupamunca char(1), @o_grupamunca char(1), @salinc decimal(10), @o_salinc decimal(10), @reglucr decimal(5,2), @o_reglucr decimal(5,2), 
			@modangaj char(1), @o_modangaj char(1), @dataSfCntr datetime, @o_dataSfCntr datetime, @valDataMDCTR varchar(100), 
			@dataJos datetime, @dataSus datetime, @utilizatorASiS varchar(50), @mesaj varchar(1000)

	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizatorASiS output

	select	
			@dataivig = @parXML.value('(/*/@dataivig)[1]', 'datetime'),
			@o_nract = isnull(@parXML.value('(/*/@o_nract)[1]', 'varchar(20)'),''),
			@nract = isnull(@parXML.value('(/*/@nract)[1]', 'varchar(20)'),''),
			@dataact = @parXML.value('(/*/@dataact)[1]', 'datetime'),
			@marca = @parXML.value('(/*/@marca)[1]', 'varchar(6)'),
			@nume = rtrim(@parXML.value('(/*/@nume)[1]', 'varchar(50)')),
			@o_nume = rtrim(@parXML.value('(/*/@o_nume)[1]', 'varchar(50)')),
			@functie = rtrim(@parXML.value('(/*/@functie)[1]', 'varchar(6)')),
			@o_functie = rtrim(@parXML.value('(/*/@o_functie)[1]', 'varchar(6)')),
			@lm = rtrim(@parXML.value('(/*/@lm)[1]', 'varchar(9)')),
			@o_lm = rtrim(@parXML.value('(/*/@o_lm)[1]', 'varchar(9)')),
			@grupamunca = @parXML.value('(/*/@grupamunca)[1]', 'varchar(1)'),
			@o_grupamunca = @parXML.value('(/*/@o_grupamunca)[1]', 'varchar(1)'),
			@salinc = @parXML.value('(/*/@salinc)[1]', 'decimal(10)'),
			@o_salinc = @parXML.value('(/*/@o_salinc)[1]', 'decimal(10)'),
			@reglucr = @parXML.value('(/*/@reglucr)[1]', 'decimal(5,2)'),
			@o_reglucr = @parXML.value('(/*/@o_reglucr)[1]', 'decimal(5,2)'),
			@modangaj = @parXML.value('(/*/@modangaj)[1]', 'varchar(1)'),
			@o_modangaj = @parXML.value('(/*/@o_modangaj)[1]', 'varchar(1)'),
			@dataSfCntr = @parXML.value('(/*/@datasf)[1]', 'datetime'),
			@o_dataSfCntr = @parXML.value('(/*/@o_datasf)[1]', 'datetime')

	if @nract='' and (/*@nume<>@o_nume or @lm<>@o_lm or*/ @functie<>@o_functie or @grupamunca<>@o_grupamunca 
			or @salinc<>@o_salinc or @reglucr<>@o_reglucr or @modangaj<>@o_modangaj or @dataSfCntr<>@o_dataSfCntr)
		raiserror ('Numar act aditional necompletat!',11,1)
	if @nract=@o_nract and (/*@nume<>@o_nume or @lm<>@o_lm or*/ @functie<>@o_functie or @grupamunca<>@o_grupamunca 
			or @salinc<>@o_salinc or @reglucr<>@o_reglucr or @modangaj<>@o_modangaj or @dataSfCntr<>@o_dataSfCntr)
		raiserror ('Numar act aditional nu s-a completat/modificat!',11,1)

	if @dataSfCntr<>@o_dataSfCntr and @modangaj='N'
		raiserror ('Data sfarsit contract perioada determinata, se completeaza doar daca modul de angajare este D=Durata determinata!',11,1)

	if @nract<>''	-- se scrie numar si data act aditional modificare contract de munca.
		exec scriuExtinfop @Marca=@marca, @Cod_inf='AA', @Val_inf=@nract, @Data_inf=@dataact, @Procent=0, @Stergere=0
	if @nume<>@o_nume
		exec scriuExtinfop @Marca=@marca, @Cod_inf='NUMESAL', @Val_inf=@nume, @Data_inf=@dataivig, @Procent=0, @Stergere=0
	if @functie<>@o_functie
		exec scriuExtinfop @Marca=@marca, @Cod_inf='DATAMFCT', @Val_inf=@functie, @Data_inf=@dataivig, @Procent=0, @Stergere=0
	if @lm<>@o_lm
		exec scriuExtinfop @Marca=@marca, @Cod_inf='DATAMLM', @Val_inf=@lm, @Data_inf=@dataivig, @Procent=0, @Stergere=0
	if @grupamunca<>@o_grupamunca
		exec scriuExtinfop @Marca=@marca, @Cod_inf='CONDITIIM', @Val_inf=@grupamunca, @Data_inf=@dataivig, @Procent=0, @Stergere=0
	if @salinc<>@o_salinc
		exec scriuExtinfop @Marca=@marca, @Cod_inf='SALAR', @Val_inf='', @Data_inf=@dataivig, @Procent=@salinc, @Stergere=0
	if @reglucr<>@o_reglucr
		exec scriuExtinfop @Marca=@marca, @Cod_inf='DATAMRL', @Val_inf='', @Data_inf=@dataivig, @Procent=@reglucr, @Stergere=0
	if @modangaj<>@o_modangaj or @dataSfCntr<>@o_dataSfCntr
	begin
		set @valDataMDCTR=(case when @o_modangaj='N' and @modangaj='D' or @o_modangaj='D' and @modangaj='N' then @modangaj 
			when @modangaj='D' and @o_modangaj='D' then convert(char(10),@dataSfCntr,103) end)
		exec scriuExtinfop @Marca=@marca, @Cod_inf='DATAMDCTR', @Val_inf=@valDataMDCTR, @Data_inf=@dataivig, @Procent=0, @Stergere=0
	end

end try

begin catch
	set @mesaj = ERROR_MESSAGE() + ' (' + OBJECT_NAME(@@PROCID) + ')'
	raiserror(@mesaj, 11, 1)
end catch
