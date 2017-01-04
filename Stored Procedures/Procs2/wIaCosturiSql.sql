--***
create procedure wIaCosturiSql (@sesiune varchar(50), @parXML xml)
as
declare @eroare varchar(500)
set @eroare=''
begin try
	declare --@data datetime, 
			@valmax decimal(13,3),
			@datajos datetime, @datasus datetime, @locm varchar(20), @comanda varchar(50),
			@denlocm varchar(50), @dencomanda varchar(100),
			@valoareJos decimal(13,3), @valoareSus decimal(13,3)
	declare @utilizator varchar(50)
	exec wIaUtilizator @sesiune=@sesiune, @utilizator=@utilizator
	set @valmax=9999999999.999
	select	--@data=@parxml.value('(row/@data)[1]','datetime'),
			@datajos=@parxml.value('(row/@datajos)[1]','datetime')
			,@datasus=@parxml.value('(row/@datasus)[1]','datetime')
			,@locm=isnull(@parxml.value('(row/@locm)[1]','varchar(20)'),'')+'%'
			,@denlocm='%'+isnull(@parxml.value('(row/@denLocm)[1]','varchar(20)'),'')+'%'
			,@comanda=isnull(@parxml.value('(row/@comanda)[1]','varchar(50)'),'%')
			,@dencomanda='%'+isnull(@parxml.value('(row/@denComanda)[1]','varchar(50)'),'')+'%'
			,@valoareJos=isnull(@parxml.value('(row/@valoareJos)[1]','decimal(13,3)'),-@valmax)
			,@valoareSus=isnull(@parxml.value('(row/@valoareSus)[1]','decimal(13,3)'),@valmax)
			
	select top 100
		convert(varchar(20),q.data,101) data, rtrim(q.lm) lm, rtrim(q.comanda) comanda
		, convert(decimal(20,3),q.costuri) costuri, convert(decimal(20,3),q.cantitate) cantitate
		, convert(decimal(20,3),q.pret) pret, q.rezolvat
		, rtrim(c.Descriere) as denComanda, rtrim(lm.Denumire) as denLm
		--, nerezolvate
	from 
		costurisql q
		left join comenzi c on q.comanda=c.comanda
		left join lm on q.lm=lm.Cod
	where data between @datajos and @datasus and
		(@locm='%' or q.lm like @locm)
		and (@comanda='%' or q.comanda like @comanda)
		and (isnull(lm.Denumire,'') like @denlocm) and (isnull(c.Descriere,'') like @dencomanda)
		and	costuri between @valoareJos and @valoareSus
--	order by costuri, comanda, lm, data
	for xml raw
end try
begin catch
	set @eroare='wIaCosturiSql:'+char(10)+error_message()
end catch

if len(@eroare)>0 raiserror(@eroare,16,1)
