Create procedure pCitireModificareTVA  @data datetime, @datajos datetime, @datasus datetime
as
	declare @subunitate varchar(9)
begin try
	select @Subunitate=isnull((select max(val_alfanumerica) from par where tip_parametru='GE' and parametru='SUBPRO'),'1')

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
		inner join terti tl on rtrim(ltrim(replace(tl.Cod_fiscal,'RO','')))=dp.cui
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

	if object_id('tempdb..#informTVA') is not null drop table #informTVA
	if object_id('tempdb..#eroriTVA') is not null drop table #eroriTVA
	
	create table #informTVA (cui varchar(20))
	exec CreazaDiezTerti @numeTabela='#informTVA'
	create table #eroriTVA (raspuns varchar(max), eroare varchar(500))
	
	insert into #informTVA (cui, data_raportare)
	select distinct cui, c.data
	from #date_p d
		inner join dbo.fcalendar(@datajos,@datasus) c on 1=1
	where (tipVechi='P' and tipNou='N') or (tipVechi='N' and tipNou='P')

	exec pCitireCifAnaf @dataRap=@data
	select * from #date_p where (tipVechi='P' and tipNou='N') or (tipVechi='N' and tipNou='P')
	select * from #informTVA
end try 

begin catch
	declare @eroare varchar(2000)
	set @eroare='Procedura pCitireModificareTVA (linia '+convert(varchar(20),ERROR_LINE())+') :'+char(10)+rtrim(error_message())
	raiserror(@eroare,16,1)
end catch
