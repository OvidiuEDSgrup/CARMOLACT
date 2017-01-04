
Create PROCEDURE wOPInlocuireComanda @sesiune VARCHAR(50), @parXML XML
AS
begin try
	SET NOCOUNT ON
/*
	Exemplu apel

		exec wOPInlocuireCodTert '','<row tert="RO17627090" comanda_noua="RO17627030"/>'
*/
	declare 
		@fara_mesaje bit, @comanda_veche varchar(20), @comanda_noua varchar(20)

	select
		@comanda_veche=@parXML.value('(/*/@comanda)[1]','varchar(20)'),
		@comanda_noua=@parXML.value('(/*/@comanda_noua)[1]','varchar(20)'),
		@fara_mesaje=ISNULL(@parXML.value('(/*/@fara_mesaje)[1]','bit'),0)

	IF @comanda_veche IS NOT NULL and @comanda_noua IS NOT NULL
	begin
		IF OBJECT_ID('tempdb..##tmp_com') IS NOT NULL
			drop table ##tmp_com
		create table ##tmp_com (comanda_veche varchar(20), comanda_noua varchar(20))

		insert into ##tmp_com(comanda_veche, comanda_noua)
		select @comanda_veche, @comanda_noua
	end

	if exists (select * from ##tmp_com tt
					where not exists (select * from terti t where t.tert=tt.comanda_noua))
		raiserror ('Comanda noua nu exista in catalogul de comenzi. ',16,1)
	
	if OBJECT_ID('tempdb..##trigg') IS NOT NULL
			drop table ##trigg
		create table ##trigg (id int identity primary key,comandaSQLDisable nvarchar(4000), comandaSQLEnable nvarchar(4000))

	if OBJECT_ID('tempdb..##date_prel') IS NOT NULL
		drop table ##date_prel	

	create table ##date_prel (id int identity primary key, tabel varchar(100), coloana varchar(100), comandaSQL nvarchar(4000))

	insert into ##date_prel (tabel, coloana)
	select 'factimpl', 'comanda' union
	select 'facturi', 'comanda' union 
	select 'istfact','comanda' union
	select 'efimpl', 'comanda' union 
	select 'efecte', 'comanda' union 
	select 'decimpl', 'comanda' union 
	select 'deconturi', 'comanda' union 
	select 'doc', 'comanda' union 
	select 'pozdoc', 'comanda' union 
	select 'pozadoc', 'comanda' union 
	select 'pozplin', 'comanda' union 
	select 'personal', 'comanda' union 
	select 'pozncon', 'comanda' union 
	select 'comenzi', 'comanda' union 
	select 'comenzi', 'comanda_beneficiar' union 
	--select 'pozncon', 'comanda' union 
	--select 'pozncon', 'comanda' union 
	--select 'con', 'comanda' union 
	--select 'contcor', 'comanda' union 
	--select 'delegexp', 'comanda' union 
	--select 'incfact', 'comanda' union 
	--select 'infotert', 'comanda' union 
	select 'fisamf', 'comanda' union
	--select 'fisamf', 'comanda' union
	--select 'istpers', 'comanda' union
	select 'decaux', 'comanda_furnizor' union
	select 'decaux', 'comanda_beneficiar' union
	select 'tehnpoz', 'comanda' union
	select 'realcom', 'comanda' union
	--select 'reallmun', 'comanda' union
	select 'cost','comanda' union
	select 'costtmp','comanda_sup' union
	select 'costtmp','comanda_inf' union
	select 'costsql','comanda_sup' union
	select 'costsql','comanda_inf' union
	select 'pretun','comanda' union
	select 'Cheltcomp','comanda' union
	select 'antetBonuri','comanda' union
	select 'bp','comanda_asis' union
	select 'bt','comanda_asis' union 
	select 'fisaAmortizare','comanda' union 
	select 'masini_masini','comanda' union 
	select 'Masini_Activitati','comanda' union
	--> mihai
	select 'activitati', 'comanda' union
	select 'activitati', 'comanda_benef' union
	select 'masini', 'comanda' union
	select 'RU_instruiri', 'comanda' union
	select 'avnefac', 'comanda' union
	select 'chind', 'comanda' union
	select 'chind', 'comanda_sursa' union
	select 'pvbon', 'comanda' union
	select 'costuri', 'comanda' union
	select 'FisaPeCont', 'comanda' union
	select 'pozincondet', 'comanda' union
	select 'PozDevize', 'comanda' union
	select 'pozcom', 'comanda' union
	select 'necesaraprov', 'comanda' union
	select 'istoricstocuri', 'comanda' union
	select 'lansrep', 'comanda' union
	select 'pozprod', 'comanda' union
	select 'fisa_lans', 'comanda' union
	select 'opprod', 'comanda' union
	select 'pozactivitati', 'comanda_benef' union
	select 'MPdoc', 'comanda' union
	select 'MPdocpoz', 'comanda' union
	select 'detpozcon', 'comanda' union
	select 'MPdocndpoz', 'comanda' union
	select 'MFnotaam', 'comanda' union
	select 'speciflm', 'comanda' union
	select 'config_nc', 'comanda' union
	select 'consrep', 'comanda' union
	select 'consrin', 'comanda' union
	select 'lansman', 'comanda' union
	select 'lansmat', 'comanda' union
	select 'RNC', 'comanda' union
	select 'planificare', 'comanda' union
	select 'ponderi', 'comanda_furn' union
	select 'ponderi', 'comanda_benef' union
	select 'itiner', 'comanda' union
	select 'Zilieri', 'comanda' union
	select 'SalariiZilieri', 'comanda' union
	select 'nete', 'comanda'


	
	-- nu se face inlocuire in tabelele atasate: infotert, TVApeTerti - se presupune ca sunt bune pe noul tert

	/* Stergem tabelele ce nu exista */
	delete d
	from ##date_prel d
	LEFT JOIN sys.objects so on so.name=d.tabel and so.type='U'
	where so.object_id IS NULL

	-- Pentru aceste doua tabele trebuie discutat si vazut daca este in regula

	declare 
		@comandaDisableTriggere nvarchar(max), @comandaEnableTriggere nvarchar(max), @comandaUpdateTabele nvarchar(max)

	insert into ##trigg(comandaSQLDisable, comandaSQLEnable)
	select
		'alter table '+tabel+' disable trigger all ','alter table '+tabel+' enable trigger all'
	from ##date_prel
	group by tabel

	update d
		set d.comandaSQL=
			'update t set t.'+d.coloana +'= c.comanda_noua from '+d.tabel +' t join ##tmp_com c on t.'+d.coloana+'=c.comanda_veche '
	from ##date_prel d

	select 
		@comandaDisableTriggere='', @comandaEnableTriggere='',@comandaUpdateTabele=''

	select 
		@comandaDisableTriggere=@comandaDisableTriggere + char(13) + comandaSQLDisable,
		@comandaEnableTriggere=@comandaEnableTriggere + char(13) + comandaSQLEnable
	from ##trigg

	select
		@comandaUpdateTabele=@comandaUpdateTabele+char(13)+ comandaSQL from ##date_prel

	begin tran 
	
		/* Executam update-urile pentru tabelele normale*/
		begin try
			exec sp_executesql  @statement=@comandaDisableTriggere
		end try
		begin catch
			declare @m1 varchar(1000)
			set @m1='Eroare la sectiunea de dezactivare a triggerelor pe tabelele implicate. '+ERROR_MESSAGE()
			raiserror (@m1,16,1)
		end catch

		begin try
			exec sp_executesql  @statement=@comandaUpdateTabele
		end try
		begin catch
			declare @m2 varchar(1000)
			set @m2='Eroare la sectiunea de actualizare a comenzii in tabele. '+ERROR_MESSAGE()
			raiserror (@m2,16,1)
		end catch

		begin try
			exec sp_executesql  @statement=@comandaEnableTriggere
		end try
		begin catch
			declare @m3 varchar(1000)
			set @m3='Eroare la sectiunea de activarea a triggerelor pe tabelele implicate. '+ERROR_MESSAGE()
			raiserror (@m3,16,1)
		end catch
			
	commit tran
	
	IF @fara_mesaje=0
		select 'Notificare' titluMesaj, 'Inlocuirea comenzii s-a finalizat cu succes!' textMesaj for xml raw, root('Mesaje')

	IF OBJECT_ID('tempdb..#tmpInlocuireConturi') IS NOT NULL
		drop table #tmpInlocuireConturi
	IF OBJECT_ID('tempdb..##tmp_com') IS NOT NULL
		drop table ##tmp_com
end try
begin catch
	if @@TRANCOUNT>0
		rollback tran
	declare @mesaj varchar(2000)
	set @mesaj=ERROR_MESSAGE() + ' ('+OBJECT_NAME(@@PROCID)+')'
	raiserror (@mesaj, 15, 1)
end catch
