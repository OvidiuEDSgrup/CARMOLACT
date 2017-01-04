--***
create procedure wIaDateUnitate @sesiune varchar(50), @parXML XML
as   
begin try
	set transaction isolation level read uncommitted

	declare @utilizator varchar(20), @denunitate varchar(200), @codfiscalGE varchar(20), @codfiscalPS varchar(20),
	@anulblocGE int ,@anulincGE int,@telefonPS varchar(200),@contbcGE varchar(200),@codjudetPS varchar(200),
	@telfaxGE varchar(200),@codsirutaGE varchar (200),@codpostalGE varchar (200),@numarPS varchar (200), @codcaenPS varchar(200),
	@apartamPS varchar(200),@codjudetaPS varchar(200),@lunainchPS int,@lunablocPS int,@anulincPS int,@anulblocPS int, @judetGE varchar(200), @judetPS varchar(200),
	@codbicGE varchar(200), @dirgenGE varchar(200),@dirgenPS varchar(200),@fdirgenGE varchar(200),
	@direcGE varchar(200),@fdirecGE varchar(200),@itmnumePS varchar(200),
	@localitPS varchar(200), @adresaGE varchar(200), @categangGE  varchar(200), @numeGE varchar(200), 
	@func1PS varchar(200), @func2PS varchar(200), @func3PS varchar(200), @func4PS varchar(200), @func5PS varchar(200),
	@nume1PS varchar(200), @nume2PS varchar(200), @nume3PS varchar(200), @nume4PS varchar(200), @nume5PS varchar(200),
	@stradaPS  varchar(200),@fjuridicaGE varchar(200),@forganizGE varchar(200),@fproprietGE varchar(200),@bancaGE varchar (200),@denbancaPS varchar (200),
	@nationpfGE varchar(200),@actidpfGE varchar(200),@scond2n decimal(10,2),@scond2c varchar(200),
	@paccmPS decimal(12,3),@datapaccm datetime, @ordregGE varchar (200),@regcomnPS int,@regcomcPS varchar(200),@regcomanPS int
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator output

	select 
	    @denunitate=max(case when parametru='UNITATE' then rtrim(val_alfanumerica) else @denunitate end),
		@codfiscalGE=max(case when tip_parametru='GE' and parametru='CODFISC' then val_alfanumerica else @codfiscalGE end),
		@codfiscalPS=max(case when tip_parametru='PS' and parametru='CODFISC' then val_alfanumerica else @codfiscalPS end),
	    @anulblocGE=max(case when tip_parametru='GE' and parametru='ANULBLOC'  then val_numerica else @anulblocGE end),
	    @anulincGE=max(case when tip_parametru='GE' and parametru='ANULINC' then val_numerica else @anulincGE end),
	    @telefonPS=max(case when tip_parametru='PS' and parametru='TELEFON' then val_alfanumerica else @telefonPS end),
	    @contbcGE=max(case when tip_parametru='GE' and parametru='CONTBC' then val_alfanumerica else @contbcGE end),
	    @codjudetPS=max(case when tip_parametru='PS' and parametru='CODJUDET' then val_alfanumerica else @codjudetPS end),
	    @telfaxGE=max(case when tip_parametru='GE' and parametru='TELFAX' then val_alfanumerica else @telfaxGE end),
	    @codsirutaGE=max(case when  tip_parametru='GE' and parametru='CODSIRUTA' then val_alfanumerica else @codsirutaGE end),
	    @codpostalGE=max(case when  tip_parametru='GE' and parametru='CODPOSTAL'  then val_alfanumerica else @codpostalGE end),
	    @numarPS=max(case when  tip_parametru='PS' and parametru='NUMAR'  then val_alfanumerica else @numarPS end),
	    @codcaenPS=max(case when  tip_parametru='PS' and parametru='CODCAEN'  then val_alfanumerica else @codcaenPS end),
	    @apartamPS=max(case when  tip_parametru='PS' and parametru='APARTAM'  then val_alfanumerica else @apartamPS end),
	    @codjudetaPS=max(case when  tip_parametru='PS' and parametru='CODJUDETA'  then val_alfanumerica else @codjudetaPS end),
	    @lunainchPS=max(case when  tip_parametru='PS' and parametru='LUNA-INCH'  then val_numerica else @lunainchPS end),
	    @lunablocPS=max(case when  tip_parametru='PS' and parametru='LUNABLOC'  then val_numerica else @lunablocPS end),
	    @anulincPS=max(case when tip_parametru='PS' and parametru='ANUL-INCH' then val_numerica else @anulincPS end),
		@anulblocPS=max(case when tip_parametru='PS' and parametru='ANULBLOC' then val_numerica else @anulblocPS end),
	    @judetGE=max(case when  tip_parametru='GE' and parametru='JUDET'  then val_alfanumerica else @judetGE end),
	    @judetPS=max(case when  tip_parametru='PS' and parametru='JUDET'  then val_alfanumerica else @judetPS end),
	    @codbicGE=max(case when  tip_parametru='GE' and parametru='CODBIC'  then val_alfanumerica else @codbicGE end),
	    @dirgenGE=max(case when  tip_parametru='GE' and parametru='DIRGEN'  then val_alfanumerica else @dirgenGE end),
	    @dirgenPS=max(case when  tip_parametru='PS' and parametru='DIRGEN'  then val_alfanumerica else @dirgenPS end),
		@fdirgenGE=max(case when  tip_parametru='GE' and parametru='FDIRGEN'  then val_alfanumerica else @fdirgenGE end),
		@direcGE=max(case when  tip_parametru='GE' and parametru='DIREC'  then val_alfanumerica else @direcGE end),
		@fdirecGE=max(case when  tip_parametru='GE' and parametru='FDIREC'  then val_alfanumerica else @fdirecGE end),
	    @itmnumePS=max(case when  tip_parametru='PS' and parametru='ITMNUME'  then val_alfanumerica else @itmnumePS end),
	    @localitPS=max(case when  tip_parametru='PS' and parametru='LOCALIT'  then val_alfanumerica else @localitPS end),
	    @adresaGE=max(case when  tip_parametru='GE' and parametru='ADRESA'  then val_alfanumerica else @adresaGE end),
	    @categangGE=max(case when  tip_parametru='GE' and parametru='CATEGANG'  then val_alfanumerica else @categangGE end),
	    @numeGE=max(case when  tip_parametru='GE' and parametru='NUME'  then val_alfanumerica else @numeGE end),
	    @func1PS=max(case when  tip_parametru='PS' and parametru='FUNC1'  then val_alfanumerica else @func1PS end),
	    @func2PS=max(case when  tip_parametru='PS' and parametru='FUNC2'  then val_alfanumerica else @func2PS end),
	    @func3PS=max(case when  tip_parametru='PS' and parametru='FUNC3'  then val_alfanumerica else @func3PS end),
	    @func4PS=max(case when  tip_parametru='PS' and parametru='FUNC4'  then val_alfanumerica else @func4PS end),
	    @func5PS=max(case when  tip_parametru='PS' and parametru='FUNC5'  then val_alfanumerica else @func5PS end),
	    @nume1PS=max(case when  tip_parametru='PS' and parametru='NUME1'  then val_alfanumerica else @nume1PS end),
	    @nume2PS=max(case when  tip_parametru='PS' and parametru='NUME2'  then val_alfanumerica else @nume2PS end),
	    @nume3PS=max(case when  tip_parametru='PS' and parametru='NUME3'  then val_alfanumerica else @nume3PS end),
	    @nume4PS=max(case when  tip_parametru='PS' and parametru='NUME4'  then val_alfanumerica else @nume4PS end),
	    @nume5PS=max(case when  tip_parametru='PS' and parametru='NUME5'  then val_alfanumerica else @nume5PS end),
	    @stradaPS=max(case when  tip_parametru='PS' and parametru='STRADA'  then val_alfanumerica else @stradaPS end),
	    @fjuridicaGE=max(case when  tip_parametru='GE' and parametru='FJURIDICA'  then val_alfanumerica else @fjuridicaGE end),
	    @forganizGE=max(case when  tip_parametru='GE' and parametru='FORGANIZ'  then val_alfanumerica else @forganizGE end),
		@fproprietGE=max(case when  tip_parametru='GE' and parametru='FPROPRIET'  then val_alfanumerica else @fproprietGE end),
	    @bancaGE=max(case when  tip_parametru='GE' and parametru='BANCA'  then val_alfanumerica else @bancaGE end),
	    @denbancaPS=max(case when  tip_parametru='PS' and parametru='DENBANCA'  then val_alfanumerica else @denbancaPS end),
	    @nationpfGE=max(case when  tip_parametru='GE' and parametru='NATIONPF'  then val_alfanumerica else @nationpfGE end),
	    @actidpfGE=max(case when  tip_parametru='GE' and parametru='ACTIDPF'  then val_alfanumerica else  @actidpfGE end),
	    @scond2n=max(case when  tip_parametru='PS' and parametru='SCOND2'  then val_numerica else @scond2n end),
	    @scond2c=max(case when  tip_parametru='PS' and parametru='SCOND2'  then val_alfanumerica else  @scond2c end),
	    @ordregGE=max(case when  tip_parametru='GE' and parametru='ORDREG'  then val_alfanumerica else  @ordregGE end),
	    @regcomnPS=max(case when  tip_parametru='PS' and parametru='REGCOM'  then val_numerica else @regcomnPS end),
	    @regcomcPS=max(case when  tip_parametru='PS' and parametru='REGCOM'  then val_alfanumerica else  @regcomcPS end),
	    @regcomanPS=max(case when  tip_parametru='PS' and parametru='REGCOMAN'  then val_numerica else @regcomanPS end)
	from par 
	where 
	   tip_parametru in ('PS') and parametru 
	   in ('UNITATE','CODFISC','TELEFON','CODPOSTAL','NUMAR','CODCAEN','APARTAM','LUNA-INCH','LUNABLOC','JUDET','NUME1','FDIRGEN','DIRGEN','FDIREC','DIREC',
	   'ITMNUME','LUNA','LOCALIT','STRADA','DENBANCA','SCOND2','CODJUDET','CODJUDETA','ANUL-INCH','ANULBLOC','REGCOM','REGCOMAN',
	   'NUME1','NUME2','NUME3','NUME4','NUME5','FUNC1','FUNC2','FUNC3','FUNC4','FUNC5') 
	or tip_parametru in ('GE') and parametru in ('CODFISC','ANULBLOC','ANULINC','CONTBC','CODJUDET','TELFAX','CODSIRUTA','JUDET',
	   'CODBIC','DIRGEN','FDIRGEN','DIREC','FDIREC','ADRESA','CATEGANG','NUME','FJURIDICA','FORGANIZ','FPROPRIET','BANCA','NATIONPF','ACTIDPF','CODPOSTAL','ORDREG')

	select top 1 @paccmPS=val_numerica,@datapaccm=data from par_lunari where tip='PS' and parametru='0.5%ACCM' order by data desc
		
    select @denunitate as denunitate, @codfiscalGE as codfiscalGE, @codfiscalPS as codfiscalPS,@anulblocGE as anulblocGE,
		@anulincGE as anulincGE,@telefonPS as telefonPS,@contbcGE as contbcGE,@codjudetPS as codjudetPS,@telfaxGE as telfaxGE,
		@codsirutaGE as codsirutaGE,@codpostalGE as codpostalGE,@numarPS as numarPS,@codcaenPS as codcaenPS,@apartamPS as apartamPS,
		@codjudetaPS as codjudetaPS,@lunainchPS as lunainchPS, @lunablocPS as lunablocPS,@anulincPS as anulincPS,@anulblocPS as anulblocPS,@judetGE as judetGE, @judetPS as judetPS, @codbicGE as codbicGE,
		@dirgenGE as dirgenGE, @dirgenPS as dirgenPS, @fdirgenGE as fdirgenGE, @direcGE as direcGE, @fdirecGE as fdirecGE, 
		@itmnumePS as itmnumePS,@localitPS as localitPS,@adresaGE as adresaGE,@categangGE as categangGE,@numeGE as numeGE,
		@func1PS as func1PS, @func2PS as func2PS, @func3PS as func3PS, @func4PS as func4PS, @func5PS as func5PS,
		@nume1PS as nume1PS, @nume2PS as nume2PS, @nume3PS as nume3PS, @nume4PS as nume4PS, @nume5PS as nume5PS,
		@stradaPS as stradaPS, 
		@fjuridicaGE as fjuridicaGE, @forganizGE as forganizGE, @fproprietGE as fproprietGE, @bancaGE as bancaGE, @denbancaPS as denbancaPS, @nationpfGE as nationpfGE,
		@actidpfGE as actidpfGE,@scond2n as scond2n,@scond2c as scond2c,@paccmPS as paccmPS, @datapaccm as datapaccm, @ordregGE as ordregGE,
		@regcomnPS as regcomnPS,@regcomcPS as regcomcPS,@regcomanPS as regcomanPS
	for xml raw
    
end try

begin catch
	declare @mesajeroare varchar(500)
	set @mesajeroare='wIaDateUnitate (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+ERROR_MESSAGE()
	raiserror(@mesajeroare, 16, 1)
end catch
