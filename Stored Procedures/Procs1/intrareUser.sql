
create procedure intrareUser @sesiune varchar(50), @parXML xml
as
	declare 
		@lista_lm int, @utilizator varchar(100)

	exec wIaUtilizator @sesiune=@sesiune,@utilizator=@utilizator output

	/* Tratare populare LMFILTRARE	*/
	set @lista_lm=
		(case when exists (select 1 from proprietati where tip='UTILIZATOR' and cod=@utilizator and cod_proprietate='LOCMUNCA' and Valoare<>'') then 1 else 0 end)

	delete from LMFiltrare where utilizator=@utilizator
	
	if @lista_lm=1
		insert into LMFiltrare (utilizator,cod)
		select @utilizator,rtrim(lm.cod)
		from proprietati p 
		inner join lm on rtrim(lm.cod) like rtrim(p.valoare) + '%'
		where p.tip='UTILIZATOR' and p.cod=@utilizator and p.cod_proprietate='LOCMUNCA' and valoare<>''
		group by rtrim(lm.cod)	--> Luci: in cazul in care s-a atribuit un lm superior si un lm "analitic" al lui
	
	/* Tratare populare PropUtiliz-> proprietati pe utilizator	*/
	delete from PropUtiliz where utilizator=@utilizator

	insert into PropUtiliz (utilizator, proprietate, valoare)
	select 
		@utilizator, p.cod_proprietate, p.valoare
	from proprietati p 
	where p.tip='UTILIZATOR' and p.cod=@utilizator and valoare<>''
