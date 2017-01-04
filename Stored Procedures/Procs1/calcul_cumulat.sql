--***
create procedure calcul_cumulat
as
declare @eroare varchar(4000)
select @eroare=''
begin try
	if object_id('tempdb..#deCumulat') is null
		create table #deCumulat(deCumulat decimal(38,5), total decimal(38,5), grupare int, ordonare int)
	
	--> daca indexul clustered e gresit - nu e pe coloanele respective - ar trebui o eroare aici:
	
	--> creez un index clustered ca sa forteze ordonarea tabelei asa cum imi trebuie pentru calcul cumulat:
	if not exists (select 1 from tempdb.sys.indexes i where i.object_id=object_id('tempdb..#deCumulat') and type_desc='CLUSTERED')
	create clustered index i on #deCumulat(grupare, ordonare)
	
	update #deCumulat set total=0
	
	declare @grupare int, @total decimal(38,5)
	select @grupare=0, @total=0
	update d
	set		@total=(case when @grupare=d.grupare then deCumulat+@total else deCumulat end),
			total=@total,
			@grupare=grupare
	from #decumulat d
end try

begin catch
	select @eroare=error_message()
end catch

if len(@eroare)>0 raiserror(@eroare,16,1)
