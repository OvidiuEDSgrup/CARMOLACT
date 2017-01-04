Create procedure wOPModificariTipTVA_p @sesiune varchar(50)=null, @parXML xml
as
declare @subunitate varchar(9), @data datetime, @datajos datetime, @datasus datetime, @cgplus int

begin try
	select @Subunitate=isnull((select max(val_alfanumerica) from par where tip_parametru='GE' and parametru='SUBPRO'),'1')
	set @data=coalesce(@parXML.value('(/*/@datalunii)[1]','datetime'),@parXML.value('(/*/@datasus)[1]','datetime'),@parXML.value('(/*/@data)[1]','datetime'),getdate())
	set @datajos=@parXML.value('(/*/@datajos)[1]','datetime')
	set @datasus=@parXML.value('(/*/@datasus)[1]','datetime')
	set @cgplus=isnull(@parXML.value('(/*/@cgplus)[1]','int'),0)

	if object_id('tempdb..#date_p') is not null 
		drop table #date_p
	create table #date_p (firma varchar(100), cui varchar(20), tipVechi char(1), tipNou char(1), adresa varchar(250), tert varchar(20), dela datetime)

	insert into #date_p (firma, cui, tipNou, adresa, tert, dela)
	select t.denumire, c.cui, (case when isnull(c.is_tli,0)=1 then 'I' when isnull(c.is_tva,0)=1 then 'P' else 'N' end), c.adresa, t.Tert, c.dela
	from cereriInformareTVA c  
		inner join terti t on c.cui=replace(replace(replace(isnull(t.cod_fiscal,''), 'RO', ''), 'R', ''), ' ','')
	where c.data_raportare=@data  

	update dp
		set dp.tipVechi=isnull(cl.tip_tva,'P')
	from #date_p dp
		inner join terti tl on tl.tert=dp.tert
		outer apply 
			(select top 1 tip_tva 
				from TvaPeTerti tt 
				where tt.tert=tl.tert 
					and nullif(tt.factura,'') is null and tt.tipf='F' and tt.dela<=@datasus
				order by tt.dela desc) cl
	
	--	Afisam cu diferente si tertii persoane fizice care au tip_tva in TVAPeTerti=P(Platitor)
	insert into #date_p (firma, cui, tipVechi, tipNou, adresa, tert, dela)
	select t.denumire, t.cod_fiscal, isnull(cl.tip_tva,'P'), 'N', t.adresa, t.tert, @datajos
	from terti t 
		inner join infotert it on it.subunitate=t.subunitate and it.tert=t.tert and it.Identificator=''
		outer apply 
			(select top 1 tip_tva 
				from TvaPeTerti tt 
				where tt.tert=t.tert 
					and nullif(tt.factura,'') is null and tt.tipf='F' and tt.dela<=@datasus
				order by tt.dela desc) cl
		inner join doc on doc.subunitate=t.subunitate and doc.cod_tert=t.tert and doc.tip in ('RM','RS','AP','AS') and doc.data between @datajos and @datasus
	where t.subunitate=@Subunitate and (len(rtrim(t.Cod_fiscal))=13 and isnull(it.zile_inc, 0)=0 or isnull(t.detalii.value('(/row/@_persfizica)[1]','int'),0)=1) and isnull(cl.tip_tva,'P')='P'

	--populare cu abonatii din UA
	if exists (select 1 from sysobjects o where o.type='U' and o.name='tvapeabonati')  and exists (select 1 from sysobjects o where o.type='P' and o.name='wOPModificariTipTVAUA_p') 
	begin
		exec wOPModificariTipTVAUA_p @sesiune=@sesiune,@parXML=@parXML
	end

	if object_id('tempdb..#diftipTVAplus') is not null
		insert into #diftipTVAplus
		select rtrim(firma) as firma, cui, rtrim(adresa) as adresa, 
			tipvechi, (case tipVechi when 'I' then 'La incasare' when 'P' then 'Platitor' when 'N' then 'Neplatitor' else '' end) dentipvechi,
			tipnou, (case tipNou when 'I' then 'La incasare' when 'P' then 'Platitor' when 'N' then 'Neplatitor' else '' end) dentipnou, 
			1 as modificare, tert, convert(varchar(10), isnull(dela,@datajos), 101) as dela
		from #date_p
		where tipVechi!=tipNou
	else 
	begin
		select
			convert(varchar(10), @datajos, 101) datajos, convert(varchar(10), @datasus, 101) datasus
		for xml raw, root('Date')

		select 
		( 
			select rtrim(firma) as firma, cui, rtrim(adresa) as adresa, 
				tipvechi, (case tipVechi when 'I' then 'La incasare' when 'P' then 'Platitor' when 'N' then 'Neplatitor' else '' end) dentipvechi,
				tipnou, (case tipNou when 'I' then 'La incasare' when 'P' then 'Platitor' when 'N' then 'Neplatitor' else '' end) dentipnou, 
				1 as modificare, tert, convert(varchar(10), isnull(dela,@datajos), 101) as dela
			from #date_p
			where tipVechi!=tipNou
			FOR XML raw ,type 
		)
		FOR XML PATH('DateGrid'), ROOT('Mesaje')
	end
end try 

begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura wOPModificariTipTVA_p (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
