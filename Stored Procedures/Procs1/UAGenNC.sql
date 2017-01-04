
--***
create procedure  UAGenNC @pardatajos datetime,@pardatasus datetime,@cHostUser char(10),@locm char(9)
as
if exists(select * from sys.objects where type='P' and name='UAGenNC_SP')
		exec UAGenNC_SP @pardatajos,@pardatasus,@cHostUser,@locm
else
begin
declare @mesaj char(200)
declare @cont_client char(13),@cont_pen char(13),@cont_comp char(13),@cont_rot char(13),@cont_taxa char(13),
@cont_tva char(13),@cont_tvane char(13),@cont_facturi_avans char(13),@cont_casa char(13),@cont_banca char(13),
@cont_trezorerie char(13),@cont_compensare char(13),@cont_cred_taxa char(13),@cSub char(9),@cdefaultcomanda char(20)

exec Luare_date_par 'UA','CONTCL',0,0,@cont_client output
exec Luare_date_par 'UA','CONTPEN',0,0,@cont_pen output
exec Luare_date_par 'UA','CONTCOMP',0,0,@cont_comp output
exec Luare_date_par 'UA','CONTROT',0,0,@cont_rot output
exec Luare_date_par 'UA','CONTTD',0,0,@cont_taxa output
exec Luare_date_par 'UA','CONTTVA',0,0,@cont_tva output
exec Luare_date_par 'UA','CONTTVANE',0,0,@cont_tvane output
exec Luare_date_par 'UA','CONTFAV',0,0,@cont_facturi_avans output
--exec Luare_date_par 'UA','CONTCASA',0,0,@cont_casa output
--exec Luare_date_par 'UA','CONTINCB',0,0,@cont_banca output
--exec Luare_date_par 'UA','CONTTREZ',0,0,@cont_trezorerie output
--exec Luare_date_par 'UA','CONTCOMP',0,0,@cont_compensare output
--exec Luare_date_par 'UA','CONTCRTD',0,0,@cont_cred_taxa output
exec luare_date_Par 'GE','SUBPRO',1,0,@cSub output
exec luare_date_Par 'UA','DEFCOM',1,0,@cdefaultcomanda output

begin try
--	BEGIN TRAN gennc
	Declare @nError int
	Set @nError = 0
	--delete from tmpNC where Terminal=@cHostUser
	delete from pozncon where DATA  between @pardatajos and @pardatasus and (isnull(@locm,'')='' or @locm=Loc_munca) and jurnal='UA' and tip='UA'

	--if exists (select * from sys.objects where type = 'U' and name='tmpFactAbonUA')
	--	drop table tmpFactAbonUA
	if exists (select * from sys.objects where type = 'U' and name='#tmpFactAbonUA')
	drop table #tmpFactAbonUA
	select * into #tmpFactAbonUA from TFactAbon(null,null,'',0,2,@locm) where tip in ('AV','AP')


	insert into pozncon(Subunitate,Tip,Numar,Data,Cont_debitor,Cont_creditor,Suma,Valuta,Curs,Suma_valuta,Explicatii,Utilizator,
	Data_operarii,Ora_operarii,Nr_pozitie,Loc_munca,Comanda,tert,Jurnal)
	select a.sub,a.tip,a.numar,a.Data,a.contd,a.contc,sum(convert(decimal(12,2),suma)),'',0,0,expl,@cHostUser,
	convert(datetime, convert(char(10), getdate(), 104), 104),RTrim(replace(convert(char(8), getdate(), 108), ':', '')),
	ROW_NUMBER() over (order by a.sub,a.data,a.Contd,a.contc,a.tip,a.numar,a.Loc_de_munca,a.Comanda,a.expl),a.Loc_de_munca,a.Comanda,'','UA'
	from (
	--facturi
	select @cSub as sub,'UA' as tip,'F'+(case when DAY(a.data)<10 then '0'+str(DAY(a.data),1) else str(DAY(a.data),2) end)+(case when MONTH(a.data)<10  then '0'+str(MONTH(a.data),1) else str(MONTH(a.data),2) end)+right(str(YEAR(a.data),4),2)+LEFT((case when ISNULL(d.loc_de_munca,'')='' then b.Loc_de_munca else d.loc_de_munca end),6) as numar,
	a.Data,@cont_client as contd,(case when ISNULL(d.cont,'')='' then n.Cont_venituri else d.cont end) as contc,
	sum(convert(decimal(12,2),(case when isnull(d.pret,0)=0 then (case when isnull(d.procent,0)=0 then b.Tarif else b.Tarif*d.procent end) else d.pret end)*b.Cantitate)) as suma,
	'NC - '+(case when max(n.Tip_serviciu)='T' then 'Taxa de dezvoltare' when max(n.Tip_serviciu)='P' then 'Penalitati' else 'Servicii' end)+' - din ASISRIA.UA' as expl,
	(case when ISNULL(d.loc_de_munca,'')='' then b.Loc_de_munca else d.loc_de_munca end) as loc_de_munca,(case when isnull(d.comanda,'')='' then b.Comanda else d.comanda end) as comanda
	from pozitiifactabon b
	inner join AntetFactAbon a on b.id_factura=a.id_factura
	inner join UACon c on c.id_contract=a.id_contract
	inner join Abonati ab on ab.abonat=c.abonat
	left outer join Grabonat gr on ab.Grupa=gr.Grupa
	left outer join NomenclAbon n on n.Cod=b.Cod
	left outer join detaliereCoduri d on n.cod=d.cod_parinte and a.Data between d.datajos and d.datasus and b.tarif=d.pret_total
	where a.Data between @pardatajos and @pardatasus and a.Tip in ('FM','FA','FI','IM') and (isnull(@locm,'')='' or @locm=a.Loc_de_munca)
	group by a.data,(case when ISNULL(d.cont,'')='' then n.Cont_venituri else d.cont end),(case when ISNULL(d.loc_de_munca,'')='' then b.Loc_de_munca else d.loc_de_munca end),(case when isnull(d.comanda,'')='' then b.Comanda else d.comanda end)
	union all	
	/*select @cSub as sub,'UA' as tip,'F'+(case when DAY(a.data)<10 then '0'+str(DAY(a.data),1) else str(DAY(a.data),2) end)+(case when MONTH(a.data)<10  then '0'+str(MONTH(a.data),1) else str(MONTH(a.data),2) end)+right(str(YEAR(a.data),4),2)+LEFT(b.Loc_de_munca,6) as numar,
	a.Data,@cont_client as contd,n.Cont_venituri as contc,sum(convert(decimal(12,2),b.Tarif*b.Cantitate)) as suma,
	'NC - '+(case when max(n.Tip_serviciu)='T' then 'Taxa de dezvoltare' when max(n.Tip_serviciu)='P' then 'Penalitati' else 'Servicii' end)+' - din ASISRIA.UA' as expl,
	b.Loc_de_munca,b.Comanda
	from pozitiifactabon b
	inner join AntetFactAbon a on b.id_factura=a.id_factura
	inner join UACon c on c.id_contract=a.id_contract
	inner join Abonati ab on ab.abonat=c.abonat
	left outer join Grabonat gr on ab.Grupa=gr.Grupa
	inner join NomenclAbon n on n.Cod=b.Cod
	where a.Data between @pardatajos and @pardatasus and a.Tip in ('FM','FA','FI','IM') and (isnull(@locm,'')='' or @locm=a.Loc_de_munca)
	group by a.data,n.Cont_venituri,b.Loc_de_munca,b.Comanda
	union all*/
	--tva facturi
	select @cSub as sub,'UA' as tip,'F'+(case when DAY(a.data)<10 then '0'+str(DAY(a.data),1) else str(DAY(a.data),2) end)+(case when MONTH(a.data)<10  then '0'+str(MONTH(a.data),1) else str(MONTH(a.data),2) end)+right(str(YEAR(a.data),4),2)+LEFT(b.Loc_de_munca,6) as numar,
	a.Data,@cont_client as contd,@cont_tva as contc,sum(convert(decimal(12,2),b.Tarif*b.Cantitate*b.Cota_TVA/100)) as suma,'NC - TVA - din ASISRIA.UA' as expl,
	b.Loc_de_munca,b.Comanda
	from pozitiifactabon b
	inner join AntetFactAbon a on b.id_factura=a.id_factura
	inner join UACon c on c.id_contract=a.id_contract
	inner join Abonati ab on ab.abonat=c.abonat
	left outer join Grabonat gr on ab.Grupa=gr.Grupa
	--left outer join NomenclAbon n on n.Cod=b.Cod
	where a.Data between @pardatajos and @pardatasus and a.Tip in ('FM','FA','FI','IM') and b.Cota_TVA<>0 and (isnull(@locm,'')='' or @locm=a.Loc_de_munca)
	group by a.data,b.Loc_de_munca,b.Comanda
	union all
	--avans
	select @cSub as sub,'UA' as tip,'F'+(case when DAY(a.data)<10 then '0'+str(DAY(a.data),1) else str(DAY(a.data),2) end)+(case when MONTH(a.data)<10  then '0'+str(MONTH(a.data),1) else str(MONTH(a.data),2) end)+right(str(YEAR(a.data),4),2)+LEFT(b.Loc_de_munca,6) as numar,
	a.Data,@cont_client as contd,n.Cont_venituri as contc,sum(convert(decimal(12,2),b.Tarif*b.Cantitate)) as suma,'NC - Avans - din ASISRIA.UA' as expl,
	b.Loc_de_munca,b.Comanda
	from pozitiifactabon b
	inner join AntetFactAbon a on b.id_factura=a.id_factura
	inner join UACon c on c.id_contract=a.id_contract
	inner join Abonati ab on ab.abonat=c.abonat
	left outer join Grabonat gr on ab.Grupa=gr.Grupa
	left outer join NomenclAbon n on n.Cod=b.Cod
	where a.Data between @pardatajos and @pardatasus and a.Tip in ('AV','AP') and (isnull(@locm,'')='' or @locm=a.Loc_de_munca)
	group by a.data,n.Cont_venituri,b.Loc_de_munca,b.Comanda
	union all
	--tva avans
	select @cSub as sub,'UA' as tip,'F'+(case when DAY(a.data)<10 then '0'+str(DAY(a.data),1) else str(DAY(a.data),2) end)+(case when MONTH(a.data)<10  then '0'+str(MONTH(a.data),1) else str(MONTH(a.data),2) end)+right(str(YEAR(a.data),4),2)+LEFT(b.Loc_de_munca,6) as numar,
	a.Data,@cont_client as contd,@cont_tva as contc,sum(convert(decimal(12,2),b.Tarif*b.Cantitate*b.Cota_TVA/100)) as suma,
	'NC - TVA Avans - din ASISRIA.UA' as expl,
	b.Loc_de_munca,b.Comanda
	from pozitiifactabon b
	inner join AntetFactAbon a on b.id_factura=a.id_factura
	inner join UACon c on c.id_contract=a.id_contract
	inner join Abonati ab on ab.abonat=c.abonat
	left outer join Grabonat gr on ab.Grupa=gr.Grupa
	--left outer join NomenclAbon n on n.Cod=b.Cod
	where a.Data between @pardatajos and @pardatasus and a.Tip in ('AV','AP') and b.Cota_TVA<>0 and (isnull(@locm,'')='' or @locm=a.Loc_de_munca)
	group by a.data,b.Loc_de_munca,b.Comanda
	union all
	--incasare factura
	select @cSub as sub,'UA' as tip,'I'+(case when DAY(b.data)<10 then '0'+str(DAY(b.data),1) else str(DAY(b.data),2) end)+(case when MONTH(b.data)<10  then '0'+str(MONTH(b.data),1) else str(MONTH(b.data),2) end)+right(str(YEAR(b.data),4),2)+LEFT(b.Loc_de_munca,6) as numar,
	b.Data,b.cont as contd,@cont_client as contc,sum(convert(decimal(12,2),b.suma-ISNULL(c.suma,0))) as suma,
	'NC - Incasare facturi - din ASISRIA.UA' as expl,b.Loc_de_munca,(case when isnull(b.Comanda,'')='' then @cdefaultcomanda else b.Comanda end)
	from incasarifactabon b
	inner join Abonati ab on ab.abonat=b.abonat
	left outer join IncasariProvizioane c on b.id=c.Id_incasare
	where b.Data between @pardatajos and @pardatasus and b.Tip='IF' and (isnull(@locm,'')='' or @locm=b.Loc_de_munca)
	group by b.data,b.cont,b.Loc_de_munca,b.Comanda
	union all
	--incasare avans
	select @cSub as sub,'UA' as tip,'I'+(case when DAY(b.data)<10 then '0'+str(DAY(b.data),1) else str(DAY(b.data),2) end)+(case when MONTH(b.data)<10  then '0'+str(MONTH(b.data),1) else str(MONTH(b.data),2) end)+right(str(YEAR(b.data),4),2)+LEFT(b.Loc_de_munca,6) as numar,
	b.Data,b.cont as contd,@cont_client as contc,sum(convert(decimal(12,2),b.suma)) as suma,
	'NC - Incasare avans - din ASISRIA.UA' as expl,b.Loc_de_munca,(case when isnull(b.Comanda,'')='' then @cdefaultcomanda else b.Comanda end)
	from incasarifactabon b
	inner join Abonati ab on ab.abonat=b.abonat
	where b.Data between @pardatajos and @pardatasus and b.Tip='IA' and (isnull(@locm,'')='' or @locm=b.Loc_de_munca)
	group by b.data,b.cont,b.Loc_de_munca,b.Comanda
	union all
	--compensare avans
	select @cSub as sub,'UA' as tip,'I'+(case when DAY(b.data)<10 then '0'+str(DAY(b.data),1) else str(DAY(b.data),2) end)+(case when MONTH(b.data)<10  then '0'+str(MONTH(b.data),1) else str(MONTH(b.data),2) end)+right(str(YEAR(b.data),4),2)+LEFT(b.Loc_de_munca,6) as numar,
	b.Data,@cont_client as contd,n.Cont_venituri as contc,sum(convert(decimal(12,2),((b.suma+ISNULL(c.suma,0))*100/(100+d.cota_tva)))) as suma,
	'NC - Compensare avans UA - din ASISRIA.UA' as expl,b.Loc_de_munca,(case when isnull(b.Comanda,'')='' then @cdefaultcomanda else b.Comanda end)
	from incasarifactabon b
	inner join Abonati ab on ab.abonat=b.abonat
	inner join #tmpFactAbonUA/*TFactAbon(null,null,'',0,2)*/ f on b.id_factura=f.id_factura and f.tip in ('AV','AP')
	inner join IncasariFactAbon bb on bb.Tip=b.tip and bb.Tip_incasare=b.tip_incasare and bb.Document=b.document and bb.Abonat=b.Abonat and bb.Suma=(-1)*b.suma
	inner join pozitiifactabon d on d.Id_factura=f.id_factura
	left outer join NomenclAbon n on n.Cod=d.Cod
	left outer join IncasariProvizioane c on bb.id=c.Id_incasare
	where b.Data between @pardatajos and @pardatasus and b.Tip='CP' and (isnull(@locm,'')='' or @locm=b.Loc_de_munca)
	group by b.data,d.cota_tva,n.Cont_venituri,b.Loc_de_munca,b.Comanda
	union all
	--compensare avans TVA
	select @cSub as sub,'UA' as tip,'I'+(case when DAY(b.data)<10 then '0'+str(DAY(b.data),1) else str(DAY(b.data),2) end)+(case when MONTH(b.data)<10  then '0'+str(MONTH(b.data),1) else str(MONTH(b.data),2) end)+right(str(YEAR(b.data),4),2)+LEFT(b.Loc_de_munca,6) as numar,
	b.Data,@cont_client as contd,@cont_tva as contc,sum(convert(decimal(12,2),((b.suma+ISNULL(c.suma,0))*(d.cota_tva*100)/(100+d.cota_tva)/100))) as suma,
	'NC - Compensare TVA avans UA - din ASISRIA.UA' as expl,b.Loc_de_munca,(case when isnull(b.Comanda,'')='' then @cdefaultcomanda else b.Comanda end)
	from incasarifactabon b
	inner join Abonati ab on ab.abonat=b.abonat
	inner join #tmpFactAbonUA/*TFactAbon(null,null,'',0,2)*/ f on b.id_factura=f.id_factura and f.tip in ('AV','AP')
	inner join IncasariFactAbon bb on bb.Tip=b.tip and bb.Tip_incasare=b.tip_incasare and bb.Document=b.document and bb.Abonat=b.Abonat and bb.Suma=(-1)*b.suma
	inner join pozitiifactabon d on d.Id_factura=f.id_factura
--	inner join NomenclAbon n on n.Cod=d.Cod
	left outer join IncasariProvizioane c on bb.id=c.Id_incasare
	where b.Data between @pardatajos and @pardatasus and b.Tip='CP' and (isnull(@locm,'')='' or @locm=b.Loc_de_munca) and d.Cota_TVA<>0
	group by b.data,d.cota_tva,b.Loc_de_munca,b.Comanda
	union all
	--incasare provizion factura
	select @cSub as sub,'UA' as tip,'I'+(case when DAY(b.data)<10 then '0'+str(DAY(b.data),1) else str(DAY(b.data),2) end)+(case when MONTH(b.data)<10  then '0'+str(MONTH(b.data),1) else str(MONTH(b.data),2) end)+right(str(YEAR(b.data),4),2)+LEFT(b.Loc_de_munca,6) as numar,
	b.Data,b.cont as contd,e.cont as contc,sum(convert(decimal(12,2),c.suma)) as suma,
	'NC - Incasare facturi - din ASISRIA.UA' as expl,b.Loc_de_munca,(case when isnull(b.Comanda,'')='' then @cdefaultcomanda else b.Comanda end)
	from incasarifactabon b
	inner join Abonati ab on ab.abonat=b.abonat
	inner join IncasariProvizioane c on b.id=c.Id_incasare
	inner join UAProvizioane d on d.Id=c.Id_provizion
	inner join UACatProvizioane e on e.Id=d.Id_provizion
	where b.Data between @pardatajos and @pardatasus and b.Tip='IF' and (isnull(@locm,'')='' or @locm=b.Loc_de_munca)
	group by b.data,b.cont,e.cont,b.Loc_de_munca,b.Comanda
	union all
	--compensare provizion avans
	select @cSub as sub,'UA' as tip,'I'+(case when DAY(b.data)<10 then '0'+str(DAY(b.data),1) else str(DAY(b.data),2) end)+(case when MONTH(b.data)<10  then '0'+str(MONTH(b.data),1) else str(MONTH(b.data),2) end)+right(str(YEAR(b.data),4),2)+LEFT(b.Loc_de_munca,6) as numar,
	b.Data,e.cont as contd,n.Cont_venituri as contc,(-1)*sum(convert(decimal(12,2),(c.suma*100/(100+d.cota_tva)))) as suma,
	'NC - Compensare avans UA(provizion) - din ASISRIA.UA' as expl,b.Loc_de_munca,(case when isnull(b.Comanda,'')='' then @cdefaultcomanda else b.Comanda end)
	from incasarifactabon b
	inner join #tmpFactAbonUA/*TFactAbon(null,null,'',0,2)*/ f on b.id_factura=f.id_factura and f.tip in ('AV','AP')
	inner join IncasariFactAbon bb on bb.Tip=b.tip and bb.Tip_incasare=b.tip_incasare and bb.Document=b.document and bb.Abonat=b.Abonat and bb.Suma=(-1)*b.suma
	inner join pozitiifactabon d on d.Id_factura=f.id_factura
	inner join IncasariProvizioane c on bb.id=c.Id_incasare
	inner join UAProvizioane g on g.Id=c.Id_provizion
	inner join UACatProvizioane e on e.Id=g.Id_provizion
	left outer join NomenclAbon n on n.Cod=d.Cod
	where b.Data between @pardatajos and @pardatasus and b.Tip='CP' and (isnull(@locm,'')='' or @locm=bb.Loc_de_munca)
	group by b.data,d.cota_tva,n.Cont_venituri,e.cont,b.Loc_de_munca,b.Comanda
	union all
	--compensare provizion avans TVA
	select @cSub as sub,'UA' as tip,'I'+(case when DAY(b.data)<10 then '0'+str(DAY(b.data),1) else str(DAY(b.data),2) end)+(case when MONTH(b.data)<10  then '0'+str(MONTH(b.data),1) else str(MONTH(b.data),2) end)+right(str(YEAR(b.data),4),2)+LEFT(b.Loc_de_munca,6) as numar,
	b.Data,e.cont as contd,@cont_tva as contc,(-1)*sum(convert(decimal(12,2),(c.suma*(d.cota_tva*100)/(100+d.cota_tva)/100))) as suma,
	'NC - Compensare TVA avans UA(provizion) - din ASISRIA.UA' as expl,b.Loc_de_munca,(case when isnull(b.Comanda,'')='' then @cdefaultcomanda else b.Comanda end)
	from incasarifactabon b
	inner join #tmpFactAbonUA/*TFactAbon(null,null,'',0,2)*/ f on b.id_factura=f.id_factura and f.tip in ('AV','AP')
	inner join IncasariFactAbon bb on bb.Tip=b.tip and bb.Tip_incasare=b.tip_incasare and bb.Document=b.document and bb.Abonat=b.Abonat and bb.Suma=(-1)*b.suma
	inner join pozitiifactabon d on d.Id_factura=f.id_factura
--	left outer join NomenclAbon n on n.Cod=d.Cod
	inner join IncasariProvizioane c on bb.id=c.Id_incasare
	inner join UAProvizioane g on g.Id=c.Id_provizion
	inner join UACatProvizioane e on e.Id=g.Id_provizion
	where b.Data between @pardatajos and @pardatasus and b.Tip='CP' and (isnull(@locm,'')='' or @locm=bb.Loc_de_munca) and d.Cota_TVA<>0
	group by b.data,d.cota_tva,e.cont,b.Loc_de_munca,b.Comanda
	--provizioane 
	union all
	select @cSub as sub,'UA' as tip,'I'+(case when DAY(b.data_operatiei)<10 then '0'+str(DAY(b.data_operatiei),1) else str(DAY(b.data_operatiei),2) end)+(case when MONTH(b.data_operatiei)<10  then '0'+str(MONTH(b.data_operatiei),1) else str(MONTH(b.data_operatiei),2) end)+right(str(YEAR(b.data_operatiei),4),2)+LEFT(a.Loc_de_munca,6) as numar,
	b.data_operatiei,c.cont as contd,@cont_client as contc,sum(convert(decimal(12,2),b.suma)) as suma,
	'NC - Provizioane - din ASISRIA.UA' as expl,a.Loc_de_munca,''
	from UAProvizioane b
	inner join antetfactabon a on b.Id_factura=a.Id_factura
	inner join UACatProvizioane c on c.Id=b.Id_provizion
	where b.data_operatiei between @pardatajos and @pardatasus and (isnull(@locm,'')='' or @locm=a.Loc_de_munca)
	group by b.data_operatiei,c.cont,a.Loc_de_munca
	)a group by a.sub,a.data,a.tip,a.numar,a.contd,a.contc,a.expl,a.Loc_de_munca,a.Comanda
	Set @nError = @nError + @@Error
--	commit tran gennc
end try
begin catch
--	ROLLBACK TRAN gennc
	set @mesaj ='UAGenNC: '+ERROR_MESSAGE()
	raiserror(@mesaj, 11, 1)	
end catch
end