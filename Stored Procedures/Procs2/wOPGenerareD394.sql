--***
Create procedure wOPGenerareD394 @sesiune varchar(50), @parXML xml
as

declare @subunitate varchar(9), @codfiscal varchar(20), @tipdecl varchar(1), @numedecl varchar(150), @prendecl varchar(50), 
	@functiedecl varchar(50), --@lm char(9), @inXML int, 
	@calefisier varchar(300), @data datetime, @lunaalfa varchar(15), @luna int, @an int, @dataj datetime, @datas datetime, 
	@userASiS varchar(10), @nrLMFiltru int, @LMFiltru varchar(9), @lmUtilizator varchar(9), @optiuniGenerare int, @siXMLPDF int, @dataInchConturi datetime, @dataInregContabile datetime

exec wIaUtilizator @sesiune=@sesiune, @utilizator=@userASiS output
select @nrLMFiltru=count(1), @LMFiltru=isnull(max(Cod),'') from LMfiltrare where utilizator=@userASiS and cod in (select cod from lm where Nivel=1)
if @nrLMFiltru=1
	set @lmUtilizator=rtrim(@LMFiltru)

if @lmUtilizator is not null
begin
	if @parXML.value('(/*/@lm)[1]','varchar(40)') IS NULL
		set @parXML.modify ('insert attribute lm {sql:variable("@lmUtilizator")} into (/*)[1]')
	else 
		set @parXML.modify('replace value of (/*/@lm)[1] with sql:variable("@lmUtilizator")')
end

exec wJurnalizareOperatie @sesiune=@sesiune, @parXML=@parXML, @obiectSql='wOPGenerareD394'

IF (select max(convert(float,versiune)) from asisria..cheiActivare)<2.4
	raiserror ('Versiunea curenta de aplicatie nu permite generarea D394. Va rugam activati ASiSria versiunea 2.4!', 16, 1)

set @subunitate = isnull(nullif((select max(Val_alfanumerica) from par where Tip_parametru='GE' and Parametru='SUBPRO'),''),'1')
--exec luare_date_par 'GE', 'CODFISC', 0, 0, @codfiscal output
--set @codfiscal=Replace (Replace (Replace (upper(@codfiscal),'RO',''),'R',''),' ','')
set @tipdecl = ISNULL(@parXML.value('(/parametri/@tipdecl)[1]', 'varchar(1)'), '')
set @numedecl = ISNULL(@parXML.value('(/parametri/@numedecl)[1]', 'varchar(150)'), '')
set @prendecl = ISNULL(@parXML.value('(/parametri/@prendecl)[1]', 'varchar(50)'), '')
set @functiedecl = ISNULL(@parXML.value('(/parametri/@functiedecl)[1]', 'varchar(50)'), '')
set @optiuniGenerare = ISNULL(@parXML.value('(/parametri/@optiunigenerare)[1]', 'int'), 0)
set @siXMLPDF = ISNULL(@parXML.value('(/parametri/@sixmlpdf)[1]', 'int'), 0)
/*exec luare_date_par 'GE', 'NDECLTVA', 0, 0, @numedecl output
set @prendecl=right(@numedecl,len(@numedecl)-CHARINDEX(' ',@numedecl))
set @numedecl=LEFT(@numedecl,CHARINDEX(' ',@numedecl)-1)
exec luare_date_par 'GE', 'FDECLTVA', 0, 0, @functiedecl output
exec luare_date_par 'GE', 'CFDECLTVA', 0, 0, @calefisier output*/
exec luare_date_par 'AR', 'CALEFORM', 0, 0, @calefisier output
select @calefisier=rtrim(@calefisier)
/*set @calefisier=rTrim (@calefisier)+(case when rTrim (@calefisier)<>'' AND 
	Right (rTrim (@calefisier),1)<>'\' then '\' else '' end)+'394_'+@tipdecl+'_D'+rTrim(Str(@luna,2))+
	Right(Str(@an,4),2)+'_J'+rTrim (@codfiscal)+'.xml'*/
--set @data = ISNULL(@parXML.value('(/parametri/@data)[1]', 'datetime'), '01/01/1901')
set @luna = ISNULL(@parXML.value('(/parametri/@luna)[1]', 'int'), 0)
set @an = ISNULL(@parXML.value('(/parametri/@an)[1]', 'int'), 0)
if @luna<>0 and @an<>0
begin
	set @data=dbo.bom(convert(datetime,str(@luna,2)+'/01/'+str(@an,4)))
	set @data=(case @tipdecl when 'T' then Dateadd(MONTH,-(Month(@data)-1) % 3,@data) when 'S' then 
		Dateadd(month,-(Month(@data)-1) % 6,@data) when 'A' then Dateadd(month,1-Month(@data),@data) 
		else @data end)
end
set @datas=dbo.EOM(@data)
select @lunaalfa=LunaAlfa from fCalendar(@data,@data)

begin try  
	/*if dbo.f_areLMFiltru(@userASiS)=1 and @nrLMFiltru>0
		raiserror('Nu puteti efectua operatia fiindca aveti drepturi de acces doar pe anumite locuri de munca!' ,16,1)
	*/		
	if @luna=0 or @an=0
		raiserror('Alegeti luna si anul!' ,16,1)
			
	if rtrim(left(@calefisier,4))='' --'\394'
		raiserror('Completati cale fisier in parametri!' ,16,1)
			
	if @numedecl='' or @prendecl='' or @functiedecl=''
		raiserror('Completati nume, prenume si functie declarant!' ,16,1)

	/*	1. Verificam data ultimei inchideri de conturi. Daca nu s-a rulat operatia pentru perioada selectata, dam mesaj de eroare. Facem aceste validari pentru declaratii valabile de la 01.10.2016. */
	if @data>='10/01/2016'
	begin
		select top 1 @dataInchConturi=data from webJurnalOperatii where obiectSQL='wOPInchidereConturi' and tip='IC' and parametruXML.value('(/row/@data)[1]','datetime') between @data and @datas
			and (nullif(parametruXML.value('(/row/@lm)[1]','varchar(9)'),'') is null or @lmUtilizator is null and parametruXML.value('(/row/@lm)[1]','varchar(9)')<>'' 
				or parametruXML.value('(/row/@lm)[1]','varchar(9)')=@lmUtilizator)
		order by data desc
		if @dataInchConturi is null
			raiserror('Nu ati rulat operatia de inchidere conturi pentru perioada selectata. Rulati operatia de Inchidere conturi si apoi generati D394!' ,16,1)

		/*	2. Daca dupa ultima inchidere de conturi s-au operat alte documente, dam din nou mesaj de eroare. Exceptam la verificare, documentele generate prin inchidere de conturi. */
		select top 1 @dataInregContabile=data_operarii
		from pozincon 
		where subunitate=@subunitate and data between @data and @datas 
			and not(tip_document='IC' or tip_document='PI' and Explicatii like '%ITVA%' 
				or tip_document='NC' and (explicatii like 'Dif.curs. fact. proviz.%' or explicatii like 'Provizion fact.%' or explicatii like 'Inc. prov. fact.%')
				or tip_document='CB' and explicatii like 'Provizion fact.%')
			and (@lmUtilizator is null or exists (select 1 from LMFiltrare lu where lu.utilizator=@userASiS and lu.cod=Loc_de_munca))
		order by data_operarii desc

		if DateDiff(mi,@dataInchConturi,@dataInregContabile)>2 and @data>='10/01/2016'	--	comentam pana tratam mai riguros data_operarii si ora_operarii in pozincon.
			raiserror('Dupa ultima inchidere de conturi ati inregistrat documente. Rulati operatia de Inchidere conturi si apoi generati D394!' ,16,1)
	end
	
	exec Declaratia394 @sesiune=@sesiune, @data=@data, @nume_declar=@numedecl, @prenume_declar=@prendecl, 
		@functie_declar=@functiedecl, @caleFisier=@calefisier, @dinRia=1, @tip_D394=@tipdecl, @optiuniGenerare=@optiuniGenerare, @siXMLPDF=@siXMLPDF

	select @numedecl=rtrim(@numedecl)+' '+@prendecl--, @calefisier=LEFT(@calefisier,CHARINDEX('394',@calefisier)-1)
	exec setare_par 'GE', 'NDECLTVA', 'Nume pers. declaratie TVA', 0, 0, @numedecl
	exec setare_par 'GE', 'FDECLTVA', 'Functie pers. declaratie TVA', 0, 0, @functiedecl
	exec setare_par 'GE', 'XMLPDF394', 'XML compatibil PDF inteligent', @siXMLPDF, 0, ''
	--exec setare_par 'GE', 'CFDECLTVA', 'Cale fisier declaratie TVA', 0, 0, @calefisier

	--    rulam macheta de modificare    
	if 1=0
	begin
		declare @D394 int
		set @D394=1
		set @parXML.modify ('insert attribute D394 {sql:variable("@D394")} into (/*)[1]')
		exec wOPVerificareCifAnaf @sesiune=@sesiune, @parXML=@parXML
	end
	
	select 'Terminat operatia'+/*rtrim(@lunaalfa)+' anul '+convert(char(4),year(@datas))+*/'!' 
		as textMesaj, 'Finalizare operatie' as titluMesaj for xml raw, root('Mesaje')
end try  

begin catch 
	declare @eroare varchar(254) 
	set @eroare=ERROR_MESSAGE()+' (wOPGenerareD394)'
	raiserror(@eroare, 16, 1) 
end catch
