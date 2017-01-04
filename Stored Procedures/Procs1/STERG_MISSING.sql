CREATE PROCEDURE STERG_MISSING
AS
BEGIN
DECLARE @cSQL varchar(500),@index varchar(250),@tabela varchar(250)

declare lst cursor for
select s.name,t.name from sys.indexes s left outer join sys.tables t on s.object_id=t.object_id 
where s.name like 'missing%'
open lst
fetch next from lst into @index,@tabela
while @@FETCH_STATUS=0
	begin
-- drop index missing_index_2312 on con
		set @cSQL='drop index '+@index+' on '+@tabela
		exec (@cSql)
		fetch next from lst into @index,@tabela
	end
close lst
deallocate lst

END