--***
Create procedure listaIntervaledinSir 
--------------
/*
	procedura care transforma o lista de delimitatori numerici de intervale	in tabela cu intervalele dorite
	se poate specifica separatorul
	ordinea e crescatoare, daca se doreste descrescatoare se modifica ulterior din procedura apelanta
	
--*/
------------------
		@intervale varchar(8000)	
		, @separator varchar(20)	=','	--> de obicei se foloseste ','
		, @farasuprapunere bit=1	--> daca sa se suprapuna capetele intervalelor sau nu
as
declare @eroare varchar(4000)
select @eroare=''
begin try		
	declare @idTabelaTemporara int
	select @idTabelaTemporara=object_id('tempdb..#intervale')
	if @idTabelaTemporara is null
		create table #intervale(nrcrt int, start int, stop int, interval varchar(8000))
	select @idTabelaTemporara=object_id('tempdb..#intervale')
	
	--> verific structura minima necesara a tabelei:
	if (select count(1) from tempdb.sys.columns c where c.object_id=@idTabelaTemporara
			and c.name in ('nrcrt','start','stop','interval'))<4
	raiserror('Structura tabelei #intervale e gresita - lipsesc coloane!',16,1)
	
	--> ma asigur ca exista intervale
	if @intervale is not null and charindex(',',@intervale)=0
	select @eroare='Parametrul @intervale trebuie sa contina cel putin un interval! (cu separatorul specificat '+@separator+')'
		if len(@eroare)>0 raiserror(@eroare,16,1)
	
	--> ma asigur ca sirul e delimitat; ca sa evit eroarea cauzata de repetarea separatorilor fac si o inlocuire de duplicate:
	select @intervale=replace(@separator+@intervale+@separator,@separator+@separator,@separator)
		
	--> mergem cu ordine crescatoare pana la final, acolo daca s-a cerut ordine inversa inversam
	
	--> generez liniile aferente fiecarui separator de intervale; 
	-->	separatorul ("start") il identific in doi pasi: aici elimin ce e inaintea lui in sirul de zile si mai jos voi elimina ce ii urmeaza
	--> pt ca imi trebuie sub forma de int deocamdata voi folosi denInterval ca stocare temporara pentru varianta sub forma de sir de caractere:
	insert into #intervale(nrcrt, start, stop, interval)
	select row_number() over (order by t.n) nrcrt
			,0 as start
			,0 as stop
			,substring(@intervale,t.n+1,len(@intervale)-t.n) as interval
		from tally t
		where t.n<=len(@intervale) and substring(@intervale,t.n,1)=','
				and len(@intervale)-t.n>0

	--> verificare caractere gresite:
	if exists (select 1 from #intervale i where isnumeric(left(interval,charindex(',',interval)-1))=0)
	select @eroare='Intervalele trebuie sa fie completate ca sir de numere, separate cu ","!'
	if len(@eroare)>0 raiserror(@eroare,16,1)
	
	--> termin de stabilit limitele numerice ale intervalelor
	update i set
		start=left(interval,charindex(',',interval)-1)
		,stop=left(interval,charindex(',',interval)-1)
	from #intervale i
	where isnumeric(left(interval,charindex(',',interval)-1))=1

	--> stabilesc a doua limita a intervalului:
	update st set stop=sf.stop
	from #intervale st left join #intervale sf
	on st.nrcrt=sf.nrcrt-1
	where sf.stop is not null and sf.stop<>st.start

	--> verificare ordine in intervale:
	if exists (select 1 from #intervale i where i.start>i.stop)
	raiserror('Intervalele trebuie completate in ordine crescatoare!',16,1)

	delete #intervale where start=stop
	
	--> decalez cu o unitate inceputul intervalelor astfel incat sa nu se suprapuna - daca s-a cerut; bineinteles, primul nu se va decala:
	if @farasuprapunere=1
	update #intervale set start=start+1 where nrcrt>1

end try
begin catch
	set @eroare=ERROR_MESSAGE() + char(10)+' (' + OBJECT_NAME(@@PROCID) + ')'
end catch
if len(@eroare)>0 raiserror(@eroare,16,1)
