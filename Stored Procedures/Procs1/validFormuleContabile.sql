create procedure validFormuleContabile
as
begin try
	/*
		Se valideaza din #formulecontabile
			- existenta in catalog
			- existenta analiticelor
	*/
	
	if exists (select 1 from sysobjects where [type]='P' and [name]='validFormuleContabileSP') 
		exec validFormuleContabileSP

	create table #formulecontabilecen (cont_debit varchar(40), cont_credit varchar(40))

	insert into #formulecontabilecen
	select cont_debit, cont_credit from #formulecontabile group by cont_debit, cont_credit

	/* Validam intai toate conturile sa fie "valide" */
	create table #cont (cont varchar(40), tip varchar(2), numar varchar(40), data datetime)

	insert into #cont (cont, tip, numar, data)
	select cont_debit, tip, numar, data
	from #formulecontabile
	union all
	select cont_credit, tip, numar, data
	from #formulecontabile
	exec validCont

	declare @contdb varchar(40), @contcr varchar(40), @err varchar(4000)
	if exists (select 1 from #formulecontabilecen where((cont_debit<>'' and left(cont_debit,1)<>'8' and left(cont_credit,1)='8' and left(cont_credit,3) not in ('891','892')) 
		or (cont_debit<>''and left(cont_debit,1)<>'9' and left(cont_credit,1)='9')))
		raiserror('Cont debitor nepermis in corespondenta cu cont creditor din clasele 8 sau 9!',16,1)

	if exists (select 1 from #formulecontabilecen where((cont_credit<>'' and left(cont_credit,1)<>'8' and left(cont_debit,1)='8' and left(cont_debit,3) not in ('891','892')) 
		or (cont_credit<>''and left(cont_credit,1)<>'9' and left(cont_debit,1)='9')))
		raiserror('Cont creditor nepermis in corespondenta cu cont debitor din clasele 8 sau 9!',16,1)

	if exists (select 1 from #formulecontabilecen where cont_credit='' and LEFT(cont_debit,1)<>'8' )
	begin
		select @err = 'Formula eronata: Cont creditor necompletat:'+ char(10) +' Cont debit, Cont credit, Tip doc., Numar, Data ' + char(10)+
			STUFF((select distinct rtrim(f.cont_debit) +', ' +rtrim(f.cont_credit) + ', '+ f.tip + ', '+ f.numar + + ', '+ convert(varchar(10), f.data, 103) +char(10) 
			from #formulecontabile f where cont_credit='' and LEFT(cont_debit,1)<>'8'  for xml PATH(''),type).value('.','VARCHAR(MAX)'),1,0,'')+char(10)	
		raiserror(@err,16,1)
	end

	if exists (select 1 from #formulecontabilecen where cont_debit='' and LEFT(cont_credit,1)<>'8' )
	begin
		select @err = 'Formula eronata: Cont debitor necompletat:'+ char(10) +' Cont debit, Cont credit, Tip doc., Numar, Data ' + char(10)+
			STUFF((select distinct rtrim(f.cont_debit) +', ' +rtrim(f.cont_credit) + ', '+ f.tip + ', '+ f.numar + + ', '+ convert(varchar(10), f.data, 103) +char(10) 
			from #formulecontabile f where cont_debit='' and LEFT(cont_credit,1)<>'8'  for xml PATH(''),type).value('.','VARCHAR(MAX)'),1,0,'')	+char(10)
		raiserror(@err,16,1)
	end

	IF exists (select 1 from par where tip_parametru='GE' and parametru='BUGETARI' and Val_logica=1)
	begin
		declare 
			@sursa_implicita varchar(20)
		exec luare_date_par 'GE','SURSAF',0,0,@sursa_implicita OUTPUT
		Select @contdb='', @contcr=''
		Select top 1 @contdb=cont_debit, @contcr=cont_credit from #formulecontabile f JOIN Conturi cd on f.cont_debit=cd.cont JOIN Conturi cc on cc.cont=f.cont_credit 
				where left(cont_debit,3) not in ('891','892') and left(cont_credit,3) not in ('891','892') 
				and ISNULL(cc.detalii.value('(row/@sursaf)[1]','varchar(20)'),@sursa_implicita) <> ISNULL(cd.detalii.value('(row/@sursaf)[1]','varchar(20)'),@sursa_implicita)
		IF @contdb<>'' and @contdb<>''
		begin
			select @err='Contul debitor ('+rtrim(@contdb)+') si contul creditor ('+rtrim(@contcr)+') trebuie sa aiba aceeasi sursa de finantare!'
			raiserror (@err,16,1)
		end
	end

	IF EXISTS (select 1 from sys.objects where name='FormuleContabile' and type='U')
	begin
		/* nu validam decat tipurile care au pusa validarea in tabel	*/
		delete fc
		from #formulecontabile fc
		LEFT JOIN formulecontabile fv on fc.tip=fv.tip
		where fv.tip is null

		IF NOT EXISTS (select 1 from #formulecontabile)	
			RETURN

		IF NOT EXISTS (select 1 from #formulecontabile fc JOIN formulecontabile fv on  fc.cont_debit=fv.cont_debit and fc.cont_credit=fv.cont_credit and fc.tip=fv.tip)				
		begin
			select @err = 'Formula contabila invalida!' + char(10) +' Cont debit, Cont credit, Tip doc., Numar, Data ' + char(10)+
			STUFF((select distinct rtrim(fc.cont_Debit) + ' ,'+ rtrim(fc.cont_credit)+ ' ,'+ rtrim(fc.tip)+ ' ,'+ rtrim(fc.numar) from #formulecontabile fc LEFT JOIN formulecontabile fv on 
			 ((fc.cont_debit=fv.cont_Debit and fc.cont_credit<>fv.cont_credit) OR (fc.cont_credit=fv.cont_credit and fc.cont_debit<>fv.cont_debit))
		where fc.tip=fv.tip  for xml PATH(''),type).value('.','VARCHAR(MAX)'),1,0,'')	+char(10)
		
		
			raiserror(@err,16,1)
		end
	end
end try
begin catch
	DECLARE @mesaj varchar(max)
	set @mesaj=ERROR_MESSAGE()+ ' (validFormuleContabile)'
	raiserror(@mesaj, 16,1)
end catch
