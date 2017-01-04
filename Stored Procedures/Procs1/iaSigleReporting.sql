--***
create procedure iaSigleReporting(@sesiune varchar(50)=null, @parxml xml=null)
as
select poza, cod from poze where cod in ('SIGLAASIS','SIGLAFIRMA')
union all
select null, 'SIGLAFIRMA' cod where not exists (select 1 from poze where cod='SIGLAFIRMA')
	order by cod desc		--> daca siglafirma nu a fost completata nu va aparea nimic; fara acest select apare sigla asw de doua ori in raport, si in stanga si in dreapta
