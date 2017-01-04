CREATE PROCEDURE [dbo].[reindexare] AS
declare @gfetch int
declare @numetabela char(128)

declare tmp cursor for
        select ltrim(rtrim(name)) from sysobjects where xtype = 'U' 
	order by name
open tmp
fetch next from tmp into @numetabela

while (@@fetch_status =0)
    begin
	-- print 'tabela : '+rtrim(@numetabela)+'   ora : '+convert(char(10),getdate(),108)
	DBCC DBREINDEX (@numetabela,' ')
	fetch next from tmp into @numetabela    

    end
close tmp
deallocate tmp