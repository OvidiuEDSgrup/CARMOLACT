--***
create procedure  [dbo].[ScriuCompensareSelectiva] @sesiune varchar(50), @parXML xml
as
  
	declare @utilizator varchar(100)
	EXEC wIaUtilizator @sesiune = @sesiune, @utilizator = @utilizator OUTPUT

begin try
	declare @pXML xml
	
	--pregatesc tabela cu facturile beneficiar
	select ROW_NUMBER() over (partition by a.tert order by a.tert,a.factura) as nrp, 0 as nrmin, 0 as nrmax,
				a.Factura, a.Tert, a.valuta, abs(a.suma) as sold, CONVERT(float,0.00) as cumulat
	into #facturiBen
	from SelectieFacturiPtCompensari a
	where a.tip='B'
		and utilizator=@utilizator
	order by a.tert,a.factura

	--select * from #facturiBen

	--pregatesc tabela cu facturile furnizor
	select ROW_NUMBER() over (partition by a.tert order by a.tert,a.factura) as nrp, 0 as nrmin, 0 as nrmax,
				a.Factura, a.Tert, a.valuta, abs(a.suma) as sold, CONVERT(float,0.00) as cumulat
	into #facturiFurn
	from SelectieFacturiPtCompensari a
	where a.tip='F'
		and utilizator=@utilizator
	order by a.tert,a.factura

	--select * from #facturiFurn

	--solduri cumulate pe facturi furnizor
	update #facturiFurn set 
		cumulat=facturicalculate.cumulat
	from (select p2.tert, p2.nrp, sum(p1.sold) as cumulat 
			from #facturiFurn p1, #facturiFurn p2 
			where p1.tert=p2.tert and p1.nrp<=p2.nrp 
			group by p2.tert, p2.nrp) facturicalculate
	where facturicalculate.tert=#facturiFurn.tert
		and facturicalculate.nrp=#facturiFurn.nrp

	--solduri cumulate facturi beneficiar
	update #facturiBen set 
		cumulat=facturicalculate.cumulat
	from (select p2.tert, p2.nrp, sum(p1.sold) as cumulat 
		from #facturiBen p1, #facturiBen p2 
		where p1.tert=p2.tert and p1.nrp<=p2.nrp 
		group by p2.tert, p2.nrp) facturicalculate
	where facturicalculate.tert=#facturiBen.tert
		and facturicalculate.nrp=#facturiBen.nrp  

	--calcul numar min
	update #facturiFurn 
 		set nrmin=st.nrp--,nrmax=dr.nrp
		from #facturiFurn c
			cross apply
				(select top 1 smin.nrp from #facturiBen smin where smin.tert=c.tert and c.cumulat-c.sold<smin.cumulat order by smin.cumulat) st 

	--calcul numar max
	update #facturiFurn 
 		set nrmax=dr.nrp
		from #facturiFurn c	
			cross apply
				(select Top 1 smax.nrp from #facturiBen smax where smax.tert=c.tert and (smax.cumulat<=c.cumulat or smax.cumulat-smax.sold<c.cumulat) order by smax.cumulat desc) dr

	--imperechere facturi	
	select row_number() over(order by pd.tert,pd.factura) as nrord_poz ,dense_rank() over(order by pd.tert) as nrord_adoc, pd.tert, 
		fc.factura as fact_ben, fc.sold as sold_fact_ben, pd.factura as fact_furn, pd.sold as sold_fact_furn,pd.valuta, 
		s.sumacompensata, convert(varchar(8),'') as nr_adoc, 0 as nr_poz
	into #tmpcompensari
	from #facturiFurn pd
		inner/*left outer*/ join #facturiBen fc on pd.tert=fc.tert and fc.nrp between pd.nrmin and pd.nrmax and pd.nrmin<>0
		cross apply (select round((case when pd.cumulat<=fc.cumulat then pd.cumulat else fc.cumulat end)
						-(case when  pd.cumulat-pd.sold>fc.cumulat-fc.sold then pd.cumulat-pd.sold else fc.cumulat-fc.sold end),2) as sumacompensata) s

	--select * from #tmpcompensari

	select @pXML=@parXML
	set @pXML.modify('delete (/*/o_DateGrid[1])')
	set @pXML.modify('delete (/*/DateGrid[1])')

	set @pXML=dbo.fInlocuireDenumireElementXML(@pXML,'row').query('/row')

	declare @xml xml
	set @xml = 
		(
		SELECT 
			'CO' as subtip,
			fact_furn as facturastinga,
			fact_ben as facturadreapta,
			convert(decimal(12,5),sumacompensata) as suma,
			convert(decimal(12,5),(case when valuta<>'' then sumacompensata else 0 end)) as sumavaluta
		from #tmpcompensari
		for xml raw,type)

	set @pXML.modify('insert sql:variable("@xml") as first into /row[1]')

	--select @pxml
	--raiserror('aici',11,1)
	exec wScriuPozAdoc @sesiune=@sesiune, @parXML=@pxml

end try  
begin catch  
	declare @mesaj varchar(255)
	set @mesaj='ScriuCompensareSelectiva: '+ERROR_MESSAGE()
	raiserror(@mesaj, 11, 1) 
end catch
