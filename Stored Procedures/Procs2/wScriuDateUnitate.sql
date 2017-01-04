--***
Create procedure dbo.wScriuDateUnitate @sesiune varchar(30), @parXML XML
as
declare @tip varchar(2), @par varchar(9), @denpar varchar(30), @vallogica int, @valnum float, @valalfa varchar(200),
    @denunitate varchar(200),@codfiscalGE varchar(200),@codfiscalPS varchar(200),@anulblocGE int,@anulincGE int,
    @telefonPS varchar(200),@contbcGE varchar(200),@codjudetPS varchar(200),
    @telfaxGE varchar(200),@codsirutaGE varchar (200),@codpostalGE varchar (200),@numarPS varchar (200), @codcaenPS varchar(200),
	@apartamPS varchar(200),@codjudetaPS varchar(200),@lunainchPS int,@lunablocPS int,@anulincPS int,@anulblocPS int,@judetGE varchar(200), @judetPS varchar(200),
	@codbicGE varchar(200), @dirgenGE varchar(200),@dirgenPS varchar(200),@fdirgenGE varchar(200),@direcGE varchar(200),@fdirecGE varchar(200),@itmnumePS varchar(200),
	@localitPS varchar(200), @adresaGE varchar(200), @categangGE  varchar(200), @numeGE   varchar(200), 
	@stradaPS  varchar(200), 
	@func1PS varchar(200), @func2PS varchar(200), @func3PS varchar(200), @func4PS varchar(200), @func5PS varchar(200),
	@nume1PS varchar(200), @nume2PS varchar(200), @nume3PS varchar(200), @nume4PS varchar(200), @nume5PS varchar(200),
	@fjuridicaGE varchar(200),@forganizGE varchar(200),@fproprietGE varchar(200),@bancaGE varchar (200),@denbancaPS varchar (200),
	@nationpfGE varchar(200),@actidpfGE varchar(200),@scond2n decimal(10,2),@scond2c varchar(200),
	@paccmPS decimal(12,3),@datapaccm datetime,@ordregGE varchar(200),@regcomnPS int,@regcomcPS varchar(200),@regcomanPS int, 
	@nLunaInch int, @nAnulInch int, @dataInch datetime, @dataInchNext datetime

set @nLunaInch=isnull((select max(val_numerica) from par where tip_parametru='PS' and parametru='LUNA-INCH'), 1)
set @nAnulInch=isnull((select max(val_numerica) from par where tip_parametru='PS' and parametru='ANUL-INCH'), 1901)
if not(@nLunaInch not between 1 and 12 or @nAnulInch<=1901)
begin
	set @DataInch=convert(datetime,str(@nLunaInch,2)+'/01/'+str(@nAnulInch,4))
	set @dataInchNext=dbo.EOM(dateadd(month,1,@dataInch))
end

Select 
       @denunitate = (@parXML.value('(/*/@denunitate)[1]','varchar(200)')),
       @codfiscalGE = (@parXML.value('(/*/@codfiscalGE)[1]','varchar(200)')),
       @codfiscalPS = (@parXML.value('(/*/@codfiscalPS)[1]','varchar(200)')),
       @anulblocGE = (@parXML.value('(/*/@anulblocGE)[1]','int')),
       @anulincGE = (@parXML.value('(/*/@anulincGE)[1]','int')),
       @telefonPS = (@parXML.value('(/*/@telefonPS)[1]','varchar(200)')),
       @contbcGE = (@parXML.value('(/*/@contbcGE)[1]','varchar(200)')),
       @codjudetPS=(@parXML.value('(/*/@codjudetPS)[1]','varchar(200)')),
       @telfaxGE=(@parXML.value('(/*/@telfaxGE)[1]','varchar(200)')),
       @codsirutaGE=(@parXML.value('(/*/@codsirutaGE)[1]','varchar(200)')),
       @codpostalGE=(@parXML.value('(/*/@codpostalGE)[1]','varchar(200)')),
       @numarPS=(@parXML.value('(/*/@numarPS)[1]','varchar(200)')),
       @codcaenPS=(@parXML.value('(/*/@codcaenPS)[1]','varchar(200)')),
       @apartamPS=(@parXML.value('(/*/@apartamPS)[1]','varchar(200)')),
       @codjudetaPS=(@parXML.value('(/*/@codjudetaPS)[1]','varchar(200)')),
       @lunainchPS = (@parXML.value('(/*/@lunainchPS)[1]','int')),
       @lunablocPS = (@parXML.value('(/*/@lunablocPS)[1]','int')),
       @anulincPS = (@parXML.value('(/*/@anulincPS)[1]','int')),
	   @anulblocPS = (@parXML.value('(/*/@anulblocPS)[1]','int')),
       @judetGE=(@parXML.value('(/*/@judetGE)[1]','varchar(200)')),
       @judetPS=(@parXML.value('(/*/@judetPS)[1]','varchar(200)')),
       @codbicGE=(@parXML.value('(/*/@codbicGE)[1]','varchar(200)')),
       @dirgenGE=(@parXML.value('(/*/@dirgenGE)[1]','varchar(200)')),
       @dirgenPS=(@parXML.value('(/*/@dirgenPS)[1]','varchar(200)')),
       @fdirgenGE=(@parXML.value('(/*/@fdirgenGE)[1]','varchar(200)')),
       @direcGE=(@parXML.value('(/*/@direcGE)[1]','varchar(200)')),
       @fdirecGE=(@parXML.value('(/*/@fdirecGE)[1]','varchar(200)')),
       @itmnumePS=(@parXML.value('(/*/@itmnumePS)[1]','varchar(200)')),
       @localitPS=(@parXML.value('(/*/@localitPS)[1]','varchar(200)')),
       @adresaGE=(@parXML.value('(/*/@adresaGE)[1]','varchar(200)')),
       @categangGE=(@parXML.value('(/*/@categangGE)[1]','varchar(200)')),
       @numeGE=(@parXML.value('(/*/@numeGE)[1]','varchar(200)')),
       @func1PS=(@parXML.value('(/*/@func1PS)[1]','varchar(200)')),
       @func2PS=(@parXML.value('(/*/@func2PS)[1]','varchar(200)')),
       @func3PS=(@parXML.value('(/*/@func3PS)[1]','varchar(200)')),
       @func4PS=(@parXML.value('(/*/@func4PS)[1]','varchar(200)')),
       @func5PS=(@parXML.value('(/*/@func5PS)[1]','varchar(200)')),
       @nume1PS=(@parXML.value('(/*/@nume1PS)[1]','varchar(200)')),
       @nume2PS=(@parXML.value('(/*/@nume2PS)[1]','varchar(200)')),
       @nume3PS=(@parXML.value('(/*/@nume3PS)[1]','varchar(200)')),
       @nume4PS=(@parXML.value('(/*/@nume4PS)[1]','varchar(200)')),
       @nume5PS=(@parXML.value('(/*/@nume5PS)[1]','varchar(200)')),
       @stradaPS=(@parXML.value('(/*/@stradaPS)[1]','varchar(200)')),
       @fjuridicaGE=(@parXML.value('(/*/@fjuridicaGE)[1]','varchar(200)')),
       @forganizGE=(@parXML.value('(/*/@forganizGE)[1]','varchar(200)')),
	   @fproprietGE=(@parXML.value('(/*/@fproprietGE)[1]','varchar(200)')),
       @bancaGE=(@parXML.value('(/*/@bancaGE)[1]','varchar(200)')),
       @denbancaPS=(@parXML.value('(/*/@denbancaPS)[1]','varchar(200)')),
       @nationpfGE=(@parXML.value('(/*/@nationpfGE)[1]','varchar(200)')),
       @actidpfGE=(@parXML.value('(/*/@actidpfGE)[1]','varchar(200)')),
       @anulblocGE = (@parXML.value('(/*/@anulblocGE)[1]','int')),
       @scond2n=(@parXML.value('(/*/@scond2n)[1]','decimal(10,2)')),
       @scond2c=(@parXML.value('(/*/@scond2c)[1]','varchar(200)')),
       @paccmPS=@parXML.value('(/*/@paccmPS)[1]','decimal(12,3)'),
       @datapaccm=@parXML.value('(/*/@datapaccm)[1]','datetime'),
       @ordregGE=(@parXML.value('(/*/@ordregGE)[1]','varchar(200)')),
       @regcomnPS=(@parXML.value('(/*/@regcomnPS)[1]','int')),
       @regcomcPS=(@parXML.value('(/*/@regcomcPS)[1]','varchar(200)')),
       @regcomanPS=(@parXML.value('(/*/@regcomanPS)[1]','int'))
 
 
begin try
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='UNITATE'
	exec setare_par 'PS', 'UNITATE', @denpar, @vallogica, @valnum, @denunitate

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='CODFISC'
	exec setare_par 'GE', 'CODFISC', @denpar, @vallogica, @valnum, @codfiscalGE

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='CODFISC'
	exec setare_par 'PS', 'CODFISC', @denpar, @vallogica, @valnum, @codfiscalPS

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par where tip_parametru='GE' and parametru='ANULBLOC'
	exec setare_par 'GE', 'ANULBLOC', @denpar, @vallogica, @anulblocGE,@valalfa
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par where tip_parametru='GE' and parametru='ANULINC'
	exec setare_par 'GE', 'ANULINC', @denpar, @vallogica, @anulincGE,@valalfa
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='TELEFON'
	exec setare_par 'PS', 'TELEFON', @denpar, @vallogica, @valnum, @telefonPS
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='CONTBC'
	exec setare_par 'GE', 'CONTBC', @denpar, @vallogica, @valnum, @contbcGE

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='CODJUDET'
	exec setare_par 'PS', 'CODJUDET', @denpar, @vallogica, @valnum, @codjudetPS

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='TELFAX'
	exec setare_par 'GE', 'TELFAX', @denpar, @vallogica, @valnum, @telfaxGE    
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='CODSIRUTA'
	exec setare_par 'GE', 'CODSIRUTA', @denpar, @vallogica, @valnum, @codsirutaGE    
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='CODPOSTAL'
	exec setare_par 'GE', 'CODPOSTAL', @denpar, @vallogica, @valnum, @codpostalGE  
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='NUMAR'
	exec setare_par 'PS', 'NUMAR', @denpar, @vallogica, @valnum, @numarPS  
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='CODCAEN'
	exec setare_par 'PS', 'CODCAEN', @denpar, @vallogica, @valnum, @codcaenPS  
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='APARTAM'
	exec setare_par 'PS', 'APARTAM', 'Apartament', @vallogica, @valnum, @apartamPS  
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='CODJUDETA'
	exec setare_par 'PS', 'CODJUDETA', @denpar, @vallogica, @valnum, @codjudetaPS 
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par where tip_parametru='PS' and parametru='LUNA-INCH'
	set @valalfa=(case @lunainchPS 
			when 1 then 'Ianuarie'
			when 2 then 'Februarie'
			when 3 then 'Martie'
			when 4 then 'Aprilie'
			when 5 then 'Mai'
			when 6 then 'Iunie'
			when 7 then 'Iulie'
			when 8 then 'August'
			when 9 then 'Septembrie'
			when 10 then 'Octombrie'
			when 11 then 'Noiembrie'
			else 'Decembrie' end)
	exec setare_par 'PS', 'LUNA-INCH', @denpar, @vallogica, @lunainchPS,@valalfa
	
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par where tip_parametru='PS' and parametru='LUNABLOC'
	set @valalfa=(case @lunablocPS 
			when 1 then 'Ianuarie'
			when 2 then 'Februarie'
			when 3 then 'Martie'
			when 4 then 'Aprilie'
			when 5 then 'Mai'
			when 6 then 'Iunie'
			when 7 then 'Iulie'
			when 8 then 'August'
			when 9 then 'Septembrie'
			when 10 then 'Octombrie'
			when 11 then 'Noiembrie'
			else 'Decembrie' end)
	exec setare_par 'PS', 'LUNABLOC', @denpar, @vallogica, @lunablocPS,@valalfa
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par where tip_parametru='PS' and parametru='ANUL-INCH'
	exec setare_par 'PS', 'ANUL-INCH', @denpar, @vallogica, @anulincPS,@valalfa
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par where tip_parametru='PS' and parametru='ANULBLOC'
	exec setare_par 'PS', 'ANULBLOC', @denpar, @vallogica, @anulblocPS,@valalfa
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='JUDET'
	exec setare_par 'GE', 'JUDET', @denpar, @vallogica, @valnum, @judetGE 
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='JUDET'
	exec setare_par 'PS', 'JUDET', @denpar, @vallogica, @valnum, @judetPS 
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='CODBIC'
	exec setare_par 'GE', 'CODBIC', @denpar, @vallogica, @valnum, @codbicGE 
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='DIRGEN'
	exec setare_par 'GE', 'DIRGEN', @denpar, @vallogica, @valnum, @dirgenGE 
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='DIRGEN'
	exec setare_par 'PS', 'DIRGEN', @denpar, @vallogica, @valnum, @dirgenPS 

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='FDIRGEN'
	exec setare_par 'GE', 'FDIRGEN', @denpar, @vallogica, @valnum, @fdirgenGE 

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='DIREC'
	exec setare_par 'GE', 'DIREC', @denpar, @vallogica, @valnum, @direcGE 

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='FDIREC'
	exec setare_par 'GE', 'FDIREC', @denpar, @vallogica, @valnum, @fdirecGE 
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='ITMNUME'
	exec setare_par 'PS', 'ITMNUME', @denpar, @vallogica, @valnum, @itmnumePS
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='LOCALIT'
	exec setare_par 'PS', 'LOCALIT', @denpar, @vallogica, @valnum, @localitPS
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='ADRESA'
	exec setare_par 'GE', 'ADRESA', @denpar, @vallogica, @valnum, @adresaGE
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='CATEGANG'
	exec setare_par 'GE', 'CATEGANG', @denpar, @vallogica, @valnum, @categangGE
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='NUME'
	exec setare_par 'GE', 'NUME', @denpar, @vallogica, @valnum, @numeGE
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='STRADA'
	exec setare_par 'PS', 'STRADA', @denpar, @vallogica, @valnum, @stradaPS

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='NUME1'
	exec setare_par 'PS', 'NUME1', @denpar, @vallogica, @valnum, @nume1PS 
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='NUME2'
	exec setare_par 'PS', 'NUME2', @denpar, @vallogica, @valnum, @nume2PS 

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='NUME3'
	exec setare_par 'PS', 'NUME3', @denpar, @vallogica, @valnum, @nume3PS 

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='NUME4'
	exec setare_par 'PS', 'NUME4', @denpar, @vallogica, @valnum, @nume4PS 

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='NUME5'
	exec setare_par 'PS', 'NUME5', @denpar, @vallogica, @valnum, @nume5PS

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='FUNC1'
	exec setare_par 'PS', 'FUNC1', @denpar, @vallogica, @valnum, @func1PS 

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='FUNC2'
	exec setare_par 'PS', 'FUNC2', @denpar, @vallogica, @valnum, @func2PS 

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='FUNC3'
	exec setare_par 'PS', 'FUNC3', @denpar, @vallogica, @valnum, @func3PS 

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='FUNC4'
	exec setare_par 'PS', 'FUNC4', @denpar, @vallogica, @valnum, @func4PS 

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='FUNC5'
	exec setare_par 'PS', 'FUNC5', @denpar, @vallogica, @valnum, @func5PS 

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='FJURIDICA'
	exec setare_par 'GE', 'FJURIDICA', @denpar, @vallogica, @valnum, @fjuridicaGE
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='FJURIDICA'
	exec setare_par 'GE', 'FJURIDICA', @denpar, @vallogica, @valnum, @fjuridicaGE
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='FORGANIZ'
	exec setare_par 'GE', 'FORGANIZ', @denpar, @vallogica, @valnum, @forganizGE

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='FPROPRIET'
	exec setare_par 'GE', 'FPROPRIET', @denpar, @vallogica, @valnum, @fproprietGE
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='BANCA'
	exec setare_par 'GE', 'BANCA', @denpar, @vallogica, @valnum, @bancaGE
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='PS' and parametru='BANCA'
	exec setare_par 'PS', 'DENBANCA', @denpar, @vallogica, @valnum, @denbancaPS
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='NATIONPF'
	exec setare_par 'GE', 'NATIONPF', @denpar, @vallogica, @valnum, @nationpfGE
	
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica
	from par where tip_parametru='GE' and parametru='ACTIDPF'
	exec setare_par 'GE', 'ACTIDPF', @denpar, @vallogica, @valnum, @actidpfGE
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par where tip_parametru='PS' and parametru='SCOND2'
	exec setare_par 'PS', 'SCOND2', @denpar, @vallogica, @scond2n,@scond2c

	select @denpar='', @vallogica='', @valnum='', @valalfa=''
	
	if @datapaccm is null or @datapaccm<=@dataInch
		set @datapaccm=@dataInchNext

    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par_lunari where tip='PS' and parametru='0.5%ACCM' and data=@datapaccm
	exec setare_par_lunari @data=@datapaccm, @tip='PS', @par='0.5%ACCM', @denp=@denpar, @val_l=@vallogica, @val_n=@paccmPS, 
		@val_a=@valalfa, @val_d='01/01/1901'
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par where tip_parametru='GE' and parametru='ORDREG'
	exec setare_par 'GE', 'ORDREG', @denpar, @vallogica, @valnum,@ordregGE
     
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par where tip_parametru='PS' and parametru='REGCOM'
	exec setare_par 'PS', 'REGCOM', @denpar, @vallogica, @regcomnPS,@regcomcPS 
    
	select @denpar='', @vallogica='', @valnum='', @valalfa=''
    select @denpar=denumire_parametru, @vallogica=val_logica, @valnum=val_numerica,@valalfa=val_alfanumerica
	from par where tip_parametru='PS' and parametru='REGCOMAN'
	exec setare_par 'PS', 'REGCOMAN', 'Registru comertului', 1, @regcomanPS,@valalfa 
     
end try

begin catch
	declare @mesaj varchar(254)
	set @mesaj = '(wScriuDateUnitate) '+ERROR_MESSAGE()
	raiserror(@mesaj, 11, 1)	
end catch


