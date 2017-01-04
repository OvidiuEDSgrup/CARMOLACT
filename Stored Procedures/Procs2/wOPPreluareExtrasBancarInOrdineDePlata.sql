
Create procedure wOPPreluareExtrasBancarInOrdineDePlata @sesiune varchar(50), @parXML xml
/**
	Procedura care importa continutul unui fisier text in tabelxml.date (de tip xml)
	Calea este cea default  - a formularelor - iar numele fisierului se primeste prin @parxml.row.fisier sau @parxml.row.cale_fisier
	
	--> se cer campurile de pozplin:
	plata_incasare	:61:[]CN/DN
	tert			~32	=ordonator/beneficiar (?)
	factura			?
	suma			:61:[]CN/DN[suma]
	cont bancar		~31
	(
	valuta			:60F:	caracterele 12->15 
	curs			: - nu pare a exista, poate trebuie luat cumva in functie de data transferului
	)
	[data			:61:	caracterele 5-->10]
	
	exemplu:
22                           ~32IANISTEF CONCEPT SRL       ~33.
                        ~31RO98UGBI0000702005655RON   ~23GARANTI
BANK S.A.          ~25IANISTEF REGULARIZARI      ~26        .
              ~27                .          ~28
         ~29                           ~60     ~61              ~
repere:
	[:61:] = inceput de operatiune
	[DN]/[CN] + suma = valoare tranzactie
	[:86:110] = inceput de operatiune
	[~20] = valoare fara comision bancar
	__SNT = suma cu minus
	__RCD = suma cu plus
	__+valuta
	[~21] = comisionul bancar
	[~31] = cont bancar
	[~23] = ?: banca sau cod fiscal in functie de plata incasare
	
*/
as

declare @eroare varchar(4000), @operatie_curenta varchar(2000), @pasul varchar(2)	--> @operatie_curenta este un semnalizator care sa ajute la identificarea momentului din procedura in care apare eventuala eroare.
select @eroare='', @operatie_curenta='', @pasul=0
declare @idOP int

begin try
	select @operatie_curenta='Citire parametri', @pasul='1'
	
	declare @continut varchar(max)
		,@tipop varchar(20), @cont varchar(100)--, @contcor varchar(200)
		,@data datetime
		,@explicatiiOP varchar(2000), @detaliiOP xml
		,@LMFiltru varchar(20), @docJurnalizare xml
		,@c_str varchar(100)	--> variabila de conversie
	if object_id('tempdb..#extras') is not null drop table #extras

	declare @utilizator varchar(100)
	exec wIautilizator @sesiune=@sesiune, @utilizator=@utilizator output
	
	select	@sesiune=isnull(@sesiune,'')	--> sa nu fie null sa nu avem probleme la aducerea datelor
			,@cont=@parxml.value('(/*/@cont)[1]','varchar(20)')
			--,@contcor=@parxml.value('(/*/@contcor)[1]','varchar(20)')
			,@tipOP = @parXML.value('(/*/@tip)[1]', 'varchar(20)')
			,@explicatiiOP = @parXML.value('(/*/@explicatii)[1]', 'varchar(2000)')
	
	select @operatie_curenta='Validare date din macheta', @pasul='2'
	if isnull(@cont,'')='' raiserror('Completati contul!',16,1)
	if not exists (select 1 from conturi c where c.cont=@cont)
		raiserror('Alegeti un cont din plan!',16,1)
	-----!!!!!!! de inlocuit codul de mai jos cu scriere in tabela ordinedeplata	!!!!!!!

	select @operatie_curenta='Pregatire import', @pasul='3'
	SELECT @LMFiltru=rtrim(isnull(min(Cod),'')) from LMfiltrare where utilizator=@utilizator /*and cod in (select cod from lm where Nivel=1)*/
	
	--IF @update = 0
	IF @parXML.exist('(/row/detalii/row)[1]') = 1
		SET @detaliiOP = @parXML.query('(/row/detalii/row)[1]')
	IF dbo.f_areLMFiltru(@utilizator)=1 and @detaliiOP.value('(/row/@lm)[1]', 'varchar(9)') is null
	BEGIN
		IF @detaliiOP is null 
			set @detaliiOP='<row />'
		set @detaliiOP.modify ('insert attribute lm {sql:variable("@LMFiltru")} into (/row)[1]')
	END
	select @operatie_curenta='import din txt', @pasul='4'
	
		declare @cale_fisier varchar(2000), @importXML xml
		select	@cale_fisier =
			isnull(
				isnull(
					@parXML.value('(/*/@fisier)[1]','varchar(2000)'),
				@parXML.value('(/*/@cale_fisier)[1]','varchar(2000)')
				)
			,'')

		if @cale_fisier = ''
			raiserror('Nu s-a ales niciun fisier pentru import!',16,1)
		
		declare @caleform varchar(1000)
		select @caleform=rtrim(val_alfanumerica)+(case when left(reverse(rtrim(val_alfanumerica)),1)='\' then '' else '\' end)+'uploads\'
			from par where tip_parametru='AR' and parametru='caleform'

		declare @comanda nvarchar(4000)
		select @comanda='SELECT @continut = replace(replace(x,char(10),''''),char(13),'''')
		FROM OPENROWSET
		 (BULK '''+@caleform+@cale_fisier+''',
		  SINGLE_BLOB) AS T(X)'
      
    EXEC sp_executesql @comanda, N'@continut varchar(max) OUTPUT', @continut OUTPUT;
	
	select @operatie_curenta='pregatire pentru luarea extraselor din text', @pasul='5'
	create table #extras (idextras int, plata_incasare varchar(10), tert varchar(2000), factura varchar(200), suma decimal(15,3), cont_bancar varchar(200), valuta varchar(200), curs decimal(15,3), data datetime,
		idtransfer int identity, explicatii varchar(max),
		date varchar(max))
	
	--declare @deanalizat varchar(max)	--> 
	declare @separator varchar(max)	--> secventa de caractere care separa "celulele cu informatii" din cadrul fisierului (echivalente cu tranzactii bancare)
			, @i_separator int		--> indexul separatorului in cadrul sirului de caractere @continut
			, @start_extras int
			, @final_extras int
			, @final_operatiune int	
			,@plata_incasare	varchar(10)		--	:61:[]CN/DN	 caracterele 11-12
			,@tert				varchar(2000)	--	~32	=ordonator/beneficiar (?)
			,@factura			varchar(200)	--	?
			,@suma				decimal(15,3)	--	:61:[]CN/DN[suma]	(D/C/RD/RC)
			,@cont_bancar		varchar(200)	--	~31
			--,(
			,@valuta			varchar(200)	--	:60F:	caracterele 12->15	; tine de extras, nu de transfer curent !!!
			,@curs				decimal(15,3)	--	: - nu pare a exista, poate trebuie luat cumva in functie de data transferului
			--,)
--			,@data				datetime		--:61:	caracterele 5-->10}
	
	select @operatie_curenta='verificarea valutei contabile sa fie lei', @pasul='6'
	declare @valuta_contabila varchar(20)
	select @valuta_contabila=rtrim(isnull(nullif((select top 1 valoare from proprietati p where p.tip='CONT' and p.cod=@cont and p.cod_proprietate='INVALUTA'),''),'RON'))
		,@valuta='xxx'

	if isnull(nullif(@valuta_contabila,''),'RON')<>'RON'	raiserror('Alegeti un cont contabil cu valuta in lei!',16,1)
	
	select @separator=':61:'
	select @i_separator=1--charindex(@separator, @continut)	--> indexul separatorului
	
	select @operatie_curenta='parcurgerea eventualelor extrase multiple (bucla)', @pasul='7'
	--> parcurg fiecare extras bancar:
	declare @idextras int, @maxim int
	select @idextras=0, @maxim=5000, @final_extras=charindex(':62F:',@continut), @start_extras=charindex(':60F:',@continut,5)
	while @final_extras>0 and @maxim>0 and @start_extras>0
	begin
		select @maxim=@maxim-1	--> variabila de siguranta pt iesire din bucla in caz de probleme
		select @start_extras=charindex(':60F:',@continut,5)
		
		select @valuta=substring(@continut, @start_extras+12,3)	--> valuta extrasului
			,@continut=substring(@continut, @start_extras, len(@continut))	--> elimin orice dinaintea startului de extras

		select @final_extras=charindex(':62F:',@continut)
			,@i_separator=charindex(@separator,@continut)	--> aflu indexul primului separator pentru a sti daca extrasul curent are informatii sau nu
			,@idextras=@idextras+1

		--> identific operatiunile de tip transfer bancar si le extrag ca secvente de caractere (prin disecarea @continut):
		while @i_separator>0 and 
			@i_separator<@final_extras and @maxim>0	--> daca nu mai exista operatiuni in extrasul curent se iese din bucla
			and @final_extras>0
		begin
			select @maxim=@maxim-1	--> variabila de siguranta pt depanari
		
			select @continut=substring(@continut, @i_separator, len(@continut))	--> avansez la urmatoarea operatiune
			select @i_separator=charindex(@separator, @continut,4)	--> indexul urmatorului separator; @continut e deja prefixat de separator deci cautarea nu o incep de la 1
				,@final_extras=charindex(':62F:',@continut)
			if @i_separator<=0
				select @final_operatiune=@final_extras
			else
				select @final_operatiune=@i_separator
			
			insert into #extras(idextras, valuta, date)
			select @idextras, @valuta, replace(substring(@continut, 1, @final_operatiune-1), char(10),'')
		end
		select @start_extras=charindex(':60F:',@continut,5) --> pt a evita o ultima bucla suplimentara
	end
	/*
	select @operatie_curenta='ignorarea extraselor cu operatiuni perechi de forma +suma -suma', @pasul='8'
	--> se ignora "extrasele" cu operatiuni perechi de forma +suma -suma:
	select e.idextras, sum(abs(e.total_parimpar)) total_parimpar into #r
	from
		(select e.idextras,
			/*	(case when charindex('CN',e.date)=0-->charindex('DN',e.date)
					then sum(convert(decimal(15,2),replace(substring(e.date,charindex('DN',e.date),charindex('N',e.date,charindex('DN',e.date)+2)-charindex('DN',e.date)-2),',','.')))
				else		sum(-convert(decimal(15,2),replace(substring(e.date,charindex('CN',e.date),charindex('N',e.date,13)-13),',','.')))
				end)*/
					sum(i.semn*convert(decimal(15,2),replace(substring(e.date,i.indx,charindex('N',e.date,i.indx)-i.indx),',','.')))
					--sum(select convert(decimal(15,2),replace(substring(e.date,charindex('DN',e.date),charindex('N',e.date,charindex('DN',e.date)+2)-charindex('DN',e.date)-2),',','.')))
				total_parimpar
			from #extras e
				cross apply(select (case when charindex('CN',e.date)>charindex('DN',e.date) and charindex('DN',e.date)<>0 or charindex('CN',e.date)=0 then charindex('DN',e.date) else charindex('CN',e.date) end)+2 indx
									,(case when charindex('CN',e.date)=0 or charindex('CN',e.date)>charindex('DN',e.date) and charindex('DN',e.date)<>0 then 1 else -1 end) as semn ) i
			group by idextras, round(idtransfer / 2,0) --order by round(idtransfer / 2,0)
		) e
	group by e.idextras
	delete e from #extras e inner join #r r on e.idextras=r.idextras where e.idextras=r.idextras and r.total_parimpar<0.001
*/
	select @operatie_curenta='verificarea existentei extrasului sa fie in lei', @pasul='9'
	--> verificarea valutei fata de valuta contului:
	if not exists (select 1 from #extras e where e.valuta=isnull(nullif(@valuta_contabila,''),'RON'))
		select @eroare='Nu exista extras bancar cu operatiuni in fisierul furnizat care sa aiba valuta contului "'+@cont+'" ("'+@valuta_contabila+'") !'
						+char(10)+'Preluare se executa doar pentru valuta in lei!'
	if len(@eroare)>0 raiserror(@eroare,16,1)
	
	--> elimin valutele care nu tin de contul curent:
	delete e from #extras e where e.valuta<>isnull(nullif(@valuta_contabila,''),'RON')
	
	--> aflu data:
	select top 1 @c_str=substring(e.date,5,6) from #extras e
	select @data=convert(datetime, @c_str)
	
	select @operatie_curenta='scrierea informatiilor in structurile ordine de plata', @pasul='10'
	--> scrierea in antete:
	BEGIN
		IF ISNULL(@idOP,'')=''
		BEGIN
			IF OBJECT_ID('tempdb..#idOP') IS NOT NULL
				DROP TABLE #idOP

			CREATE TABLE #idOP (id INT)

			INSERT INTO OrdineDePlata (tip, data, cont_contabil, explicatii, detalii)
			OUTPUT inserted.idOP
			INTO #idOP(id)
			SELECT @tipOP, @data, @cont, @explicatiiOP, @detaliiOP

			SELECT TOP 1 @idOP = id
			FROM #idOP

			SET @docJurnalizare = (
					SELECT @idOP idOP, 'Operat' AS stare, 'Operare' operatie
					FOR XML raw
					)

			/*
			UPDATE #setPozitiiOP
			SET idOP = @idOP
--							select *, @idOP from #setPozitiiOP
--							return	*/
			EXEC wScriuJurnalOrdineDePlata @sesiune = @sesiune, @parXML = @docJurnalizare
		END
/*
		INSERT INTO PozOrdineDePlata (idOP, tert, marca, factura, decont, banca, IBAN,  explicatii, suma, stare, detalii,data_scadentei,soldscadent)
		SELECT idOP, tert, marca, factura, decont, banca, IBAN, explicatii, suma, stare, detalii,data_scadentei,soldscadent
		FROM #setPozitiiOP
		*/
	END
	--insert into extraseBancare(idjurnal, valuta, idtransfer, date)
	--select @idjurnal, valuta, idtransfer, date from #extras
	
	insert into pozOrdineDePlata(idOP, detalii, stare)
	select @idOP, (select date, 0 stare for xml raw), 1 from #extras
	
	--> "post-procesarea" tabelei #extras - adica alocarea informatiilor in coloanele lor respective:
	declare @p xml
	select @p=(select @idOP as idOP for xml raw)
	select @operatie_curenta='apelul procedurii postpreluare (care trateaza pentru fiecare operatiune extragerea datelor in campuri importabile in plati incasari)', @pasul='11'
	exec wOPPreluareExtrasBancarInOrdineDePlata_postpreluare @sesiune=@sesiune, @parxml=@p
end try

begin catch
	set @eroare=ERROR_MESSAGE() + char(10)+' (' + OBJECT_NAME(@@PROCID) + ')'+char(10)+char(10)+'Eroarea a aparut la pasul '+@pasul+' din 11:'+char(10)+@operatie_curenta
	--> elimin antetul daca nu s-a preluat cu succes si nu avem nici pozitii:
	if isnull(@idop,0)<>0 and not exists (select 1 from pozordinedeplata p where p.idop=@idop)
		delete o from ordinedeplata o where o.idop=@idop and not exists(select 1 from pozordinedeplata p where p.idop=o.idop)
end catch

if object_id('tempdb..#extras') is not null drop table #extras
if len(@eroare)>0 raiserror(@eroare,16,1)
