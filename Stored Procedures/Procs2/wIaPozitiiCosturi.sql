--***
create procedure wIaPozitiiCosturi (@sesiune varchar(50), @parXML xml)
as
declare @eroare varchar(500)
set @eroare=''
begin try
	declare 
		@cautare varchar(40),
		@datajos datetime, @datasus datetime, @locm varchar(20), @comanda varchar(50)--, @tipDoc varchar(20)
	select	
		@datasus=dbo.eom(@parxml.value('(row/@data)[1]','datetime')),
		/*@datajos=@parxml.value('(row/@datajos)[1]','datetime'),
		@datasus=@parxml.value('(row/@datasus)[1]','datetime'),*/
		@locm=isnull(@parxml.value('(row/@lm)[1]','varchar(20)'),'')--+'%'
		,@comanda=isnull(@parxml.value('(row/@comanda)[1]','varchar(50)'),'%'),
		--,@tipDoc=isnull(@parxml.value('(row/@tipDoc)[1]','varchar(20)'),'%')
		@cautare = isnull(@parXML.value('(/row/@_cautare)[1]', 'varchar(40)'),'')

	set @cautare = '%'+ replace(@cautare,' ','%') + '%'
	declare @utilizator varchar(50)
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator
	select @datajos=dbo.bom(@datasus)
	
	select top 100
		convert(varchar(20),data,101) data	--, lm_sup, comanda_sup, art_sup
			,rtrim(lm_inf) lm_inf, rtrim(comanda_inf) comanda_inf
			,convert(decimal(20,3),cantitate) cantitate
			,convert(decimal(20,3),valoare) valoare, parcurs, tip, numar
			,(case when art_sup='T' then art_inf else art_sup end) as art
			,rtrim(lm.Denumire) as denLm
			,rtrim(c.Descriere) as denComanda
			,rtrim(a.Denumire) as denArt
	from costsql q left join lm on q.LM_INF=lm.Cod
			left join comenzi c on q.COMANDA_INF=c.Comanda
			left join artcalc a on (case when q.art_sup='T' then q.art_inf else q.art_sup end)=a.Articol_de_calculatie
	where data between @datajos and @datasus
		and (lm_sup like @locm)
		and (comanda_sup like @comanda)
		--and (@tipDoc='%' or tip like @tipDoc)
		and (@cautare = '' or lm_inf like @cautare or lm.Denumire like @cautare)
	order by lm_inf, comanda_inf
	for xml raw
end try
begin catch
	set @eroare='wIaPozitiiCosturi:'+char(10)+error_message()
end catch

if len(@eroare)>0 raiserror(@eroare,16,1)
