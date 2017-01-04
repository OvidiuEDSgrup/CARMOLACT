create procedure validTert  
as
begin try
	/*
		Se valideaza folosind tabela #terti (cod varchar(20), data datetime)
			- existenta in catalog si "blank"
			- terti declarati invalizi pe o anumita perioada
			
	*/

	if exists(select 1 from #terti where cod='')
	begin
		raiserror('Tert necompletat!',16,1)
	end

	if exists(select 1 from #terti t left join terti tt on t.cod=tt.tert where tt.tert is null)
	begin
		declare
			@tert_err varchar(MAX)
		set @tert_err = ''
		select @tert_err = @tert_err + RTRIM(t.cod) + ',' from #terti t left join terti tt on t.cod=tt.tert where tt.tert is null
		set @tert_err = 'Tert inexistent in catalog (' + left(@tert_err,LEN(@tert_err)-1) + ')!'		-- Sterg ultima virgula din @tert_err
		raiserror(@tert_err,16,1)
	end

	/** Terti declarati invalizi */
	select t.* into #tertInv from #terti t inner join terti tt on t.cod = tt.Tert
	where t.data between tt.detalii.value('(/row/@data_invalid_jos)[1]', 'datetime')
		and tt.detalii.value('(/row/@data_invalid_sus)[1]', 'datetime')

	if (select count(*) from #tertInv) > 0
	begin
		declare @mesajInvalidare varchar(max) , @nr int
		select @mesajInvalidare ='' 
		select @nr = count(*) from #tertInv
		select @mesajInvalidare = @mesajInvalidare + RTRIM(cod) + ', ' from #tertInv
		set @mesajInvalidare = left(@mesajInvalidare, len(@mesajInvalidare) - 1)

		set @mesajInvalidare = 'Nu se pot opera documente cu ' + (case when @nr > 1 then 'acesti terti: ' else 'acest tert: ' end)
			+ @mesajInvalidare + (case when @nr > 1 then '. Declarati invalizi!' else '. Declarat invalid!' end)
		raiserror(@mesajInvalidare, 16, 1)
	end

	if object_id('tempdb.dbo.#tertInv') is not null drop table #tertInv

end try
begin catch
	DECLARE @mesaj varchar(max)
	set @mesaj=ERROR_MESSAGE()+ ' (validTert)'
	raiserror(@mesaj, 16,1)
end catch
