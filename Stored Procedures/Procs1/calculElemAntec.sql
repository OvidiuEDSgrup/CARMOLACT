create  procedure [dbo].[calculElemAntec] @id int 
as

declare @el varchar(20), @ordine int, @formula varchar(100),@cod varchar(20), @valoare float,@select varchar(100),
		@exec varchar(1000),@rez varchar(20),@procent float,@iCount int, @current int

declare elem cursor for select element,formula,nrOrdine from elemantec where element not in ('MAN','MAT') order by nrOrdine
open elem
fetch next from elem into @el,@formula, @ordine
	while @@FETCH_STATUS = 0
	begin
		set @select=@formula
		set @iCount=(select COUNT(*) from pozTehnologii where tip='E' and idp=@id )
		set @current = 1
		declare val cursor for select cod,pret from pozTehnologii where tip='E' and idp=@id
		open val
		fetch next from val into @cod,@valoare
		while  @current <=@iCount
		begin
			set @select = REPLACE(@select,'['+rtrim(@cod)+']',@valoare)
			fetch next from val into @cod,@valoare
			set @current = @current + 1
		end		
		
		declare @sql nvarchar(90)
		set @sql = 'select @rez='+ @select
		EXEC sp_executesql 
        @query = @sql, 
        @params = N'@rez varchar(20) OUTPUT', 
        @rez = @rez OUTPUT     
        if (select procent from elemantec where element=@el)=1
        begin
			set @procent=(select cantitate from pozTehnologii where idp=@id and tip='E' and cod=@el)
			set @rez= CONVERT(varchar(20),convert(float,@rez)*@procent)
		end
		set @exec ='update pozTehnologii set pret=' + @rez + ' where idp='+convert(varchar(10),@id)+' and tip=''E'' and cod= '+''''+@el+''''
		print @exec
		exec (@exec)
		close val
		deallocate val
		fetch next from elem into @el, @formula,@ordine
	end
close elem
deallocate elem