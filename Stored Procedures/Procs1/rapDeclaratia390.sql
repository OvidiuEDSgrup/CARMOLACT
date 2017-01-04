--***
Create procedure rapDeclaratia390 @sesiune varchar(50)=null	-->	parametrul sesiune nu va avea efect pana ce nu-l vom trimite catre ftert
	,@datajos datetime, @datasus datetime='2999-1-1', @tert varchar(100)='', @tipop varchar(1)='0'
as

if object_id('tempdb..#tvarecap') is null
begin
	create table #tvarecap (subunitate varchar(20))
	exec Declaratia39x_tabela
end
--select * from #tvarecap
	--/*
	declare @RP int
	select top 1 @RP=w.parametruxml.value('(row/@RP)[1]','int') 
		from webJurnalOperatii w where obiectsql like 'wOPGenerareD390' and data<=@datajos
	order by data desc

	select @RP=isnull(@RP,0)

exec Declaratia390
	@datajos=@datajos, @datasus=@datasus,
	@genRaport=2, @tert=@tert, @RP=@RP
--*/

select d.dentert Denumire, d.* from #tvarecap d
where (@tipop='0' or d.tipop=@tipop)
	order by d.dentert, d.data

if object_id('tempdb..#tvarecap') is not null
	drop table #tvarecap
