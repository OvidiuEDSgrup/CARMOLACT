--***
create procedure verificaInchidereLunaAnterioara @data datetime, @locm varchar(20), @inchidTVA int, @inchid121 int
as  
begin try
	declare @data_jos datetime, @data_sus datetime, 
	@cont_4426 float, @cont_4427 float, @cont_6 float, @cont_7 float

	
	select @data_jos = dateadd(d,1-day(dateadd(M,-1,@data)),dateadd(M,-1,@data))
	select @data_sus = dateadd(d,-1,dateadd(M,1,@data_jos))
	
	select 
		@cont_4426 = sum((case when cont_debitor like '4426%' or cont_creditor like '4426%' then (case when cont_debitor like '4426%' then 1 else -1 end)*suma else 0 end)), 
		@cont_4427 = sum((case when cont_debitor like '4427%' or cont_creditor like '4427%' then (case when cont_debitor like '4427%' then 1 else -1 end)*suma else 0 end)), 
		@cont_6 = sum((case when cont_debitor like '6%' or cont_creditor like '6%' then (case when cont_debitor like '6%' then 1 else -1 end)*suma else 0 end)), 
		@cont_7 = sum((case when cont_debitor like '7%' or cont_creditor like '7%' then (case when cont_debitor like '7%' then 1 else -1 end)*suma else 0 end)) 
	from pozincon
	where data between @data_jos and @data_sus 
		and --(@locm='' or 
		Loc_de_munca like @locm+'%'--)

	if (abs(@cont_4426) > 0.001 or abs(@cont_4427) > 0.001 or abs(@cont_6) > 0.001 or abs(@cont_7) > 0.001)
	begin
		declare @msg varchar(300)
		if @inchidTVA=1 and abs(@cont_4426) > 0.001
			set @msg='Sold cont 4426: '+ltrim(str(@cont_4426,15,2))
		if @inchidTVA=1 and abs(@cont_4427) > 0.001
			set @msg='Sold cont 4427: '+ltrim(str(@cont_4427,15,2))
		if @inchid121=1 and abs(@cont_6) > 0.001
			set @msg='Sold pe conturi cl. 6: '+ltrim(str(@cont_6,15,2))
		if @inchid121=1 and abs(@cont_7) > 0.001
			set @msg='Sold pe conturi cl. 7: '+ltrim(str(@cont_7,15,2))
		set @msg='Inchiderea nu a fost efectuata pe luna anterioara! '+@msg+'. Inchiderea curenta nu se poate efectua!'
		raiserror (@msg, 16, 1)
	end
end try

begin catch
	declare @mesaj varchar(1000)
	set @mesaj=ERROR_MESSAGE() + char(10)+'('+OBJECT_NAME(@@PROCID)+')'
	raiserror(@mesaj, 16, 1)	
end catch
