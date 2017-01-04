create procedure validLunaInchisaConta  
as
begin try
	/**
		Se valideaza in raport cu data construita din EOM la LUNABLOC+ANULBLOC
		Tabelul este #lunaconta (data datetime, lm varchar(20))
	**/

	if exists (select 1 from sysobjects where [type]='P' and [name]='validLunaInchisaContaSP1')
	begin
		exec validLunaInchisaContaSP1
		return
	end

	declare 
		@data_inchisa datetime, @anbloc int, @lunabloc int

	IF EXISTS (select 1 from sys.objects where name='parlm' and type='U')
	BEGIN
		IF EXISTS (select 1 from parlm)
		begin
			delete #lunaconta where isnull(lm,'')=''
			
			select 
				RTRIM(loc_de_munca) lm, 
				dbo.EOM(cast (MAX(convert(varchar(4), (case when parametru='ANULBLOC' then val_numerica else  1901 end))) + '-' 
				+ MAX(convert(varchar(2),(case when parametru='LUNABLOC' then val_numerica else  1 end) )) + '-' + CAST('01' AS varchar) AS DATETIME)) datainc
			INTO #luniinchise
			from parlm 
			where parametru in ('LUNABLOC','ANULBLOC') and tip_parametru='ge'  and loc_de_munca<>''
			group by loc_de_munca

			IF EXISTS (select 1 from #lunaconta lc JOIN #luniinchise li on rtrim(lc.lm) like rtrim(li.lm)+'%' and lc.data<=li.datainc)
				raiserror ('Violare integritate date. Incercare de modificare inainte de luna inchisa contabilitate (multifirma)',16,1)		
		end
	END

	exec luare_date_par 'GE','LUNABLOC',0,@lunabloc OUTPUT,''
	exec luare_date_par 'GE','ANULBLOC',0,@anbloc OUTPUT,''
	
	select @data_inchisa=CAST(CAST(@anbloc AS varchar) + '-' + CAST(@lunabloc AS varchar) + '-' + CAST('01' AS varchar) AS DATETIME)
	select @data_inchisa=dbo.EOM(@data_inchisa)

	if exists (select 1 from #lunaconta where data<=@data_inchisa)
		raiserror ('Violare integritate date. Incercare de modificare inainte de luna inchisa contabilitate',16,1)

	if exists (select 1 from sysobjects where [type]='P' and [name]='validLunaInchisaContaSP')
		exec validLunaInchisaContaSP
end try
begin catch
	DECLARE @mesaj varchar(max)
	set @mesaj=ERROR_MESSAGE()+ ' (validLunaInchisaConta)'
	raiserror(@mesaj, 16,1)
end catch
